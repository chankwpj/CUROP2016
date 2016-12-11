function [ status onsetTimeDetected ] = MIREX_Machine( AudioPath, AlgorithmPath )
%MIREX_MACHINE input Full AudioPath and AlgorithmPath, output oneset
%dectected by time. status = 0 is okay, 1 = errors;
%   

commandStr = strcat('python', [' ', AlgorithmPath ' single'], [' ' AudioPath]);
%commandStr1 = 'python C:/Users/genius/Desktop/Evaluation/MIRE_2015/OnsetDectector/ComplexFlux.py single C:/Users/genius/Desktop/Evaluation/MIRE_2015/OnsetDectector/pro_2_short.wav';
[status, commandOut] = system(commandStr);
onsetTimeDetected = [];
if status==0
    %fprintf('squared result is %d\n',str2num(commandOut));
    onsetTimeDetected = str2num(commandOut);
else
    commandOut
end

