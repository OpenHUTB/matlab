function standalone_open_system(model,~)




    modelInterface=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
    modelInterface.initializeForDeployment();
    modelInterface.debugLog(2,['open_system(''',model,''') called ']);
end
