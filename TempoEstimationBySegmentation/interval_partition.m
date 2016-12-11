function [ cpt ] = partition(N, cost)



argmax = 1;



best = zeros(N+1, 1);

last = zeros(N, 1);

best(end) = 0;

n = N + 1;



while true

    ma = -1e99;

    for j = N:-1:n-1

        xx = cost(n-1, j);

        xx = best(j+1) + xx;

        

        if xx > ma

            ma = xx;

            argmax = j;

        end

    end

    best(n-1) = ma; 

    last(n-1) = argmax; 

    

    if n-1==1, break; end

    n = n-1;

end



index = last( 1 ); cpt = [];

while index < N

    cpt = [ cpt index + 1 ]; %#ok<AGROW>

    index = last( index + 1 );

end

