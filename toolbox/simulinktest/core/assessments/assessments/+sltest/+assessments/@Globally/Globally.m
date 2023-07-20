


classdef(Sealed)Globally<sltest.assessments.UnaryInterval
    methods
        function self=Globally(interval,expr)
            self@sltest.assessments.UnaryInterval(interval,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.expr.internal.globally(self.interval);
        end
    end
end
