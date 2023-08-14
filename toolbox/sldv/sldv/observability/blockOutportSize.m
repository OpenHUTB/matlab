function inportSize=blockOutportSize(blockH)







    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    inportSize=coder.const(sldvprivate('getOutportSize',blockH));
end
