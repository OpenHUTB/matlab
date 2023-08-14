function inportSize=blockInportSize(blockH,portIdx)








    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(portIdx);
    coder.extrinsic('sldvprivate');
    inportSize=coder.const(sldvprivate('getInportSize',blockH,portIdx));
end

