clear;
close all;

fs = 44100;

d = fs / (144 / 60);
dist = repmat(d, 1, 20);
% d = fs ./ (linspace(144, 60, 30) / 60);
% dist = [dist d];
d = fs / (120 / 60);
dist = [dist repmat(d, 1, 30)];

pos = cumsum(dist);
figure(1); clf;
pos = pos + fs/100 * randn(size(pos));

pos = round(pos);
y = zeros(max(pos), 1);
remove = randperm(numel(pos));
remove = remove(1:floor(0.1 * numel(pos)));
pos(remove) = [];
plot(diff(pos)); hold on

y(pos) = 1;

cpt = interval_partition(numel(pos), @(b, e) objfn_tempo(pos, b, e));
if ~isempty(cpt)
    vline(cpt, 'k:')
end

intervals = [[1 cpt]; [cpt numel(pos)]];

for i = 1:size(intervals, 2)
    tempo = fit_tempo(pos(intervals(1, i):intervals(2, i)));
    plot(intervals(:, i), [tempo; tempo], 'r', 'LineWidth', 2)
end
hold off

%{
figure(2); clf;
hold on
for i = 1:size(intervals, 2)
    tempo = fit_tempo(pos(intervals(1, i):intervals(2, i)));
    plot(pos(intervals(:, i)), 60 * fs ./ [tempo; tempo], 'r', 'LineWidth', 2)
end
plot(y * 200)
hold off

%}