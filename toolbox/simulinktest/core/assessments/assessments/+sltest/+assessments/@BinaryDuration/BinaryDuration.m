


classdef(Abstract,...
    AllowedSubclasses={
    ?sltest.assessments.IfThenAfter
    ?sltest.assessments.IfThenAtFallingEdge
    ?sltest.assessments.StaysTrueUntil
    ?sltest.assessments.BecomesTrueAndStaysTrueForAtLeast
    ?sltest.assessments.BecomesTrueAndStaysTrueForAtMost
    ?sltest.assessments.BecomesTrueAndStaysTrueForBetween
    ?sltest.assessments.IsTrueAndStaysTrueForAtLeast
    ?sltest.assessments.IsTrueAndStaysTrueForAtMost
    ?sltest.assessments.IsTrueAndStaysTrueForBetween
    ?sltest.assessments.IsTrueAndStaysTrueUntil
    })BinaryDuration<sltest.assessments.Binary
    properties(SetAccess=immutable)
duration
    end

    methods(Access=protected,Hidden)
        function self=BinaryDuration(left,right,duration)
            self@sltest.assessments.Binary(left,right);
            self.duration=duration;
        end
    end
end
