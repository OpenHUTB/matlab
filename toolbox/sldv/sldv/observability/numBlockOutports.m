function out=numBlockOutports(blockH)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    out=coder.const(sldvprivate('numBlockOutports',blockH));
end
