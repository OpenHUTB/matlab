classdef StateflowDataExporter<Simulink.sdi.internal.export.ElementExporter



    methods

        function ret=getDomainType(~)
            ret='sf_data';
        end


        function ret=exportElement(~,~,dataStruct)
            ret=Stateflow.SimulationData.Data;
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


            if isa(ret.Values,'timeseries')
                ret.Values.Name=dataStruct.SignalName;
            end


            if isequal(dataStruct.SSID,0)
                ret.SSIdNumber=[];
            else
                ret.SSIdNumber=dataStruct.SSID;
            end
        end

    end

end
