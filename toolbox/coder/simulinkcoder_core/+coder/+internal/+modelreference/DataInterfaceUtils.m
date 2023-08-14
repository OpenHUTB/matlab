


classdef DataInterfaceUtils<handle
    methods(Static,Access=public)
        function status=isGlobalTid(dataInterface)
            status=regexp(dataInterface.GraphicalName,'GlobalTID');
        end


        function varIndexes=getVariableIndexesFromIdentifier(dataInterfaces,regExpression)
            numberOfDataInterfaces=length(dataInterfaces);
            varIndexes=-ones(numberOfDataInterfaces,1);
            for idx=1:numberOfDataInterfaces
                varInfo=regexp(dataInterfaces(idx).Implementation.Identifier,regExpression,'tokens','once');
                if~isempty(varInfo)
                    varIndexes(idx)=str2double(varInfo{1});
                end
            end
        end


        function hasVarDim=hasVardimPort(ports)
            hasVarDim=false;
            numberOfPorts=length(ports);

            if(numberOfPorts==1)
                hasVarDim=ports.IsVarDim;
            else
                for portIdx=1:numberOfPorts
                    if ports{portIdx}.IsVarDim
                        hasVarDim=true;
                        return;
                    end
                end
            end
        end


        function status=isCustomExpression(dataInterface)
            status=isa(dataInterface.Implementation,'RTW.CustomExpression');
        end
    end
end
