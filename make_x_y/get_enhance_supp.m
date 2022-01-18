function tempenhsup = get_enhance_supp(trial, eventvec)

% 'Match Enhance (CW)'
% 'Match Enhance (CCW)'
% 'Non Match Enhance(CW)'
% 'Non Match Enhance(CCW)'
% 'Match Suppression (CW)'
% 'Match Suppression (CCW)'
% 'Non Match Suppression(CW)'
% 'Non Match Suppression(CCW)'

enh = 1.5;
sup = 0.5;
match = strcmp(trial.direction_1(1:end-3),trial.direction_2(1:end-3));
CW1 = strcmp(trial.direction_1(1:end-3),'CW');
issample20 = contains(trial.direction_1,'20');
istest20 = contains(trial.direction_2,'20');
issample40 = contains(trial.direction_1,'40');
istest40 = contains(trial.direction_2,'40');
is_speed_match = (issample20&istest20) | (issample40&istest40); %remove the effect from non match speed



times = find(eventvec);
empty = zeros(1, length(eventvec));
sample = empty;
test = empty;
sample(times(3):times(4)-1) = 1;
test(times(7):times(8)-1) = 1;

tempenhsup = is_speed_match*[(CW1*1*sample+test*CW1*enh)*match;...
    ((1-CW1)*1*sample+test*(1-CW1)*enh)*match;...
    (CW1*1*sample+test*(1-CW1)*enh)*(1-match);...
    ((1-CW1)*1*sample+test*CW1*enh)*(1-match);...
    (CW1*1*sample+test*CW1*sup)*match;...
    ((1-CW1)*1*sample+test*(1-CW1)*sup)*match;...
    (CW1*1*sample+test*(1-CW1)*sup)*(1-match);...
    ((1-CW1)*1*sample+test*CW1*sup)*(1-match)];


end