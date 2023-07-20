


classdef(Sealed)AfterAtMostDelay<sltest.assessments.UnaryDuration
    methods
        function self=AfterAtMostDelay(duration,expr)
            self@sltest.assessments.UnaryDuration(duration,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.eventually([0,self.duration]),'with a delay of at most ',self.duration,' seconds, ',self.expr.internal);
        end
    end
end
