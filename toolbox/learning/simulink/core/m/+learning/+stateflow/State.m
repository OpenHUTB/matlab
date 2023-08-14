

classdef State<handle



    properties
Name
LabelString
Inputs
Outputs
Entry
During
Exit
    end

    methods
        function obj=State(Name)


            if nargin>0


                obj.Name=Name;
            end
        end
    end
end

