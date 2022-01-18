function run_GLM_SCC(anm, sessionNo)

if isunix
    ZDRIVE = '/net/claustrum/mnt/data/';
    addpath(genpath('../GLM_chen_lab'))
    
    NUM_CPUS = str2num(getenv('NSLOTS'));
    N = maxNumCompThreads(NUM_CPUS);
    addpath('/net/claustrum/mnt/data/Dropbox/Chen Lab Dropbox/Chen Lab Team Folder/Analysis Suite/PIPELINE/SlackMATLAB/');
    parObj = parpool(NUM_CPUS);
    
elseif ispc
    ZDRIVE = 'Z:/';
    addpath(genpath('D:/Github/GLM_chen_lab'))
    
    addpath('Z:/Dropbox/Dropbox/Chen Lab Team Folder/Analysis Suite/PIPELINE/SlackMATLAB/');
    parObj = gcp;
end

directory = [ZDRIVE '/Dropbox/Chen Lab Dropbox/Chen Lab Team Folder/Projects/Perirhinal/Animals/'];

% anm = 'pr023';

if ~ischar(sessionNo) && ~isstring(sessionNo)
    sessionNo = num2str(sessionNo);
end

% session = 'pr023-9';
session = [anm '-' sessionNo];

plotfigure = 1;

% ROI_list = {'pr023-09-A0-0111','pr023-09-A0-0064','pr023-09-A0-0078','pr023-09-A1-0222'};
ROI_list = {};

Project = 'Perirhinal';
includeWhisker = 0;
coupling = 1;
denoise = 1;
plot_whiskers = 0;
enhsup = 0;


run_GLM_session(directory, anm, session, plotfigure, ROI_list,Project,...
    includeWhisker,denoise,plot_whiskers,coupling,enhsup)

end