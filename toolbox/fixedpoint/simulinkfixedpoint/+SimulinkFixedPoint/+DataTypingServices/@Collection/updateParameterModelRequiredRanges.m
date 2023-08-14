function updateParameterModelRequiredRanges(~,parameterObjectWrapper,pObjInfo,result)



    pObjEA=SimulinkFixedPoint.EntityAutoscalers.ParameterObjectEntityAutoscaler;


    varAssociateParam=pObjEA.gatherAssociatedParam(parameterObjectWrapper);

    valueMin=SimulinkFixedPoint.safeConcat(varAssociateParam.ModelRequiredMin,pObjInfo.min,result.ModelRequiredMin);
    valueMax=SimulinkFixedPoint.safeConcat(varAssociateParam.ModelRequiredMax,pObjInfo.max,result.ModelRequiredMax);


    result.updateResultData(struct(...
    'ModelRequiredMin',valueMin,...
    'ModelRequiredMax',valueMax));

end
