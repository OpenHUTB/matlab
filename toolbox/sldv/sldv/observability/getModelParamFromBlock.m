function paramVal=getModelParamFromBlock(blockH,param)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(param);
    coder.extrinsic('sldvprivate');
    paramVal=coder.const(sldvprivate('getModelParamFromBlock',blockH,param));
end

