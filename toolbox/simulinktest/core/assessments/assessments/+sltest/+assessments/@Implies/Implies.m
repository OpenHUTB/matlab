


classdef(Sealed)Implies<sltest.assessments.Binary
    methods
        function self=Implies(left,right)
            self@sltest.assessments.Binary(left,right);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.left.internal.implies(self.right.internal);
        end
    end
end
