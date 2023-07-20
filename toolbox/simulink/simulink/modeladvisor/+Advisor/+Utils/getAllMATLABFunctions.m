function mlObj=getAllMATLABFunctions(system)











    fcnObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,'on','all');
    fcnDependencyObjs=Advisor.Utils.Eml.getReferencedMFiles(system,fcnObjs);
    mlObj={};


    for k=1:length(fcnDependencyObjs)
        curObj=fcnObjs{k};
        if isa(curObj,'Stateflow.EMChart')||isa(curObj,'Stateflow.EMFunction')
            mlObj=[mlObj,{Simulink.ID.getStateflowSID(curObj)}];
        elseif isa(curObj,'table')
            mlObj=[mlObj,curObj.EndNodes{2}];
        else
            mlObj=[mlObj,{curObj.FileName}];
        end
    end
