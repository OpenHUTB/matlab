function reparentWrappedMFObjectUnder(this,parentDasObj)






    this.eventListener.Enabled=false;
    this.dataModelObj.parent=parentDasObj.dataModelObj;
    this.eventListener.Enabled=true;
end
