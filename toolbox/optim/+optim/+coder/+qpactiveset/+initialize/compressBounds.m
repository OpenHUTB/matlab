function[indexLB,mLB,indexUB,mUB,indexFixed,mFixed,maxAbsLB,maxAbsUB]=...
    compressBounds(nVar,indexLB,indexUB,indexFixed,lb,ub,NonFiniteSupport,ConstraintTolerance)















%#codegen

    coder.allowpcode('plain');


    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(indexLB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(indexUB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(indexFixed,{coder.internal.indexIntClass},{'2d'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(NonFiniteSupport,{'logical'},{'scalar'});
    validateattributes(ConstraintTolerance,{'double'},{'scalar'});

    coder.internal.prefer_const(lb,ub,NonFiniteSupport,ConstraintTolerance);

    mLB=coder.internal.indexInt(0);
    mUB=coder.internal.indexInt(0);
    mFixed=coder.internal.indexInt(0);

    maxAbsUB=0.0;
    maxAbsLB=0.0;

    if~isempty(ub)
        if~isempty(lb)

            for idx=1:nVar
                if optim.coder.utils.isFiniteLB(lb(idx))
                    if(abs(lb(idx)-ub(idx))<ConstraintTolerance)
                        mFixed=mFixed+1;
                        indexFixed(mFixed)=idx;
                        maxAbsUB=max(abs(ub(idx)),maxAbsUB);
                        maxAbsLB=max(abs(lb(idx)),maxAbsLB);
                        continue;
                    else
                        mLB=mLB+1;
                        indexLB(mLB)=idx;
                        maxAbsLB=max(abs(lb(idx)),maxAbsLB);
                    end
                end
                if optim.coder.utils.isFiniteUB(ub(idx))
                    mUB=mUB+1;
                    indexUB(mUB)=idx;
                    maxAbsUB=max(abs(ub(idx)),maxAbsUB);
                end
            end
        else

            for idx=1:nVar
                if optim.coder.utils.isFiniteUB(ub(idx))
                    mUB=mUB+1;
                    indexUB(mUB)=idx;
                    maxAbsUB=max(abs(ub(idx)),maxAbsUB);
                end
            end
        end
    elseif~isempty(lb)

        for idx=1:nVar
            if optim.coder.utils.isFiniteLB(lb(idx))
                mLB=mLB+1;
                indexLB(mLB)=idx;
                maxAbsLB=max(abs(lb(idx)),maxAbsLB);
            end
        end
    end

end

