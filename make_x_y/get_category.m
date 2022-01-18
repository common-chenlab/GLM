function [catvectors] = get_category(trial, eventvec)
 
% 'Cat M (Pre)';
% 'Cat M (sample)';
% 'Cat M (ED)';
% 'Cat M (LD)';
% 'Cat M (test)';
% 'Cat M (report)';
% 'Cat NM (Pre)';
% 'Cat NM (sample)';
% 'Cat NM (ED)';
% 'Cat NM (LD)';
% 'Cat NM (test)';
% 'Cat NM (report)';

is_M = strcmp(trial.direction_1,trial.direction_2);
is_NM = ~strcmp(trial.direction_1,trial.direction_2);

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

catvectors = [Pre*is_M;...
            Cue*is_M;...
            Early_delay*is_M;...
            Late_delay*is_M;...
            Target*is_M;...
            Report*is_M;...
            Pre*is_NM;...
            Cue*is_NM;...
            Early_delay*is_NM;...
            Late_delay*is_NM;...
            Target*is_NM;...
            Report*is_NM];