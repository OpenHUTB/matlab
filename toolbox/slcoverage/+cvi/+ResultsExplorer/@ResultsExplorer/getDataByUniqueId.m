function data=getDataByUniqueId(obj,uniqueId)




    data=[];
    if obj.maps.uniqueIdMap.isKey(uniqueId)
        data=obj.maps.uniqueIdMap(uniqueId);
    end
end