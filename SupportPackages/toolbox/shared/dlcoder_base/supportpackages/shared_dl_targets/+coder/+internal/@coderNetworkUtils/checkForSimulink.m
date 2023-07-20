function checkForSimulink



    coder.allowpcode('plain');
    if coder.target('sfun')
        checkCppTargetForSimulinkSimulation();
    end
end
