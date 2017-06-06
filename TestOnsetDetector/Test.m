clear;  
%% Paths
AudioPath = ['Test1.mid'; 'Test2.mid'; 'Test3.mid'; 'Test4.mid'; 'Test5.mid'];
AlgorithmFile = ['OnsetDetector.py'];
AlgorithmPath = strcat('', char(AlgorithmFile));


%%Test
results = [];
%loop throught all the input
for i = 1:size(AudioPath,1)
    midi = readmidi(AudioPath(i,:));
    midiOnset = MidiToMidiOnset(midi);
    %convert midi to wav
    [y, Fs, path] = MidiToWav(midi);
    [status, detectedOnset] = MIREX_Machine(path, AlgorithmPath);
    % test result
    [error,missDetectionRate,overDetectionRate] = CheckOnsetDetectionResult(midiOnset, detectedOnset); %[error,missDetectionRate,overDetectionRate ]
    results = [results; error,missDetectionRate,overDetectionRate];
end

% mean of the result
%[error,missDetectionRate,overDetectionRate]
mean(results)


