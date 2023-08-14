function visitStatementWrapper(visitor,Stmt)






    visitThisStmt=isempty(Stmt.VisitorIndex);

    visitStatementWrapper@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Stmt);



    isFixedVar=true;
    storeForwardMemoryRAD(visitor,visitThisStmt,isFixedVar);

end
