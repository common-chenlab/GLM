function [sample_test,firingrate]=get_samp_test_fr(trial, eventvec,ca,samprate)

% This function will return the test firing rate instead of ones


% CW sample (10x1)zeros CW test
% CW sample (10x1)zeros CCW test
% CCW sample (10x1)zeros CW test
% CCW sample (10x1)zeros CCW test

CW1 = strcmp(trial.direction_1,'CW 40');
CCW1 = strcmp(trial.direction_1,'CCW 40');

CW2 = strcmp(trial.direction_2,'CW 40');
CCW2 = strcmp(trial.direction_2,'CCW 40');

times = find(eventvec);
empty = zeros(length(ca(:,1)), length(eventvec));
sample_test = empty;
sample_test(:,times(3):times(4)-1) = ca(:,times(3):times(4)-1);
sample_test(:,times(7):times(8)-1) = ca(:,times(7):times(8)-1);


firingrate = [sum(ca(:,times(3):times(3)+round(samprate)),2),sum(ca(:,times(7):times(7)+round(samprate)),2)];

end