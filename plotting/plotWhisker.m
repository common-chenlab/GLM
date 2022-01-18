%%
function plotWhisker(X, select_covariates, trial_info)


%Plots whiskers features for the given sessiont

%Cam Condylis 12/3/19
trial_end_indices = trial_info.end_indices;
type_key = trial_info.type_key;
types = trial_info.type;
decision_key = trial_info.decision_key;
decision = trial_info.decision;
all_whisker_covariates = {'W touch on';'W touch off';'W angle';'W recon';'W phase';'W amp';'W setpt';'W curve change'};

labels = {};
whiskdata = [];

[X_reshape_whisk, labels_whisk] = reshape_X_trials(X, all_whisker_covariates, select_covariates, trial_end_indices);


max_length = size(X_reshape_whisk,3);

type_matrix = zeros([length(type_key),length(types)]);
dec_matrix = zeros([length(decision_key),length(decision)]);
for tr = 1:length(types)
    type_matrix(types(tr),tr) = 1;
    dec_matrix(decision(tr),tr) = 1;
end
    
trim = 50;
figure; 
for cov = 1:length(all_whisker_covariates)
    subplot(length(all_whisker_covariates),1, cov); title(all_whisker_covariates{cov})
    for type = 1:length(type_key)
        plot(reshape(nanmean(X_reshape_whisk(cov,logical(type_matrix(type,:)),trim+1:end),2),[1,max_length-trim])); hold on;
    end
    title(all_whisker_covariates{cov}); legend(type_key)
end


saveas(gcf,[trial_info.session '_whisker.png']);



end
