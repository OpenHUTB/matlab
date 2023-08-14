function uniqueID=getUniqueIDForBusElement(busObjName,elementIndex,contextBlock)







    bdrootHandle=bdroot(contextBlock.Handle);


    modelName=get_param(bdrootHandle,'Name');


    appdata=SimulinkFixedPoint.getApplicationData(modelName);
    runObj=appdata.dataset.getRun(appdata.ScaleUsing);
    metadata=runObj.getMetaData;


    busObjHandleMap=metadata.getBusObjectHandleMap();


    if busObjHandleMap.isKey(busObjName)


        busObjHandle=busObjHandleMap.getDataByKey(busObjName);


        busObject=busObjHandle.busObj;
        if~isempty(find(busObjHandle.leafChildIndices==elementIndex,1))

            elementName=busObject.Elements(elementIndex).Name;


            uniqueID=fxptds.SimulinkDataObjectIdentifier(busObjHandle,elementName);
        else

            uniqueID=[];
        end
    else


        uniqueID=[];
    end

end


