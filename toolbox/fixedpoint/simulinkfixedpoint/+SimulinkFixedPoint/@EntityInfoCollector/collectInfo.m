function info=collectInfo(this,entityAutoscaler,blockObject,pathItem)



















    [info.dMin,info.dMax]=entityAutoscaler.gatherDesignMinMax(blockObject,pathItem);

    info.actualSrcIDs=entityAutoscaler.getActualSrcIDs(blockObject);

    [info.isResolved,info.slSignalInfo]=entityAutoscaler.getResolvedSLSignal(blockObject);


    info.varAssociateParam=entityAutoscaler.gatherAssociatedParam(blockObject);


    if isa(blockObject,'Simulink.Signal')||isa(blockObject,'Simulink.Parameter')
        info.varAssociateParam.pathItem=pathItem;
    end


    [info.specDTConInfo,info.specDTComments]=entityAutoscaler.gatherSpecifiedDT(blockObject,pathItem);


    [info.hasDTConstraints,info.curDTConstraintsSet]=entityAutoscaler.gatherDTConstraints(blockObject);


    info.sharedList=entityAutoscaler.gatherSharedDT(blockObject);


    info.busObjHandleAndICList=...
    entityAutoscaler.getAssociatedBusObjectHandleAndIC(blockObject,pathItem,this.busObjHandleMap);



    if~isempty(info.busObjHandleAndICList)


        busObjSharedList=...
        entityAutoscaler.gatherSharedDTWithBusObj(...
        blockObject,pathItem,this.busObjHandleMap);



        if~isempty(busObjSharedList)
            info.sharedList(end+1:end+length(busObjSharedList))...
            =busObjSharedList;
        end
    end

end


