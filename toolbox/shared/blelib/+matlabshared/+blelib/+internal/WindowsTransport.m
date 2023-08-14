classdef WindowsTransport<matlabshared.blelib.internal.TransportBase




    properties(Access=?matlabshared.blelib.internal.MessageHandler)


        ServicesChangedErrorMap=containers.Map
    end

    methods
        function obj=WindowsTransport(varargin)
            obj@matlabshared.blelib.internal.TransportBase(varargin{:});
        end

        function output=getAdvertisementDataFieldnamesImpl(~)
            output=["Type",...
            "Appearance",...
            "ShortenedLocalName",...
            "CompleteLocalName",...
            "TxPowerLevel",...
            "SlaveConnectionIntervalRange",...
            "ManufacturerSpecificData",...
            "ServiceData",...
            "CompleteServiceUUIDs",...
            "IncompleteServiceUUIDs",...
            "ServiceSolicitationUUIDs"];
        end

        function saveFoundDevicesImpl(~,tableOutput)
            addresses=tableOutput.Address;
            names=tableOutput.Name;
            connectables=cell(numel(addresses),1);
            for index=1:numel(addresses)
                connectables{index}=any(tableOutput.Advertisement(index).Type.startsWith("Connectable"));
            end
            info=struct('Name',cellstr(names),'Connectable',connectables);
            matlabshared.blelib.internal.Utility.getInstance.setDevices(addresses,info);
        end

        function output=updateAdvertisementDataPlatformDependentImpl(~,input)
            output=input;

            for index=1:height(input)
                adv=input.Advertisement(index);
                if~isempty(adv.SlaveConnectionIntervalRange)

                    min=parseConnectionInterval(adv.SlaveConnectionIntervalRange(1));
                    max=parseConnectionInterval(adv.SlaveConnectionIntervalRange(2));


                    if(isnumeric(min)&&isnumeric(max))||(isstring(min)&&isstring(max))
                        output.Advertisement(index).SlaveConnectionIntervalRange=[min,max];
                    else
                        output.Advertisement(index).SlaveConnectionIntervalRange={min,max};
                    end
                end
            end

            function output=parseConnectionInterval(input)

                if input>=matlabshared.blelib.internal.Constants.MinSlaveConnectionInterval&&input<=matlabshared.blelib.internal.Constants.MaxSlaveConnectionInterval
                    output=double(input)*matlabshared.blelib.internal.Constants.SlaveConnectionIntervalUnit;
                elseif input==matlabshared.blelib.internal.Constants.NoSpecificSlaveConnectionInterval
                    output="none";
                else
                    output="reserved";
                end
            end
        end

        function output=execute(obj,command,address,varargin)






            if command==matlabshared.blelib.internal.ExecuteCommands.GET_PERIPHERAL_STATE

            elseif command==matlabshared.blelib.internal.ExecuteCommands.DISCONNECT_PERIPHERAL

                if isKey(obj.ServicesChangedErrorMap,address)
                    obj.ServicesChangedErrorMap.remove(address);
                end
            else
                if isKey(obj.ServicesChangedErrorMap,address)
                    matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:deviceProfileChanged',address);
                end
            end
            output=execute@matlabshared.blelib.internal.TransportBase(obj,command,address,varargin{:});
        end
    end
end