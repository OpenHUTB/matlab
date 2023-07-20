

function outRange=calcDivideRange(inRangeOne,inRangeTwo,isComplex)

    import Simulink.FixedPointAutoscaler.InternalRange
    if nargin<3
        isComplex=false;
    end

    if isComplex
        outRange=divRangeCpx(inRangeOne,inRangeTwo);
    else
        outRange=InternalRange.calcMultiRangeOp(@divRangeReal,isComplex,inRangeOne,inRangeTwo);
    end
end

function outRange=divRangeReal(inRangeOne,inRangeTwo,~)
    import Simulink.FixedPointAutoscaler.InternalRange
    if(min(inRangeTwo)<=0&&max(inRangeTwo)>=0)
        outRange=[-inf,inf];
    else
        outRange=InternalRange.cartesianRange(inRangeOne,inRangeTwo,@(a,b)(a/b));
    end
end

function outRange=divRangeCpx(inRangeOne,inRangeTwo)
    import Simulink.FixedPointAutoscaler.InternalRange





    rangeSq=InternalRange.calcSquareRange(inRangeTwo);
    rangeSqAdd=InternalRange.calcMultiRangeOp(@InternalRange.calcAddRange,false,rangeSq,rangeSq);
    rangeDenom=InternalRange.mergeRange(rangeSqAdd,rangeSq);


    rangeRe=InternalRange.calcMultiRangeOp(@InternalRange.calcMultiplyRange,false,inRangeOne,inRangeTwo);
    rangeReAdd=InternalRange.calcMultiRangeOp(@InternalRange.calcAddRange,false,rangeRe,rangeRe);
    rangeReDiv=InternalRange.calcMultiRangeOp(@InternalRange.calcDivideRange,false,rangeReAdd,rangeDenom);
    re=InternalRange.mergeRange(rangeRe,rangeReAdd);
    re=InternalRange.mergeRange(re,rangeDenom);
    re=InternalRange.mergeRange(re,rangeReDiv);


    rangeIm=InternalRange.calcMultiRangeOp(@InternalRange.calcMultiplyRange,false,inRangeOne,inRangeTwo);
    rangeImSub=InternalRange.calcMultiRangeOp(@InternalRange.calcAddRange,rangeIm,rangeIm);
    rangeImDiv=InternalRange.calcMultiRangeOp(@InternalRange.calcDivideRange,false,rangeImSub,rangeDenom);
    im=InternalRange.mergeRange(rangeIm,rangeImSub);
    im=InternalRange.mergeRange(im,rangeDenom);
    im=InternalRange.mergeRange(im,rangeImDiv);

    outRange=InternalRange.mergeRange(re,im);
end