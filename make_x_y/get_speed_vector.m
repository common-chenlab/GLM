function tempspeed = get_speed_vector(trial, eventvec)
% 'Speed'
% 'Cue Speed  (sample)';
% 'Cue Speed  (ED)';
% 'Cue Speed  (LD)';
% 'Cue Speed  (test)';


issample20 = contains(trial.direction_1,'20')*20;
istest20 = contains(trial.direction_2,'20')*20;
issample40 = contains(trial.direction_1,'40')*40;
istest40 = contains(trial.direction_2,'40')*40;


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

tempspeed= [Cue*issample20+Cue*issample40 + Target*istest20+Target*istest40;...            
            Cue*issample40+Cue*issample20;...
            Early_delay*issample40+Early_delay*issample20;...
            Late_delay*issample40+Late_delay*issample20;...
            Target*issample40+Target*issample20];

end