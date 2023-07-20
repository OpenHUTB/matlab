function targetsNames=getTargetList()



    if~ispc||~stm.internal.slrealtime.checkxpctarget()
        targetsNames={};
    else
        tgs=slrealtime.Targets;
        targetsNames=tgs.getTargetNames();
    end
end

