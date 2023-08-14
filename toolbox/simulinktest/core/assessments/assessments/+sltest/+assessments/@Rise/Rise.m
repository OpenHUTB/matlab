


classdef(Sealed)Rise<sltest.assessments.Unary
    properties(SetAccess=immutable)
delay
relativeValue
    end

    methods
        function self=Rise(delay,expr,relativeValue)
            self@sltest.assessments.Unary(expr);
            self.delay=delay;
            self.relativeValue=relativeValue;
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.expr.internal.shift(self.delay)-self.expr.internal>=self.relativeValue,...
            'Rise(',self.delay,',',self.expr.internal,',',self.relativeValue,')');
        end
    end
end

