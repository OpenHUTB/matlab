function importHardwareFromHook(hHardware,hookFile,mdlName)



    wordlengths=feval(hookFile,'wordlengths',mdlName);
    set(hHardware,'TargetBitPerChar',wordlengths.CharNumBits);
    set(hHardware,'TargetBitPerShort',wordlengths.ShortNumBits);
    set(hHardware,'TargetBitPerInt',wordlengths.IntNumBits);
    set(hHardware,'TargetBitPerLong',wordlengths.LongNumBits);
    if isfield(wordlengths,'WordSize')
        set(hHardware,'TargetWordSize',wordlengths.WordSize);
    end

    cImp=feval(hookFile,'cImplementation',mdlName);
    set(hHardware,'TargetShiftRightIntArith',cImp.ShiftRightIntArith);
    if isfield(cImp,'PreprocMaxBitsSint')
        set(hHardware,'TargetPreprocMaxBitsSint',cImp.PreprocMaxBitsSint);
    end
    if isfield(cImp,'PreprocMaxBitsUint')
        set(hHardware,'TargetPreprocMaxBitsUint',cImp.PreprocMaxBitsUint);
    end

    if isfield(cImp,'Endianess')
        set(hHardware,'TargetEndianess',cImp.Endianess);
    end
