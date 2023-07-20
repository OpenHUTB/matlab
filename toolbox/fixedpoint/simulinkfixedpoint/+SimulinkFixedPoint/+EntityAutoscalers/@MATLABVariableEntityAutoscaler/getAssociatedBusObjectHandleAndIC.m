function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(this,variableIdentifier,~,busObjHandleMap)




    busObjHandleAndICList=[];
    mlBlock=variableIdentifier.getMATLABFunctionBlock;
    if isempty(mlBlock)
        return;
    end
    portHandles=mlBlock.PortHandles;
    portHandleVec=[portHandles.Inport,portHandles.Outport];

    busObjNameSet=containers.Map();
    ICValue=[];

    for i=1:numel(portHandleVec)
        [sigH,isBus]=hGetBusSignalHierarchy(this,portHandleVec(i));
        if~isBus
            continue;
        end
        isNonVirtualBus=this.hIsNonVirtualBus(portHandleVec(i));

        [newBusObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(this,sigH,...
        ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);
        busObjHandleAndICList=this.hAppendList(busObjHandleAndICList,...
        newBusObjHandleAndICList);
    end


    paramData=find(mlBlock,'-isa','Stateflow.Data','Scope','Parameter');%#ok<GTARG>
    for i=1:numel(paramData)
        busName=this.hCleanBusName(paramData(i).CompiledType);
        if busObjHandleMap.isKey(busName)
            sigH=this.hGetSigHFromBusObject(busName,busObjHandleMap,'');
            [newBusObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(this,sigH,...
            ICValue,false,busObjHandleMap,busObjNameSet);
            busObjHandleAndICList=this.hAppendList(busObjHandleAndICList,...
            newBusObjHandleAndICList);
        end
    end



