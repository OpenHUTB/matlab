function cordicInfo=getSysObjInfo(this,hC,sysObjHandle)%#ok<INUSL>








    cordicInfo=hdldefaults.Cordic.getSinCosCordicInfo(...
    sysObjHandle.Prop2,...
    sysObjHandle.FunctionName,...
    hC.PirInputSignals(1).Type.getLeafType.WordLength...
    );
