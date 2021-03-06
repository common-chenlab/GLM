function [bigStruct, Y, X,  ROI_list_Ca1, ROI_list_Ca2, complete_whisker_trials] = make_x_y_backup(anm, datmat, directory, includeWhisker)
% this is a backup function, this function works well with Cameron's cc
% data. (deconv not deconv_REF)
% David Lee
% Last update: 6/17/19

% Change log:

%12/17/19 - cam - added CCD_idx check to account for missing CCD files 
%12/10/19 - CAM added delta_curve and curve fields to bigStruct, added output
% variable 'complete whisker trials' that contains the trial numbers of all
% trials with complete whisker data.

% 6/17/19 - Removed extra code for adding time-shifted feature vectors; old
% code is now generateCovariates_defshift.m
% 6/17/19 - Added Hilbert transform to extract phase, amplitude, and set
% point from whisker data; includeWhisker by default if .mat file exists
% 6/14/19 - Added code to determine if whisker data has too many NaNs or
% too many consecutive NaNs and ignore the data
% 6/11/19 - Added eventKey, generateEventVector, and includeWhisker option
% 6/10/19 - Implemented lick vector and whisker data import
% tic

% Name of file to import & parse

%functions path
addpath('Z:\Dropbox\Chen Lab Dropbox\Chen Lab Team Folder\Projects\CRACK\software\e_GLM-1\Generate Covariates')

if nargin == 0
    anm = 'cc034';
    datmat = 'cc034-6.mat';
    directory = 'Z:\Dropbox\Dropbox\Chen Lab Team Folder\Projects\CRACK\Animals\';
end

D = load([directory anm filesep datmat]);
trials = D.trials;
summary = D.summary;

%% check data structure
if isfield(D,'licks')
    licks = D.licks;
    lick_exist = 1;
else
    lick_exist = 0;
end

[ROI_list_Ca1, ROI_list_Ca2, areano, cal, cal2, matlist, cal2_matfiles] = count_areas(D);

if contains(datmat,'.mat')
    datmat = datmat(1:end-4);
end

wdatmat = [datmat '_whisker.mat'];
wdatmat = [directory anm filesep wdatmat];

if exist(wdatmat,'file') == 2 && includeWhisker
    whiskerdat_available = 1;
    W = load(wdatmat);
    whisker_dat = W.whisker_dat;
else
    whiskerdat_available = 0;
    W = [];
end

minlen = 0;
samprate = cal.sampling_rate;


%% -----------------------------------------------------------

% Do not edit
% Used for adjusting which window of data to select
bigStruct = struct('trialID', [], 'Ca1_spikes',[],'Ca2_spikes',[],'timevec',[],...
    'stim1',[],'stim2',[],'CW',[],'CCW',[],'match',[],'nonmatch',[],...
    'response_HFCM', []);
%     'def_shift',def_shift);

% Events and numbers referring to each event (used in timevec)
eventKey = {'begin','present_time','direction_1_time',...
    'delay_time','delay_withdraw_time','delay_present_time','direction_2_time',...
    'report_time','reward_time','withdraw_time'};
eKnum = num2cell(1:length(eventKey));
eKdesc = {'Trial Start','Present','Direction 1 Start','Delay',...
    'Delay Withdraw','Delay Present','Direction 2 Start','Report',...
    'Reward','Withdraw'};
bigStruct.eventKey = {eventKey{:}; eKnum{:}; eKdesc{:}};


complete_whisker_trials = [];
bS = 1; % bigStruct index

   
for c1ti = 1:length(cal.trial_info)
    trialName = cal.trial_info{c1ti}.mat_file(4:end-4);
    proceed = 0;
    
    % Proceed if the trial was recorded on both channels
    if areano == 2
        if any(contains(cal2_matfiles,trialName))
            sRow = find(contains(matlist,trialName),1,'last'); % Row in summary table containing trial info
            if isempty(sRow) == 0                
                proceed = 1;
            else
                proceed = 0;
            end
        else
            proceed = 0;
        end
    else        
        sRow = find(contains(matlist,trialName),1,'last'); % Row in summary table containing trial info
        if isempty(sRow) == 0 
            proceed = 1;
        end
    end
    
    %check for complete whisker data if using whisker data, skip trial if not present
    if whiskerdat_available
        try
            CCD_idx = summary.table{sRow,14};
            if ~isempty(CCD_idx)&& ~isempty(whisker_dat(CCD_idx).mean_angle)&&~isempty(whisker_dat(CCD_idx).mean_curve)&&~isempty(whisker_dat(CCD_idx).touch_vector)
                proceed = 1;
            else
                proceed = 0;
            end
        catch
            if isempty(sRow)
                disp('no whisker data for unknown trial')
            else
            disp(['no whisker data for trial ' num2str(summary.table{sRow,1})]);
            end
            proceed = 0;
        end
        
    end
    
    
    
    if proceed == 1
        % Add neuron data
%         Ca1_spikes = cal.deconv_REF{c1ti};
        Ca1_spikes = cal.deconv{c1ti};
        [~, c1col] = size(Ca1_spikes);
        
        if areano == 2
%             Ca2_spikes = cal2.deconv_REF{contains(cal2_matfiles,trialName)};
            Ca2_spikes = cal2.deconv{contains(cal2_matfiles,trialName)};
            [~, c2col] = size(Ca2_spikes);
        else
            c2col = c1col;
        end
        
        % Some calcium data is missing a sample. Alert if more than one is
        % missing; may indicate something is misaligned
        % Also alert if trial is shorter than minimum trial length (samps)
        
        if abs(c1col-c2col) ==0 && c1col >= minlen && c2col >= minlen
            
            % Begin by finding stimulus onset times (used to build feature vectors)
            
            sRow = find(contains(matlist,trialName),1,'last'); % Row in summary table containing trial info
            if isempty(sRow)
                continue
            end
            
            trialnum = summary.table{sRow,1};
            
            % skip the trial that present time happens before the 2p
            % recording
            endtime = trials(trialnum).recording_time;
            Ca_offset = endtime-length(Ca1_spikes(1,:))*1000/samprate; %in ms
            offset_threshold = trials(trialnum).present_time;
            if Ca_offset > offset_threshold
                trialnum
                continue
            end
            
            bigStruct(bS).trialID = uint16(trialnum);
            
            %% build calcium data for trial - NEEDS TO BE UPDATED
            bigStruct(bS).A0_idx = summary.table{sRow,5};           
            bigStruct(bS).trialNameCa1 = cal.trial_info{c1ti}.mat_file;                        
            Ca1 = Ca1_spikes; % Cut off extra samples so all vectors have same length
            bigStruct(bS).Ca1_spikes = single(Ca1);            
     
            if areano == 2
                Ca2 = Ca2_spikes;
                bigStruct(bS).Ca2_spikes = single(Ca2);
                bigStruct(bS).A1_idx = summary.table{sRow,7};                
            end
            
            %% Create time vector - NEEDS TO BE UPDATED
%             record_time_samples = round(trials(trialnum).recording_time/1000*Ca.sampling_rate);
%             timevec = (0:samps-1)/samprate * 1000; % use ms for time unit
            timevec = (0:length(Ca1_spikes(1,:))-1)/samprate * 1000; % use ms for time unit, 2p timvec
%             timevec = Ca_offset:1000/samprate:endtime; % trial timevec
%             timevec = timevec(1:end-1); %trial timevec
            eventvec = generateEventVector(timevec,trials(trialnum),bigStruct(1).eventKey,Ca_offset);
            bigStruct(bS).timevec = single([timevec;eventvec]);
            
            %% build X matrix for each trial
                       
            tempX = [];            
            tempstims = get_stimvectors(trials(trialnum), eventvec); tempX = [tempX; tempstims];  % create stim matrix
            tempcats = get_category(trials(trialnum),eventvec); tempX = [tempX; tempcats]; % create category matrix
            tempdecs = get_decision(trials(trialnum),eventvec); tempX = [tempX; tempdecs]; % create decision matrix
                        
            if lick_exist  % create lick vector
                templicks = get_lickvector(licks, trialnum, Ca_offset, timevec); tempX = [tempX; templicks];
            end
            
            if whiskerdat_available % create whisker data / touch onset offset if available
                tempwhisks = get_whiskvector(whisker_dat, summary, sRow, Ca_offset, timevec); tempX = [tempX; tempwhisks];
            end
            
            bigStruct(bS).X = tempX; % store X matrix for trial
            bS = bS + 1;  % Increment structure index
            
           
        elseif c1col < minlen || c2col < minlen  % Make a note and skip the data if more than one sample is missing
            disp(['Ignoring Trial ' num2str(c1ti) '. Trial is too short.'])
        else
            disp(['Large discrepancy in F_dF size, ignoring trial: ' trialName])
            disp(['Ca1: ' num2str(c1col) '; Ca2: ' num2str(c2col)])
            disp(' ')        
        end
        % Make a note if a trial is missing in the second calcium dataset
    else
        str = ['Note: ' trialName ' does not exist in cal2'];
        disp(str)
        disp(' ')
    end
end

%% make bigX and bigY
X = [];
Y = [];
for i = 1:length(bigStruct)
    X = [X, bigStruct(i).X];
    temp = bigStruct(i).Ca1_spikes;
    if areano == 2
        temp = [temp; bigStruct(i).Ca2_spikes];
    end
    Y = [Y, temp];
end






