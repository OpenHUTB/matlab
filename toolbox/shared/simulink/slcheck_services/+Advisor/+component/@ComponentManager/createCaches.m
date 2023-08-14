function createCaches(this)
    instanceIDs=this.getComponentIDs();
    this.ByTypeCache=containers.Map('KeyType','double','ValueType','any');
    for n=1:length(instanceIDs)
        instObj=this.getComponent(instanceIDs{n});


        typeNum=instObj.Type.double;

        if this.ByTypeCache.isKey(typeNum)
            this.ByTypeCache(typeNum)=...
            [this.ByTypeCache(typeNum),instObj.ID];
        else
            this.ByTypeCache(typeNum)={instObj.ID};
        end
    end
end