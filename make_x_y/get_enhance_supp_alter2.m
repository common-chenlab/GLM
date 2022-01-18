function tempenhsup_alt2 = get_enhance_supp_alter2(trial, eventvec)

% 'Sample CW'
% 'Sample CCW'
% 'Sample CW NM';
% 'Sample CW M';
% 'Test CW NM'
% 'Test CCW NM'
% 'Test CW M'
% 'Test CCW M'

CW1 = strcmp(trial.direction_1(1:end-3),'CW');
CW2 = strcmp(trial.direction_2(1:end-3),'CW');
dirmatch = strcmp(trial.direction_1(1:end-3),trial.direction_2(1:end-3));
times = find(eventvec);
empty = zeros(1, length(eventvec));
sample = empty;
test = empty;
sample(times(3):times(4)-1) = 1;
test(times(7):times(8)-1) = 1;

tempenhsup_alt2 = [CW1*sample;...
    (1-CW1)*sample;...
    CW1*sample*(1-dirmatch);...
    CW1*sample*dirmatch;...
    CW2*(1-dirmatch)*test;...
    (1-CW2)*(1-dirmatch)*test;...
    CW2*dirmatch*test;...
    (1-CW2)*(1-dirmatch)*test];



end

