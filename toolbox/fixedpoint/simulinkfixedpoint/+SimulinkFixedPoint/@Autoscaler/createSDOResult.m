function[result,numRecAdded]=createSDOResult(runObj,slSignalInfo,modelName)





    signalObject=slSignalInfo.object;
    signalName=slSignalInfo.name;
    signalObjectWrapper=...
    SimulinkFixedPoint.SignalObjectWrapperCreator.getWrapper(...
    signalObject,signalName,modelName);
    [result,numRecAdded]=runObj.getResult(signalObjectWrapper,signalName);
    if isempty(result)
        result=runObj.createAndUpdateResult(...
        fxptds.SimulinkDataArrayHandler(...
        struct('Object',signalObjectWrapper,...
        'ElementName',signalName)));
        numRecAdded=1;
    end
end