function portDim=getIndexPortEntries(blockH)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    portDim=coder.const(sldvprivate('getIndexPortEntries',blockH));
end

