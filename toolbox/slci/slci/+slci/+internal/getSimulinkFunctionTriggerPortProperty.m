




function prop=getSimulinkFunctionTriggerPortProperty(fcnSub)
    assert(strcmpi(slci.internal.getSubsystemType(fcnSub),'SimulinkFunction'),...
    'this is not a Simulink Function block');
    opt=Simulink.FindOptions('SearchDepth',1);
    triggers=Simulink.findBlocksOfType(fcnSub.Handle,'TriggerPort',opt);
    assert(numel(triggers)==1,['Only 1 trigger port is expected at root level'...
    ,'of Simulink Function Subsystem'])
    prop=slci.SimulinkFunctionTriggerPortProperty(triggers(1));
end
