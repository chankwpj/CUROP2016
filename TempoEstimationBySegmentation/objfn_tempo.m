function score = objfn_tempo(x, b, e)

if abs(e - b) < 5
    score = -100000;
end
[tempo, dev] = fit_tempo(x(b:e));


score = -(dev + 100);
score;