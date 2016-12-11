function plot_tempo_spectrogram(x, fs, name)

if nargin < 3
    name = '';
end
x = x(:); xlen = length(x);
%fmin = 27.5;
fmin = 1;
%B = 48;
B = 25;
%gamma = 20; 
fmax = 16;
Xcq = cqt(x, B, fs, fmin, fmax, 'rasterize', 'full', 'normalize', 'sine');
c = Xcq.c;

%subplot(2,1,2);
imagesc(20*log10(abs(flipud(c))+eps));
hop = xlen/size(c,2);
xtickVec = 0:round(fs/hop):size(c,2)-1;
set(gca,'XTick',xtickVec);

%ytickVec = 0:B/5:size(c,1)-1;
ytickVec = 0:B:size(c,1)-1;
set(gca,'YTick',ytickVec);
ytickLabel = round(fmin * 2.^( (size(c,1)-ytickVec)/B));
set(gca,'YTickLabel',ytickLabel);

%xtickLabel = 0 : length(xtickVec) ;
xtickLabel = [];
set(gca,'XTickLabel',xtickLabel);
xlabel('time [s]', 'FontSize', 12, 'Interpreter','latex'); 
ylabel('frequency [Hz]', 'FontSize', 12, 'Interpreter','latex');
set(gca, 'FontSize', 10);
%title('Grieg  In the Hall of the Mountain');
title(name);