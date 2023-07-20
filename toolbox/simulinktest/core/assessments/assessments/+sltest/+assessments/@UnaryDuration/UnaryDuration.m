


classdef(Abstract,...
    AllowedSubclasses={
    ?sltest.assessments.AfterAtMostDelay
    ?sltest.assessments.StaysTrueFor
    ?sltest.assessments.StaysTrueForAtLeast
    ?sltest.assessments.StaysTrueForAtMost
    ?sltest.assessments.IsTrueAndStaysTrueForAtLeast
    ?sltest.assessments.IsTrueAndStaysTrueForAtMost
    })UnaryDuration<sltest.assessments.Unary
    properties(SetAccess=immutable)
duration
    end

    methods(Access=protected,Hidden)
        function self=UnaryDuration(duration,expr)
            self@sltest.assessments.Unary(expr);
            self.duration=duration;
        end
    end
end
