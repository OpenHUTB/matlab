


classdef(Sealed)AfterBetweenDelay<sltest.assessments.UnaryInterval
    methods
        function self=AfterBetweenDelay(delay,expr)
            self@sltest.assessments.UnaryInterval(delay,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.eventually(self.interval),'with a delay of between ',self.interval(1),' seconds and ',self.interval(2),' seconds, ',self.expr.internal);
        end
    end
end
