classdef StateflowWindowResolver<handle




    properties(Access=private)
        SupportedTypes=["chart","state","transition","junction","SFBlock",...
        "truthTable","StateflowMatlabFunction","EMLChart",...
        "SimulinkMatlabFunction",...
        "TestSequenceChart","ConditionTable"]
    end

    methods(Access=public)

        function windowInfo=getInfo(obj,location)
            if any(obj.SupportedTypes==location.Type)
                windowInfo=struct(...
                'Type','Simulink',...
                'Id',string(location.Location).extractBefore('/')...
                );
            else
                windowInfo=[];
            end
        end

    end

end
