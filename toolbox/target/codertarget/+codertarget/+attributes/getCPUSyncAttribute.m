function out=getCPUSyncAttribute(hCS,fcnName)





    out='';
    if codertarget.targethardware.hasMultipleProcessingUnits(hCS)
        procUnit=codertarget.targethardware.getProcessingUnitInfo(hCS);
    end
    cpuSyncInfo=procUnit.getMasterSlaveSyncInfo;
    if~isempty(cpuSyncInfo)
        out=cpuSyncInfo.(fcnName);
    end
end