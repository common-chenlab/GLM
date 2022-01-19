directory = 'Z:\Dropbox\Dropbox\Chen Lab Team Folder\Projects\Connectomics\Animals\'; %directory to your dataset
anm = 'jc105';
session = 'jc105-19';
plotfigure = 1;
ROI_list = {'jc105-19-A1-0145','jc105-19-A1-0109'};
Project = 'Connectomics';
includeWhisker = 0;
coupling = 0;
denoise = 1;
plot_whiskers = 0;
enhsup =  0;
run_GLM_session(directory, anm, session, plotfigure, ROI_list,Project,includeWhisker,denoise,plot_whiskers,coupling,enhsup)


