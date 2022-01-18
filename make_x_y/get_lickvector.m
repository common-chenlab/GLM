function templicks = get_lickvector(licks, trialnum, Ca_offset, timevec)

samps = length(timevec);

lick_ind = find([licks(:).trial] == trialnum); % Index in licks struct for trial of interest
if ~isempty(lick_ind)
    lick_ind = lick_ind(1);
    lickvec = licks(lick_ind).lick_vector(1,:); % Binary lick vector
    lto = licks(lick_ind).lick_vector(2,:) * 1000 - Ca_offset; % Timestamps to ms & time-shifted
    
    lickTimeSamps = [find(lto<0,1,'last') find(lto>=0 & lto<=max(timevec))]; % Find samples within time range and one before t=0 for binning
    lt = lto(lickTimeSamps); % Lick time vector
    lickvec = lickvec(lickTimeSamps);
    lickvec_ds = zeros(1,samps); % Downsampled lick vector
    
    % If any licks occurred in time bin, consider as one lick
    lickvec_ds(1) = sum(lickvec(lt<=0));
for dsi = 2:samps
    lickvec_ds(dsi) = sum(lickvec(lt>timevec(dsi-1) & lt<=(timevec(dsi))));
end
else
    lickvec_ds = zeros(1,samps);
end

templicks = single(lickvec_ds);