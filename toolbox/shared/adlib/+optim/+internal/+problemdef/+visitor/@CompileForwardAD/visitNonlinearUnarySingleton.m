function visitNonlinearUnarySingleton(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);


    visitNonlinearUnarySingleton@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);



    if isChildJacAllZero(visitor,1)

        pushJacAllZeros(visitor,numel(Node));
    else

        [gradStr,addParens]=getGradientString(op,leftVarName);


        [leftJacVarName,leftJacParens]=getChildJacArgumentName(visitor,1,addParens);






        jacStr=leftJacVarName+gradStr+".'";
        jacNumParens=leftJacParens+addParens;
        jacIsArgOrVar=false;
        jacIsAllZero=false;


        pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);
    end

end
