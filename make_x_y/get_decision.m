function tempdecs = get_decision(trial, eventvec)

% 'Dec Lick (Pre)';
% 'Dec Lick (Stim)';
% 'Dec Lick (ED)';
% 'Dec Lick (LD)';
% 'Dec Lick (test)';
% 'Dec Lick (report)';
% 'Dec No Lick (Pre)';
% 'Dec No Lick (Stim)';
% 'Dec No Lick (ED)';
% 'Dec No Lick (LD)';
% 'Dec No Lick (test)';
% 'Dec No Lick (report)';

is_Lick = strcmp(trial.decision,'Hit')|strcmp(trial.decision,'FA');
is_No_lick = strcmp(trial.decision,'Miss')|strcmp(trial.decision,'CR');

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
Pre(times(1):times(3)-1) = 1;
Cue(times(3):times(4)-1) = 1;
Early_delay(times(4):times(6)-1) = 1;
Late_delay(times(6):times(7)-1) = 1;
Target(times(7):times(8)-1) = 1;
Report(times(8):times(9)) = 1;

tempdecs = [Pre*is_Lick;...
            Cue*is_Lick;...
            Early_delay*is_Lick;...
            Late_delay*is_Lick;...
            Target*is_Lick;...
            Report*is_Lick;...
            Pre*is_No_lick;...
            Cue*is_No_lick;...
            Early_delay*is_No_lick;...
            Late_delay*is_No_lick;...
            Target*is_No_lick;...
            Report*is_No_lick];