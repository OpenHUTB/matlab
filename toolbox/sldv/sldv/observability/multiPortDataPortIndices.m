function portIndices=multiPortDataPortIndices(blockH)

    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    portIndices=coder.const(sldvprivate('getMPSwitchDataPortIndices',blockH));
end
