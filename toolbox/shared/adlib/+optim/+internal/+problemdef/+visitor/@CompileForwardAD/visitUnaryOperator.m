function visitUnaryOperator(visitor,op,Node)





    visitUnaryOperator@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
    visitor,op,Node);




    leftJacIsAllZero=isChildJacAllZero(visitor,1);
    if leftJacIsAllZero

        pushJacAllZeros(visitor,numel(Node));
        return;
    end



    addParens=getOutputParens(op);
    [leftJacVarName,leftJacParens]=getChildJacArgumentName(...
    visitor,1,addParens);


    [jacStr,jacNumParens]=buildNonlinearStr(op,visitor,...
    leftJacVarName,[],leftJacParens,[]);
    jacIsArgOrVar=false;
    jacIsAllZero=false;


    pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);

end
