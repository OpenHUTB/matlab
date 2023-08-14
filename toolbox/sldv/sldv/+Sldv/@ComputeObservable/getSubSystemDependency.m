















function getSubSystemDependency(obj,stList)

    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getSubSystemDependency",...
    "Constructing Dependency for Model/Subsystem::"+get_param(obj.SubSysQueue(obj.SubSysQueIndex),"Name"));
    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getSubSystemDependency",...
    "All inports of model/subsystem are its starting-point");

    for i=1:length(stList)
        if~iscell(stList)

            startH=stList(i);
        else
            startH=get_param(stList{i},'Handle');
        end

        Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","getSubSystemDependency",...
        "Starting DFS(blockH, inportNo, srcBlockH, srcPortNo)::("+get_param(startH,"Name")+",0,0,0)");
        obj.doDFSAnalysis(startH,0,0,0);
    end

    if obj.SubSysQueIndex<length(obj.SubSysQueue)
        obj.SubSysQueIndex=obj.SubSysQueIndex+1;

        obj.setSubSysExpanded(obj.SubSysQueue(obj.SubSysQueIndex));
        stList=obj.initializeStartListAndSubsystems(obj.SubSysQueue(obj.SubSysQueIndex));
        obj.getSubSystemDependency(stList);
    end
end



