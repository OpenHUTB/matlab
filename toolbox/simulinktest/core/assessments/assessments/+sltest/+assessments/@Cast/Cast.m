


classdef(Sealed)Cast<sltest.assessments.Unary
    properties(SetAccess=immutable)
targetType
saturate
    end

    methods
        function self=Cast(expr,targetType,saturate)
            self@sltest.assessments.Unary(expr);
            self.targetType=targetType;
            if nargin<3
                self.saturate=true;
            else
                self.saturate=saturate;
            end
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            if(self.saturate)
                internal=self.expr.internal.cast(self.targetType);
            else
                internal=self.expr.internal.cast_no_saturation(self.targetType);
            end
        end
    end
end
