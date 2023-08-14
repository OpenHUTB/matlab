function out=getAdvancedParamForEnhancedMCDC()


    coder.inline('always');
    coder.allowpcode('plain');

    coder.extrinsic('sldvprivate');
    out=coder.const(sldvprivate('getAdvancedParamForEnhancedMCDC'));
end
