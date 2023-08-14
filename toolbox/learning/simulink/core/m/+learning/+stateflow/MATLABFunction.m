
classdef MATLABFunction<handle



    properties
Name
Inputs
Outputs
Function
    end

    methods
        function obj=MATLABFunction(Name)

            if nargin>0
                obj.Name=Name;
            end
        end
    end
end