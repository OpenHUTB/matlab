function visitOperatorPlus(visitor,~,Node)





    curNodeIdx=visitor.CurNodeIdx;
    monomialFactor=visitor.MonomialFactor;
    isMonomialRoot=visitor.IsMonomialRoot;




    childIdx=getChildrenIndices(Node,curNodeIdx);

    isMonomialRoot(childIdx)=true;
    fac=monomialFactor(curNodeIdx);
    monomialFactor(childIdx)=fac;

    isMonomialRoot(curNodeIdx)=false;
    monomialFactor(curNodeIdx)=NaN;


    visitor.MonomialFactor=monomialFactor;
    visitor.IsMonomialRoot=isMonomialRoot;

end