classdef SimulinkTimeseriesParser<Simulink.sdi.internal.import.TimeseriesParser



    methods


        function ret=supportsType(~,obj)
            ret=isa(obj,'Simulink.Timeseries');
        end


        function ret=getBlockSource(this)
            ret=this.VariableValue.BlockPath;

        end


        function ret=getSID(this)
            bpath=getBlockSource(this);
            try
                ret=Simulink.ID.getSID(bpath);
            catch me %#ok<NASGU>
                ret='';
            end
        end


        function ret=getModelSource(this)
            bpath=getBlockSource(this);
            ret=Simulink.SimulationData.BlockPath.getModelNameForPath(bpath);
        end


        function ret=getPortIndex(this)
            ret=this.VariableValue.PortIndex;
        end


        function ret=getInterpolation(~)
            ret='zoh';
        end


        function ret=getUnit(~)
            ret='';
        end
    end
end
