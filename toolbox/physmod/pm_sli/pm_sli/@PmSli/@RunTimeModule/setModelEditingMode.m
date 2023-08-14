function success=setModelEditingMode(this,hModel,requestedMode)








    propOwningObj=this.getConfigSet(hModel.Handle);

    this.setCcEditingMode(propOwningObj,requestedMode);

    success=true;




