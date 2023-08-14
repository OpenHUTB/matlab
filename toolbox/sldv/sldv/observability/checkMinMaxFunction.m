function isMinBlock=checkMinMaxFunction(blockH)







    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    isMinBlock=coder.const(sldvprivate('getMinMaxFunction',blockH));
end
