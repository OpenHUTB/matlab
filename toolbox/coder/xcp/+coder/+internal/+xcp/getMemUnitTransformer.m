



function memUnitTransformer=getMemUnitTransformer(model,isHostBased)
    cs=getActiveConfigSet(model);
    isLittleEndian=~coder.internal.xcp.isBigEndianTarget(model,cs,isHostBased);
    typeInfo=coder.internal.xcp.getTypeInfo(model,false);
    isByteAddressable=rtw.connectivity.ExtendedHardwareConfig.staticIsByteAddressable(typeInfo);
    wordSizeInBytes=typeInfo.wordSize/8;
    memUnitTransformer=coder.internal.connectivity.MemUnitTransformer(wordSizeInBytes,...
    isByteAddressable,...
    isLittleEndian);
end