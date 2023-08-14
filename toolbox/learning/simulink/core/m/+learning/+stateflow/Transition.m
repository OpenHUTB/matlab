

classdef Transition<handle



    properties
LabelString
ExecutionOrder
Source
Destination
    end

    methods
        function obj=Transition(LabelString)


            if nargin>0
                obj.LabelString=LabelString;
            end
        end
    end
end

