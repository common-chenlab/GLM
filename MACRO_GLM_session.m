animals = {'jc105'};
project = 'Connectomics';
directory = ['Z:\Dropbox\Dropbox\Chen Lab Team Folder\Projects\' project '\Animals\'];
plotfigure = 1;
addpath('Z:\Dropbox\Dropbox\Chen Lab Team Folder\Analysis Suite\PIPELINE\SlackMATLAB\');
% selectROIlist = {}; %testing the model
ROI_list = {};
includeWhisker = 0;
denoise = 1;
plot_whiskers = 0;
coupling = 1;
interestfile = {'jc105-7','jc105-19'};
% two sections below: fish  
%% FISH
for i = 1:length(animals)
    anm = animals{i};
    files = dir([directory anm '\' anm '*-*.mat']); %% find all mat files for animal
    load([directory anm '\in vivo ref.mat']); %% get ROIs found in FISH 
    for j = length(ROI_list):-1:1
        if ROI_list(j).linked ~= 1
            ROI_list(j) = [];
        end
    end
    ROI_list = struct2cell(ROI_list);
    ROI_list = ROI_list(1,:,:);    
    ROI_list = permute(ROI_list, [3,1,2]);
    for j = 1:length(files)
                    files(j).name
                     try
                        run_GLM_session(directory, anm, files(j).name, plotfigure, ROI_list, project, includeWhisker,denoise,plot_whiskers,coupling);
                         SendSlackNotification('https://hooks.slack.com/services/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', ...
                             ['GLM complete with ' files(j).name], '#e_pipeline_log');
                     catch
                        disp(['Error with ' files(j).name]);
                         SendSlackNotification('https://hooks.slack.com/services/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', ...
                             ['GLM errors with ' files(j).name], '#e_pipeline_log');
                    end

    end
end

%% Enhance Suppression
for i = 1:length(animals)
    anm = animals{i};
    files = dir([directory anm '\' anm '*-*.mat']); %% find all mat files for animal
    load([directory anm '\in vivo ref.mat']); %% get ROIs found in FISH 
    for j = length(ROI_list):-1:1
        if ROI_list(j).enhsupTest ~= 1
            ROI_list(j) = [];
        end
    end
    ROI_list = struct2cell(ROI_list);
    ROI_list = ROI_list(2,:,:);    
    ROI_list = permute(ROI_list, [3,1,2]);
%     files = files([3,4,14,15]) %18 19 6 7
    files = files([1,3,4,5,11,14,15]) %1 2 3 18 19 6 7
    
    for j = 1:length(files)
        files(j).name                    
                     try
                        run_GLM_session(directory, anm, files(j).name(1:end-4), plotfigure, ROI_list, project, includeWhisker,denoise,plot_whiskers,coupling,1);
                         SendSlackNotification('https://hooks.slack.com/services/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', ...
                             ['GLM complete with ' files(j).name], '#e_pipeline_log');
                     catch
                        disp(['Error with ' files(j).name]);
                         SendSlackNotification('https://hooks.slack.com/services/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', ...
                             ['GLM errors with ' files(j).name], '#e_pipeline_log');
                    end

    end
end

