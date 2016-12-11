#!/usr/bin/env python
# encoding: utf-8
"""
DBNDownBeatTracker downbeat tracking algorithm.

"""

from __future__ import absolute_import, division, print_function

import argparse

from madmom.processors import IOProcessor, io_arguments
from madmom.audio.signal import SignalProcessor
from madmom.features import ActivationsProcessor
from madmom.features.beats import (RNNDownBeatProcessor,
                                   DBNDownBeatTrackingProcessor)


def main():
    """DBNDownBeatTracker"""

    # define parser
    p = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter, description='''
    The DBNDownBeatTracker program detects all beats and downbeats in an audio
    file according to the method described in:

    "Joint Beat and Downbeat Tracking with Recurrent Neural Networks"
    Sebastian Böck, Florian Krebs and Gerhard Widmer.
    Proceedings of the 17th International Society for Music Information
    Retrieval Conference (ISMIR), 2016.

    This program can be run in 'single' file mode to process a single audio
    file and write the detected beats to STDOUT or the given output file.

    $ DBNDownBeatTracker single INFILE [-o OUTFILE]

    If multiple audio files should be processed, the program can also be run
    in 'batch' mode to save the detected beats to files with the given suffix.

    $ DBNDownBeatTracker batch [-o OUTPUT_DIR] [-s OUTPUT_SUFFIX] LIST OF FILES

    If no output directory is given, the program writes the files with the
    detected beats to same location as the audio files.

    The 'pickle' mode can be used to store the used parameters to be able to
    exactly reproduce experiments.

    ''')
    # version
    p.add_argument('--version', action='version',
                   version='DBNDownBeatTracker')
    # input/output options
    io_arguments(p, output_suffix='.beats.txt')
    ActivationsProcessor.add_arguments(p)
    # signal processing arguments
    SignalProcessor.add_arguments(p, norm=False, gain=0)
    # peak picking arguments
    DBNDownBeatTrackingProcessor.add_arguments(p, beats_per_bar=[3, 4])

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
        in_processor = RNNDownBeatProcessor()

    # output processor
    if args.save:
        # save the RNN beat activations to file
        out_processor = ActivationsProcessor(mode='w', **vars(args))
    else:
        # track the beats with a DBN
        downbeat_processor = DBNDownBeatTrackingProcessor(**vars(args))
        if args.downbeats:
            # simply write the timestamps
            from madmom.utils import write_events as writer
        else:
            # borrow the note writer for outputting timestamps + beat numbers
            from madmom.features.notes import write_notes as writer
        # sequentially process them
        out_processor = [downbeat_processor, writer]

    # create an IOProcessor
    processor = IOProcessor(in_processor, out_processor)

    # and call the processing function
    args.func(processor, **vars(args))


if __name__ == '__main__':
    main()
