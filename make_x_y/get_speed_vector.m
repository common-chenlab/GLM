function tempspeed = get_speed_vector(trial, eventvec, eventKey)
% 'Speed'
% 'Cue Speed  (Pre)';
% 'Cue Speed  (sample)';
% 'Cue Speed  (ED)';
% 'Cue Speed  (LD)';
% 'Cue Speed  (test)';
% 'Cue Speed  (report)';


issample20 = contains(trial.direction_1,'20')*20;
istest20 = contains(trial.direction_2,'20')*20;
issample40 = contains(trial.direction_1,'40')*40;
istest40 = contains(trial.direction_2,'40')*40;

[Pre, Cue, Early_delay, Late_delay, ~, Target, Report] = get_times(eventvec, eventKey);

tempspeed= [Cue*issample20+Cue*issample40 + Target*istest20+Target*istest40;...
            Pre*issample40+Pre*issample20;...
            Cue*issample40+Cue*issample20;...
            Early_delay*issample40+Early_delay*issample20;...
            Late_delay*issample40+Late_delay*issample20;...
            Target*issample40+Target*issample20;...
            Report*issample40+Report*issample20];

end