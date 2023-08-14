classdef DeployedLoggingSpecificationImpl<Simulink.Simulation.internal.LoggingSpecificationImpl
    properties(SetAccess=private,GetAccess=public)
        SignalsToLog=[]
    end

    methods
        function addSignalsToLog(~,varargin)
        end

        function removeSignalsToLog(~,~)
        end
    end

    methods(Hidden=true)
        function dlo=getSignalsToLog(~,~)
        end
    end
end