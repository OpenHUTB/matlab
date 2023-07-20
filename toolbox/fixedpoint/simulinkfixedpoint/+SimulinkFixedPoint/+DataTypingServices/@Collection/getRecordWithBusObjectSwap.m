function[curRecord,recAdded,numAdded]=getRecordWithBusObjectSwap(~,curSignal,busObjectHandleMap,runObj)





















    numAdded=0;
    recAdded={};
    curRecord=[];%#ok<NASGU>
    dataHandler=fxptds.SimulinkDataArrayHandler;

    if isfield(curSignal,'srcInfo')&&...
        ~isempty(curSignal.srcInfo)&&...
        ~isempty(curSignal.srcInfo.busObjectName)&&...
        ~isempty(curSignal.srcInfo.busElementName)


        thisPathItem=SimulinkFixedPoint.AutoscalerUtils.getBlkPathItemsFromPort(curSignal.blkObj,[],curSignal.pathItem);
        uniqueID=dataHandler.getUniqueIdentifier(struct('Object',curSignal.blkObj,'ElementName',thisPathItem{1}));
        [origBlkRecord,addedRecNum]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',uniqueID});
        if addedRecNum>0
            numAdded=numAdded+addedRecNum;
            recAdded{end+1}=origBlkRecord;
        end


        busObjectName=curSignal.srcInfo.busObjectName;
        busObjectHandle=busObjectHandleMap.getDataByKey(busObjectName);

        elementName=curSignal.srcInfo.busElementName;

        if~busObjectHandle.leafChildName2IndexMap.isKey(elementName)

            curRecord=origBlkRecord;
            return;
        end

        leafElementName=elementName;


        curSignal.blkObj=busObjectHandle;
        curSignal.pathItem=leafElementName;




        uniqueID=dataHandler.getUniqueIdentifier(struct('Object',busObjectHandle,'ElementName',leafElementName));
        [curRecord,addedRecNum]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',uniqueID});
    else
        if isa(curSignal.blkObj,'fxptds.MATLABVariableIdentifier')
            [curRecord,addedRecNum]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',curSignal.blkObj});
        else
            thisPathItem=SimulinkFixedPoint.AutoscalerUtils.getBlkPathItemsFromPort(...
            curSignal.blkObj,[],curSignal.pathItem);
            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',curSignal.blkObj,'ElementName',thisPathItem{1}));
            [curRecord,addedRecNum]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',uniqueID});
        end
    end

    if addedRecNum>0
        numAdded=numAdded+addedRecNum;
        recAdded{end+1}=curRecord;
    end
end


