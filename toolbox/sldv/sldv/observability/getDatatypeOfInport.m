function datatype=getDatatypeOfInport(blockH,inportIdx)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(inportIdx);
    coder.extrinsic('sldvprivate');
    datatype=coder.const(@sldvprivate,'getDatatypeMinimumMaximum',blockH,inportIdx);
end

