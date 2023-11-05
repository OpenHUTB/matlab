function usingHSP=isUsingHSP(ctx)

    usingHSP=false;
    if isempty(ctx)
        return;
    end
    toolchainName=ctx.getConfigProp('Toolchain');
    if~isempty(toolchainName)&&contains(toolchainName,'NVCC for NVIDIA Embedded Processors')&&...
        strcmp(ctx.CodeGenTarget,'rtw')
        usingHSP=true;
    end
end
