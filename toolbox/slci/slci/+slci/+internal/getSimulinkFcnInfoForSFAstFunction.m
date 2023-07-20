
















function[flag,slfcnInfo]=getSimulinkFcnInfoForSFAstFunction(astObj)
    assert(isa(astObj,'slci.ast.SFAstFunction'))
    callerObj=astObj.ParentBlock;
    mdlObj=astObj.ParentModel;
    flag=false;
    slfcnInfo=[];
    funcInfos=mdlObj.getFuncInfoForCaller(callerObj.getHandle);
    if isempty(funcInfos)

        return;
    end
    funcStr=astObj.getName;
    fcnStrCell=split(funcStr,'.');
    assert(numel(fcnStrCell)<=2,'Simulink Function can have atmost 1 qualifier');
    callerPath=callerObj.getName;
    for i=1:numel(funcInfos)
        func=funcInfos{i};
        fName=func.getFunctionName;
        fcnBlkType=func.getFunctionBlockType;
        fcnPath=func.getFunctionBlockPath;
        if~strcmp(fcnBlkType,'SimulinkFunction')
            continue;
        end
        if numel(fcnStrCell)==1

            astFuncName=fcnStrCell{1};
            if strcmp(astFuncName,fName)&&...
                slci.internal.isAWithinScopeOfB(callerPath,fcnPath)
                slfcnInfo=func;
                flag=true;
            end
        elseif numel(fcnStrCell)==2

            astFuncName=fcnStrCell{2};
            astScopeName=fcnStrCell{1};
            if strcmp(astFuncName,fName)&&strcmp(func.getScope,astScopeName)&&...
                slci.internal.isAAtParentLevelOfB(callerPath,fcnPath)
                slfcnInfo=func;
                flag=true;
            end
        end
    end