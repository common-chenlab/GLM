function [CW_Enh_T_M,CW_Enh_T_NM,CCW_Enh_T_M,CCW_Enh_T_NM] = get_test_fir(trial, eventvec,ca,samprate)
% This function will return the test firing rate instead of ones


% CW M T E Fir Rate
% CW NM T E Fir Rate
% CCW M T E Fir Rate
% CCW NM T E Fir Rate

CW1 = strcmp(trial.direction_1,'CW 40');

CW2 = strcmp(trial.direction_2,'CW 40');
CCW2 = strcmp(trial.direction_2,'CCW 40');

times = find(eventvec);
empty = zeros(1, length(eventvec));
test = empty;
test(times(7):times(8)-1) = 1;
firing_sum = sum(ca(:,times(7):times(7)+round(samprate)),2)+0.001;


CW_Enh_T_M= test.*firing_sum*CW2*CW1;
CW_Enh_T_NM = test.*firing_sum*CW2*(1-CW1);
CCW_Enh_T_M = test.*firing_sum*CCW2*(1-CW1);
CCW_Enh_T_NM = test.*firing_sum*CCW2*CW1;
end