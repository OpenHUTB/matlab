classdef TransportBase<handle





    properties(Access=protected)
AsyncioChannel
CustomEventListener
DataWrittenListener
    end

    properties(Access=private)

Peripherals


        BufferMap=containers.Map



        DefaultExecuteTimeout=15


        DefaultDisconnectTimeout=10
    end

    methods(Abstract)
        output=getAdvertisementDataFieldnamesImpl(~)
        output=updateAdvertisementDataPlatformDependentImpl(~,~)
        saveFoundDevicesImpl(~,~)
    end

    methods
        function obj=TransportBase(channel)

            if nargin<1
                obj.AsyncioChannel=matlabshared.asyncio.internal.Channel(...
                fullfile(toolboxdir('shared'),'blelib','bin',computer('arch'),'libmwbledevice'),...
                fullfile(toolboxdir('shared'),'blelib','bin',computer('arch'),'libmwblemlconverter'),...
                Options=struct([]),...
                StreamLimits=[Inf,0],...
                MessageHandler=matlabshared.blelib.internal.MessageHandler);
            else
                obj.AsyncioChannel=channel;
            end
            obj.AsyncioChannel.InputStream.Timeout=obj.DefaultExecuteTimeout;
            obj.AsyncioChannel.open;
            obj.CustomEventListener=event.listener(obj.AsyncioChannel,'Custom',@obj.onCustomEvent);
            obj.DataWrittenListener=event.listener(obj.AsyncioChannel.InputStream,'DataWritten',@obj.onDataReceived);
        end

        function output=discoverPeripherals(obj,timeout,uuids)
            obj.AsyncioChannel.BluetoothError=[];
            obj.Peripherals=[];

            obj.AsyncioChannel.InputStream.Timeout=timeout;
            if isempty(uuids)
                execute(obj.AsyncioChannel,matlabshared.blelib.internal.ExecuteCommands.DISCOVER_PERIPHERALS_START.String);
            else
                params.ServiceUUID=uuids;
                execute(obj.AsyncioChannel,matlabshared.blelib.internal.ExecuteCommands.DISCOVER_PERIPHERALS_START.String,params);
            end



            obj.AsyncioChannel.InputStream.wait(@(obj)false);
            execute(obj.AsyncioChannel,matlabshared.blelib.internal.ExecuteCommands.DISCOVER_PERIPHERALS_STOP.String);


            if isempty(obj.Peripherals)

                if~isempty(obj.AsyncioChannel.BluetoothError)
                    matlabshared.blelib.internal.localizedError(obj.AsyncioChannel.BluetoothError);
                end
                output=[];
                return;
            end
            output=convertPeripheralsToTable(obj);
            output=sortrows(output,'RSSI','ComparisonMethod','abs');

            for index=1:height(output)
                output.Index(index)=index;
            end


            saveFoundDevicesImpl(obj,output);
        end

        function output=execute(obj,command,address,varargin)

            output=[];
            timeout=obj.DefaultExecuteTimeout;
            switch command
            case{matlabshared.blelib.internal.ExecuteCommands.CONNECT_PERIPHERAL,...
                matlabshared.blelib.internal.ExecuteCommands.GET_PERIPHERAL_STATE,...
                matlabshared.blelib.internal.ExecuteCommands.DISCOVER_SERVICES}
                params.PeripheralAddress=address;

            case matlabshared.blelib.internal.ExecuteCommands.DISCONNECT_PERIPHERAL
                params.PeripheralAddress=address;
                timeout=obj.DefaultDisconnectTimeout;

            case matlabshared.blelib.internal.ExecuteCommands.DISCOVER_CHARACTERISTICS
                params.PeripheralAddress=address;
                params.ServiceIndex=uint8(varargin{1}-1);

            case{matlabshared.blelib.internal.ExecuteCommands.READ_CHARACTERISTIC,...
                matlabshared.blelib.internal.ExecuteCommands.UNSUBSCRIBE_CHARACTERISTIC,...
                matlabshared.blelib.internal.ExecuteCommands.DISCOVER_DESCRIPTORS,...
                matlabshared.blelib.internal.ExecuteCommands.GET_CHARACTERISTIC_STATUS}
                params.PeripheralAddress=address;
                params.ServiceIndex=uint8(varargin{1}-1);
                params.CharacteristicIndex=uint8(varargin{2}-1);

            case matlabshared.blelib.internal.ExecuteCommands.SUBSCRIBE_CHARACTERISTIC
                params.PeripheralAddress=address;
                params.ServiceIndex=uint8(varargin{1}-1);
                params.CharacteristicIndex=uint8(varargin{2}-1);
                params.Type=uint8(varargin{3});
                params.Flag=logical(varargin{4});

            case matlabshared.blelib.internal.ExecuteCommands.WRITE_CHARACTERISTIC
                params.PeripheralAddress=address;
                params.ServiceIndex=uint8(varargin{1}-1);
                params.CharacteristicIndex=uint8(varargin{2}-1);
                params.Data=varargin{3};
                params.Type=logical(varargin{4});

            case matlabshared.blelib.internal.ExecuteCommands.READ_DESCRIPTOR
                params.PeripheralAddress=address;
                params.ServiceIndex=uint8(varargin{1}-1);
                params.CharacteristicIndex=uint8(varargin{2}-1);
                params.DescriptorIndex=uint8(varargin{3}-1);

            case matlabshared.blelib.internal.ExecuteCommands.WRITE_DESCRIPTOR
                params.PeripheralAddress=address;
                params.ServiceIndex=uint8(varargin{1}-1);
                params.CharacteristicIndex=uint8(varargin{2}-1);
                params.DescriptorIndex=uint8(varargin{3}-1);
                params.Data=varargin{4};

            case matlabshared.blelib.internal.ExecuteCommands.REGISTER_CHARACTERISTIC_BUFFER
                serviceIndex=varargin{1}-1;
                characteristicIndex=varargin{2}-1;
                buffer=varargin{3};
                obj.registerCharacteristicBuffer(address,serviceIndex,characteristicIndex,buffer);
                return

            case matlabshared.blelib.internal.ExecuteCommands.UNREGISTER_CHARACTERISTIC_BUFFER
                serviceIndex=varargin{1}-1;
                characteristicIndex=varargin{2}-1;
                obj.unregisterCharacteristicBuffer(address,serviceIndex,characteristicIndex);
                return

            otherwise
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:unknownExecuteCommand');
            end
            output=obj.executeCommand(command.String,params,timeout);
        end
    end

    methods(Access=private)
        function output=executeCommand(obj,cmd,params,timeout)


            obj.AsyncioChannel.InputStream.Timeout=timeout;
            obj.AsyncioChannel.ExecuteStatus=[];
            obj.AsyncioChannel.ExecuteResult=[];
            execute(obj.AsyncioChannel,cmd,params);
            obj.AsyncioChannel.InputStream.wait(@(~)~isempty(obj.AsyncioChannel.ExecuteStatus));
            if isempty(obj.AsyncioChannel.ExecuteStatus)||~obj.AsyncioChannel.ExecuteStatus
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:failToExecute');
            end
            output=obj.AsyncioChannel.ExecuteResult;
        end

        function output=convertPeripheralsToTable(obj)

            fnames=getAdvertisementDataFieldnamesImpl(obj);
            for name=fnames
                struct_template.(name)=[];
            end
            output=table(ones(0,1),strings(0,1),strings(0,1),zeros(0,1),repmat(struct_template,0,1));
            output.Properties.VariableNames=["Index","Name","Address","RSSI","Advertisement"];
            numrows=1;




            peripherals=obj.Peripherals;
            for index=1:length(peripherals)
                row=output(output.Address==peripherals(index).Address,:);

                if isempty(row)
                    peripherals(index).Index=numrows;
                    peripherals(index).RSSI=double(peripherals(index).RSSI);
                    output=[output;struct2table(peripherals(index),'AsArray',true)];%#ok<AGROW>
                    numrows=numrows+1;
                else

                    if~isempty(peripherals(index).Name)
                        output.Name(row.Index(1))=peripherals(index).Name;
                    end
                    output.RSSI(row.Index(1))=double(peripherals(index).RSSI);
                    for name=fnames
                        if~isempty(peripherals(index).Advertisement.(name))
                            output.Advertisement(row.Index(1)).(name)=peripherals(index).Advertisement.(name);
                        end
                    end
                end
            end
            output=updateAdvertisementData(obj,output);
        end


        function output=updateAdvertisementData(obj,input)
            output=input;

            for index=1:height(input)
                adv=input.Advertisement(index);
                if~isempty(adv.TxPowerLevel)
                    output.Advertisement(index).TxPowerLevel=double(adv.TxPowerLevel);
                end
                if~isempty(adv.ManufacturerSpecificData)
                    output.Advertisement(index).ManufacturerSpecificData=double(adv.ManufacturerSpecificData);
                end
                if~isempty(adv.ServiceData)
                    for loop=1:numel(adv.ServiceData)
                        output.Advertisement(index).ServiceData(loop).Data=double(adv.ServiceData(loop).Data);
                    end
                end
            end
            output=updateAdvertisementDataPlatformDependentImpl(obj,output);
        end

        function registerCharacteristicBuffer(obj,address,sindex,cindex,buffer)

            key=address+string(sindex)+string(cindex);
            obj.BufferMap(key)=buffer;
        end

        function unregisterCharacteristicBuffer(obj,address,sindex,cindex)

            key=address+string(sindex)+string(cindex);
            if isKey(obj.BufferMap,key)
                obj.BufferMap.remove(key);
            end
        end
    end

    methods(Access=private)
        function onCustomEvent(obj,~,data)
            if strcmp(data.Type,'scan_peripheral')
                obj.Peripherals=[obj.Peripherals,data.Data];
            end
        end

        function onDataReceived(obj,~,evt)


            for index=1:evt.CurrentCount
                data=obj.AsyncioChannel.InputStream.read(1);
                key=data.Address+string(data.ServiceIndex)+string(data.CharacteristicIndex);
                if isKey(obj.BufferMap,key)
                    buffer=obj.BufferMap(key);
                    buffer.write(data.Value);

                    pause(1e-3);
                end
            end
        end
    end


    methods(Access=?matlabshared.blelib.internal.TestAccessor)
        function channel=getChannel(obj)
            channel=obj.AsyncioChannel;
        end
    end

    methods
        function delete(obj)
            try
                delete(obj.CustomEventListener);
                delete(obj.DataWrittenListener);
                obj.AsyncioChannel.close;
                delete(obj.AsyncioChannel);
            catch

            end
        end
    end
end