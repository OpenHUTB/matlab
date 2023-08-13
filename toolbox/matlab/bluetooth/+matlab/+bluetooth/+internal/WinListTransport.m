classdef WinListTransport<matlab.bluetooth.internal.ListTransportBase

    methods
        function obj=WinListTransport(channel)
            obj@matlab.bluetooth.internal.ListTransportBase(channel);
        end

        function timeout=getScanTimeout(~)
            timeout=35;
        end

        function output=parseSDPData(~,input)

            output=[];
            ProtocolDescriptorListID=4;
            for ii=1:numel(input)

                if input(ii).Key==ProtocolDescriptorListID
                    value=input(ii).Value;














                    if length(value)<2||value(end-1)~=8
                        return
                    end
                    output=double(value(end));
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

                address=split(string(input(ii).Address),"-");
                address=address(end);
                address=regexp(address,"([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}","match");
                if~isempty(address)
                    address=strrep(address,":","");
                end
                output=[output,struct("Name",input(ii).Name,"Address",upper(address))];%#ok<AGROW>
            end
        end
    end
end