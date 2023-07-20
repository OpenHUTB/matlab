function ShareMATLABForCoSim()





    load_simulink;
    matlab.engine.shareEngine;
    addpath(fullfile(matlabroot,'toolbox','shared','fmu_share','fmuexport','cosim'));
    addpath(fullfile(matlabroot,'toolbox','shared','fmu_share','obj',['lib',computer('arch')]));

    Simulink.fmuexport.internal.getSetCoSimVar('','IsVisible',true);


    fprintf('%s\n',DAStudio.message('FMUShare:FMU:ShareMATLABForFMUCoSim',matlab.engine.engineName));
end

