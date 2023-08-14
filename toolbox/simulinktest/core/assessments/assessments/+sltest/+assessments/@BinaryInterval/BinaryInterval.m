


classdef(Abstract,...
    AllowedSubclasses={
    ?sltest.assessments.Until
    })BinaryInterval<sltest.assessments.Binary
    properties(SetAccess=immutable)
interval
    end

    methods(Access=protected,Hidden)
        function self=BinaryInterval(left,interval,right)
            self@sltest.assessments.Binary(left,right);
            self.interval=interval;
        end
    end
end
