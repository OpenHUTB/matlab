classdef MacListTransport<matlab.bluetooth.internal.ListTransportBase




    methods
        function obj=MacListTransport(channel)
            obj@matlab.bluetooth.internal.ListTransportBase(channel);
        end

        function timeout=getScanTimeout(~)
            timeout=20;
        end

        function output=parseSDPData(~,input)







            output=[];
            ProtocolDescriptorListID=4;
            for protocolDescriptorList=input
                if protocolDescriptorList.Key==ProtocolDescriptorListID
                    output=double(protocolDescriptorList.Value);
                    return
                end
            end
        end

        function output=extractDeviceInfo(~,input)






            output=[];
            if isempty(input)
                return
            end
            for ii=1:numel(input)

                address=strrep(input(ii).Address,"-","");
                output=[output,struct("Name",input(ii).Name,"Address",upper(address))];%#ok<AGROW>
            end
        end
    end
end