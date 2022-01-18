function plot_GLM_fit_wo_partial(out,trial_info, select_covariates, task_factors, align_to)


trial_end_indices = trial_info.end_indices;
type_key = trial_info.type_key;
types = trial_info.type;
decision_key = trial_info.decision_key;
decision = trial_info.decision;
event_times = trial_info.event_times;
event_key = trial_info.event_key;

event_num = find(contains(event_key, align_to));


Y = out.spk_neuron;

[Y_reshape, align_time_pt] = reshape_Y_trials(Y,trial_end_indices, event_times, event_num);


max_length = size(Y_reshape,2);

type_matrix = zeros([length(type_key),length(types)]);
dec_matrix = zeros([length(decision_key),length(decision)]);
for tr = 1:length(types)
    type_matrix(types(tr),tr) = 1;
    dec_matrix(decision(tr),tr) = 1;
end

trim = 0;

f = figure;
f.Position = [10 10  1800 1500];

subplot(3,1,1);
for type = 1:length(type_key)
    nm = nanmean(Y_reshape(logical(type_matrix(type,:)),trim+1:end),1);
    %nmr = reshape(nm, [1 max_length-trim]);
    nm(isnan(nm)) = 0;
    plot(smooth(nm,10)); hold on;
end
title('Firing rate by type');
legend(type_key,'Location','bestoutside')
legend('boxoff')

subplot(3,1,2);
for type = 1:length(decision_key)
    nm = nanmean(Y_reshape(logical(dec_matrix(type,:)),trim+1:end),1);
    %nmr = reshape(nm, [1 max_length-trim]);
    nm(isnan(nm)) = 0;
    plot(smooth(nm,10)); hold on;
end
title('Firing rate by decision');
legend(decision_key,'Location','bestoutside')
legend('boxoff')

subplot(3,1,3);
bar(out.w); xticks(1:length(select_covariates)); xticklabels(select_covariates); title('weights');set(gca,'XTickLabelRotation',45)
grid on



suptitle(out.cellid);
if ~exist(out.saveloc, 'dir')
    mkdir(out.saveloc)
end
saveas(gcf,[out.saveloc out.cellid '_GLM_fit_wo_partial.png']);
disp([out.cellid,' saved to ',out.saveloc])

end











