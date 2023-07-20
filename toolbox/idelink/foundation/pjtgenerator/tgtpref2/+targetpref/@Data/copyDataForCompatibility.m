function newData=copyDataForCompatibility(h,newData)




    newData.mem.dspbios=h.mTargetInfo.mem.dspbios;
    newData.dspbios=h.mTargetInfo.dspbios;
    newData.peripherals=h.mTargetInfo.peripherals;
    if(isfield(h.mTargetInfo,'OS'))
        newData.OS=h.mTargetInfo.OS;
    end