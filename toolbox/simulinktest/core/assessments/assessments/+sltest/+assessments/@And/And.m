


classdef(Sealed)And<sltest.assessments.Binary
    methods
        function self=And(left,right)
            self@sltest.assessments.Binary(left,right);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.left.internal&self.right.internal;
        end
    end
end
