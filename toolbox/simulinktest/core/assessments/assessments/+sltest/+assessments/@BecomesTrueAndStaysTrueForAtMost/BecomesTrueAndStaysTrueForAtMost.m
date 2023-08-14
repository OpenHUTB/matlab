


classdef(Sealed)BecomesTrueAndStaysTrueForAtMost<sltest.assessments.BinaryDuration
    methods
        function self=BecomesTrueAndStaysTrueForAtMost(duration,expr)
            self@sltest.assessments.BinaryDuration(sltest.assessments.BecomesTrue(expr),sltest.assessments.StaysTrueForAtMost(duration,expr),duration);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.left.internal&self.right.internal,self.left.internal,' and stays true for at most ',self.duration,' seconds');
        end
    end
end

