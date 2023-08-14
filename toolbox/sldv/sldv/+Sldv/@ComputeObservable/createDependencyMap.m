





function createDependencyMap(obj)


    modelName=obj.ModelQueue{obj.MdlQueIndex};




    status=initializeDependencyMap(obj,modelName);
    if~status

        return;
    end


    Sldv.ComputeObservable.logDebugMsgs("ComputeObservable","createDependencyMap",...
    "Constructing Dependency for model::"+modelName);



    oc=compileModel(modelName);%#ok<NASGU>





    obj.InitSubSysQueue();


    startList=obj.getModelStartList(get_param(modelName,'Handle'));





    obj.getSubSystemDependency(startList);


    if obj.MdlQueIndex<length(obj.ModelQueue)
        obj.MdlQueIndex=obj.MdlQueIndex+1;
        obj.createDependencyMap();
    end
end


function oc=compileModel(modelName)
    oc=[];
    simStatus=get_param(modelName,'SimulationStatus');
    compStatus=strcmp(simStatus,'paused')||strcmp(simStatus,'initializing');
    if~compStatus
        feval(modelName,[],[],[],'compile');
        oc=onCleanup(@()feval(modelName,[],[],[],'term'));
    end
end
