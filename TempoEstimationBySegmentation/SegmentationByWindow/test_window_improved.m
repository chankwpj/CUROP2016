close all;
clear;
% AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/Mozart_Fantasy.wav';
 %AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/am_1.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/pro_1.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/am_2.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/pro_2.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/am_3.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/FlueElise/pro_3.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_am1.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_am2.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_pro1.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_pro2.wav';
% AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/In_the_hall_of_mountain_king.wav';

%%coverted from midi files
AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/for_elise_by_beethoven.wav';
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/beethoven-piano-sonata-pathetique-2.wav'; %2 movement
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/1move.wav'; %1movement
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/carnival-of-the-animals-the-elephant-piano-solo.wav'; 

%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/piano_fantasie_396_(hisamori).wav'; %fantasie
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Autumn-piano-arrangement.wav'; %Autumn
%AudioPath = 'C:/Users/genius/Desktop/SourceCode/Audio/Dvorak-Symphony9-2-from-the-New-World-piano.wav'; 



%% onset detection
AlgorithmFile = ['OnsetDetector.py'];
AlgorithmPath = strcat('C:/Users/genius/Desktop/SourceCode/MIREX_2015/OnsetDectector/', char(AlgorithmFile));
[y, fs] = audioread(AudioPath);
[status, onsetTime] = MIREX_Machine(AudioPath, AlgorithmPath);

%load('matlab_onset_fan.mat');
%load('matlab_onset_king.mat');
%load('matlab_onset_fueElise_am1.mat');
pos = onsetTime.' * 1000; %millisecond second form
pos = round(pos);
step = 150; %200

%% Data to Segments
%shorten the partition time
%segments is the output
% if 0
count = 1;
for n = 1:step: length(pos)
    if n + step > length(pos)
        segments{count} = pos(n:length(pos));
    else
        segments{count} = pos(n: n+step);
    end
    count = count + 1;
end
%the segments (step = 150) -> [1 to 151] [151 to 301] .....
% end

% pos = pos(1:4:end);
% segments = {};
% segments{1} = pos;

%% calculate optimal partitioning and tempo in every interval/segment
%intervals is the output
for n = 1:length(segments)
    %intervals in each segment
    segcpt = interval_partition(numel(segments{n}), @(b, e) objfn_tempo(segments{n}, b, e));
    segIntervals = [[1 segcpt]; [segcpt numel(segments{n})]];
    intervals{n} = segIntervals;
end

%% calculate tempo in each interval
%each segment corrsponding to a interval. Each interval may has to >= 1
%part(s)
%tempos is output
%loop all the segments
for n = 1:length(segments)
    t = [];
   %loop all the intervals in intervals variable
   for k = 1:size(intervals{n}, 2) 
       interval_head = intervals{n}(1, k);
       interval_tail = intervals{n}(2, k);
       sub_tempo = fit_tempo (segments{n}(interval_head : interval_tail)); %unit of time
       t = [t sub_tempo];
   end
   tempos{n} = t;   
end

%% merge those intervals and tempos
%merge intervals cell to mat
%pos intervals tempos in 3 arrays, no segments anymore
intervals = cell2mat(intervals);
for n = 2:size(intervals, 2)
    space = intervals(2, n) - intervals(1, n);
    intervals(1, n) = intervals(2, n-1);
    intervals(2, n) = intervals(1, n) + space;
end

tempos = cell2mat(tempos);

%% plot diff pos tempos intervals
figure;
hold on;
plot(diff(pos))
for n = 1:size(intervals, 2)
    plot(intervals(:, n), [tempos(n); tempos(n)], 'r', 'LineWidth', 2)
end
vline(intervals(1, :));
title('diff pos');
hold off;


%% noise merging
factor = 1/2;
pos_no_noise = pos;
shifts = [];
for n = 1:size(intervals, 2)
    interval_head = intervals(1, n);
    interval_tail = intervals(2, n);
    shift = 0;
    for j = interval_head + 1:interval_tail
       curgap = pos(j) - pos(j-1);
       if (curgap < factor*tempos(n))
          pos_no_noise(j-1) = -1; %-1 is a flag
          shift = shift + 1;
       else
           %do nothing
       end
    end
    shifts = [shifts shift];
end
pos_no_noise = pos_no_noise(pos_no_noise >=0);
%interval shifting
newIntervals = intervals;
for n = 1:numel(shifts)
    newIntervals(2, n) = newIntervals(2, n) - shifts(n);
    newIntervals(:, n+1 : end) = newIntervals(:, n+1 : end) - shifts(n);
end

%% plot
% 
% figure;
% hold on;
% plot(diff(pos_no_noise))
% for n = 1:size(newIntervals, 2)
%     plot(newIntervals(:, n), [tempos(n); tempos(n)], 'r', 'LineWidth', 2)
% end
% title('diff pos no noise');
% hold off;


%% splitting notes
scales = [1 2 3 4 6 8 12 16];
newpos = [];
shifts = [];
for n = 1:size(newIntervals, 2)
    interval_head = newIntervals(1, n);
    interval_tail = newIntervals(2, n);
    shift = 0;
    for j = interval_head +1:interval_tail
        curgap = pos_no_noise(j) - pos_no_noise(j - 1);
        scaled = curgap ./ scales;
        d = abs(tempos(n) - scaled);
        [~, best_scale_idx] = min(d);
        best_scale = scales(best_scale_idx);
        newSet = linspace(pos_no_noise(j-1), pos_no_noise(j), best_scale + 1);
        newSet = round(newSet);   
        newpos = [newpos newSet(1:end-1)]; %#ok<AGROW>
        shift = shift + numel(newSet(2:end-1));
    end
    shifts = [shifts shift];
end
newpos = [newpos pos_no_noise(end)]; %the last element

%shift intervals
finalIntervals = newIntervals;
for n = 1:numel(shifts)
    finalIntervals(2, n) = finalIntervals(2, n) + shifts(n);
    finalIntervals(:, n+1 : end) = finalIntervals(:, n+1 : end) + shifts(n);
end

%% plot 

figure(3); clf;
hold on;
xdata = newpos / 1000;
plot(xdata(2:end), diff(newpos))
for n = 1:size(finalIntervals, 2)
    plot(xdata(finalIntervals(:, n)), [tempos(n); tempos(n)], 'r', 'LineWidth', 2)
end
title('diff pos no noise,splitted');
grid MINOR;
vline(xdata(finalIntervals(1,:)))
hold off;


%% plot onset time and fit a line
% 
% figure(4); clf;
% xdata = newpos / 1000; xdata = xdata(2:end);
% ydata = diff(newpos);
% yy2 = smooth(xdata,ydata,0.1,'rlowess'); %0.1
% bpm_scale = 60 * 1000;
% %plot(xx,bpm_scale ./ ydata(ind),'b.',xx, bpm_scale ./ yy2(ind),'r-')
% plot(xdata, bpm_scale ./ ydata, 'b.', xdata, bpm_scale ./ yy2 , 'r-')
% legend('Original Data','Smoothed Data Using ''rlowess''', 'Location','NE')
% title('smooth without segments')
% grid MINOR;
% hold off;

%% plot onset time and fit a line, smooth by segments
figure(5); clf;
xdata = newpos / 1000; xdata = xdata(2:end);
ydata = diff(newpos);
bpm_scale = 60 * 1000;
yy2 = [];
%deleted first data, all interval shifts 1, but not the first interval
%starting point
in = finalIntervals - 1;
in(1,1) = 1;
for n = 1:size(in, 2)
    head = in(1,n); 
    tail = in(2,n);
    t_yy2 = smooth(xdata(head:tail), ydata(head:tail), 0.9, 'rlowess');
    yy2 = [yy2; t_yy2(1:end-1)];
end
yy2 = [yy2; t_yy2(end)];
plot(xdata, bpm_scale ./ ydata, 'b.', xdata, bpm_scale ./ yy2 , 'r-')

legend('Original Data','Smoothed Data Using ''rlowess''', 'Location','NE')
title('smooth by segment')
grid MINOR;

vline(xdata(in(1, :)));

xlabel = get(gca, 'xtick');
newxLabel = [xlabel(1):20:xlabel(end)];
set(gca, 'xtick', newxLabel);


%% test %%

% figure(6); clf;
% newpos = newpos(finalIntervals(1,1):finalIntervals(1,2));
% xdata = newpos / 1000; xdata = xdata(2:end);
% ydata = diff(newpos);
% yy2 = smooth(xdata,ydata,0.1,'rlowess');
% bpm_scale = 60 * 1000;
% %plot(xx,bpm_scale ./ ydata(ind),'b.',xx, bpm_scale ./ yy2(ind),'r-')
% plot(xdata, bpm_scale ./ ydata, 'b.', xdata, bpm_scale ./ yy2 , 'r-')
% legend('Original Data','Smoothed Data Using ''rlowess''', 'Location','NE')
% grid MINOR;
% hold off;
