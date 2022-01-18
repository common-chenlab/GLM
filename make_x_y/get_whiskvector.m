function tempwhisks = get_whiskvector(whisker_dat, summary, trialnum, Ca_offset, timevec)
    
%     'W touch on';
%     'W touch off';
%     'W angle';
%     'W recon';
%     'W phase';
%     'W amp';
%     'W setpt';
%     'W curve change';



    samps = length(timevec);

    whiskSampRate = 500; % Sampling rate of whisker data, Hz
    lpcutoff = 15; % Hz, cutoff for lowpass whisker filter
    w_lp = lpcutoff*2*pi/whiskSampRate;
    [b_lp,a_lp] = butter(2,w_lp,'low');


tRow_whisk = summary.table{trialnum,14}; %added by cam, look in summary table and find CCD index belonging to this trialnum
if (~isempty(tRow_whisk))
    if ~isempty(whisker_dat(tRow_whisk).touch_vector)&& ~isempty(whisker_dat(tRow_whisk).mean_angle)&& ~isempty(whisker_dat(tRow_whisk).mean_curve)
        % Grab relevant data
        touchVec = whisker_dat(tRow_whisk).touch_vector;
        meanAng = whisker_dat(tRow_whisk).mean_angle;
        meanCurve = whisker_dat(tRow_whisk).mean_curve;
        
        % Determine relevant time window
        nWsamps = min([length(touchVec) length(meanAng) length(meanCurve)]); % Number of samples in whisker data (smallest of the three)
        whiskTimevec_O = (0:nWsamps-1)./whiskSampRate * 1000 - Ca_offset; % Time in ms, beginning at behavior start, relative to 2P start
        whiskTimeSamps = [find(whiskTimevec_O<0,1,'last') find(whiskTimevec_O>=0 & whiskTimevec_O<=max(timevec))]; % Indices for samples within relevant range (decided by timevec)
        whiskTimevec = whiskTimevec_O(whiskTimeSamps);
        
        % Downsample relevant touch data
        touchVec = touchVec(whiskTimeSamps);
        touch_ds = [touchVec(1) zeros(1,samps-1)]; % Pre-allocate downsampled touch vector
        for dsi = 2:samps
            touch_ds(dsi) = any(touchVec(whiskTimevec>=timevec(dsi-1) & whiskTimevec<timevec(dsi))); % If whisker touched during time bin, record 1
        end
        all_whisker_touch = single(touch_ds);
        
        % Downsample relevant whisking data
        meanAng = meanAng(whiskTimeSamps); % Get relevant whisking data
        meanCurve = meanCurve(whiskTimeSamps);
        
        % meanAng may have NaN, which is a problem for filtering & GLM
        tf1 = isnan(meanAng);
        maxConsNaNs1 = maxConsecutive(tf1);
        
        
        ConsNaN_Limit = 200; % Limit of consecutive NaNs before ignoring whisker data
        NaN_Limit1 = 0.25*numel(meanAng); % Limit of total NaNs before ignoring whisker data
        
        if sum(tf1) < NaN_Limit1 && maxConsNaNs1 < ConsNaN_Limit
            ix1 = 1:numel(meanAng);
            meanAng(tf1) = interp1(ix1(~tf1),meanAng(~tf1),ix1(tf1)); % Interpolate NaNs
            meanAng(find(isnan(meanAng))) = nanmean(meanAng);  %% temporary added by Jerry.
            
            meanCurve(tf1) = interp1(ix1(~tf1),meanCurve(~tf1),ix1(tf1)); % Interpolate NaNs
            meanCurve(find(isnan(meanCurve))) = nanmean(meanCurve);  %% temporary added by Jerry.
            
            % Low-pass filter the meanAngle signal for Hilbert
            meanAng = filtfilt(b_lp,a_lp,meanAng);
            
            % Find phase, set point, and amplitude using Hilbert transform
            bp = [4 20]; % bandpass filter for finding phase
            setpt_func = inline( '(max(x) + min (x)) / 2');
            amp_func  = @range ;
            
            phase = phase_from_hilbert( meanAng, whiskSampRate, bp );
            [amp,tops] = get_slow_var(meanAng, phase, amp_func );
            
            try
                amp = amp - nanmean(amp(1:500));
            catch
            end
            
            setpt = get_slow_var(meanAng, phase, setpt_func );
            reconstruction = setpt + (amp/2).*cos(phase);
            
            % Prea-allocate vectors for filtered whisker signal,
            % reconstruction, phase, setpoint, and amplitude vectors
            ang_ds = [meanAng(1) zeros(1,samps-1)];
            rec_ds = [reconstruction(1) zeros(1,samps-1)];
            phase_ds = [phase(1) zeros(1,samps-1)];
            amp_ds = [amp(1) zeros(1,samps-1)];
            setpt_ds = [setpt(1) zeros(1,samps-1)];
            
            %% moving average
            meanAng = movmean(meanAng,20);
            reconstruction = movmean(reconstruction,20);
            phase = movmean(phase, 8);
            amp = movmean(amp,20);
            setpt = movmean(setpt,20);
            
            for dsi = 2:samps
                ds_samp = find(whiskTimevec<=timevec(dsi),1,'last'); % Flexible downsampling: grab data point from nearest time before each point in timevec
                ang_ds(dsi) = meanAng(ds_samp);
                rec_ds(dsi) = reconstruction(ds_samp);
                phase_ds(dsi) = phase(ds_samp);
                amp_ds(dsi) = amp(ds_samp);
                setpt_ds(dsi) = setpt(ds_samp);
            end
            

            
            whisker_angle = single(ang_ds);
            whisk_reconstruction = single(rec_ds);
            whisk_phase = single(phase_ds);
            whisk_amp = single(amp_ds);
            whisk_setpt = single(setpt_ds);
        else
            tempwhisks = [];
        end
        
        %Calculate change in whisker curvature
        perc = .2; %percentage of timepoints (in native sampling rate) to include in calculation of baseline/initial value for delta curvature calculations
        
        curve_init = nanmean(meanCurve(1:floor(perc*length(meanCurve))));
        deltaCurve = (meanCurve - curve_init)/abs(curve_init);
        
        for dsi = 2:samps
            ds_samp = find(whiskTimevec<=timevec(dsi),1,'last'); % Flexible downsampling: grab data point from nearest time before each point in timevec
            curve_ds(dsi) = meanCurve(ds_samp);
            delta_curve_ds(dsi) = deltaCurve(ds_samp);
        end
        curve = single(curve_ds);
        delta_curve = single(delta_curve_ds);
        [Onset, Offset] = getOnsetOffset(all_whisker_touch, 5);
        
        
        
        
        
        
        
    end
end

%     'W touch on';
%     'W touch off';
%     'W angle';
%     'W recon';
%     'W phase';
%     'W amp';
%     'W setpt';
%     'W curve change';
tempwhisks = [Onset;...
            Offset;...
            whisker_angle;...
            whisk_reconstruction;...
            whisk_phase;...
            whisk_amp;...
            whisk_setpt;...
            delta_curve];
end
%%

function [Onset, Offset] = getOnsetOffset(trial, window_length)
    
    %take a trial of whisker touch events and finds touch onset/offset
    %times, then creates covariates for each of these represented as a
    %boxcar with length window_length.
    
    changepoints = ischange(trial);
    Onset = zeros(1,length(trial));
    Offset = Onset;
    
    times = find(changepoints);
    
    Onset(times(1:2:end)) = 1;
    Offset(times(2:2:end)) = 1;
    
    if ~isempty(find(Onset,1))
        for i = find(Onset)
            if i >=window_length/2 && i + window_length/2 < length(trial)
                Onset(logical(i - window_length/2:i + window_length/2)) = 1;
            end
        end
    end
    if ~isempty(find(Offset,1))
        for i = find(Offset)
            if i >=window_length/2 && i + window_length/2 < length(trial)
                Offset(logical(i - window_length/2:i + window_length/2)) = 1;
            end
        end
    end
end