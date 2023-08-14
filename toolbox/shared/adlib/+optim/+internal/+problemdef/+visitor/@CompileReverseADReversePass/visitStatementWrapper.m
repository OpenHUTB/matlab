function visitStatementWrapper(visitor,Stmt)





    visitThisNode=getForwardMemory(visitor);

    if visitThisNode


        lhsImplList=Stmt.LHSImplList;
        numLHS=numel(lhsImplList);
        for n=1:numLHS
            thisLHS=lhsImplList{n};


            initializeLHS(visitor,thisLHS);
        end

        nStmt=Stmt.NumStatements;
        stmtList=Stmt.StatementList;
        for n=nStmt:-1:1

            acceptVisitor(stmtList{n},visitor);
        end
    end

end
