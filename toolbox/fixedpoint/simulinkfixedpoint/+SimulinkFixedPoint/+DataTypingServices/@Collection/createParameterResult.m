function[result,isNew,parameterObjectWrapper]=createParameterResult(this,modelName,pObjInfo,runObj)



    isNew=false;
    parameterObject=pObjInfo.object;
    parameterName=pObjInfo.Name;


    parameterObjectWrapper=...
    SimulinkFixedPoint.ParameterObjectWrapperCreator.getWrapper(...
    parameterObject,parameterName,modelName);
    data=struct('Object',parameterObjectWrapper,'ElementName',parameterName);
    dHandler=fxptds.SimulinkDataArrayHandler;
    result=runObj.getResultByID(dHandler.getUniqueIdentifier(data));
    if isempty(result)
        isNew=true;
        result=runObj.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(...
        struct('Object',parameterObjectWrapper,'ElementName',parameterName)));
    end

    result.computeIfInheritanceReplaceable;

    pObjEA=SimulinkFixedPoint.EntityAutoscalers.ParameterObjectEntityAutoscaler;


    result=this.setDesignMinMaxAndSpecifiedDT(pObjEA,result);
end