


classdef(Sealed)StaysTrueUntil<sltest.assessments.BinaryDuration
    methods
        function self=StaysTrueUntil(left,duration,right)
            self@sltest.assessments.BinaryDuration(left,right,duration);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(until(self.left.internal,[0,self.duration],self.right.internal),self.left.internal,' stays true until ',self.right.internal,' becomes true within ',self.duration);
        end
    end
end
