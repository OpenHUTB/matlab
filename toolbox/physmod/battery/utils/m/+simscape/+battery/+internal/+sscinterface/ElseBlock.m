classdef(Sealed,Hidden)ElseBlock<simscape.battery.internal.sscinterface.ConditionalBlock




    properties(Constant)
        Type="ElseBlock";
    end

    properties(Constant,Access=protected)
        Operator="else";
    end

    properties(Access=protected)
        Condition="";
    end

    methods
        function obj=ElseBlock()

        end
    end
end


