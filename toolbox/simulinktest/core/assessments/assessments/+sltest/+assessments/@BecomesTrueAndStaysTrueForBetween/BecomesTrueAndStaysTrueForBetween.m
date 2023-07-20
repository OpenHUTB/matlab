


classdef(Sealed)BecomesTrueAndStaysTrueForBetween<sltest.assessments.BinaryDuration
    methods
        function self=BecomesTrueAndStaysTrueForBetween(duration,expr)
            self@sltest.assessments.BinaryDuration(sltest.assessments.BecomesTrue(expr),sltest.assessments.StaysTrueForBetween(duration,expr),duration);
            self=self.initializeInternal();
        end
    end

    methods(Access=protected,Hidden)
        function internal=constructInternal(self)
            internal=alias(self.left.internal&self.right.internal,self.left.internal,' and stays true for between ',self.duration(1),' seconds and ',self.duration(2),' seconds');
        end
    end
end

