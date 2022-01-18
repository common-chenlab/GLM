function [all_covariates, select_covariates, convariates_subidx, taskfactor] = define_covariate_factor_idx()

%% USER - all covariates to be generated in make_x_y
all_covariates = CommonCovariates;

%% USER - subset of covariates to be used in the GLM.  strings must match
select_covariates = {    
    'Cue CW (ED)';
    'Cue CW (LD)';
    'Cue CCW (ED)';
    'Cue CCW (LD)';
    'Dec Lick (report)';
    'Dec No Lick (report)';
    
     %get_enhance_supp_alter2
%     'Sample CW'
%     'Sample CCW'

    

   
    'Speed';
        
    'Reward';
    
    'CW CW E Fir Rate';
    'CW CCW E Fir Rate';
    'CCW CCW E Fir Rate';
    'CCW CW E Fir Rate';
    'CW CW S Fir Rate';
    'CW CCW S Fir Rate';
    'CCW CCW S Fir Rate';
    'CCW CW S Fir Rate'};


%% USER - task factors defined.  strings must match
taskfactor = {
%     'Direction', {'Stim CW', 'Stim CCW'};     
    'Sample ED', {'Cue CW (ED)', 'Cue CCW (ED)'};   
    'Sample LD', {'Cue CW (LD)'; 'Cue CCW (LD)'};
% 
%     'Stimulus',{'Sample CW'; 'Sample CCW';'CW NM T E Fir Rate';'CW M T E Fir Rate';'CCW NM T E Fir Rate';'CCW M T E Fir Rate';
%     'CCW NM T S Fir Rate';'CW NM T S Fir Rate';'CCW M T S Fir Rate';'CCW NM T S Fir Rate'};
%     
    'M Sup',{'CW CW S Fir Rate';'CCW CCW S Fir Rate'};
    'M Enh',{'CW CW E Fir Rate';'CCW CCW E Fir Rate'};
    'NM Sup',{'CW CCW S Fir Rate';'CCW CW S Fir Rate'};
    'NM Enh',{'CW CCW E Fir Rate';'CCW CW E Fir Rate'};
  
    
    'Stim Speed',{'Speed'};
    'Reward',{'Reward'};
    'Decision report', {'Dec Lick (report)', 'Dec No Lick (report)'}
%     'touch onset', {'W touch on'}; 
%     'touch onset', {'W touch off'}; 
%     'whisker kinematics', {'W touch on', 'W touch off', 'W angle', 'W recon', 'W phase', 'W amp', 'W setpt', 'W curve change'};
    }; %last is NMF


%% get index, don't edit
[c2 convariates_subidx ib2] = intersect(all_covariates, select_covariates, 'stable');

for i = 1:size(taskfactor,1)
    [c2 temp ib2] = intersect(select_covariates,taskfactor{i,2});
    taskfactor{i,2} = temp';
end
