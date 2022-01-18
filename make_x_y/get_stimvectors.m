function tempstims = get_stimvectors(trial, eventvec)

% 'Stim CW'
% 'Stim CCW'
% 'Cue CW (Pre)';
% 'Cue CW (sample)';
% 'Cue CW (ED)';
% 'Cue CW (LD)';
% 'Cue CW (test)';
% 'Cue CW (report)';
% 'Cue CCW (Pre)';
% 'Cue CCW (sample)';
% 'Cue CCW (ED)';
% 'Cue CCW (LD)';
% 'Cue CCW (test)';
% 'Cue CCW (report)';

is_CW_stim1 = strcmp(trial.direction_1(1:end-3),'CW');
is_CCW_stim1 = strcmp(trial.direction_1(1:end-3),'CCW');
is_CW_stim2 = strcmp(trial.direction_2(1:end-3),'CW');
is_CCW_stim2 = strcmp(trial.direction_2(1:end-3),'CCW');

%define time periods of trial. 
times = find(eventvec);
empty = zeros(1, length(eventvec));
Pre = empty;
Cue = empty;
Early_delay = empty;
Late_delay = empty;
Target = empty;
Report = empty; 

%time-period boxcars
%use eventKey to set these
Pre(times(1):times(3)-1) = 1;
Cue(times(3):times(4)-1) = 1;
Early_delay(times(4):times(6)-1) = 1;
Late_delay(times(6):times(7)-1) = 1;
Target(times(7):times(8)-1) = 1;
Report(times(8):times(9)) = 1;

tempstims = [Cue*is_CW_stim1 + Target*is_CW_stim2;
            Cue*is_CCW_stim1 + Target*is_CCW_stim2;
            Pre*is_CW_stim1;...
            Cue*is_CW_stim1;...
            Early_delay*is_CW_stim1;...
            Late_delay*is_CW_stim1;...
            Target*is_CW_stim1;...
            Report*is_CW_stim1;...
            Pre*is_CCW_stim1;...
            Cue*is_CCW_stim1;...
            Early_delay*is_CCW_stim1;...
            Late_delay*is_CCW_stim1;...
            Target*is_CCW_stim1;...
            Report*is_CCW_stim1];
            
end
            





