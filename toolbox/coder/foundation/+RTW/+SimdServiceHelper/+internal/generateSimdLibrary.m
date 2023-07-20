function libName=generateSimdLibrary(instructionSetName)
    aSimdService=RTW.SimdServiceHelper.internal.getSimdService(instructionSetName);
    hTflTable=RTW.SimdServiceHelper.internal.createSimdCrlTableFromService(aSimdService);
    supportedHWList=RTW.SimdServiceHelper.internal.getSupportedHWForInstructionSet(instructionSetName);

    tblName=['generated_',instructionSetName,'_simd_crl_table'];
    savePath=userpath;
    save(fullfile(savePath,[tblName,'.mat']),'hTflTable');

    tr=RTW.TargetRegistry.getInstance;
    libName=['generated_',instructionSetName,'_SIMD_Library'];

    lib=loc_foundTflRegistry(tr,libName);
    if~isempty(lib)


        lib.TargetHWDeviceType=supportedHWList;
    else
        lib=RTW.TflRegistry;
        lib.Name=libName;
        lib.TableList={[tblName,'.mat']};
        lib.TargetHWDeviceType=supportedHWList;
        tr.registerTargetInfo(lib);
    end

end

function lib=loc_foundTflRegistry(tr,libName)
    try
        lib=coder.internal.getTfl(tr,libName);
    catch
        lib=[];
    end
end