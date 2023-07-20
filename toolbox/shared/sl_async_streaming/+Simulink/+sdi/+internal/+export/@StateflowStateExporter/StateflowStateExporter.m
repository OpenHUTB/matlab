classdef StateflowStateExporter<Simulink.sdi.internal.export.ElementExporter



    methods

        function ret=getDomainType(~)
            ret={'sf_state','sf_state_child','sf_state_leaf'};
        end


        function ret=exportElement(~,~,dataStruct)
            ret=Stateflow.SimulationData.State;
            ret.BlockPath=dataStruct.BlockPath;
            ret.Values=dataStruct.Values;

            if(isequal(dataStruct.LoggedName,dataStruct.Name)||...
                isempty(dataStruct.LoggedName))

                pos=strfind(dataStruct.Name,':');
                if isempty(pos)
                    ret.Name=dataStruct.Name;
                else
                    ret.Name=dataStruct.Name(1:pos-1);
                end
            else
                ret.Name=dataStruct.LoggedName;
            end


            ret.BlockPath.SubPath=dataStruct.SubPath;


            pos=strfind(dataStruct.SignalName,'.');
            if isempty(pos)
                ret.Values.Name=dataStruct.SignalName;
            else
                ret.Values.Name=dataStruct.SignalName(pos(end)+1:end);
            end


            if isequal(dataStruct.SSID,0)
                ret.SSIdNumber=[];
            else
                ret.SSIdNumber=dataStruct.SSID;
            end
        end

    end

end
