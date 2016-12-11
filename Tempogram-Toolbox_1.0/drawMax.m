function [line] = drawMax(FourierXautocorrelation, BPM)

%windowSize = 1*44100; %1s
z = zeros(size(FourierXautocorrelation));
for n = 1:length(FourierXautocorrelation)
    temp = abs(FourierXautocorrelation(:,n));
    max_val = max(temp);
    index = find(temp >= max_val);
    %z(index, n) = max_val;
    z(index, n) = 1;
end
maxs = z;
line = zeros(length(maxs), 1);
for n = 1:length(line)
    column = maxs(:, n);
    if (isempty(find(column >= 1)))
        line(n) = 0;
    else
        [r, c] = find(column >= 1);
        if length(r) > 1
            line(n) = r(1) + min(BPM); %value 0 is min PBM ;
        else
            line(n) = r + min(BPM); %value 0 is min PBM ;
        end
    end

end
