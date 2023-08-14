classdef StateExporter<Simulink.sdi.internal.export.ElementExporter





    methods

        function ret=getDomainType(~)
            ret={'state','final_state'};
        end


        function ret=exportElement(~,~,dataStruct)
            ret=Simulink.SimulationData.State;
            ret.BlockPath=dataStruct.BlockPath;
            ret.Values=dataStruct.Values;

            if isempty(dataStruct.LoggedName)
                ret.Name=dataStruct.Name;
            else
                ret.Name=dataStruct.LoggedName;
            end


            ret.BlockPath.SubPath=dataStruct.SubPath;


            ret.Label=Simulink.SimulationData.StateType.DSTATE;


            if isstruct(ret.Values)
                if dataStruct.NonVirtual
                    ret.Label='dstate_nvbus';
                else
                    ret.Label='dstate_vbus';
                end
            end


            if isa(ret.Values,'timeseries')
                ret.Values.Name=dataStruct.SignalName;
                tsi=ret.Values.getinterpmethod;
                if strcmpi(tsi,'linear')
                    ret.Label=Simulink.SimulationData.StateType.CSTATE;
                end
            end
        end
    end

end
