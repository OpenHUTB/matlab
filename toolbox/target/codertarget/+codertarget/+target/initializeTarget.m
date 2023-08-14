function initializeTarget(hCS,tgtHWInfo)









    codertarget.internal.setProdHWDeviceType(hCS,tgtHWInfo.ProdHWDeviceType);
    codertarget.internal.setToolChain(hCS,tgtHWInfo);
    codertarget.internal.setExtModeTransport(hCS);
end