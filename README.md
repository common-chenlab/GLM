# GLM_chen_lab
create your own copy of define_covariate_factor_idx for your project


User Manual:
1. run_GLM_session(directory, anm, session, plotfigure, ROI_list,Project,includeWhisker,denoise,plot_whiskers,coupling,enhsup)
    
    'directory/anm/session': directory for raw data
    ROI_list: leave it empty if you don't have specific neurons to cover, or {'jc105-19-A1-0145','jc105-19-A1-0109'}
    Project = 'Connectomics';% find TODO Project and add your project and your define_covariate_factor_idx
    includeWhisker = 0; % 1 if you have whisker data
    coupling = 0; %1 if you want include coupling, ref Cameron's paper(Dense functional and molecular readout of a circuit hub in sensory cortex)
    denoise = 1; %1 if your raw data has been preprocessed by the deepinterpolation
    plot_whiskers = 0;
    enhsup =  0;  %only 1 if your data has a enhance suppression case, ref Cameron's paper(Context dependent sensory processing across primary and secondary  
    somatosensory cortex)
    
