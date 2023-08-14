function ssid=mapFromHarnessSID(this,ssid)




    rootId=this.rootId;
    ownerBlock=this.modelinfo.ownerBlock;
    harnessModel=this.modelinfo.analyzedModel;
    ssid=cvdata.mapFromHarnessSID_internal(ssid,rootId,ownerBlock,harnessModel);
end
