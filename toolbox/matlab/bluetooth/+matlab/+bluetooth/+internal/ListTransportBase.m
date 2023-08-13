classdef ListTransportBase<handle

    properties(Access=private)

AsyncioChannel


CustomEventListener


RawDeviceData
    end

    properties(Constant,Access=public)

        START_DISCOVERY="start_discovery"
        STOP_DISCOVERY="stop_discovery"
        GET_PAIRED_DEVICES="get_paired_devices"
        EVENT_TYPE="scan_device"
    end

    methods(Abstract)

        timeout=getScanTimeout(obj)

        output=parseSDPData(obj,input)

        output=extractDeviceInfo(obj,input);
    end

    methods(Access=public)
        function obj=ListTransportBase(channel)
            obj.AsyncioChannel=channel;
            open(obj.AsyncioChannel);
            obj.CustomEventListener=event.listener(obj.AsyncioChannel,"Custom",@obj.onCustomEvent);
        end

        function delete(obj)
            try
                delete(obj.CustomEventListener);
                close(obj.AsyncioChannel);
                delete(obj.AsyncioChannel);
            catch

            end
        end
    end

    methods(Access=public)
        function output=discoverDevices(obj,timeout)

            obj.AsyncioChannel.ExecuteStatus=[];
            obj.RawDeviceData=[];

            execute(obj.AsyncioChannel,obj.START_DISCOVERY);


            if~isempty(obj.AsyncioChannel.ExecuteStatus)&&~obj.AsyncioChannel.ExecuteStatus
                id="MATLAB:bluetooth:bluetoothlist:failedScan";
                throwAsCaller(MException(id,getString(message(id))));
            end



            if isempty(timeout)
                timeout=getScanTimeout(obj);
            end
            t=tic;
            while toc(t)<timeout&&isempty(obj.AsyncioChannel.ExecuteStatus)
                pause(1e-3);
            end

            execute(obj.AsyncioChannel,obj.STOP_DISCOVERY);

            if isempty(obj.RawDeviceData)
                output=[];
                return
            end

            cache=matlab.bluetooth.internal.SPPDevicesCache.getInstance;

            output=table(strings(0,1),strings(0,1),repmat(categorical,0,1),strings(0,1));
            output.Properties.VariableNames=["Name","Address","Channel","Status"];
            devices=obj.RawDeviceData;
            for index=1:numel(devices)
                device=setDeviceChannel(obj,devices(index));
                device=setDeviceStatus(obj,device);
                output=[output;{device.Name,upper(device.Address),device.Channel,device.Status}];%#ok<AGROW>

                if device.Channel~=categorical("Unknown")
                    setDevice(cache,device.Name,device.Address,str2double(string(device.Channel)));
                end
            end
        end

        function output=getPairedDevices(obj)
            obj.AsyncioChannel.ExecuteResult=[];
            execute(obj.AsyncioChannel,obj.GET_PAIRED_DEVICES);
            devices=obj.AsyncioChannel.ExecuteResult;
            output=extractDeviceInfo(obj,devices);
        end
    end

    methods(Access=private)
        function onCustomEvent(obj,~,data)
            if data.Type==obj.EVENT_TYPE
                obj.RawDeviceData=[obj.RawDeviceData,data.Data];
            end
        end
    end


    methods(Access=private)
        function device=setDeviceChannel(obj,device)

            channel=parseSDPData(obj,device.SPPSDP);
            if isempty(channel)
                channel="Unknown";
            end
            device.Channel=categorical(channel);
        end

        function device=setDeviceStatus(~,device)




            connections=matlab.bluetooth.internal.ConnectionMap.getInstance;
            channel=get(connections,device.Address);
            if~isempty(channel)
                device.Status=message("MATLAB:bluetooth:bluetoothlist:statusConnected").string;
                device.Channel=categorical(channel);
                return
            end

            if device.Connected


                if device.Channel~=categorical("Unknown")
                    device.Status=message("MATLAB:bluetooth:bluetoothlist:statusConnected").string;
                else


                    device.Status=message("MATLAB:bluetooth:bluetoothlist:statusUnknown").string;
                end
            else

                if device.HasServices

                    if~isempty(device.SPPSDP)
                        if device.Paired
                            device.Status=message("MATLAB:bluetooth:bluetoothlist:statusReady").string;
                        else
                            device.Status=message("MATLAB:bluetooth:bluetoothlist:statusUnpaired").string;
                        end
                    else

                        device.Status=message("MATLAB:bluetooth:bluetoothlist:statusUnsupported").string;
                    end
                else

                    device.Status=message("MATLAB:bluetooth:bluetoothlist:statusUnknown").string;
                end
            end
        end
    end
end