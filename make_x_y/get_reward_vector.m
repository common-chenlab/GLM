function tempreward=get_reward_vector(trial, timevec,offset)
tempreward = zeros(1, length(timevec));

is_reward = 1-isnan(trial.reward_time);
%define time periods of trial.
if is_reward
    Ind = find(timevec<trial.reward_time - offset,1,'last');
    tempreward(Ind-2:Ind+2) = 1;
end
    

end