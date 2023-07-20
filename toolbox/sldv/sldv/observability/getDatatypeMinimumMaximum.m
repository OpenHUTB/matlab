function[datatype,typeMin,typeMax]=getDatatypeMinimumMaximum(blockH,inportIdx,outportIdx)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.const(inportIdx);
    coder.const(outportIdx);
    coder.extrinsic('sldvprivate');
    [datatype,typeMin,typeMax]=coder.const(@sldvprivate,'getDatatypeMinimumMaximum',blockH,inportIdx,outportIdx);
end

