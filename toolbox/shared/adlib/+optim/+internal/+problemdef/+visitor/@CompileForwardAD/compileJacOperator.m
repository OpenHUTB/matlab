function compileJacOperator(visitor,op,~)





    addParens=1;
    [leftJacVarName,leftJacParens]=getChildJacArgumentName(visitor,1,addParens);
    [rightJacVarName,rightJacParens]=getChildJacArgumentName(visitor,2,leftJacParens+addParens);


    [jacStr,jacNumParens]=buildNonlinearStr(op,visitor,...
    leftJacVarName,rightJacVarName,leftJacParens,rightJacParens);
    jacIsArgOrVar=false;
    jacIsAllZero=false;


    pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);

end
