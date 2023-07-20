function[newBusObjectResults,numbOfBusRecAdded]=createBusResultsFromParameter(this,parameterObjectWrapper,runObj,srcIDs)




    pObjEA=SimulinkFixedPoint.EntityAutoscalers.ParameterObjectEntityAutoscaler;
    busObjEA=SimulinkFixedPoint.EntityAutoscalers.SLBusObjectEntityAutoscaler;
    busObjHandleMap=runObj.getMetaData.getBusObjectHandleMap();
    busObjHandleAndICList=...
    pObjEA.getAssociatedBusObjectHandleAndIC(parameterObjectWrapper,[],busObjHandleMap);

    [newBusObjectResults,numbOfBusRecAdded]=this.createAndUpdateBusObjectResults(...
    busObjHandleAndICList,srcIDs,runObj);

    if numbOfBusRecAdded>0
        for newBusRecIdx=1:numbOfBusRecAdded
            this.setDesignMinMaxAndSpecifiedDT(busObjEA,newBusObjectResults{newBusRecIdx});
        end

    end
end
