
















function[flag,slfcnBlkHdl]=isMTreeNodeSimulinkFunctionCall(mtreeNode,astObj)
    assert(isa(mtreeNode,'mtree'));
    flag=false;
    slfcnBlkHdl=[];
    if(~any(strcmpi(mtreeNode.kind,{'CALL','SUBSCR'})))
        return
    end
    argNode=[];%#ok<NASGU>
    caller=astObj.ParentBlock;
    mdlObj=astObj.ParentModel;
    funcHdls=mdlObj.getSLFcnBlockHandles;
    if strcmpi(mtreeNode.kind,'CALL')

        [resolved,fcnHdl]=resolveFunctionCallWithinScope(caller,funcHdls,...
        mtreeNode);
        if resolved
            flag=true;
            slfcnBlkHdl=fcnHdl;
            return;
        end
    else
        [resolved,fcnHdl]=...
        resolveFunctionCallUsingQualifier(caller,funcHdls,mtreeNode);
        if resolved
            flag=true;
            slfcnBlkHdl=fcnHdl;
            return;
        end
    end
end


function[flag,slfcnBlkHdl]=resolveFunctionCallWithinScope(callerObj,...
    fcnHdls,mtreeNode)
    assert(isa(mtreeNode,'mtree'));
    assert(strcmpi(mtreeNode.kind,'CALL'));
    flag=false;
    slfcnBlkHdl=[];
    fnode=mtreeNode.Left;
    nodeFname=fnode.string;
    callerPath=callerObj.getName;
    for i=1:numel(fcnHdls)
        fcnBlk=get_param(fcnHdls{i},'Object');
        assert(isa(fcnBlk,'Simulink.SubSystem')&&...
        strcmpi(slci.internal.getSubsystemType(fcnBlk),'simulinkfunction'),...
        "Only Simulink Function subsystem is expected to be called by MTree node")
        triggerProp=slci.internal.getSimulinkFunctionTriggerPortProperty(fcnBlk);
        fcnName=triggerProp.getFcnName;
        fcnPath=getFullName(fcnBlk);
        if strcmp(fcnName,nodeFname)&&slci.internal.isAWithinScopeOfB(...
            callerPath,fcnPath)
            flag=true;
            slfcnBlkHdl=fcnHdls{i};
            return;
        end
    end
end



function[flag,slfcnBlkHdl]=resolveFunctionCallUsingQualifier(callerObj,...
    fcnHdls,mtreeNode)
    assert(isa(mtreeNode,'mtree'));
    assert(strcmp(mtreeNode.kind,'SUBSCR'));
    flag=false;
    slfcnBlkHdl=[];
    fcnPart=mtreeNode.Left;
    callerPath=callerObj.getName;
    if strcmpi(fcnPart.kind,'DOT')
        scopeNode=fcnPart.Left;
        fcnIdNode=fcnPart.Right;
        if strcmpi(scopeNode.kind,'ID')&&strcmpi(fcnIdNode.kind,'FIELD')
            nodeFcnName=fcnIdNode.string;
            nodeScopeName=scopeNode.string;
            for i=1:numel(fcnHdls)
                fcnBlk=get_param(fcnHdls{i},'Object');
                assert(isa(fcnBlk,'Simulink.SubSystem')&&...
                strcmpi(slci.internal.getSubsystemType(fcnBlk),...
                'simulinkfunction'),["Only Simulink Function subsystem is"...
                ," expected to be called by MTree node"])
                fcnScope=slci.internal.getSimulinkFunctionScope(fcnHdls{i});
                fcnPath=getFullName(fcnBlk);
                triggerProp=slci.internal.getSimulinkFunctionTriggerPortProperty(fcnBlk);
                fcnName=triggerProp.getFcnName;
                if strcmp(nodeFcnName,fcnName)&&...
                    strcmp(fcnScope,nodeScopeName)&&...
                    slci.internal.isAAtParentLevelOfB(callerPath,fcnPath)
                    flag=true;
                    slfcnBlkHdl=fcnHdls{i};
                    return;
                end
            end
        end

    end
end



