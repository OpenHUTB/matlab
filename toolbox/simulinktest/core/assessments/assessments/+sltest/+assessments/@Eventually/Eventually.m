


classdef(Sealed)Eventually<sltest.assessments.UnaryInterval
    methods
        function self=Eventually(interval,expr)
            self@sltest.assessments.UnaryInterval(interval,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.expr.internal.eventually(self.interval);
        end
    end
end
