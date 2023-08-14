function visitOperatorStaticSubsasgn(visitor,Op,Node)





    LHS=Node.ExprLeft;
    [leftSz,leftCanAD]=popNodePties(visitor,LHS);

    [rightSz,rightCanAD]=popChildPties(visitor,2);


    visitOperatorStaticSubsasgn@optim.internal.problemdef.visitor.ComputeType(visitor,Op,Node);


    canAD=supportsAD(Op,visitor)&&leftCanAD&&rightCanAD;


    [sz,idxSz]=getOutputSize(Op,leftSz,rightSz,visitor);


    pushNodePties(visitor,LHS,sz,canAD);


    if~isequal(LHS.Size,sz)




        error('shared_adlib:static:SizeChangeDetected','The size of the LHS must not change');
    end

    numIdx=Op.NumIndex;
    if~isequal(numIdx,prod(idxSz))



        error('shared_adlib:static:SizeChangeDetected','The size of the LHS must not change');
    end

    [~,val]=popNode(visitor,LHS);
    LHS.Value=val;

end
