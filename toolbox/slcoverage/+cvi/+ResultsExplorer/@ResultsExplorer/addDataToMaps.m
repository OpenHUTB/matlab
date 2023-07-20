function addDataToMaps(obj,data)




    assert(~obj.maps.uniqueIdMap.isKey(data.uniqueId),['Not unique id: ',data.fullFileName]);
    obj.maps.uniqueIdMap(data.uniqueId)=data;
    obj.maps.fileMap(data.fullFileName)=data;
end