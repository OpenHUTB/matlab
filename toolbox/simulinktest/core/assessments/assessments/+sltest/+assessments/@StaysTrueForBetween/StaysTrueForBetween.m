


classdef(Sealed)StaysTrueForBetween<sltest.assessments.UnaryInterval
    methods
        function self=StaysTrueForBetween(interval,expr)
            self@sltest.assessments.UnaryInterval(interval,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.until(self.interval,~self.expr.internal),self.expr.internal,' stays true for at least ',self.interval(1),' and at most ',self.interval(2));
        end
    end
end
