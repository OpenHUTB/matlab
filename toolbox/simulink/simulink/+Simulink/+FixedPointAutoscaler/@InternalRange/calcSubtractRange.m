

function outRange=calcSubtractRange(inRangeOne,inRangeTwo,isComplex)

    if nargin<3
        isComplex=false;
    end

    outRange=Simulink.FixedPointAutoscaler.InternalRange.calcMultiRangeOp(@subRange,isComplex,inRangeOne,inRangeTwo);
end

function outRange=subRange(inRangeOne,inRangeTwo,~)



    outRange=inRangeOne-fliplr(inRangeTwo);
end

