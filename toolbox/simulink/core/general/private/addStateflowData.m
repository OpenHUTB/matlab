function dataID=addStateflowData(blockHandle,dataType,portIndex,dataName)



    chartID=sfprivate('block2chart',blockHandle);
    if(~isempty(dataName))
        dataID=sfprivate('new_data',chartID,dataType,dataName);
    else
        dataID=sfprivate('new_data',chartID,dataType);
    end

    dataUDD=idToHandle(sfroot,dataID);
    dataUDD.Port=portIndex;
end
