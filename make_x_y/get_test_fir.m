function [CW_Enh,CW_Sup,CCW_Enh,CCW_Sup] = get_test_fir(trial, eventvec,ca,samprate)

% CW Enh Test Firing Rate
% CW Sup Test Firing Rate
% CCW Enh Test Firing Rate
% CCW Sup Test Firing Rate

CW2 = strcmp(trial.direction_2(1:end-3),'CW');
times = find(eventvec);
empty = zeros(1, length(eventvec));
test = empty;
test(times(7):times(8)-1) = 1;
firing_sum = sum(ca(:,times(7):times(7)+round(samprate)),2)+0.01;


CW_Enh= test.*firing_sum*CW2;
CW_Sup = test.*firing_sum*CW2;
CCW_Enh = test.*firing_sum*(1-CW2);
CCW_Sup = test.*firing_sum*(1-CW2);
end