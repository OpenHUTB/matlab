
function outRange=calcMultiplyRange(inRangeOne,inRangeTwo,isComplex)
    import Simulink.FixedPointAutoscaler.InternalRange

    if nargin<3
        isComplex=false;
    end

    if isComplex
        outRange=mulRangeCpx(inRangeOne,inRangeTwo);
    else
        outRange=InternalRange.calcMultiRangeOp(@mulRangeReal,isComplex,inRangeOne,inRangeTwo);
    end
end

function outRange=mulRangeCpx(inRangeOne,inRangeTwo)
    import Simulink.FixedPointAutoscaler.InternalRange






    rangeRe=InternalRange.calcMultiRangeOp(@InternalRange.calcMultiplyRange,false,inRangeOne,inRangeTwo);
    rangeReSub=InternalRange.calcMultiRangeOp(@InternalRange.calcSubtractRange,false,rangeRe,rangeRe);
    re=InternalRange.mergeRange(rangeRe,rangeReSub);


    rangeIm=InternalRange.calcMultiRangeOp(@InternalRange.calcMultiplyRange,false,inRangeOne,inRangeTwo);
    rangeImAdd=InternalRange.calcMultiRangeOp(@InternalRange.calcAddRange,false,rangeRe,rangeRe);
    im=InternalRange.mergeRange(rangeIm,rangeImAdd);




    inverseRe=invertRange(rangeRe);
    outRange=InternalRange.mergeRange(re,im,inverseRe);
end

function outRange=mulRangeReal(inRangeOne,inRangeTwo,~)
    import Simulink.FixedPointAutoscaler.InternalRange
    outRange=InternalRange.cartesianRange(inRangeOne,inRangeTwo,@(a,b)(a*b));
end

function range=invertRange(inRange)
    range=sort(inRange*-1);
end
