# GLM_chen_lab
prerequisite: your matlab has following toolbox:
1. Curve fitting
2. Signal Processing
3. Statistics and Machine Learning

create your own copy of define_covariate_factor_idx for your project

User Manual:
1. clone the codes.
2. copy paste cc034 from [here](https://doi.gin.g-node.org/10.12751/g-node.7q0lz0/) to the same folder as the code
3. unzip cc034-4_whisker.zip
4. run run_GLM_session
    
    inputs in the codes are:
    1. 'directory/anm/session': directory for raw data
    2. ROI_list: leave it empty if you don't have specific neurons to cover, or in this format: {'neuron1','neuron2'}
    3. Project = 'CRACK';% find TODO Project and add your project and your define_covariate_factor_idx
    4. includeWhisker = 0; % 1 if you have whisker data
    5. coupling = 0; %1 if you want include coupling,(ref [Dense functional and molecular readout of a circuit hub in sensory cortex](https://www.science.org/doi/10.1126/science.abl5981))
    6. denoise = 1; %1 if your raw data has been preprocessed by the deepinterpolation
    7. plot_whiskers = 0;
    8. enhsup =  0;  %only 1 if your data has a enhance suppression case, (ref [Context dependent sensory processing across primary and secondary somatosensory cortex](https://www.sciencedirect.com/science/article/pii/S0896627320301033))
    
