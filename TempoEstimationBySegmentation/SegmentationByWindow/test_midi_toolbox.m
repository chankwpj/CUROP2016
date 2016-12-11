%clear;
% close all;
nmat = readmidi('for_elise_by_beethoven.mid');


bpm = gettempo(nmat);
%pianoroll(nmat,'name','sec','vel');
% plotmelcontour(nmat,0.25,'abs',':r.'); hold on;
% plotmelcontour(nmat,1,'abs','-bo'); hold off;
% legend(['resolution in beats=.25'; 'resolution in beats=1.0']);
nonset = nmat(:, 6)*1000;

first_44sec_tempo = gettempo(onsetwindow(nmat,0,44,'sec'));

%plot(diff(nonset))
% 
% 
% figure(6); 
% xdata = nonset / 1000; xdata = xdata(2:end);
% ydata = diff(nonset);
% yy2 = smooth(xdata,ydata,0.3,'rlowess'); %0.1
% bpm_scale = 60 * 1000;
% %plot(xx,bpm_scale ./ ydata(ind),'b.',xx, bpm_scale ./ yy2(ind),'r-')
% plot(xdata, bpm_scale ./ ydata, 'b.', xdata, bpm_scale ./ yy2 , 'r-')
% legend('Original Data','Smoothed Data Using ''rlowess''', 'Location','NE')
% title('smooth without segments')
% 
% grid MINOR;
% hold off;