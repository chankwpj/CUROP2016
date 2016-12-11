clear;
close all;

filename{1} = '';

for n = 1:4
    filename{n} = strcat('C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_am', num2str(n), '.wav');
    %filename{n} = strcat('am_', num2str(n+5), '.wav');
    
end

for n = 1:4
    filename{n+4} = strcat('C:/Users/genius/Desktop/SourceCode/Audio/Fantasia/fantasia_pro', num2str(n), '.wav');
    %filename{n+5} = strcat('pro_', num2str(n+5), '.wav');
end


windowSec = 5;
plotD = 0; % fale


for n = 1:8
    [FxAMC_n, T, BPM] = function_tempogram_novelty( filename{n}, windowSec, plotD  );
    [FxAMC_s, T, BPM]= function_tempogram_sine( filename{n}, windowSec, plotD  );
    visualize_tempogram(FxAMC_n.*FxAMC_s,T,BPM);
    title(strcat(filename{n}, '-', 'N*S'))
    %savefig(filename{n}(10:end-4));
end 


%{
%compare tempogram
filename1 = 'am_4.wav'; %Flue Elise am
filename2 = 'pro_4.wav'; %Flue Elise pro
filename3 = 'am_4.wav'; %Flue Elise am
filename4 = 'pro_4.wav'; %Flue Elise pro
filename5 = 'am_5.wav'; %Flue Elise am
filename6 = 'pro_5.wav'; %Flue Elise pro

windowSec = 5;
plotD = 0; % fale

[FxAMC_n, T, BPM] = function_tempogram_novelty( filename1, windowSec, plotD  );
[FxAMC_s, T, BPM]= function_tempogram_sine( filename1, windowSec, plotD  );
visualize_tempogram(FxAMC_n.*FxAMC_s,T,BPM);
title(strcat(filename1, '-', 'mix'))

[FxAMC_n, T, BPM] = function_tempogram_novelty( filename2, windowSec, plotD  );
[FxAMC_s, T, BPM]= function_tempogram_sine( filename2, windowSec, plotD  );
visualize_tempogram(FxAMC_n.*FxAMC_s,T,BPM);
title(strcat(filename2, '-', 'mix'))

[FxAMC_n, T, BPM] = function_tempogram_novelty( filename3, windowSec, plotD  );
[FxAMC_s, T, BPM]= function_tempogram_sine( filename3, windowSec, plotD  );
visualize_tempogram(FxAMC_n.*FxAMC_s,T,BPM);
title(strcat(filename3, '-', 'mix'))

[FxAMC_n, T, BPM] = function_tempogram_novelty( filename4, windowSec, plotD  );
[FxAMC_s, T, BPM]= function_tempogram_sine( filename4, windowSec, plotD  );
visualize_tempogram(FxAMC_n.*FxAMC_s,T,BPM);
title(strcat(filename4, '-', 'mix'))

[FxAMC_n, T, BPM] = function_tempogram_novelty( filename5, windowSec, plotD  );
[FxAMC_s, T, BPM]= function_tempogram_sine( filename5, windowSec, plotD  );
visualize_tempogram(FxAMC_n.*FxAMC_s,T,BPM);
title(strcat(filename5, '-', 'mix'))

[FxAMC_n, T, BPM] = function_tempogram_novelty( filename6, windowSec, plotD  );
[FxAMC_s, T, BPM]= function_tempogram_sine( filename6, windowSec, plotD  );
visualize_tempogram(FxAMC_n.*FxAMC_s,T,BPM);
title(strcat(filename6, '-', 'mix'))


%}