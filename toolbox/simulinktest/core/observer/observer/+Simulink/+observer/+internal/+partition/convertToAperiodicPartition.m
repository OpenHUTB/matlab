function convertToAperiodicPartition(subsystemH)



    obsModel=bdroot(subsystemH);
    aperiodicSubsys=Simulink.findBlocks(obsModel,...
    "BlockType","SubSystem","ScheduleAs","Aperiodic partition");


    obsModel=get_param(bdroot(subsystemH),"Name");
    if get_param(obsModel,"SolverType")=="Fixed-step"
        set_param(obsModel,"EnableMultiTasking","on");
    end

    partitionName=getUniquePartitionName(aperiodicSubsys);
    set_param(subsystemH,"ScheduleAs","Aperiodic partition",...
    "TreatAsAtomicUnit","on","PartitionName",partitionName);

    setPartitionPosition(subsystemH);
end

function setPartitionPosition(aperiodicH)
    pos=get_param(aperiodicH,"Position");
    pos=pos+[0,0,110,35];
    set_param(aperiodicH,"Position",pos);
end

function newName=getUniquePartitionName(aperiodicSubsys)

    existingNames=string(get_param(aperiodicSubsys,"PartitionName"));


    TEMPLATE="ConditionalObserverPartition";
    existingNames=[existingNames;TEMPLATE];


    existingNames=matlab.lang.makeUniqueStrings(existingNames);
    newName=existingNames(end);
end
