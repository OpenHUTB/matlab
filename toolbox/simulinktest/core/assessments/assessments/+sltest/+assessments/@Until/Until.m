


classdef(Sealed)Until<sltest.assessments.BinaryInterval
    methods
        function self=Until(left,interval,right)
            self@sltest.assessments.BinaryInterval(left,interval,right);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=self.left.internal.until(self.interval,self.right.internal);
        end
    end
end
