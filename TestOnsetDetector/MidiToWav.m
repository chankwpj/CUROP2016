function [ y, Fs, path ] = MidiToWav( midi)
%Give a midi object from readmidi() as input. Function returns wav signal
%with y and Fs as well as a path of .wav tempoary file

    [y,Fs] = midi2audio(midi);    
    y = .95.*y./max(abs(y));
    audiowrite('temp.wav', y, Fs);
    path = 'temp.wav';
   
    
end

