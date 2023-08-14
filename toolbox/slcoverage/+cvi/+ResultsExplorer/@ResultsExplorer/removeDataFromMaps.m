function removeDataFromMaps(obj,data)




    if obj.maps.uniqueIdMap.isKey(data.uniqueId)
        obj.maps.uniqueIdMap.remove(data.uniqueId);
        obj.maps.fileMap.remove(data.fullFileName);
    end
end