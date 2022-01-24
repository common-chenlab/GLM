function run_GLM_session(directory, anm, session, plotfigure, ROI_list,Project,includeWhisker,denoise,plot_whiskers,coupling,enhsup)

if nargin == 0
    directory =pwd;
    anm ='';
    session = 'cc034-4';
    plotfigure = 1;
    ROI_list = {'cc034-4-A0-0016-temp','cc034-4-A0-0029-temp','cc034-4-A0-0034-temp','cc034-4-A0-0063-temp','cc034-4-A0-0001-draw','cc034-4-A0-0004-draw',...
        'cc034-4-A0-0005-draw','cc034-4-A0-0008-draw','cc034-4-A0-0014-draw','cc034-4-A0-0017-draw','cc034-4-A0-0018-draw','cc034-4-A0-0020-draw','cc034-4-A0-0021-draw',...
        'cc034-4-A0-0022-draw','cc034-4-A0-0023-draw','cc034-4-A0-0025-draw','cc034-4-A1-0030-temp','cc034-4-A1-0052-temp','cc034-4-A1-0120-temp','cc034-4-A1-0002-draw','cc034-4-A1-0007-draw'};
    Project = 'CRACK';
    includeWhisker = 1;
    coupling = 1;
    denoise = 0;
    plot_whiskers = 0;
    enhsup =  0;
end


saved_day = convertStringsToChars(string(datetime('now','TimeZone','local','Format','_MMM_d_y_HH')));
addpath(genpath(pwd))


%% THESE TWO FUNCTIONS NEED TO BE CUSTOMIZED
% TODO Project
if strcmp(Project,'CRACK')
    [all_covariates, select_covariates, covariates_subidx, taskfactor] = define_covariate_factor_idx_CRACK();
    [bigStruct, Y, X, ROI_list_Ca1, ROI_list_Ca2, trial_info] = make_x_y(anm, session, directory, includeWhisker,denoise);

elseif strcmp(Project,'Connectomics')
    [all_covariates, select_covariates, covariates_subidx, taskfactor] = define_covariate_factor_idx_Connectomics();
    [bigStruct, Y, X, ROI_list_Ca1, ROI_list_Ca2, trial_info,test_firing_rate] = make_x_y(anm, session, directory, includeWhisker,denoise);

elseif strcmp(Project,'Perirhinal')
    load('Z:/Dropbox/Chen Lab Dropbox/Chen Lab Team Folder/Projects/Perirhinal/Animals/covStruct.mat')
    [all_covariates, select_covariates, covariates_subidx, taskfactor] = define_covariate_factor_idx_PRH(covStruct);
    [bigStruct, Y, X, ROI_list_Ca1, ROI_list_Ca2, trial_info] = make_x_y_PRH(anm, session, directory, includeWhisker,denoise);

end

coupling = any(contains(select_covariates,'coupling'));


%%
if plotfigure == 1
    if plot_whiskers == 1
        plotWhisker(X(covariates_subidx(1:end-1),:), select_covariates, trial_info)
    end
end

%% hyper parameters
numLambda = 6; % #hyper
nCV = 4; % #hyper

%% Run
tic
out = {};
wreg2 = {};
stats2 = {};
Area =  {};
NrnNum = {};
cellid = {};
b0 = {};
w = {};
lam = {};
LAM = {};
spk_neuron = {};
wreg1 = {};
stats1 = {};
dev2 = {};
dev1 = {};
dAIC = {};
pval = {};

%% prepare master list of ROIs
master_list = {};
master_idx = [];

if isempty(ROI_list_Ca1) == 0  % Run on Area 1
    master_list = ROI_list_Ca1;
    master_idx(1:length(ROI_list_Ca1),1) = 1;
    master_idx(1:length(ROI_list_Ca1),2) = 1:length(ROI_list_Ca1);
end

if isempty(ROI_list_Ca2) == 0     % Run on Area 2
    master_list = [master_list; ROI_list_Ca2];
    a2_idx(1:length(ROI_list_Ca2),1) = 2;
    a2_idx(1:length(ROI_list_Ca2),2) = 1:length(ROI_list_Ca2);
    master_idx = [master_idx; a2_idx];
end
%%

if isempty(master_list) == 0
    
    X = X(covariates_subidx(1:end-coupling-enhsup*4),:); %select sub X, no coupling added yet
    proceed = 1;
    for kki = 1:length(master_list)  %% all the ROIs
        proceed = 0;
        caughterror = 0;
        if isempty(ROI_list) == 1
            proceed = 1;
        elseif ismember(master_list{kki}, ROI_list) == 1
            proceed = 1;
        end
        if proceed == 1
            Area{kki} =  master_idx(kki, 1);
            NrnNum{kki} = master_idx(kki, 2);
            cellid{kki} =  master_list{kki};
            
            disp([master_list{kki} ' running' num2str(kki)]);
            
            yt = Y(kki,:); % select yt
            tempX = X;
            if enhsup
                Sample_FR_mean_CW = bigStruct(1).Firingrate_Sample_CW(kki)+0.01;
                Sample_FR_mean_CCW = bigStruct(1).Firingrate_Sample_CCW(kki)+0.01;
                tempTestCW_Enh = test_firing_rate{1}(kki,:)>Sample_FR_mean_CW;
                tempTestCW_Sup = (test_firing_rate{2}(kki,:)<Sample_FR_mean_CW).*(test_firing_rate{2}(kki,:)>0);
                tempTestCCW_Enh = test_firing_rate{3}(kki,:)>Sample_FR_mean_CCW;
                tempTestCCW_Sup = (test_firing_rate{4}(kki,:)<Sample_FR_mean_CCW).*(test_firing_rate{4}(kki,:)>0);
                tempX = [tempX;tempTestCW_Enh;tempTestCW_Sup;tempTestCCW_Enh;tempTestCCW_Sup];    
            
            end
            %% add coupling if necessary
            if coupling == 1
                tempX = get_NMF(tempX, Y, kki, 1);
            end
            
            tempX = zscore(tempX')'; % zscore
            
            %% run full and partial model
            try
                tempout = run_full_model(master_list{kki}, master_idx(kki, 2), master_idx(kki, 1), numLambda, nCV, tempX', yt);
                disp([master_list{kki} ' finish full model']);

                [tempout, caughterror] = run_partial_model(tempout, tempX', yt, numLambda, nCV, taskfactor); % run partial model and LLR
                disp([master_list{kki} ' finish partial model']);
                tempout.saveloc = [directory,anm,filesep,'GLM_plots',filesep,'plots',saved_day,filesep];
                %% store results
                wreg2{kki} = tempout.wreg2;
                stats2{kki} = tempout.stats2;
                b0{kki} = tempout.b0;
                w{kki} = tempout.w;
                lam{kki} =  tempout.lam;
                %LAM{kki} =  tempout.LAM;
                spk_neuron{kki} = tempout.spk_neuron;
                wreg1{kki} = tempout.wreg1;
                stats1{kki} = tempout.stats1;
                dev2{kki} = tempout.dev2;
                dev1{kki} = tempout.dev1;
                dAIC{kki} = tempout.dAIC;
                pval{kki} = tempout.pval;
                
                if plotfigure == 1 && ~caughterror
                    align_to = 'direction_1_time';
                    plot_GLM_fit(tempout,trial_info, select_covariates, taskfactor, align_to);
                    disp([master_list{kki} ' finish full plot']);
                elseif plotfigure == 1
                    align_to = 'direction_1_time';
                    plot_GLM_fit_wo_partial(tempout,trial_info, select_covariates, taskfactor, align_to);
                    disp([master_list{kki} ' finish partial plot']);

                end
                disp([master_list{kki} ' successful']);
            catch
                display(['error with' master_list{kki}]);
                Area{kki} =  [];
                NrnNum{kki} = [];
                cellid{kki} =  [];
                wreg2{kki} = [];
                stats2{kki} = [];
                b0{kki} = [];
                w{kki} = [];
                lam{kki} = [];
                %                LAM{kki} =  [];
                spk_neuron{kki} = [];
                wreg1{kki} = [];
                stats1{kki} = [];
                dev2{kki} = [];
                dev1{kki} = [];
                dAIC{kki} = [];
                pval{kki} = [];
            end
            
            
            
        end
    end
end

toc

%% output values
for counter = 1:length(wreg2)
    
    out{counter}.wreg2  = wreg2{counter};
    out{counter}.stats2 = stats2{counter};
    out{counter}.Area = Area{counter};
    out{counter}.NrnNum = NrnNum{counter};
    out{counter}.cellid = cellid{counter};
    out{counter}.b0 = b0{counter};
    out{counter}.w = w{counter};
    out{counter}.lam = lam{counter};
    %out{counter}.LAM = LAM{counter};
    out{counter}.spk_neuron = spk_neuron{counter};
    out{counter}.wreg1 = wreg1{counter};
    out{counter}.stats1 = stats1{counter};
    out{counter}.dev2 = dev2{counter};
    out{counter}.dev1 = dev1{counter};
    out{counter}.dAIC = dAIC{counter};
    out{counter}.pval = pval{counter};
    
end

%%

save([directory anm, filesep,'GLM_' session saved_day '.mat'] ,'out', 'all_covariates', 'select_covariates', 'covariates_subidx', 'taskfactor','bigStruct');
% save([directory anm, '\GLM_' session] ,'covariates','taskfactor','-append');

end


