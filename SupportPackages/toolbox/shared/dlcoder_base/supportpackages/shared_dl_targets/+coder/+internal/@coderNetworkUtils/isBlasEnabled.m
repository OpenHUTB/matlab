function isBlas=isBlasEnabled()




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    if coder.const(feval('dlcoderfeature','UseCodegenConfigSetForSimulation'))&&...
        coder.target('Sfun')


        isBlas=coder.const(coder.internal.coderNetworkUtils.isCustomBLASCallbackEnabled());
    else
        isBlas=coder.const(coder.internal.coderNetworkUtils.isCustomBLASCallbackEnabled()||...
        coder.internal.coderNetworkUtils.isMexCodeConfig()||...
        coder.internal.coderNetworkUtils.isSfunCodeConfig());
    end

end
