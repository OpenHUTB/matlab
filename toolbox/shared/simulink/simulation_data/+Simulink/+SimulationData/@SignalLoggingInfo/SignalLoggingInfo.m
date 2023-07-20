









classdef SignalLoggingInfo<Simulink.SimulationData.SignalObserverInfo


    methods


        function this=SignalLoggingInfo(varargin)


            this=this@Simulink.SimulationData.SignalObserverInfo(varargin{:});
        end
    end


    methods(Hidden=true)


        function structure=utStructWithEscapeCharForBlockPath(this)
            structure.BlockPath=this.blockPath_.utStringWithEscapeChar;
            structure.OutputPortIndex=this.outputPortIndex_;
            structure.LoggingInfo=this.loggingInfo_.get_struct;
        end
    end

end




