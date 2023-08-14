classdef StatementWrapper<optim.internal.problemdef.ExpressionImpl





    properties(Hidden=true)


StatementList

NumStatements



LHSImplList
    end

    properties(Hidden)
        SupportsAD;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        StatementWrapperVersion=1;
    end

    methods


        function obj=StatementWrapper(lhsImplList,stmtExprList)
            obj.LHSImplList=lhsImplList;
            obj.StatementList=cellfun(@wrapInputs,stmtExprList,'UniformOutput',false);
            obj.NumStatements=numel(stmtExprList);
        end



        function addInitializations(obj,initExprList)
            newStatementList=cellfun(@wrapInputs,initExprList,'UniformOutput',false);
            numStatements=numel(newStatementList);
            obj.StatementList=[newStatementList,obj.StatementList];
            obj.NumStatements=obj.NumStatements+numStatements;
        end



        function addLHSImpl(obj,newStmtLHSImpl)
            obj.LHSImplList=newStmtLHSImpl;
        end





        function depth=getDepth(obj)
            depth=cellfun(@(stmt)stmt.Depth,obj.StatementList);
            depth=max(depth);
        end


        function vars=getVariables(StmtWrapper)

            vars=cellfun(@(stmt)stmt.Variables,StmtWrapper.StatementList,...
            'UniformOutput',false);

            vars=optim.internal.problemdef.HashMapFunctions.arrayunion(vars,...
            'OptimizationExpression');
        end

    end

    methods(Hidden)


        function acceptVisitor(obj,visitor)
            visitStatementWrapper(visitor,obj);
        end

    end

end


function input=wrapInputs(input)
    input=forest2tree(getExprImpl(input));
end
