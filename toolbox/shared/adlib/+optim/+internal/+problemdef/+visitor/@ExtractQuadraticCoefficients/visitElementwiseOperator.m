function visitElementwiseOperator(visitor,op,Node)





    [bLeft,~,HLeft]=popChild(visitor,1);
    [bRight,~,HRight]=popChild(visitor,2);


    visitElementwiseOperator@optim.internal.problemdef.visitor.ExtractLinearCoefficients(...
    visitor,op,Node);


    HRight=evaluate(op,sparse(0),HRight,visitor);

    nExpr=max(numel(bLeft),numel(bRight));
    if isscalar(bLeft)
        HLeft=repmat(HLeft,nExpr,1);
    end
    if isscalar(bRight)
        HRight=repmat(HRight,nExpr,1);
    end

    if nnz(HLeft)<1
        Hval=HRight;
    elseif nnz(HRight)<1
        Hval=HLeft;
    else
        Hval=HLeft+HRight;
    end


    pushH(visitor,Hval);

end
