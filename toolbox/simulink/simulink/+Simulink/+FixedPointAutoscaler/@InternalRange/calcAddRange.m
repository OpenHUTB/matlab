

function outRange=calcAddRange(inRangeOne,inRangeTwo,isComplex)

    if nargin<3
        isComplex=false;
    end

    outRange=Simulink.FixedPointAutoscaler.InternalRange.calcMultiRangeOp(@addRange,isComplex,inRangeOne,inRangeTwo);
end

function outRange=addRange(inRangeOne,inRangeTwo,~)
    outRange=inRangeOne+inRangeTwo;
end
