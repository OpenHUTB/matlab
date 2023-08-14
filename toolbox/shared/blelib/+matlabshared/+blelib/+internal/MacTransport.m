classdef MacTransport<matlabshared.blelib.internal.TransportBase




    methods
        function obj=MacTransport(varargin)
            obj@matlabshared.blelib.internal.TransportBase(varargin{:});
        end

        function output=getAdvertisementDataFieldnamesImpl(~)
            output=["Connectable",...
            "LocalName",...
            "TxPowerLevel",...
            "ManufacturerSpecificData",...
            "ServiceData",...
            "ServiceUUIDs",...
            "ServiceSolicitationUUIDs"];
        end

        function saveFoundDevicesImpl(~,tableOutput)
            addresses=tableOutput.Address;
            names=tableOutput.Name;
            connectables=[tableOutput.Advertisement(:).Connectable];
            info=struct('Name',cellstr(names),'Connectable',num2cell(connectables'));
            matlabshared.blelib.internal.Utility.getInstance.setDevices(addresses,info);
        end

        function output=updateAdvertisementDataPlatformDependentImpl(~,input)
            output=input;
        end
    end
end