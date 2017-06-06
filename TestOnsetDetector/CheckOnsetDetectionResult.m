function [ error, missDetectionRate, overDetectionRate ] = CheckOnsetDetectionResult( midiOnset, detectedOnset)
%Give midiOnset from MidiToMidiOnset() function as argument1 and detected
%onset from MIREX_Machine() function as argument 2. Function returns the
%error(shift) of detected onset, miss and over detection rate.
%   each detected onset is assigned to the position of midiOnset based on
%   the distance
%   Compare the buckets to see over/miss detection
%   ignore the over and miss detection, to calculate the distance between
%   midi onset and detected onset
    dt = detectedOnset;
    %% preprocess the midi onset. Merge same time onset
    mt = unique(midiOnset);
    %mt = midiOnset;
    [uv,~,idx] = unique(midiOnset);
    buckets = accumarray(idx(:),1);

    %% fit onsets 
    mtPointer = 1;
    dtPointer = 1;
    dtMergeMt = zeros(size(mt));
    vote = zeros(numel(mt), 6); %first col is number of vote 
    vote(:,1) = 1;
    while (dtPointer <= numel(dt))
         %1p 1n
         neigPointer = mtPointer;
         dist = abs(mt(mtPointer) - dt(dtPointer));
         if (mtPointer > 1 && abs(mt(mtPointer-1) - dt(dtPointer)) <= dist)
            dist =  abs(mt(mtPointer-1) - dt(dtPointer));
            neigPointer = mtPointer - 1;
         end
         %then while next
         newMtPointer = mtPointer + 1;
         while (true)
            if ( newMtPointer <= numel(mt) && abs(mt(newMtPointer) - dt(dtPointer)) <= dist)
                dist = abs(mt(newMtPointer) - dt(dtPointer));
                neigPointer = newMtPointer;
                newMtPointer = newMtPointer + 1;
            else
                if (newMtPointer > numel(mt) || mt(newMtPointer) ~= mt(newMtPointer -1))
                    break;
                else
                    newMtPointer = newMtPointer + 1;
                end
            end
         end
        mtPointer = neigPointer;    
        colInd = vote(neigPointer,1) + 1;
        vote(neigPointer, colInd) = dist;
        vote(neigPointer,1) = colInd;
        dtMergeMt(neigPointer) = dt(dtPointer);
        dtPointer = dtPointer + 1;
    end
    vote(:,1) = vote(:,1) - 1;

    %% statistic miss and over detection rate
    miss = buckets - vote(:,1);
    miss = sum(miss(miss > 0));
    missDetectionRate = miss/numel(midiOnset);
    over = vote(:,1) - buckets;
    over = sum(over(over > 0));
    overDetectionRate = over/numel(midiOnset);
    
    %% distance
    error = [];
    for i = 1:numel(buckets)
       temp = vote(i, 2: 2-1+ vote(i));
       temp = sort(temp);
       if (numel(temp) < buckets(i))
            error = [error, temp];
       else
            error = [error, temp(1:buckets(i))];
       end
    end
    error = mean(error);

end

