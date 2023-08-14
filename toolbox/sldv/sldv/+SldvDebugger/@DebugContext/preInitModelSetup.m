
function simIn=preInitModelSetup(obj)

    simIn=Simulink.SimulationInput(obj.debugMdl);


    stepSize=obj.getStepSize;
    simIn=simIn.setModelParameter('FixedStep',num2str(stepSize));


    simIn=obj.turnOffDiagnostics(simIn);





    tempState=Simulink.internal.TemporaryModelState(simIn,'EnableConfigSetRefUpdate','on');


    obj.preInitTempState=tempState;
end