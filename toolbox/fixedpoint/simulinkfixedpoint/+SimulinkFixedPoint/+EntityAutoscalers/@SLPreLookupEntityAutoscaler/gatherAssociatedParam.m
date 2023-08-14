function associateRecords=gatherAssociatedParam(h,blockObject)












    associateRecords=[];
    pathItems=getPathItems(h,blockObject);


    ph=blockObject.PortHandles;
    srcInfoIndex=[];
    srcInfoFraction=[];
    if h.hIsNonVirtualBus(ph.Outport(1))
        sigH=get_param(ph.Outport(1),'SignalHierarchy');
        busObjectName=h.hCleanDTOPrefix(sigH.BusObject);










        uniqueID=SimulinkFixedPoint.AutoscalerUtils.getUniqueIDForBusElement(busObjectName,1,blockObject);
        elementName=uniqueID.getElementName;
        srcInfoIndex.busObjectName=busObjectName;
        srcInfoIndex.busElementName=elementName;



        uniqueID=SimulinkFixedPoint.AutoscalerUtils.getUniqueIDForBusElement(busObjectName,2,blockObject);
        elementName=uniqueID.getElementName;
        srcInfoFraction.busObjectName=busObjectName;
        srcInfoFraction.busElementName=elementName;
    end


    numPoints=getNumberOfPoints(h,blockObject);
    associateRecords=[associateRecords,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blockObject,'1',srcInfoIndex,1,numPoints,[])];


    if ismember('2',pathItems)


        associateRecords=[associateRecords,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blockObject,'2',srcInfoFraction,0,1,[])];
    end
    if~isempty(srcInfoFraction)


        associateRecords=[associateRecords,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blockObject,'1',srcInfoFraction,0,1,[])];
    end


    [isValid,minimumValue,maximumValue,parameterObject]=getBreakpointData(h,blockObject);
    if isValid
        associateRecords=[associateRecords...
        ,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(...
        blockObject,'Breakpoint',[],...
        minimumValue,maximumValue,parameterObject)];
    end
end


