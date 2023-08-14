function visitOperatorStaticSubsasgn(visitor,Op,Node)





    LHS=Node.ExprLeft;
    leftJacName=popNodeJac(visitor,LHS);


    addParens=0;
    rightJacName=getChildJacArgumentName(visitor,2,addParens);


    addParens=1;
    [linIdxStr,~,linIdxBody]=compileStaticLinIdxString(visitor,Op,addParens);


    linIdxStrJac="(:, "+linIdxStr+")";


    if isscalar(Node.ExprRight)&&Op.NumIndex>1


        subsStr=leftJacName+linIdxStrJac+" = "+...
        "repmat("+rightJacName+", "+...
        "1, "+Op.NumIndex+");"+newline;
    else


        subsStr=leftJacName+linIdxStrJac+" = "+...
        rightJacName+";"+newline;
    end


    visitor.ExprAndJacBody=visitor.ExprAndJacBody+linIdxBody+subsStr;




    pushNodeJacIsAllZero(visitor,LHS,false);


    visitOperatorStaticSubsasgn@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Op,Node);

end
