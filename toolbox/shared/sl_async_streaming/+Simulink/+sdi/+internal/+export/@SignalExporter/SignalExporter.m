classdef SignalExporter<Simulink.sdi.internal.export.ElementExporter



    methods

        function ret=getDomainType(~)
            ret='';
        end


        function ret=exportElement(~,ret,dataStruct)
            ret.Name=dataStruct.Name;
            ret.BlockPath=dataStruct.BlockPath;
            ret.PortType='outport';
            values=dataStruct.Values;
            if dataStruct.PortIndex>1
                ret.PortIndex=dataStruct.PortIndex;
            end
            if~isempty(dataStruct.LoggedName)||~isempty(dataStruct.PropName)||~isempty(dataStruct.SignalName)
                ret.Name=dataStruct.LoggedName;
                ret.PropagatedName=dataStruct.PropName;
                if isa(values,'timeseries')
                    for idx=1:length(values)
                        values(idx).Name=dataStruct.SignalName;
                    end
                end
            end
            ret.Values=values;
        end

    end

end
