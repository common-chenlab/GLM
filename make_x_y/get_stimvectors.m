function tempstims = get_stimvectors(trial, eventvec, eventKey)

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

[Pre, Cue, Early_delay, Late_delay, Delay, Target, Report] = get_times(eventvec, eventKey);

tempstims = [Cue*is_CW_stim1 + Target*is_CW_stim2;
            Cue*is_CCW_stim1 + Target*is_CCW_stim2;
            Pre*is_CW_stim1;...
            Cue*is_CW_stim1;...
            Early_delay*is_CW_stim1;...
            Late_delay*is_CW_stim1;...
            Delay*is_CW_stim1;...
            Target*is_CW_stim1;...
            Report*is_CW_stim1;...
            Pre*is_CCW_stim1;...
            Cue*is_CCW_stim1;...
            Early_delay*is_CCW_stim1;...
            Late_delay*is_CCW_stim1;...
            Delay*is_CCW_stim1;...
            Target*is_CCW_stim1;...
            Report*is_CCW_stim1];
            
end
            





