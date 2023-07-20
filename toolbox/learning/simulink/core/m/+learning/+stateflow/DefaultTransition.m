

classdef DefaultTransition<learning.stateflow.Transition



    methods
        function obj=DefaultTransition(LabelString)

            obj@learning.stateflow.Transition();
            if nargin>0
                obj.LabelString=LabelString;
            end
            obj.Source='';
        end
    end
end

