classdef ValueConstraints<handle

    methods
        function obj=ValueConstraints(pdef,pmin,pmax,pposs)
            obj.DefaultValue=pdef;
            obj.MinValue=pmin;
            obj.MaxValue=pmax;
            obj.PossibleValues=pposs;
        end
    end

    properties(SetAccess=private)
DefaultValue
MinValue
MaxValue
PossibleValues
    end

end
