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
                Onset(i - window_length/2:i + window_length/2) = 1;
            end
        end
    end
    if ~isempty(find(Offset,1))
        for i = find(Offset)
            if i >=window_length/2 && i + window_length/2 < length(trial)
                Offset(i - window_length/2:i + window_length/2) = 1;
            end
        end
    end
end


