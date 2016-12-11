%% paths
AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/am_2_short.wav';
%AlgorithmFile = cell(2,1);
AlgorithmFile{1} = 'ComplexFlux.py';
AlgorithmFile{2} = 'SuperFlux.py';
AlgorithmFile{3} = 'LogFiltSpecFlux.py';
AlgorithmFile{4} = 'OnsetDetector.py';
AlgorithmFile{5} = 'OnsetDetectorLL.py';

%% test
%MIREX Onset Detection
for n = 1:length(AlgorithmFile)
   
    AlgorithmPath = strcat('C:/Users/genius/Desktop/SourceCode/MIREX_2015/OnsetDectector/', char(AlgorithmFile(n)));
    [status, onsetTime] = MIREX_Machine(AudioPath, AlgorithmPath );
    if status == 0 
        Plot_TimeAmplitude(AudioPath, char(AlgorithmFile(n)), onsetTime, n)
        %Plot_Spectrogram(AudioPath, char(AlgorithmFile(n)), onsetTime, n)        
    else
        display error
        AlgorithmFile(n)
    end
    
end
