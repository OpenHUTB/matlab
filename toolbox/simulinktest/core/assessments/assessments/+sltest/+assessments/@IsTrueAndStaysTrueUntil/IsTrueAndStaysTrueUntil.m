


classdef(Sealed)IsTrueAndStaysTrueUntil<sltest.assessments.BinaryDuration
    methods
        function self=IsTrueAndStaysTrueUntil(left,duration,right)
            self@sltest.assessments.BinaryDuration(left,right,duration);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.left.internal&until(self.left.internal,[0,self.duration],self.right.internal),self.left.internal,' must stay true until ',self.right.internal,' becomes true (within ',self.duration,' seconds)');
        end
    end
end

