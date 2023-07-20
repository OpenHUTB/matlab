function beginId=logicCovIdBeginIdx(blockH,portIdx)






























    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(portIdx);
    stId=1;
    endId=coder.const(portIdx-1);

    coder.extrinsic('sldvprivate');
    beginId=coder.const(sldvprivate('getCumulativeInportSize',...
    blockH,stId,endId));
end
