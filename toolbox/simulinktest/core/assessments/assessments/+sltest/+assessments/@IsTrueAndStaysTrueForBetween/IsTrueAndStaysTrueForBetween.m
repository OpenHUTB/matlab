


classdef(Sealed)IsTrueAndStaysTrueForBetween<sltest.assessments.UnaryInterval
    methods
        function self=IsTrueAndStaysTrueForBetween(interval,expr)
            self@sltest.assessments.UnaryInterval(interval,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal&self.expr.internal.until(self.interval,~self.expr.internal),self.expr.internal,' must stay true for at least ',self.interval(1),' seconds and at most ',self.interval(2),' seconds');
        end
    end
end

