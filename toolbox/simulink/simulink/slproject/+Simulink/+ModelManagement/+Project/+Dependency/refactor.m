function refactor(jRegistry,jOldUpVertex,jOldDownVertex,jEdge,jNewPath)










    oldDep=convertEdge(jOldUpVertex,jOldDownVertex,jEdge);
    newPath=char(jNewPath);

    registry=eval(char(jRegistry.getMatlabRegistry));
    dependencies.internal.action.refactor(oldDep,newPath,registry.RefactoringHandlers);

end
