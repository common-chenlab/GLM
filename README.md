# GLM_chen_lab
create your own copy of define_covariate_factor_idx for your project

sample: 'define_covariate_factor_idx_CRACK or define_covariate_factor_idx_Connectomics'


User Manual:
1. clone the codes.
2. run demo_GLM -- this is a demo use one connectomics data, estimate running time ~20min
3. run_GLM_session(directory, anm, session, plotfigure, ROI_list,Project,includeWhisker,denoise,plot_whiskers,coupling,enhsup) -- customize for your own dataset
    
    1. 'directory/anm/session': directory for raw data
    2. ROI_list: leave it empty if you don't have specific neurons to cover, or in this format: {'neuron1','neuron2'}
    3. Project = 'CRACK';% find TODO Project and add your project and your define_covariate_factor_idx
    4. includeWhisker = 0; % 1 if you have whisker data
    5. coupling = 0; %1 if you want include coupling,(ref [Dense functional and molecular readout of a circuit hub in sensory cortex](https://www.science.org/doi/10.1126/science.abl5981))
    6. denoise = 1; %1 if your raw data has been preprocessed by the deepinterpolation
    7. plot_whiskers = 0;
    8. enhsup =  0;  %only 1 if your data has a enhance suppression case, (ref [Context dependent sensory processing across primary and secondary somatosensory cortex](https://www.sciencedirect.com/science/article/pii/S0896627320301033))
    
