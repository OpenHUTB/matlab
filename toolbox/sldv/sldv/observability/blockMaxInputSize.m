function maxSize=blockMaxInputSize(blockH)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    maxSize=coder.const(sldvprivate('getMaxInputSize',blockH));
end
