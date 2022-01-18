function [all_covariates, select_covariates, covariates_subidx, taskfactor] = define_covariate_factor_idx_PRH(covStruct)

%% USER - all covariates to be generated in make_x_y
all_covariates = {covStruct(:).name};

%% USER - subset of covariates to be used in the GLM.  strings must match
select_covariates = all_covariates(logical([covStruct(:).select]));


%% USER - task factors defined.  strings must match
% taskfactor_1 = {'Direction', {'Stim CW', 'Stim CCW'};     
%     'Sample ED', {'Cue CW (ED)', 'Cue CCW (ED)'};   
%     'Sample LD', {'Cue CW (LD)'; 'Cue CCW (LD)'};
%     'Category test', {'Cat M (test)', 'Cat NM (test)'};
%     'Category report', {'Cat M (report)', 'Cat NM (report)'};
%     'Decision test', {'Dec Lick (test)', 'Dec No Lick (test)'}; 
%     'Decision report', {'Dec Lick (report)', 'Dec No Lick (report)'};
%     'touch onset', {'W touch on'}; 
%     'touch onset', {'W touch off'}; 
%     'whisker kinematics', {'W touch on', 'W touch off', 'W angle', 'W recon', 'W phase', 'W amp', 'W setpt', 'W curve change'};
%     'coupling', {'coupling'}}; %last is NMF

for n = 1:length(covStruct)
    if isempty(covStruct(n).taskfactor)
        covStruct(n).taskfactor = '';
    end
end

tt = {covStruct(:).taskfactor};
taskfactor = unique(tt(~ismissing(tt))');
taskfactor = [taskfactor, cell(length(taskfactor),1)];

for m = 1:length(covStruct)
    if covStruct(m).select && ~isempty(covStruct(m).taskfactor)
        tf_ind = find(strcmp(taskfactor(:,1),covStruct(m).taskfactor));
        if isempty(taskfactor{tf_ind,2})
            taskfactor{tf_ind,2} = covStruct(m).name;
        else
            taskfactor{tf_ind,2} = {taskfactor{tf_ind,2},covStruct(m).name};
        end
    end
end

%% get index, don't edit
[c2, covariates_subidx, ib2] = intersect(all_covariates, select_covariates, 'stable');

for i = 1:size(taskfactor,1)
    [c2, temp, ib2] = intersect(select_covariates,taskfactor{i,2});
    taskfactor{i,2} = temp';
end

% Clear out empty task factors
tfnums = cellfun(@(x) size(x,2), taskfactor(:,2));
taskfactor(tfnums==0,:) = [];
