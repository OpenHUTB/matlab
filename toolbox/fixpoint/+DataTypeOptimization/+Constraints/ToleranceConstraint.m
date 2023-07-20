classdef(Abstract)ToleranceConstraint<DataTypeOptimization.Constraints.AbstractConstraint






    properties(SetAccess=protected,GetAccess=public)
        loggingInfo Simulink.SimulationData.SignalLoggingInfo
    end

    methods
        function initializeConstraint(this,path,portIndex,value)
            this.loggingInfo=Simulink.SimulationData.SignalLoggingInfo(path,portIndex);
            this.value=value;
        end

        function setLoggingInfo(this,loggingInfo)
            validateattributes(loggingInfo,{'Simulink.SimulationData.LoggingInfo'},{'scalar'});
            this.loggingInfo.LoggingInfo=loggingInfo;
        end

    end

    methods(Hidden)
        function p=getPath(this)
            p=this.loggingInfo.BlockPath.convertToCell{1};
        end

        function p=getPortIndex(this)
            p=this.loggingInfo.OutputPortIndex;
        end
    end

end