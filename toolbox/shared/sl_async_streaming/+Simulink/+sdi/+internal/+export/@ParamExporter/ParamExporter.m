classdef ParamExporter<Simulink.sdi.internal.export.ElementExporter



    methods

        function ret=getDomainType(~)
            ret='param';
        end


        function ret=exportElement(~,~,dataStruct)
            ret=Simulink.SimulationData.Parameter;
            ret.Name=dataStruct.Name;
            ret.BlockPath=dataStruct.BlockPath;
            ret.Values=dataStruct.Values;
            ret.ParameterName=dataStruct.PropName;
            ret.VariableName=dataStruct.SignalName;
            if isa(ret.Values,'timeseries')
                ret.Values.Name=dataStruct.SignalName;
            end
        end

    end

end
