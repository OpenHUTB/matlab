

function range=calcInverseRange(obj,inRange,inDim,isComplex)

    if obj.isScalar(inDim)&&~isComplex
        range=obj.calcDivideRange([1,1],inRange,isComplex);
    else
        range=[-Inf,Inf];
    end
end