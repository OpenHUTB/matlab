function hTflTable=createSimdCrlTableFromService(simdService)
    hTflTable=RTW.TflTable;
    simdApi=simdService.API;

    simdImplFcns=simdApi.Functions;
    for i=1:length(simdImplFcns)
        aImplFcn=simdImplFcns(i);
        hEntry=RTW.SimdServiceHelper.internal.createSimdEntryFromTgtFcn(aImplFcn,simdApi);
        hTflTable.addEntry(hEntry);
    end
end