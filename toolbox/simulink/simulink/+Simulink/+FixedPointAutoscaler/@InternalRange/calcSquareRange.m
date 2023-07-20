

function outRange=calcSquareRange(inRange,isComplex)

    if nargin<2
        isComplex=false;
    end






    if size(inRange,1)==1
        outRange=sqRange(inRange,isComplex);
    else
        outRange=Simulink.FixedPointAutoscaler.InternalRange.calcMultiplyRange(inRange,inRange,isComplex);
    end
end

function outRange=sqRange(inRange,isComplex)



    if isComplex

        rangeA2=Simulink.FixedPointAutoscaler.InternalRange.calcSquareRange(inRange);
        rangeDiff=Simulink.FixedPointAutoscaler.InternalRange.calcSubtractRange(rangeA2,rangeA2);
        rangeMul=2*Simulink.FixedPointAutoscaler.InternalRange.calcMultiplyRange(inRange,inRange);

        outRange=Simulink.FixedPointAutoscaler.InternalRange.unionRange(rangeDiff,rangeMul);
    else
        if(min(inRange)>=0)
            outRange=[min(inRange)^2,max(inRange)^2];
        else
            outRange=[0,max(max(inRange)^2,min(inRange)^2)];
        end
    end
end
