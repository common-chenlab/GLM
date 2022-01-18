function [X_reshape, labels] = reshape_X_trials(X, subset_covariates, select_covariates, trial_end_indices)

%Cam Condylis 7/7/21
%function to take large X matrix of covariates across all timepoints and
%break it up into trials. useful for plotting

%inputs:
% 1. X: array of shape [N covariates X M time points]
% 2. subset_covariates: cell array of P specific covariate names you want to include
% in reshape (P <= N). useful to look at just whisker covariates or just
% stim etc.
% 3. select_covariates: cell array of all N covariate names in X
% 4. trial_end_indices: array of indices of end point of all trials within M
%timepoints

%outputs:
% 1. X_reshape: Array of size [P x T x R] where P is subset of covariates, T is
%number of trials, and R number of timepoints in each trial. 
%NOTE: because of variable trial length, R = length of longest trial.  all other trials are
%padded with NaNs at the beginnning of each trial so that they are length R.
% 2. labels: same as subset_covariates input. list of all covariate names
% included in X_reshape.

labels = {};
data = [];


for i = 1:length(subset_covariates)
    covar = subset_covariates{i};
    if ismember(covar, select_covariates)
        [~,locb] = ismember(covar, select_covariates);
        data = [data; X(locb,:)];
        labels = [labels, covar];
    end
end

%reshape
X_reshape = [];
trial_lengths = [];
for i = 2:length(trial_end_indices)
    trial_lengths(i) = trial_end_indices(i) - trial_end_indices(i-1);
end
trial_lengths(1) = trial_end_indices(1);


max_length = max(trial_lengths);
for i = 1:length(labels)
    for trial = 2:length(trial_end_indices)
         trial_data = data(i, trial_end_indices(trial-1)+1:trial_end_indices(trial));
         padded_trial = padarray(double(trial_data), [0 max_length - length(trial_data)], NaN, 'pre'); 
         X_reshape(i,trial,:) = padded_trial;
    end
end

end