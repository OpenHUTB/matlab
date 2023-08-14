function paramVal=get_param_block(blockH,param)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(param);
    coder.extrinsic('sldvprivate');
    paramVal=coder.const(sldvprivate('get_param_block',blockH,param));
end

