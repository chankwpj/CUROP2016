function [tempo, POS] = tempo_by_quantisation(onsetTime, y, fs);

wnd = fs * 16;
lap = 49693;%wnd / 8;

tempo = [];
POS = [];
on = ceil(onsetTime * fs);
pos = 1;
while pos + wnd - 1 <= size(y, 1)
    POS = [POS; pos];
    idx = find(on >= pos & on < pos + wnd);
    this = on(idx);
    
    k = 4;
    d = diff(this);
    if numel(d) < 1
%         if ~isempty(tempo)
%             tempo = [tempo; tempo(end)];
%         else
%             tempo = [tempo; 0];
%         end
        tempo = [tempo; nan];
        pos = pos + lap;
        continue;
    end
    [l, c, d] = kmeans(d, min(k, numel(d)));
    L = mode(l);
    C = c(L);
    tempo = [tempo; 1 / (C / fs)]; %#ok<AGROW>
    pos = pos + lap;
end