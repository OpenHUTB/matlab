function maxSize=blockCompiledPortDims(blockH)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    maxSize=coder.const(sldvprivate('getCompiledPortDimsForBlock',blockH));
end
