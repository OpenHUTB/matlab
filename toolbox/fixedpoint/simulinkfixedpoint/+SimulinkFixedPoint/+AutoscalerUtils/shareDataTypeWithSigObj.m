function sharedList=shareDataTypeWithSigObj(currentAutoscaler,blk)




    sharedList={};
    [isResolved,slSignalInfo]=currentAutoscaler.getResolvedSLSignal(blk);
    if isResolved
        srcID=slSignalInfo.actualSrcID{1};
        signalObject=slSignalInfo.object;
        signalName=slSignalInfo.name;
        signalObjectWrapper=SimulinkFixedPoint.SignalObjectWrapperCreator.getWrapper(...
        signalObject,signalName,bdroot(blk.getFullName));
        sharedList={struct('blkObj',srcID.getObject,'pathItem',srcID.getElementName),...
        struct('blkObj',signalObjectWrapper,'pathItem',signalName)};
    end
