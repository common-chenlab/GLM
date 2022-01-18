function [eventTiming] = generateEventVector(timeVector,trialInfo,eventList,offset)
% Generates a vector containing zeros and numbers which represent events
% aligned with timeVector
% timeVector: Timing (ms) of each sample from experiment start
% trialInfo: Struct for trial of interest with time stamps for events
% eventList: Cell containing fields to extract from trialInfo in row 1 and
%              number representing each event in row 2
% offset: Timing difference between imaging start and trial start

eventTiming = zeros(1,length(timeVector));

for eventNo = 1:length(eventList)
    event = eventList{1,eventNo};
    
    if isfield(trialInfo,event)
        timestamp = trialInfo.(event) - offset;
        eInd = find(timeVector<timestamp,1,'last');
        eventTiming(eInd) = eventNo;
    elseif strcmp(event,'begin')
        eventTiming(1) = eventNo;
    end
end
end