function [ status onsetTimeDetected ] = MIREX_Machine( AudioPath, AlgorithmPath )
%MIREX_MACHINE input Full AudioPath and AlgorithmPath, output detected oneset time
%. status = 0 is okay, 1 = errors;
%   
commandStr = strcat('python', [' ', AlgorithmPath ' single'], [' ' AudioPath]);
%commandStr1 = 'python C:/Users/genius/Desktop/Evaluation/MIRE_2015/OnsetDectector/ComplexFlux.py single C:/Users/genius/Desktop/Evaluation/MIRE_2015/OnsetDectector/pro_2_short.wav';
[status, commandOut] = system(commandStr);
onsetTimeDetected = [];
if status==0
    cells = strsplit(commandOut, '\n');
    for i = 1:length(cells)
        temp = str2num(cell2mat(cells(i)));
        if (length(temp) > 0 )
            onsetTimeDetected(length(onsetTimeDetected) + 1) = temp;
        else
           break; 
        end
    end
else
    commandOut
end

