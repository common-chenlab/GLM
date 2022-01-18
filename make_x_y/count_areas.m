function  [ROI_list_Ca1, ROI_list_Ca2, areano, cal, cal2, matlist, cal2_matfiles] = count_areas(D,denoise)


summary = D.summary;
ROI_list_Ca1 = {};
ROI_list_Ca2 = {};


% counter number of areas
areano = 0;

if isfield(D,'CaA0')
    cal = D.CaA0;
    if denoise
        ROI_list_Ca1 = cal.cellid_REF;
    else
        ROI_list_Ca1 = cal.cellid;
    end
    areano = 1;
else
    disp('CaA0 not found')
%     return
end

if areano == 0
    if isfield(D,'CaA2')
        cal = D.CaA2;
        if denoise
            ROI_list_Ca1 = cal.cellid_REF;
        else
            ROI_list_Ca1 = cal.cellid;
        end
        areano = 1;
    elseif isfield(D,'CaA1')
        cal = D.CaA1;
        if denoise
            ROI_list_Ca1 = cal.cellid_REF;
        else
            ROI_list_Ca1 = cal.cellid;
        end
        areano = 1;
    else
        disp('Second area (CaA1 or CaA2) not found')
        %     return
    end
else    
    if isfield(D,'CaA2')
        cal2 = D.CaA2;
        if denoise
            ROI_list_Ca2 = cal2.cellid_REF;
        else
            ROI_list_Ca2 = cal2.cellid;
        end
        areano = 2;
    elseif isfield(D,'CaA1')
        cal2 = D.CaA1;
        if denoise
            ROI_list_Ca2 = cal2.cellid_REF;
        else
            ROI_list_Ca2 = cal2.cellid;
        end
        areano = 2;
    else
        disp('Second area (CaA1 or CaA2) not found')
        %     return
    end
end


matlist = summary.table(:,contains(summary.table(1,:),'A0_Name'));
for i = 1:length(matlist)
    if isempty(matlist{i}) == 1
        matlist{i} = '';
    end
end
if areano == 2
    % Make second calcium trial info more useful (as a single struct)
    cal2_ti = struct('motion_metric',[],'time_stamp',[],'fileloc',[],'mat_file',[]);
    for struct_ind = 1:length(cal2.trial_info)
        cal2_ti(struct_ind) = cal2.trial_info{struct_ind};
    end
    % Make a list of mat files in second calcium dataset
    cal2_matfiles = {cal2_ti.mat_file}';
    for i = 1:length(cal2_matfiles)
        if isempty(cal2_matfiles{i}) == 1
            cal2_matfiles{i} = 'empty';
        end
    end
end

