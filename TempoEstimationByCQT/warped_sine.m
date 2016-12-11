function signal = warped_sine(onsets, y, fs)

onsets = ceil(onsets * fs);
signal = zeros(size(y, 1), 1);

for i = 1:numel(onsets) - 1
    this = onsets(i);
    next = onsets(i + 1);
    len = next - this; % This many samples = 2pi
    x = linspace(0, 2*pi, len);
    y = cos(x);
    signal(this:(next-1)) = y;
end
