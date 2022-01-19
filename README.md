# GLM_chen_lab
create your own copy of define_covariate_factor_idx for your project


User Manual:
1. run_GLM_session(directory, anm, session, plotfigure, ROI_list,Project,includeWhisker,denoise,plot_whiskers,coupling,enhsup)
    
    1. 'directory/anm/session': directory for raw data
    2. ROI_list: leave it empty if you don't have specific neurons to cover, or {'jc105-19-A1-0145','jc105-19-A1-0109'}
    3. Project = 'Connectomics';% find TODO Project and add your project and your define_covariate_factor_idx
    4. includeWhisker = 0; % 1 if you have whisker data
    5. coupling = 0; %1 if you want include coupling, ref Cameron's paper(Dense functional and molecular readout of a circuit hub in sensory cortex)
    6. denoise = 1; %1 if your raw data has been preprocessed by the deepinterpolation
    7. plot_whiskers = 0;
    8. enhsup =  0;  %only 1 if your data has a enhance suppression case, ref Cameron's paper(Context dependent sensory processing across primary and secondary  
    somatosensory cortex)
    
