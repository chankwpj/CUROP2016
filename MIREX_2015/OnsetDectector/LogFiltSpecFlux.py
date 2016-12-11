#!/usr/bin/env python
# encoding: utf-8
"""
LogFiltSpecFlux onset detection algorithm.

"""

from __future__ import absolute_import, division, print_function

import argparse

from madmom.processors import IOProcessor, io_arguments
from madmom.audio.signal import SignalProcessor, FramedSignalProcessor
from madmom.audio.filters import FilterbankProcessor
from madmom.audio.spectrogram import (LogarithmicSpectrogramProcessor,
                                      LogarithmicFilteredSpectrogramProcessor,
                                      SpectrogramDifferenceProcessor)
from madmom.features import ActivationsProcessor
from madmom.features.onsets import SpectralOnsetProcessor, PeakPickingProcessor


def main():
    """LogFiltSpecFlux"""

    # define parser
    p = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter, description='''
    The LogFiltSpecFlux program detects all onsets in an audio file according
    to the LogFiltSpecFlux algorithm described in:

    "Evaluating the Online Capabilities of Onset Detection Methods"
    Sebastian Böck, Florian Krebs and Markus Schedl.
    Proceedings of the 13th International Society for Music Information
    Retrieval Conference (ISMIR), 2012.

    This program can be run in 'single' file mode to process a single audio
    file and write the detected onsets to STDOUT or the given output file.

    $ LogFiltSpecFlux single INFILE [-o OUTFILE]

    If multiple audio files should be processed, the program can also be run
    in 'batch' mode to save the detected onsets to files with the given suffix.

    $ LogFiltSpecFlux batch [-o OUTPUT_DIR] [-s OUTPUT_SUFFIX] LIST OF FILES

    If no output directory is given, the program writes the files with the
    detected onsets to same location as the audio files.

    The 'pickle' mode can be used to store the used parameters to be able to
    exactly reproduce experiments.

    ''')
    # version
    p.add_argument('--version', action='version',
                   version='LogFiltSpecFlux.2014')
    # add arguments
    io_arguments(p, output_suffix='.onsets.txt')
    ActivationsProcessor.add_arguments(p)
    SignalProcessor.add_arguments(p, norm=False, gain=0)
    FramedSignalProcessor.add_arguments(p, fps=100, online=False)
    FilterbankProcessor.add_arguments(p, num_bands=12, fmin=30, fmax=17000,
                                      norm_filters=False)
    LogarithmicSpectrogramProcessor.add_arguments(p, log=True, mul=1, add=1)
    SpectrogramDifferenceProcessor.add_arguments(p, diff_ratio=0.5,
                                                 positive_diffs=True)
    PeakPickingProcessor.add_arguments(p, threshold=1.6, pre_max=0.01,
                                       post_max=0.05, pre_avg=0.15, post_avg=0,
                                       combine=0.03, delay=0)
    # parse arguments
    args = p.parse_args()
    # switch to offline mode
    if args.norm:
        args.online = False
    # print arguments
    if args.verbose:
        print(args)

    # input processor
    if args.load:
        # load the activations from file
        in_processor = ActivationsProcessor(mode='r', **vars(args))
    else:
        # define processing chain
        sig = SignalProcessor(num_channels=1, **vars(args))
        frames = FramedSignalProcessor(**vars(args))
        spec = LogarithmicFilteredSpectrogramProcessor(**vars(args))
        diff = SpectrogramDifferenceProcessor(**vars(args))
        odf = SpectralOnsetProcessor(onset_method='spectral_flux',
                                     **vars(args))
        in_processor = [sig, frames, spec, diff, odf]

    # output processor
    if args.save:
        # save the onset activations to file
        out_processor = ActivationsProcessor(mode='w', **vars(args))
    else:
        # perform peak picking of the onset function
        peak_picking = PeakPickingProcessor(**vars(args))
        from madmom.utils import write_events as writer
        # sequentially process them
        out_processor = [peak_picking, writer]

    # create an IOProcessor
    processor = IOProcessor(in_processor, out_processor)

    # and call the processing function
    args.func(processor, **vars(args))


if __name__ == '__main__':
    main()
