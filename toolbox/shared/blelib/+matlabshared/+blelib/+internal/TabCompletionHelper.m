classdef TabCompletionHelper<handle




    methods(Static)
        function services=getAllServices

            table=matlabshared.blelib.internal.ServicesCharacteristicsDescriptorsInfo.getInstance;
            services=[table.getAllServiceUUIDs,table.getAllServiceNames];
        end

        function output=getFoundIdentifiers

            output=[];
            foundDevices=matlabshared.blelib.internal.Utility.getInstance.getDevices;
            if~isempty(foundDevices)

                infos=cell2mat(foundDevices.values);
                output=unique(string({infos(:).Name}));

                output(output=="")=[];
                output=[output,string(foundDevices.keys)];
            end


        end

        function output=getSupportedServices(peripheral)

            if isempty(peripheral.Services)
                output=[];
                return
            end
            output=peripheral.Services.ServiceName;

            output(output=="Custom")=[];
            if isempty(output)
                output=peripheral.Services.ServiceUUID;
            else
                output=[output;peripheral.Services.ServiceUUID];
            end
        end

        function output=getSupportedCharacteristics(peripheral,sid)

            subtable=peripheral.Characteristics(peripheral.Characteristics.ServiceUUID==sid,:);
            if isempty(subtable)
                subtable=peripheral.Characteristics(peripheral.Characteristics.ServiceName==sid,:);
            end
            output=subtable.CharacteristicName;

            output(output=="Custom")=[];
            if isempty(output)
                output=subtable.CharacteristicUUID;
            else
                output=[output;subtable.CharacteristicUUID];
            end
        end

        function output=getSupportedDescriptors(characteristic)

            if isempty(characteristic.Descriptors)
                output=[];
                return
            end
            output=characteristic.Descriptors.DescriptorName;

            output(output=="Custom")=[];
            if isempty(output)
                output=characteristic.Descriptors.DescriptorUUID;
            else
                output=[output;characteristic.Descriptors.DescriptorUUID];
            end
        end

        function output=getReadModes(characteristic)

            if any(ismember(["Notify","Indicate"],characteristic.Attributes))
                output=matlabshared.blelib.internal.Constants.SupportedReadModesNotifyOnly;
            elseif ismember("Read",characteristic.Attributes)
                output=matlabshared.blelib.internal.Constants.SupportedReadModesReadOnly;
            else
                output=[];
            end
        end

        function output=getWriteTypes(characteristic)

            output=[];
            if any(ismember("Write",characteristic.Attributes))
                output=[output,"withresponse"];
            end
            if any(ismember("WriteWithoutResponse",characteristic.Attributes))
                output=[output,"withoutresponse"];
            end
        end

        function output=getWritePrecisions

            output=matlabshared.blelib.internal.Constants.WritePrecisions;
        end

        function output=getSupportedSubscriptionTypes(characteristic)


            output=[];
            if any(ismember(["Notify","NotifyEncryptionRequired"],characteristic.Attributes))
                output=[output,"notification"];
            end
            if any(ismember(["Indicate","IndicateEncryptionRequired"],characteristic.Attributes))
                output=[output,"indication"];
            end
        end
    end
end