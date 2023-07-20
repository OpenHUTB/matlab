


classdef(Sealed)IsTrueAndStaysTrueForAtLeast<sltest.assessments.UnaryDuration
    methods
        function self=IsTrueAndStaysTrueForAtLeast(duration,expr)
            self@sltest.assessments.UnaryDuration(duration,expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.globally([0,self.duration]),self.expr.internal,' must stay true for at least ',self.duration,' seconds');
        end
    end
end

