




classdef LoggingSpecification<matlab.mixin.Copyable
    properties(Access=private)
LoggingSpecificationImpl
    end

    properties(Dependent,SetAccess=private,GetAccess=public)
SignalsToLog
    end

    methods
        function obj=LoggingSpecification()
            obj.LoggingSpecificationImpl=getSimulationInputLoggingSpecificationImpl();
        end

        function sigs=get.SignalsToLog(obj)
            sigs=obj.LoggingSpecificationImpl.SignalsToLog;
        end

        function addSignalsToLog(obj,varargin)
            obj.LoggingSpecificationImpl.addSignalsToLog(varargin{:});
        end

        function removeSignalsToLog(obj,sigs)
            obj.LoggingSpecificationImpl.removeSignalsToLog(sigs);
        end

        function applyToModel(obj)
            for i=1:length(obj.SignalsToLog)
                signalToLog=obj.SignalsToLog(i);
                block=signalToLog.BlockPath.getLastPath;
                portHandle=get_param(block,'PortHandles');
                outport=portHandle.Outport(signalToLog.OutputPortIndex);
                set_param(outport,'DataLogging','on');
            end
        end
    end

    methods(Hidden=true)
        function dlo=getSignalsToLog(obj,modelName)
            dlo=obj.LoggingSpecificationImpl.getSignalsToLog(modelName);
        end
    end
end