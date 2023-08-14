function reqSetName=getSfReqSet(this,mdlHandle)
    reqSetName=[];
    if this.sfReqSetMap.isKey(mdlHandle)
        reqSetName=this.sfReqSetMap(mdlHandle);
    end
end