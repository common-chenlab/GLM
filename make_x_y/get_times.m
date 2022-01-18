function [pre, cue, ed, ld, delay, target, report] = get_times(eventvec, eventKey)
% Get time period boxcars using event vector and key

%use eventKey to define and find start and end of each period
pre_keys = [find(strcmp(eventKey(3,:),'Trial Start')), find(contains(eventKey(3,:),'Direction 1'))];
cue_keys = [find(contains(eventKey(3,:),'Direction 1')), find(strcmp(eventKey(3,:),'Delay'))];
ed_keys = [find(strcmp(eventKey(3,:),'Delay')), find(strcmp(eventKey(3,:),'Delay Present'))];
ld_keys = [find(strcmp(eventKey(3,:),'Delay Present')), find(contains(eventKey(3,:),'Direction 2'))];
delay_keys = [find(strcmp(eventKey(3,:),'Delay')), find(contains(eventKey(3,:),'Direction 2'))];
target_keys = [find(contains(eventKey(3,:),'Direction 2')), find(strcmp(eventKey(3,:),'Report'))];

% Defining Report period is different. Can last from beginning of report
% period to Reward if present or Withdraw otherwise
if ~isempty(find(eventvec==find(strcmp(eventKey(3,:),'Reward')),1))
    report_keys = [find(strcmp(eventKey(3,:),'Report')), find(strcmp(eventKey(3,:),'Reward'))];
else
    report_keys = [find(strcmp(eventKey(3,:),'Report')), find(strcmp(eventKey(3,:),'Withdraw'))];
end

if length(report_keys) == 1
    disp('Empty Report Period')
end

pre = build_time_boxcar(eventvec, pre_keys);
cue = build_time_boxcar(eventvec, cue_keys);
ed = build_time_boxcar(eventvec, ed_keys);
ld = build_time_boxcar(eventvec, ld_keys);
delay = build_time_boxcar(eventvec, delay_keys);
target = build_time_boxcar(eventvec, target_keys);
report = build_time_boxcar(eventvec, report_keys);
end

function outBoxcar = build_time_boxcar(eventvec, keyInds)
% Use key indices to build a time period boxcar based on eventvec

% Pre-allocate to all zeroes
outBoxcar = zeros(1,length(eventvec));

% If there is a start and end index, fill the time period with ones
if length(keyInds) == 2
    outBoxcar(find(eventvec == keyInds(1)):find(eventvec == keyInds(2))-1)=1;
end
end