function pv=getSettingStrategies(entityAutoscaler,blkObj,pathItem,~)




    pv={};


    [~,~,paramNames]=gatherSpecifiedDT(entityAutoscaler,blkObj,pathItem);


    dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,paramNames.wlStr);



    [blkObjToBeSet,paramNameToBeSetWl]=dialogParamTracer.getDestinationProperties();


    dialogParamTracer=SimulinkFixedPoint.TracingUtils.DialogParameterTracer(blkObj,paramNames.flStr);
    [~,paramNameToBeSetFl]=dialogParamTracer.getDestinationProperties();


    blockPathFL=blkObjToBeSet.getFullName;
    pv{1,1}={'FractionLengthStrategy',blockPathFL,paramNameToBeSetFl};

    blockPathWL=blkObjToBeSet.getFullName;
    pv{end+1,1}={'WordLengthStrategy',blockPathWL,paramNameToBeSetWl};


    pv{end+1,1}={'GenericPropertyStrategy',blockPathFL,paramNames.modeStr,'Binary point scaling'};

end

