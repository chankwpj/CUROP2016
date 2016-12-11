filename{1} = '';

for n = 1:5
    filename{n} = strcat('am_', num2str(n), '.wav');
    %filename{n} = strcat('am_', num2str(n+5), '.wav');
    
end

for n = 1:5
    filename{n+5} = strcat('pro_', num2str(n), '.wav');
    %filename{n+5} = strcat('pro_', num2str(n+5), '.wav');
end


FourierXAutocorrelation(filename{1}, 5, 2, 1) ;
FourierXAutocorrelation(filename{2}, 5, 2, 3) ;
FourierXAutocorrelation(filename{3}, 5, 2, 5) ;
FourierXAutocorrelation(filename{4}, 5, 2, 7) ;
FourierXAutocorrelation(filename{5}, 5, 2, 9) ;
FourierXAutocorrelation(filename{6}, 5, 2, 2) ;
FourierXAutocorrelation(filename{7}, 5, 2, 4) ;
FourierXAutocorrelation(filename{8}, 5, 2, 6) ;
FourierXAutocorrelation(filename{9}, 5, 2, 8) ;
FourierXAutocorrelation(filename{10}, 5, 2, 10) ;


