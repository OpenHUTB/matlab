function[rApprox,continuedFractions,rError]=ratRecovery(u)


























































    validateattributes(u,{'numeric','embedded.fi','logical'},{'real','finite','numel',1});

    nt=fixed.internal.type.extractNumericType(u);

    assert(fixed.internal.type.isTrivialSlopeAdjustBias(nt),'Only binary point scaling is supported.')


    assert(u>0);

    rOrig=getExactRat(u);
    distPrevNext=fixed.internal.math.distPrevNext(u);
    rHalf=fixed.internal.ratPlus(1,2);
    rLowerBound=rOrig-(getExactRat(distPrevNext.DistPrev).*rHalf);
    rUpperBound=rOrig+(getExactRat(distPrevNext.DistNext).*rHalf);

    [rApprox,continuedFractions,rError]=fixed.internal.ratApproxInBounds(rOrig,rLowerBound,rUpperBound);
    if u<0
        rApprox=-rApprox;
    end
end

function y=getExactRat(u)

    ut=fixed.internal.type.tightFi(u);
    y=fixed.internal.ratPlus(ut);
end


