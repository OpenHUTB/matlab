classdef(Hidden=true)PortParameter
    properties(SetAccess=private,GetAccess=public)
PortHandle
Name
Value
    end

    methods
        function obj=PortParameter(ph,name,value)
            obj.PortHandle=ph;
            obj.Name=name;
            obj.Value=value;
        end
    end
end
