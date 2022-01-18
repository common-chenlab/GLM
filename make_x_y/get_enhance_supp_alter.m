function tempenhsup_alt = get_enhance_supp_alter(trial, eventvec)

% 'CW Sample'
% 'CCW Sample'
% 'CW Test Enhancement M'
% 'CW Test Suppression M'
% 'CW Test Remain M'
% 'CCW Test Enhancement M'
% 'CCW Test Suppression M'
% 'CCW Test Remain M'
% 'CW Test Enhancement NM'
% 'CW Test Suppression NM'
% 'CW Test Remain NM'
% 'CCW Test Enhancement NM'
% 'CCW Test Suppression NM'
% 'CCW Test Remain NM'

%enhance variables
enh_fs = 1/2; %one spike per frame
enh_duration = .9; 

%suppresion variables
sup_fs = 1/4; %one spike per frame
sup_duration = .5; %half of the whole period

CW1 = strcmp(trial.direction_1(1:end-3),'CW');
CW2 = strcmp(trial.direction_2(1:end-3),'CW');

% % speed match check
% issample20 = contains(trial.direction_1,'20');
% istest20 = contains(trial.direction_2,'20');
% issample40 = contains(trial.direction_1,'40');
% istest40 = contains(trial.direction_2,'40');
% is_speed_match = (issample20&istest20) | (issample40&istest40); %remove the effect from non match speed

dirmatch = strcmp(trial.direction_1(1:end-3),trial.direction_2(1:end-3));
times = find(eventvec);
empty = zeros(1, length(eventvec));
sample = empty;
test = empty;
sample(times(3):times(4)-1) = 1;
test(times(7):times(8)-1) = 1;

test_enh = empty;
test_sup = empty;
test_rem = empty;
for i = times(7):times(8)-1
    if rem(i, 1/enh_fs) == 0 
        test_enh(i) = 1;
    elseif rem(i,1/sup_fs) == 1 & i < round(sup_duration*(times(8)-1)+(1-sup_duration)*times(7))
        test_sup(i) = 1;
    elseif i>=round(enh_duration*(times(8)-1)+(1-enh_duration)*times(7))
        test_enh(i) = 1;
    else
        test_rem(i) = 1;
    end
end

tempenhsup_alt = [CW1*sample;...
    (1-CW1)*sample;...
    dirmatch*CW2*test_enh;...
    dirmatch*CW2*test_sup;...
    dirmatch*CW2*test_rem;...
    dirmatch*(1-CW2)*test_enh;...
    dirmatch*(1-CW2)*test_sup;...
    dirmatch*(1-CW2)*test_rem;...
    (1-dirmatch)*CW2*test_enh;...
    (1-dirmatch)*CW2*test_sup;...
    (1-dirmatch)*CW2*test_rem;...
    (1-dirmatch)*(1-CW2)*test_enh;...
    (1-dirmatch)*(1-CW2)*test_sup;...
    (1-dirmatch)*(1-CW2)*test_rem];


end