



function featureAvailable=feature_CreateSimulationApp()
    hasSimulinkCompilerLicense=(builtin('license','test','Simulink_Compiler')>0);
    isSimulinkCompilerInstalled=~isempty(ver('simulinkcompiler'));
    featureAvailable=hasSimulinkCompilerLicense&&isSimulinkCompilerInstalled;
end