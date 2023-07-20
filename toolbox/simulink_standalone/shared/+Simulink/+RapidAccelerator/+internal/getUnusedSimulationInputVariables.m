function unusedVars=getUnusedSimulationInputVariables(simInput,rtp)
    rtpVars=Simulink.RapidAccelerator.internal.getVariablesFromRTP(rtp);
    nonRTPVars=locGetNonRTPVariables(simInput);


    allVars=string([rtpVars,nonRTPVars]);
    simInputVars=string({simInput.Variables.Name});
    unusedVars=setdiff(simInputVars,allVars);
end


function nonRTPVars=locGetNonRTPVariables(simInput)
    nonRTPVars=Simulink.RapidAccelerator.internal.getVariablesFromModelParameters(simInput);
end