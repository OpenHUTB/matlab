classdef Statement<handle





    properties

LHSASTVars

StatementExpr
    end

    methods

        function asmt=Statement(lhs,stmt)
            asmt.LHSASTVars=lhs;
            asmt.StatementExpr=stmt;
        end

        function[stmt,lhsVar]=getData(Statement)
            stmt=Statement.StatementExpr;
            lhsVar=Statement.LHSASTVars;
        end
    end
end
