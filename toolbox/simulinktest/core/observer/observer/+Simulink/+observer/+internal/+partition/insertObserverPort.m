function insertObserverPort(obsPortH)
    if~isempty(Simulink.observer.internal.partition.getPartitionFromObsPort(obsPortH))
        return;
    end
    Simulink.BlockDiagram.createSubsystem(obsPortH,"Name","Aperiodic",...
    "MakeNameUnique","on");
    subsystem=get_param(obsPortH,"Parent");
    subsystemH=get_param(subsystem,"Handle");
    Simulink.observer.internal.partition.convertToAperiodicPartition(subsystemH);
    terminateObsPortOutput(subsystemH);
end


function terminateObsPortOutput(aperiodicH)
    replBlks=replace_block(aperiodicH,"Outport","Terminator","noprompt");
    assert(isscalar(replBlks));
    set_param(replBlks{1},"Name","Terminator");
end
