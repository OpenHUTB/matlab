


classdef(Abstract,...
    AllowedSubclasses={...
    ?sltest.assessments.UnaryDuration
    ?sltest.assessments.UnaryInterval
    ?sltest.assessments.Not
    ?sltest.assessments.Uminus
    ?sltest.assessments.Abs
    ?sltest.assessments.Increasing
    ?sltest.assessments.StrictlyIncreasing
    ?sltest.assessments.Decreasing
    ?sltest.assessments.StrictlyDecreasing
    ?sltest.assessments.FallingStep
    ?sltest.assessments.RisingStep
    ?sltest.assessments.FallingEdge
    ?sltest.assessments.RisingEdge
    ?sltest.assessments.Fall
    ?sltest.assessments.Rise
    ?sltest.assessments.BecomesTrue
    ?sltest.assessments.WheneverIsTrue
    ?sltest.assessments.WithNoDelay
    ?sltest.assessments.Cast
    ?sltest.assessments.IsTrue
    })Unary<sltest.assessments.Expression
    properties(SetAccess=immutable)
expr
    end

    methods
        function res=children(self)
            res={self.expr};
        end

        function visit(self,functionHandle)
            functionHandle(self);
            self.expr.visit(functionHandle);
        end

        function res=transform(self,functionHandle)
            res=functionHandle(self,[]);
            res.children={self.expr.transform(functionHandle)};
        end
    end

    methods(Access=protected,Hidden)
        function self=Unary(expr)
            self.expr=expr;
        end
    end
end
