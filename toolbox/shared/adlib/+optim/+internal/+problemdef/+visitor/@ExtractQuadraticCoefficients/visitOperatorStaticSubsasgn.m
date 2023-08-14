function visitOperatorStaticSubsasgn(visitor,Op,Node)





    LHS=Node.ExprLeft;
    [bLeft,ALeft,HLeft]=popQuadNode(visitor,LHS);

    [bRight,ARight,HRight]=popChild(visitor,2);


    nOut=prod(Op.LhsSize);
    nnzLeft=nnz(HLeft)>0;
    nnzRight=nnz(HRight)>0;
    nVar=visitor.TotalVar;


    if~nnzLeft&&~nnzRight
        visitOperatorStaticSubsasgn@optim.internal.problemdef.visitor.ExtractLinearCoefficients(visitor,Op,Node);
        Hval=[];
        pushHNode(visitor,LHS,Hval);
        return;
    end



    linIdx=getLinIndex(Op,Op.LhsSize,visitor);











    if nnzLeft
        Hval=HLeft;
    else
        Hval=sparse(nOut*nVar,nVar);
    end
    [Aval,bval]=visitor.extractLinearCoefficientsForSubsasgn(ALeft,bLeft,ARight,bRight,linIdx,nVar);



    if~nnzRight
        HRight=0;
    elseif isscalar(bRight)&&~isscalar(linIdx)
        HRight=repmat(HRight,numel(linIdx),1);
    end


    Hidx=(1:nVar)'+(linIdx(:)'-1)*nVar;
    Hval(Hidx,:)=HRight;


    pushQuadNode(visitor,LHS,Hval,Aval,bval);
end
