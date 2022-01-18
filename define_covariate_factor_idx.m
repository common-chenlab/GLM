function [all_covariates, select_covariates, convariates_subidx, taskfactor] = define_covariate_factor_idx()

%% USER - all covariates to be generated in make_x_y
all_covariates = {'Stim CW';
    'Stim CCW';      
    'Cue CW (Pre)';
    'Cue CW (sample)';
    'Cue CW (ED)';
    'Cue CW (LD)';
    'Cue CW (test)';
    'Cue CW (report)';
    'Cue CCW (Pre)';
    'Cue CCW (sample)';
    'Cue CCW (ED)';
    'Cue CCW (LD)';
    'Cue CCW (test)';
    'Cue CCW (report)';
    'Cat M (Pre)';
    'Cat M (sample)';
    'Cat M (ED)';
    'Cat M (LD)';
    'Cat M (test)';
    'Cat M (report)';
    'Cat NM (Pre)';
    'Cat NM (sample)';
    'Cat NM (ED)';
    'Cat NM (LD)';
    'Cat NM (test)';
    'Cat NM (report)';
    'Dec Lick (Pre)';
    'Dec Lick (sample)';
    'Dec Lick (ED)';
    'Dec Lick (LD)';    
    'Dec Lick (test)';
    'Dec Lick (report)';
    'Dec No Lick (Pre)';
    'Dec No Lick (sample)';
    'Dec No Lick (ED)';
    'Dec No Lick (LD)';    
    'Dec No Lick (test)';
    'Dec No Lick (report)';
    'Licks';
    'W touch on';
    'W touch off';
    'W angle';
    'W recon';
    'W phase';
    'W amp';
    'W setpt';
    'W curve change';
    'Speed'
    'Cue Speed (Pre)';
    'Cue Speed (sample)';
    'Cue Speed (ED)';
    'Cue Speed (LD)';
    'Cue Speed (test)';
    'Cue Speed (report)';
    'Reward'
    'coupling'};

%% USER - subset of covariates to be used in the GLM.  strings must match
select_covariates = {'Stim CW';
    'Stim CCW';    
    'Cue CW (ED)';
    'Cue CW (LD)';
    'Cue CCW (ED)';
    'Cue CCW (LD)';
    'Cat M (test)';
    'Cat M (report)';
    'Cat NM (test)';
    'Cat NM (report)';
    'Dec Lick (test)';
    'Dec Lick (report)';
    'Dec No Lick (test)';
    'Dec No Lick (report)';
    'Licks';
    'W touch on';
    'W touch off';
    'W angle';
    'W recon';
    'W phase';
    'W amp';
    'W setpt';
    'W curve change';
    'coupling'};


%% USER - task factors defined.  strings must match
taskfactor = {'Direction', {'Stim CW', 'Stim CCW'};     
    'Sample ED', {'Cue CW (ED)', 'Cue CCW (ED)'};   
    'Sample LD', {'Cue CW (LD)'; 'Cue CCW (LD)'};
    'Category test', {'Cat M (test)', 'Cat NM (test)'};
    'Category report', {'Cat M (report)', 'Cat NM (report)'};
    'Decision test', {'Dec Lick (test)', 'Dec No Lick (test)'}; 
    'Decision report', {'Dec Lick (report)', 'Dec No Lick (report)'};
    'touch onset', {'W touch on'}; 
    'touch onset', {'W touch off'}; 
    'whisker kinematics', {'W touch on', 'W touch off', 'W angle', 'W recon', 'W phase', 'W amp', 'W setpt', 'W curve change'};
    'coupling', {'coupling'}}; %last is NMF


%% get index, don't edit
[c2 convariates_subidx ib2] = intersect(all_covariates, select_covariates, 'stable');

for i = 1:size(taskfactor,1)
    [c2 temp ib2] = intersect(select_covariates,taskfactor{i,2});
    taskfactor{i,2} = temp';
end
