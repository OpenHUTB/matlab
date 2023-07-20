function compileNoSubsasgnWithSubsref(visitor,treeHeadIdx,treeIdxStr)









    addParens=Inf;
    [treeJacStr,jacNumParens,~,jacIsAllZero]=getChildJacArgumentName(visitor,treeHeadIdx,addParens);


    compileNoSubsasgnWithSubsref@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,...
    treeHeadIdx,treeIdxStr);



    treeJacIdxStr="(:,"+treeIdxStr+")";


    forestJacStr=treeJacStr+treeJacIdxStr;
    jacNumParens=jacNumParens+2;
    jacIsArgOrVar=false;


    pushJac(visitor,forestJacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);
end
