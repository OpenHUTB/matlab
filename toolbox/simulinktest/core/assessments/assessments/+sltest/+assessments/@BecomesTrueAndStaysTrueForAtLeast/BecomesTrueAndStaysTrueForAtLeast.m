


classdef(Sealed)BecomesTrueAndStaysTrueForAtLeast<sltest.assessments.BinaryDuration
    methods
        function self=BecomesTrueAndStaysTrueForAtLeast(duration,expr)
            self@sltest.assessments.BinaryDuration(sltest.assessments.BecomesTrue(expr),sltest.assessments.StaysTrueForAtLeast(duration,expr),duration);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.left.internal&self.right.internal,self.left.internal,' and stays true for at least ',self.duration,' seconds');
        end
    end
end

