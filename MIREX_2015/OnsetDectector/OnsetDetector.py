#!/usr/bin/env python
# encoding: utf-8
"""
OnsetDetector onset detection algorithm.

"""

from __future__ import absolute_import, division, print_function

import argparse

from madmom.processors import IOProcessor, io_arguments
from madmom.audio.signal import SignalProcessor
from madmom.features import ActivationsProcessor
from madmom.features.onsets import RNNOnsetProcessor, PeakPickingProcessor


def main():
    """OnsetDetector"""

    # define parser
    p = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter, description='''
    The OnsetDetector program detects all onsets in an audio file with a
    recurrent neural network similar to method described in:

    "Universal Onset Detection with bidirectional Long Short-Term Memory Neural
     Networks"
    Florian Eyben, Sebastian Böck, Björn Schuller and Alex Graves.
    Proceedings of the 11th International Society for Music Information
    Retrieval Conference (ISMIR), 2010.

    Instead of 'LSTM' units, this version uses 'tanh' units and a simplified
    peak picking method.

    This program can be run in 'single' file mode to process a single audio
    file and write the detected onsets to STDOUT or the given output file.

    $ OnsetDetector single INFILE [-o OUTFILE]

    If multiple audio files should be processed, the program can also be run
    in 'batch' mode to save the detected onsets to files with the given suffix.

    $ OnsetDetector batch [-o OUTPUT_DIR] [-s OUTPUT_SUFFIX] LIST OF FILES

    If no output directory is given, the program writes the files with the
    detected onsets to same location as the audio files.

    The 'pickle' mode can be used to store the used parameters to be able to
    exactly reproduce experiments.

    ''')
    # version
    p.add_argument('--version', action='version', version='OnsetDetector.2013')
    # input/output options
    io_arguments(p, output_suffix='.onsets.txt')
    ActivationsProcessor.add_arguments(p)
    # signal processing arguments
    SignalProcessor.add_arguments(p, norm=False, gain=0)
    # peak picking arguments
    PeakPickingProcessor.add_arguments(p, threshold=0.3, smooth=0.07)

    # parse arguments
    args = p.parse_args()

    # set immutable defaults
    args.fps = 100
    args.pre_max = 1. / args.fps
    args.post_max = 1. / args.fps

    # print arguments
    if args.verbose:
        print(args)

    # input processor
    if args.load:
        # load the activations from file
        in_processor = ActivationsProcessor(mode='r', **vars(args))
    else:
        # use a RNN to predict the onsets
        in_processor = RNNOnsetProcessor()

    # output processor
    if args.save:
        # save the RNN onset activations to file
        out_processor = ActivationsProcessor(mode='w', **vars(args))
    else:
        # perform peak picking on the onset activations
        peak_picking = PeakPickingProcessor(**vars(args))
        # output handler
        from madmom.utils import write_events as writer
        # sequentially process them
        out_processor = [peak_picking, writer]

    # create an IOProcessor
    processor = IOProcessor(in_processor, out_processor)

    # and call the processing function
    args.func(processor, **vars(args))


if __name__ == '__main__':
    main()
