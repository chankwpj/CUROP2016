close all;
clear;
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/Mozart_Fantasy.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/am_1.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/pro_1.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_am1.wav';
% AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_am2.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_pro1.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_pro2.wav';
AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/In_the_hall_of_mountain_king.wav';
AlgorithmFile = ['OnsetDetector.py'];
AlgorithmPath = strcat('C:/Users/genius/Desktop/SourceCode/MIREX_2015/OnsetDectector/', char(AlgorithmFile));
[y, fs] = audioread(AudioPath);
[status, onsetTime] = MIREX_Machine(AudioPath, AlgorithmPath);

pos = onsetTime.' * 1000; %millisecond second form
pos = round(pos);
step = 150; %200
newpos = [];
lastSeg = 0;

figure(1);
plot(diff(pos)); hold on
title('diff of pos');

scales = [1 2 3 4 6 8 12 16];
%outter loop throughs the segments 
for n = 1:step: length(pos)
    %create segment
    if n + step > length(pos)
        seg = pos(n - 1:length(pos));
        lastSeg = 1;
    else
        if ( n ~= 1) 
            seg = pos(n-1 : n +step);
        else
            seg = pos(n:n+step); 
        end
    end
    
    %get partition partitions
    segcpt = interval_partition(numel(seg), @(b, e) objfn_tempo(seg, b, e));
    if ~isempty(segcpt)
        vline(segcpt+n, 'k:')
    end
    
    %intervals in the segment 
    intervals = [[1 segcpt]; [segcpt numel(seg)]];
    
    newSeg = [];
    newIntervals = [];
    %loop through the intervals
    for i = 1:size(intervals, 2)
        %calculate the temp of a interval
        tempo = fit_tempo(seg(intervals(1, i):intervals(2, i))); %unit of time
        plot(intervals(:, i)+n, [tempo; tempo], 'r', 'LineWidth', 2)
              
        %merge the noise in the whole interval
        shift = 0;
        %factor
        factor = 1/2;
        %loop through a interval and merge noise
        previousMerged = 0;
        for j = intervals(1, i)+1:intervals(2, i)
            curseg = seg(j) - seg(j-1);
            if (curseg < tempo*factor)
                if previousMerged == 0
                    newSeg = [newSeg seg(j)];
                else
                    newSeg(end) = seg(j);
                end
                previousMerged =1 ;
                shift = shift + 1;
            else
                if previousMerged == 1
                    %no action
                else
                    newSeg = [newSeg seg(j-1)]; 
                end
                previousMerged = 0 ;
            end
        end
        newSeg = [newSeg seg(j)];
        
       %due to shifting. all the intervals have to be shifted
       if (isempty(newIntervals) )
            newIntervals = [newIntervals [intervals(1, i); intervals(2, i)-shift-1]];
       else
            newIntervals = [newIntervals [newIntervals(end); intervals(2, i)-shift-1]];
       end
        
       1;
       
        %loop through a interval and split notes
        for k = newIntervals(1, i)+1:newIntervals(2, i)
            curseg = newSeg(k) - newSeg(k-1);
            scaled = curseg ./ scales;
            d = abs(tempo - scaled);
            [~, best_scale_idx] = min(d);
            best_scale = scales(best_scale_idx);
            newSet = linspace(newSeg(k-1), newSeg(k), best_scale + 1);
            newSet = round(newSet);          
            newpos = [newpos newSet(1:end-1)]; %#ok<AGROW>
        end     
    end    
end

        
%delete overlap/duplicated
index_overlap = find(diff(newpos) == 0);
if (~isempty(index_overlap))
  newpos(index_overlap) = -1;
  newpos = newpos(newpos >= 0);
end

ylim([0 1000])
hold off

figure;
plot(diff(newpos))
title('diff new pos')
ylim([0 1000])