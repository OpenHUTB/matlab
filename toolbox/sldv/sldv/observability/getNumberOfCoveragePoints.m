function out=getNumberOfCoveragePoints(blockH)

    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    out=coder.const(sldvprivate('getNumberOfCoveragePoints',blockH));
end
