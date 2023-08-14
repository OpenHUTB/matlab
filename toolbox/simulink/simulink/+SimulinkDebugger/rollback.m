function rollback(mdl,modelHandle)








    slInternal('sldebug',mdl,'setIsRollingBack',true);
    revert=onCleanup(@()slInternal('sldebug',mdl,'setIsRollingBack',false));

    Simulink.SimulationStepper(mdl).forward();


    numSteps=get_param(mdl,'NumberOfSteps');
    ocSteps=onCleanup(@()set_param(mdl,'NumberOfSteps',numSteps));
    set_param(mdl,'NumberOfSteps',1);
    rollbackStr=['Simulink.SimulationStepper('''...
    ,mdl...
    ,''').rollback()'];
    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,rollbackStr);
end


