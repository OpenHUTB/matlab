
function[lBuildConfiguration,lCustomToolchainOptions]=...
    getCompileConfigurationForSim(cs)









    switch get_param(cs,'SimCompilerOptimization')
    case 'off'
        lBuildConfiguration='Faster Builds';
    case 'on'
        lBuildConfiguration='Faster Runs';
    end
    lCustomToolchainOptions={};

