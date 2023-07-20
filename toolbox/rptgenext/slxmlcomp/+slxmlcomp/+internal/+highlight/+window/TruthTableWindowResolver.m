classdef TruthTableWindowResolver<handle




    properties(Access=private)
        SupportedTypes=["ConditionTable","TruthTableChart",...
        "SimulinkTruthTable","StateflowTruthTable"]
    end

    methods(Access=public)

        function windowInfo=getInfo(obj,location)
            if any(obj.SupportedTypes==location.Type)
                stateflowInfo=slxmlcomp.internal.stateflow.stateflowPathToStruct(location.Location);
                blockPath=string(stateflowInfo.Block);
                windowInfo=struct(...
                'Type','Simulink',...
                'Id',blockPath.extractBefore('/')...
                );
            else
                windowInfo=[];
            end

        end

    end

end
