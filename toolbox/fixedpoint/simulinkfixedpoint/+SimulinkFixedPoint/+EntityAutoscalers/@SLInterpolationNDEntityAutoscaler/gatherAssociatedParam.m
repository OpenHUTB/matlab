function associateRecords=gatherAssociatedParam(h,blockObject)












    associateRecords=[];


    [isValid,minimumValue,maximumValue,parameterObject]=getTableData(h,blockObject);

    if isValid
        pathItems=getPathItems(h,blockObject);

        nPathItems=length(pathItems);
        for iPathItem=1:nPathItems
            associateRecords=[associateRecords,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(...
            blockObject,pathItems{iPathItem},[],...
            minimumValue,maximumValue,parameterObject)];%#ok<AGROW>
        end
    end

    hPorts=get_param(blockObject.Handle,'PortHandles');



    [~,fracPortNums,busPortNums,~]=analyzeInports(h,blockObject);

    if isempty(busPortNums)

        nFrac=length(fracPortNums);
        for idx=1:nFrac
            iInport1=fracPortNums(idx);
            portObj=get_param(hPorts.Inport(iInport1),'Object');
            [sourceBlk,srcPathItem,srcInfo]=h.getSourceSignal(portObj);
            if~isempty(sourceBlk)&&~isempty(srcPathItem)
                associateRecords=[associateRecords...
                ,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(...
                sourceBlk,srcPathItem,srcInfo,...
                0,1,[])];%#ok<AGROW>
            end
        end
    else


        nBuses=length(busPortNums);
        for idx=1:nBuses




            if h.hIsNonVirtualBus(hPorts.Inport(busPortNums(idx)))

                portObj=get_param(hPorts.Inport(busPortNums(idx)),'Object');
                [sourceBlk,srcPathItem,~]=h.getSourceSignal(portObj);


                portHandles=blockObject.PortHandles;
                busInportHandle=portHandles.Inport(busPortNums(idx));
                sigH=get_param(busInportHandle,'SignalHierarchy');
                busObjectName=h.hCleanDTOPrefix(sigH.BusObject);




                uniqueID=SimulinkFixedPoint.AutoscalerUtils.getUniqueIDForBusElement(busObjectName,2,blockObject);
                elementName=uniqueID.getElementName;
                srcInfo.busObjectName=busObjectName;
                srcInfo.busElementName=elementName;

                associateRecords=[associateRecords...
                ,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(...
                sourceBlk,srcPathItem,srcInfo,...
                0,1,[])];%#ok<AGROW>
            end
        end
    end
end
