function [Y_reshape, align_time_pt] = reshape_Y_trials(Y, trial_end_indices, event_times, event_num)

%Cam Condylis 7/7/21
%function to take large X matrix of neurons spikes across all timepoints and
%break it up into trials. useful for plotting

%inputs:
% 1. Y: array of spikes [N neurons X M time points]
% 2. trial_end_indices: array of indices of end point of all trials within M
%timepoints

%outputs:
% 1. Y_reshape: Array of size [P x T x R] where P is neurons, T is
%number of trials, and R number of timepoints in each trial. 
%NOTE: because of variable trial length, R = length of longest trial.  all other trials are
%padded with NaNs at the beginnning of each trial so that they are length R.



data = Y;



%get max trial length
trial_lengths = [];
for i = 2:length(trial_end_indices)
    trial_lengths(i) = trial_end_indices(i) - trial_end_indices(i-1);
end
trial_lengths(1) = trial_end_indices(1);
max_length = max(trial_lengths);

Y_reshape = [];
for trial = 1:length(trial_end_indices)
    if trial == 1
            trial_data = data(1:trial_end_indices(trial));
    else
            trial_data = data(trial_end_indices(trial-1)+1:trial_end_indices(trial));
    end
    align_time = find(event_times{trial}==event_num);
    pad_start = padarray(trial_data(1:align_time-1), [0 max_length - length(trial_data(1:align_time-1))], NaN, 'pre'); 
    pad_end = padarray(trial_data(align_time:end), [0 max_length - length(trial_data(align_time:end))], NaN, 'post');
    padded_trial = [pad_start, pad_end];
    Y_reshape(trial,:) = padded_trial;
end

align_time_pt = [zeros(1,max_length), 1, zeros(1, max_length-1)];
align_time_pt = align_time_pt(any(~isnan(Y_reshape)));
Y_reshape = Y_reshape(:,any(~isnan(Y_reshape))); %trim columns with all Nans

end