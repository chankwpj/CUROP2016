function [ midiOnset ] = MidiToMidiOnset( midi )
%Give a midi object from readmidi() as input. Function returns all onset
%times
    Notes = midiInfo(midi,0); % col 
    % track num, channel number, note number, velocity, st, et, 7, 8
    midiOnset = Notes(:, 5);

end

