function [bigStruct, Y, X,  ROI_list_Ca1, ROI_list_Ca2, trial_info,test_firing_rate] = make_x_y(anm, datmat, directory, includeWhisker,denoise)
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
    includeWhisker = 1;
    denoise = 0;
%     selectROIlist = {};
end
denoise_frameLost = 30; % frame lost before and after, from deeplearning denoisng
D = load([directory anm filesep datmat]);
trials = D.trials;
summary = D.summary;

start_trim = 20; 
end_trim = 40;

if denoise
    start_trim = 0;
    end_trim = 0;
end
%% check data structure
if isfield(D,'licks')
    licks = D.licks;
    lick_exist = 1;
else
    lick_exist = 0;
end

[ROI_list_Ca1, ROI_list_Ca2, areano, cal, cal2, matlist, cal2_matfiles] = count_areas(D,denoise);

% if ~isempty(selectROIlist)
%     TF_Ca1 = matches(ROI_list_Ca1,selectROIlist);
%     TF_Ca2 = matches(ROI_list_Ca2,selectROIlist);
% end


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


bS = 1; % bigStruct index

stack_sample_fr_Ca_CW = [];
stack_sample_fr_Ca_CCW = [];


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
            ConsNaN_Limit = 200;
            NaN_Limit1 = 0.25*numel(whisker_dat(CCD_idx).mean_angle); % Limit of total NaNs before ignoring whisker data
            
            tf1 = isnan(whisker_dat(CCD_idx).mean_angle);
            maxConsNaNs1 = maxConsecutive(tf1);
            if sum(tf1) < NaN_Limit1 && maxConsNaNs1 < ConsNaN_Limit
                proceed = 1;
            else
                disp(['too many NaNs in whisker data for trial: ' num2str(summary.table{sRow,1})]);
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
        if denoise
            Ca1_spikes = cal.deconv_REF{c1ti};
        else
            Ca1_spikes = cal.deconv{c1ti};
        end
        [~, c1col] = size(Ca1_spikes);
        
        if areano == 2
            if denoise
                Ca2_spikes = cal2.deconv_REF{contains(cal2_matfiles,trialName)};
            else
                Ca2_spikes = cal2.deconv{contains(cal2_matfiles,trialName)};
            end
            [~, c2col] = size(Ca2_spikes);
        else
            c2col = c1col;
        end
        
        % Some calcium data is missing a sample. Alert if more than one is
        % missing; may indicate something is misaligned
        % Also alert if trial is shorter than minimum trial length (samps)
        
        if abs(c1col-c2col) <=1 && c1col >= minlen && c2col >= minlen
            
            % Make sure both areas have the same number of samples
            Ca1_spikes = Ca1_spikes(:,1:min([c1col, c2col]));
            Ca2_spikes = Ca2_spikes(:,1:min([c1col, c2col]));
            
            % Begin by finding stimulus onset times (used to build feature vectors)
            
            sRow = find(contains(matlist,trialName),1,'last'); % Row in summary table containing trial info
            if isempty(sRow)
                continue
            end
            
            trialnum = summary.table{sRow,1};
            % skip the trial that present time happens before the 2p
            % recording
            endtime = trials(trialnum).recording_time;
            if denoise
                endtime = endtime-denoise_frameLost/samprate*1000; % in ms, 30 frames before the denoise
            end
            Ca_offset = endtime-length(Ca1_spikes(1,:))*1000/samprate; %in ms (starts of 2p or denois(2p) when trial starts = 0sec

            offset_threshold = trials(trialnum).present_time;
            withdraw_time = trials(trialnum).withdraw_time;
            
            if Ca_offset > offset_threshold | endtime < withdraw_time  %make sure Ca_spike contains present_time and withdraw
                continue
            end
            
            if denoise
                Ca_offset = Ca_offset-denoise_frameLost/samprate*1000; %in ms, 30 frames after the denoise
            end
            

            
            bigStruct(bS).trialID = uint16(trialnum);
            
            %% set up trial type and response vectors for plotting later. 
            %THIS WILL NEED TO BE UPDATED FOR NON DNMS TASKS
            
            %trial types:
            %1 = CW:CW
            %2 = CW:CCW
            %3 = CCW:CW
            %4 = CCW:CCW
            
            %decisions:
            %1 = Hit
            %2 = FA
            %3 = CR
            %4 = Miss
            
            trial_type_key = {'CW:CW', 'CW:CCW', 'CCW:CW', 'CCW:CCW'}; 
            decision_key = {'Hit', 'FA', 'CR', 'Miss'};
            
            stim1 = trials(trialnum).direction_1(1:end-3);
            stim2 = trials(trialnum).direction_2(1:end-3);
            speedmatch = (contains(trials(trialnum).direction_2,'40')&contains(trials(trialnum).direction_1,'40'))|...
                (contains(trials(trialnum).direction_2,'20')&contains(trials(trialnum).direction_1,'20'));
            dec = trials(trialnum).decision;
            tt = [];
            if strcmp(stim1,stim2) && ~contains(stim1, 'CCW')
                tt = 1;
            elseif ~strcmp(stim1,stim2) && ~contains(stim1, 'CCW')
                tt = 2;
            elseif ~strcmp(stim1,stim2) && contains(stim1, 'CCW')
                tt = 3;
            elseif strcmp(stim1,stim2) && contains(stim1, 'CCW')
                tt = 4;
            end
            bigStruct(bS).trialtype = tt;
            
            r = [];
            if strcmp(dec,'Hit')
                r = 1;
            elseif strcmp(dec, 'FA')
                r = 2;
            elseif strcmp(dec, 'CR')
                r = 3;
            elseif strcmp(dec, 'Miss')
                r = 4;
            end
            bigStruct(bS).decision = r;
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
            timevec = (0:length(Ca1_spikes(1,:))-1)/samprate * 1000; % use ms for time unit, 2p timvec
            if denoise
                timevec = timevec+denoise_frameLost/samprate*1000;
            end

            eventvec = generateEventVector(timevec,trials(trialnum),bigStruct(1).eventKey,Ca_offset);
            bigStruct(bS).timevec = single([timevec;eventvec]);
            
            %% save firing rate
            Ca1 = bigStruct(bS).Ca1_spikes;
            times = find(eventvec);
            
            temp_fr_sample = sum(Ca1(:,times(3):times(3)+round(samprate)),2);
            
            if areano == 2
                Ca2 = bigStruct(bS).Ca2_spikes;
                samplefirrateCa2 = sum(Ca2(:,times(3):times(3)+round(samprate)),2);
                temp_fr_sample = [temp_fr_sample;samplefirrateCa2];
            end
            
            if ~contains(stim1, 'CCW')                
                stack_sample_fr_Ca_CW = [stack_sample_fr_Ca_CW,temp_fr_sample];

            else
                stack_sample_fr_Ca_CCW = [stack_sample_fr_Ca_CCW,temp_fr_sample];

            end
            %% build X matrix for each trial - USER DEFINED
                       
            tempX = [];
            tempstims = get_stimvectors(trials(trialnum), eventvec); tempX = [tempX; tempstims];  % create stim matrix
              tempcats = get_category(trials(trialnum),eventvec); tempX = [tempX; tempcats]; % create category matrix
            tempdecs = get_decision(trials(trialnum),eventvec); tempX = [tempX; tempdecs]; % create decision matrix
            
            if lick_exist  % create lick vector
                templicks = get_lickvector(licks, trialnum, Ca_offset, timevec); tempX = [tempX; templicks];
            else
                templicks = NaN*ones(1,length(eventvec)); tempX = [tempX; templicks];
            end
            
            if whiskerdat_available % create whisker data / touch onset offset if available
                tempwhisks = get_whiskvector(whisker_dat, summary, sRow, Ca_offset, timevec); tempX = [tempX; tempwhisks];
            else
                tempwhisks =NaN*ones(8,length(eventvec)); tempX = [tempX; tempwhisks];
            end
            

                        
            tempspeed = get_speed_vector(trials(trialnum),eventvec); tempX = [tempX; tempspeed]; % create speed matrix
            tempreward=get_reward_vector(trials(trialnum),timevec,Ca_offset); tempX = [tempX; tempreward]; % create reward matrix
            
            
            %% build firing rate info + enh/sup as a separate Matrix
            tempTestCW_Enh = [];
            tempTestCW_Sup = [];
            tempTestCCW_Enh = [];
            tempTestCCW_Sup = [];
            [tempTestCW_Enh,tempTestCW_Sup,tempTestCCW_Enh,tempTestCCW_Sup] = get_test_fir(trials(trialnum),eventvec,Ca1,samprate); 
            if areano == 2
                [tempTestCW_Enh1,tempTestCW_Sup1,tempTestCCW_Enh1,tempTestCCW_Sup1] = get_test_fir(trials(trialnum),eventvec,Ca2,samprate); 
                tempTestCW_Enh = [tempTestCW_Enh; tempTestCW_Enh1]; % create enhance and suppression matrix
                tempTestCW_Sup = [tempTestCW_Sup; tempTestCW_Sup1]; % create enhance and suppression matrix
                tempTestCCW_Enh = [tempTestCCW_Enh; tempTestCCW_Enh1]; % create enhance and suppression matrix
                tempTestCCW_Sup = [tempTestCCW_Sup; tempTestCCW_Sup1]; % create enhance and suppression matrix
            end
                %%
            bigStruct(bS).X = tempX; % store X matrix for trial
            bigStruct(bS).FR_test = {tempTestCW_Enh,tempTestCW_Sup,tempTestCCW_Enh,tempTestCCW_Sup};
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
mean_sampe_fr_Ca_CW = mean(stack_sample_fr_Ca_CW,2);
bigStruct(1).Firingrate_Sample_CW = mean_sampe_fr_Ca_CW;
mean_sampe_fr_Ca_CCW = mean(stack_sample_fr_Ca_CCW,2);
bigStruct(1).Firingrate_Sample_CCW = mean_sampe_fr_Ca_CCW;

%% make bigX and bigY
X = [];
Y = [];
test_firing_rate = {[],[],[],[]};
trial_end_indices = [];
trial_type = [];
decision = [];
trial_event_times = {};
for i = 1:length(bigStruct)
    X_temp = [X, bigStruct(i).X(:,start_trim+1:end-end_trim)];
    X = X_temp;
    
    %get index of last time point in each trial for plotting purposes
    if i == 1
        trial_end_indices(i) = size(bigStruct(i).X(:,start_trim+1:end-end_trim),2);
    else
        trial_end_indices(i) = trial_end_indices(i-1) + size(bigStruct(i).X(:,start_trim+1:end-end_trim),2);
    end
    temp = bigStruct(i).Ca1_spikes;
    if areano == 2
        temp = [temp; bigStruct(i).Ca2_spikes];
    end
    Y = [Y, temp(:,start_trim+1:end-end_trim)];
    
    FR_test_temp = bigStruct(i).FR_test;
    
    for covariant = 1:4
        test_firing_rate{covariant} = [test_firing_rate{covariant},FR_test_temp{covariant}];
    end
    
    trial_type(i) = bigStruct(i).trialtype;
    decision(i) = bigStruct(i).decision;
    trial_event_times{i} = bigStruct(i).timevec(2,:);
end

trial_info.type = trial_type;
trial_info.type_key = trial_type_key;
trial_info.end_indices = trial_end_indices;
trial_info.decision = decision;
trial_info.decision_key = decision_key;
trial_info.session = datmat;
trial_info.event_times = trial_event_times;
trial_info.event_key = eventKey;
end



