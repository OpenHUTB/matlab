function out=getNumDecSwitchcase(blockH,portIdx)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(portIdx);
    coder.extrinsic('sldvprivate');
    out=coder.const(sldvprivate('getNumDecSwitchcase',blockH,portIdx));
end
