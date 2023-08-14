


classdef(Sealed)StaysTrueForAtLeast<sltest.assessments.UnaryDuration
    methods
        function self=StaysTrueForAtLeast(duration,expr)
            self@sltest.assessments.UnaryDuration(duration,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.globally([0,self.duration]),self.expr.internal,' stays true for at least ',self.duration);
        end
    end
end
