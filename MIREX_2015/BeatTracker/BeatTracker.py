#!/usr/bin/env python
# encoding: utf-8
"""
BeatTracker beat tracking algorithm.

"""

from __future__ import absolute_import, division, print_function

import argparse

from madmom.processors import IOProcessor, io_arguments
from madmom.audio.signal import SignalProcessor
from madmom.features import ActivationsProcessor
from madmom.features.beats import RNNBeatProcessor, BeatTrackingProcessor
from madmom.features.tempo import TempoEstimationProcessor


def main():
    """BeatTracker"""

    # define parser
    p = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter, description='''
    The BeatTracker program detects all beats in an audio file according to the
    method described in (while following tempo changes):

    "Enhanced Beat Tracking with Context-Aware Neural Networks"
    Sebastian Böck and Markus Schedl.
    Proceedings of the 14th International Conference on Digital Audio Effects
    (DAFx), 2011.

    Instead of using the originally proposed auto-correlation method to build
    a tempo histogram, a new method based on comb filters is used:

    "Accurate Tempo Estimation based on Recurrent Neural Networks and
     Resonating Comb Filters"
    Sebastian Böck, Florian Krebs and Gerhard Widmer.
    Proceedings of the 16th International Society for Music Information
    Retrieval Conference (ISMIR), 2015.

    This program can be run in 'single' file mode to process a single audio
    file and write the detected beats to STDOUT or the given output file.

    $ BeatTracker single INFILE [-o OUTFILE]

    If multiple audio files should be processed, the program can also be run
    in 'batch' mode to save the detected beats to files with the given suffix.

    $ BeatTracker batch [-o OUTPUT_DIR] [-s OUTPUT_SUFFIX] LIST OF FILES

    If no output directory is given, the program writes the files with the
    detected beats to same location as the audio files.

    The 'pickle' mode can be used to store the used parameters to be able to
    exactly reproduce experiments.

    ''')
    # version
    p.add_argument('--version', action='version', version='BeatTracker.2014')
    # input/output arguments
    io_arguments(p, output_suffix='.beats.txt')
    ActivationsProcessor.add_arguments(p)
    # signal processing arguments
    SignalProcessor.add_arguments(p, norm=False, gain=0)
    # beat tracking arguments
    TempoEstimationProcessor.add_arguments(p, method='comb', min_bpm=40,
                                           max_bpm=240, act_smooth=0.09,
                                           hist_smooth=7, alpha=0.79)
    BeatTrackingProcessor.add_arguments(p, look_ahead=10)

    # parse arguments
    args = p.parse_args()

    # set immutable arguments
    args.fps = 100

    # print arguments
    if args.verbose:
        print(args)

    # input processor
    if args.load:
        # load the activations from file
        in_processor = ActivationsProcessor(mode='r', **vars(args))
    else:
        # use a RNN to predict the beats
        in_processor = RNNBeatProcessor()

    # output processor
    if args.save:
        # save the RNN beat activations to file
        out_processor = ActivationsProcessor(mode='w', **vars(args))
    else:
        # track the beats in the activation function
        beat_processor = BeatTrackingProcessor(**vars(args))
        # output handler
        from madmom.utils import write_events as writer
        # sequentially process them
        out_processor = [beat_processor, writer]

    # create an IOProcessor
    processor = IOProcessor(in_processor, out_processor)

    # and call the processing function
    args.func(processor, **vars(args))


if __name__ == '__main__':
    main()
