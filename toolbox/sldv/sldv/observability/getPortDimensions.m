function portDim=getPortDimensions(blockH,inPortIdx,outPortIdx)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(inPortIdx);
    coder.const(outPortIdx);
    coder.extrinsic('sldvprivate');
    portDim=coder.const(sldvprivate('getPortDimensions',blockH,inPortIdx,outPortIdx));
end

