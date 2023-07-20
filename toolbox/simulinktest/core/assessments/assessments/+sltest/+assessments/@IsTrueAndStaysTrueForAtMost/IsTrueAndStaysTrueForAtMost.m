


classdef(Sealed)IsTrueAndStaysTrueForAtMost<sltest.assessments.UnaryDuration
    methods
        function self=IsTrueAndStaysTrueForAtMost(duration,expr)
            self@sltest.assessments.UnaryDuration(duration,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal&eventually(~self.expr.internal,[0,self.duration]),self.expr.internal,' must stay true for at most ',self.duration,' seconds');
        end
    end
end

