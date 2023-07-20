function targetsNames=getTargetListDup()



    if~ispc||~stm.internal.genericrealtime.checkxpctarget()
        targetsNames={};
    else
        tgs=slrealtime.Targets;
        targetsNames=tgs.getTargetNames();
    end
end
