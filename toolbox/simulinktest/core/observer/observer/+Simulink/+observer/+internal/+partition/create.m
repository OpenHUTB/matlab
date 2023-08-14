function aperiodicH=create(obsPort)



    obsModel=bdroot(obsPort);
    obsModel=string(get_param(obsModel,"Name"));
    aperiodicH=createSubsystem(obsModel);

    Simulink.observer.internal.partition.convertToAperiodicPartition(aperiodicH);
end

function subsystemH=createSubsystem(obsModel)
    pos=getMaxPos(obsModel);


    subsystemH=add_block("simulink/Commonly Used Blocks/Subsystem",obsModel+"/Partition",...
    "MakeNameUnique","on","Position",pos);


    Simulink.SubSystem.deleteContents(subsystemH);
end

function pos=getMaxPos(obsModel)

    f=Simulink.FindOptions("SearchDepth",1);
    topBlocks=Simulink.findBlocks(obsModel,f);
    pos=get_param(topBlocks,"Position");
    if iscell(pos)
        pos=cell2mat(pos);
    end
    pos=max(pos)+[0,40,0,40];
end
