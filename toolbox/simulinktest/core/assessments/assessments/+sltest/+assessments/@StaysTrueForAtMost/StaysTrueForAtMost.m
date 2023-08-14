


classdef(Sealed)StaysTrueForAtMost<sltest.assessments.UnaryDuration
    methods
        function self=StaysTrueForAtMost(duration,expr)
            self@sltest.assessments.UnaryDuration(duration,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(eventually(~self.expr.internal,[0,self.duration]),self.expr.internal,' stays true for at most ',self.duration);
        end
    end
end
