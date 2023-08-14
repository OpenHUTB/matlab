function nlpComplError=computeComplError(fscales,xCurrent,mIneq,cIneq,finiteLB,mLB,lb,finiteUB,mUB,ub,lambda,iL0)
















%#codegen

    coder.allowpcode('plain');


    validateattributes(fscales,{'struct'},{'scalar'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(cIneq,{'double'},{'2d'});
    validateattributes(finiteLB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(finiteUB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mUB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(lambda,{'double'},{'2d'});
    validateattributes(iL0,{coder.internal.indexIntClass},{'scalar'});

    nlpComplError=0.0;

    mLinIneq=coder.internal.indexInt(numel(fscales.lineq_constraint));
    mNonlinIneq=coder.internal.indexInt(numel(fscales.cineq_constraint));


    if(mIneq+mLB+mUB>0)


        iLineq0=iL0-1;
        for idx=1:mLinIneq
            minVal=min(abs(cIneq(idx)*lambda(iLineq0+idx)/fscales.objective),...
            min(abs(cIneq(idx))/fscales.lineq_constraint(idx),...
            lambda(iLineq0+idx)/fscales.objective*fscales.lineq_constraint(idx)));

            nlpComplError=max(nlpComplError,minVal);
        end

        iLineq0=iLineq0+mLinIneq;
        for idx=1:mNonlinIneq
            minVal=min(abs(cIneq(mLinIneq+idx)*lambda(iLineq0+idx)/fscales.objective),...
            min(abs(cIneq(mLinIneq+idx))/fscales.cineq_constraint(idx),...
            lambda(iLineq0+idx)/fscales.objective*fscales.cineq_constraint(idx)));

            nlpComplError=max(nlpComplError,minVal);
        end



        lbOffset=iL0+mIneq-1;
        ubOffset=lbOffset+mLB;
        for idx=1:mLB
            idxFiniteLB=finiteLB(idx);
            lbDelta=xCurrent(idxFiniteLB)-lb(idxFiniteLB);
            lbLambda=lambda(lbOffset+idx);
            minVal=min(abs(lbDelta*lbLambda/fscales.objective),...
            min(abs(lbDelta),lbLambda/fscales.objective));
            nlpComplError=max(nlpComplError,minVal);
        end

        for idx=1:mUB
            idxFiniteUB=finiteUB(idx);
            ubDelta=ub(idxFiniteUB)-xCurrent(idxFiniteUB);
            ubLambda=lambda(ubOffset+idx);
            minVal=min(abs(ubDelta*ubLambda/fscales.objective),...
            min(abs(ubDelta),ubLambda/fscales.objective));
            nlpComplError=max(nlpComplError,minVal);
        end
    end

end

