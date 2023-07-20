classdef AssessmentHandle<sltest.expressions.mi.AssessmentHandle




    properties(SetAccess=private)




TestCase
    end

    properties(Dependent)
Expr
    end

    properties(Access=private)
ExprCached
    end

    methods(Access=private)
        function obj=AssessmentHandle()
            obj@sltest.expressions.mi.AssessmentHandle();
        end
    end

    methods(Static)
        function obj=makeMoveFrom(testCase,miAssessment)
            if~isa(miAssessment,"sltest.expressions.mi.AssessmentHandle")
                error("Argment must be sltest.expressions.mi.AssessmentHandle.");
            end
            obj=sltest.expressions.AssessmentHandle();
            obj.moveFrom(miAssessment);
            obj.TestCase=testCase;
        end
    end

    methods
        function expr=get.Expr(self)



            import sltest.expressions.*
            if isempty(self.ExprCached)
                self.ExprCached=ExprHandle.makeMoveFrom(self.ExprImpl);
            end
            expr=self.ExprCached;
        end

        function set.Expr(self,expr)
            self.ExprCached=[];
            self.setExprImpl(expr);
        end
    end
end

