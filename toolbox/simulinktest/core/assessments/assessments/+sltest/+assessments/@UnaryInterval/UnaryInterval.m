


classdef(Abstract,...
    AllowedSubclasses={
    ?sltest.assessments.Eventually
    ?sltest.assessments.Globally
    ?sltest.assessments.StaysTrueForBetween
    ?sltest.assessments.AfterBetweenDelay
    ?sltest.assessments.IsTrueAndStaysTrueForBetween
    })UnaryInterval<sltest.assessments.Unary
    properties(SetAccess=immutable)
interval
    end

    methods(Access=protected,Hidden)
        function self=UnaryInterval(interval,expr)
            self@sltest.assessments.Unary(expr);
            self.interval=interval;
        end
    end
end
