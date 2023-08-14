


classdef(Sealed)Uminus<sltest.assessments.Unary
    methods
        function self=Uminus(expr)
            self@sltest.assessments.Unary(expr);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=-self.expr.internal;
        end
    end
end
