function visitOperatorUminus(visitor,~,~)






    curNodeIdx=visitor.CurNodeIdx;
    monomialFactor=visitor.MonomialFactor;
    isMonomialRoot=visitor.IsMonomialRoot;


    childIdx=curNodeIdx-1;

    isMonomialRoot(childIdx)=true;
    fac=monomialFactor(curNodeIdx);
    monomialFactor(childIdx)=-fac;

    isMonomialRoot(curNodeIdx)=false;
    monomialFactor(curNodeIdx)=NaN;


    visitor.MonomialFactor=monomialFactor;
    visitor.IsMonomialRoot=isMonomialRoot;

end