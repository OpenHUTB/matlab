function out=getOffsetInCoveragePointsForLogicBlock(blockH,portIdx)

    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(portIdx);
    coder.extrinsic('sldvprivate');
    out=coder.const(sldvprivate('getOffsetInCoveragePointsForLogicBlock',blockH,portIdx));
end
