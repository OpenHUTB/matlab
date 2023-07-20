function newID=addSLInternalIdToMap(this,uniqueId,uniqueIdObj)



    if this.ModelBlockSLIntIdObjMap.isKey(uniqueId)

        uniqueId=this.ModelBlockSLIntIdObjMap.getCount();
        this.ModelBlockSLIntIdObjMap.insert(uniqueId,uniqueIdObj);
    else
        this.ModelBlockSLIntIdObjMap.insert(uniqueId,uniqueIdObj);
    end
    newID=uniqueId;
end
