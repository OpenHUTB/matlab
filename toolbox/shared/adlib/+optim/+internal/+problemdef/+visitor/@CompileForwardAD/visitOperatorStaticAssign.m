function visitOperatorStaticAssign(visitor,Op,Node)





    LHS=Node.ExprLeft;
    leftJacName=popNodeJac(visitor,LHS);


    addParens=0;
    [rightJacVarName,~,isRightJacArg]=getChildJacArgumentName(...
    visitor,2,addParens);


    if~(isRightJacArg&&strcmp(leftJacName,rightJacVarName))


        asmtStr=leftJacName+" = "+rightJacVarName+";"+newline;


        visitor.ExprAndJacBody=visitor.ExprAndJacBody+asmtStr;
    end




    pushNodeJacIsAllZero(visitor,LHS,false);


    visitOperatorStaticAssign@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Op,Node);

end
