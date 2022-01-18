function tempTouch = get_touchtimes(eventvec, eventKey, samprate)
% Get time period boxcars using event vector and key

withdrawTime = round(samprate * 0.6); % withdrawing 1.5cm takes 600ms, convert to samples

%use eventKey to define and find start and end of each period
touch_on_keys = [find(strcmp(eventKey(3,:),'Present')), find(contains(eventKey(3,:),'Direction 1'))];

% If trial begins after Present, make the first time point == Present
if isempty(find(eventvec==find(strcmp(eventKey(3,:),'Present')),1))
    eventvec(1) = find(strcmp(eventKey(3,:),'Present'));
end

% If delay present is present, then add another set of keys for touch onset
if ~isempty(find(eventvec==find(strcmp(eventKey(3,:),'Delay Present')),1))
    d2_touch_on_keys = [find(strcmp(eventKey(3,:),'Delay Present')), find(contains(eventKey(3,:),'Direction 2'))];
    touch_on_keys = [touch_on_keys; d2_touch_on_keys];
end

% Defining touch offset - in case trimming removed within 600ms of end
% withdraw, touch offset becomes Withdraw to End of eventvec
end_withdraw_ind = find(strcmp(eventKey(3,:),'Withdraw'));
touch_off_keys = end_withdraw_ind;

% If delay withdraw is present, then add another set of keys for touch
% offset after D1

if ~isempty(find(eventvec==find(strcmp(eventKey(3,:),'Delay Withdraw')),1))
    delay_withdraw_ind = find(strcmp(eventKey(3,:),'Delay Withdraw'));
    d1_touch_off_keys = [delay_withdraw_ind, delay_withdraw_ind + withdrawTime];
    touch_off_keys = [touch_off_keys; d1_touch_off_keys];
end

touch_on = build_time_boxcar(eventvec, touch_on_keys);
touch_off = build_offset_boxcar(eventvec, touch_off_keys, withdrawTime);

tempTouch = [touch_on;...
    touch_off;...
    ];
end

function outBoxcar = build_time_boxcar(eventvec, keyInds)
% Use key indices to build a time period boxcar based on eventvec

% Pre-allocate to all zeroes
outBoxcar = zeros(1,length(eventvec));

% If there is a start and end index, fill the time period with ones
for rN = 1:size(keyInds,1)
    outBoxcar(find(eventvec == keyInds(rN,1)):find(eventvec == keyInds(rN,2))-1)=1;
end
end

function outBoxcar = build_offset_boxcar(eventvec, keyInds, withdrawTime)
outBoxcar = zeros(1,length(eventvec));

for rN = 1:size(keyInds,1)
    withdrawStart = find(eventvec == keyInds(rN,1));
    
    withdrawEnd = withdrawStart + withdrawTime;
    
    if withdrawEnd > length(eventvec)
        withdrawEnd = length(eventvec);
    end
    
    outBoxcar(withdrawStart:withdrawEnd) = 1;
end
end
