function instructions=getInstructionsFromService(simdService)

    simdAPI=simdService.API;
    if isempty(simdAPI)
        error("No api specified in SIMD service");
    end

    simdImplFcns=simdAPI.Functions;
    if isempty(simdImplFcns)
        error("No function specified in SIMD service")
    end

    for i=1:length(simdImplFcns)
        instruction=RTW.SimdServiceHelper.internal.createInstructionFromTgtFcn(simdImplFcns(i),simdAPI);
        instructions(i)=instruction;
    end

end