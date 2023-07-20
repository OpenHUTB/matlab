


classdef(Sealed)IfThenAfterAtMost<sltest.assessments.BinaryDuration
    methods
        function self=IfThenAfterAtMost(left,right,duration)
            self@sltest.assessments.BinaryDuration(left,right,duration);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.left.internal.implies(self.right.internal.eventually([0,self.duration])),'If ',self.left.internal,' then after at most ',self.duration,' ',self.right.internal);
        end
    end
end
