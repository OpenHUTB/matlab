classdef ServicesCharacteristicsDescriptorsInfo<handle






    properties(Access=private,Constant=true)
        BaseUUID="-0000-1000-8000-00805F9B34FB"
    end

    properties(Access=private)

        ServiceUUIDToName=containers.Map



        CharacteristicUUIDToName=containers.Map


        DescriptorUUIDToName=containers.Map
    end

    methods(Hidden,Static)
        function obj=getInstance()
            persistent Instance;

            if isempty(Instance)
                Instance=matlabshared.blelib.internal.ServicesCharacteristicsDescriptorsInfo();
            end
            obj=Instance;
        end
    end

    methods(Access=private)
        function obj=ServicesCharacteristicsDescriptorsInfo()



            files=dir(fullfile(toolboxdir('shared'),'blelib','+matlabshared','+blelib','+internal','*ServicesCharacteristics.json'));
            pairs=[];
            for index=1:numel(files)
                pairs=[pairs;jsondecode(fileread(fullfile(files(index).folder,files(index).name)))];%#ok<AGROW>
            end

            for service=pairs'
                obj.ServiceUUIDToName(service.UUID)=service.Name;
                temp=containers.Map;
                for characteristic=service.Characteristics'
                    temp(characteristic.UUID)=characteristic.Name;
                end
                obj.CharacteristicUUIDToName(service.UUID)=temp;
            end
            files=dir(fullfile(toolboxdir('shared'),'blelib','+matlabshared','+blelib','+internal','*Descriptors.json'));
            pairs=[];
            for index=1:numel(files)
                pairs=[pairs;jsondecode(fileread(fullfile(files(index).folder,files(index).name)))];%#ok<AGROW>
            end
            for descriptor=pairs'
                obj.DescriptorUUIDToName(descriptor.UUID)=descriptor.Name;
            end
        end
    end

    methods(Access=public)
        function uuid=getServiceUUID(obj,value)


            [found,uuid]=getUUID(obj,obj.ServiceUUIDToName,value);
            if~found
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:invalidServiceUUIDValue');
            end
        end

        function uuid=getCharacteristicUUID(obj,suuid,value)




            map=[];
            if isKey(obj.CharacteristicUUIDToName,suuid)
                map=obj.CharacteristicUUIDToName(suuid);
            end

            [found,uuid]=getUUID(obj,map,value);
            if~found
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:invalidCharacteristicUUIDValue');
            end
        end

        function uuid=getDescriptorUUID(obj,value)


            [found,uuid]=getUUID(obj,obj.DescriptorUUIDToName,value);
            if~found
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:invalidDescriptorUUIDValue');
            end
        end

        function output=get128BitUUID(obj,uuid)


            len=strlength(uuid);
            if len==4
                output="0000"+uuid+obj.BaseUUID;
            elseif len==8
                output=uuid+obj.BaseUUID;
            else
                output=uuid;
            end
        end

        function output=getShortestUUID(obj,uuid)





            output=regexp(uuid,"(?<=^0000)[0-F]{4}$",'match');
            if isempty(output)

                output=regexp(uuid,"(?<=^0000)[0-F]{4}(?="+obj.BaseUUID+"$)",'match');
                if isempty(output)

                    output=uuid;
                end
            end
        end

        function uuids=getAllServiceUUIDs(obj)

            uuids=string(obj.ServiceUUIDToName.keys);
        end

        function names=getAllServiceNames(obj)

            names=string(obj.ServiceUUIDToName.values);
        end

        function uuids=getAllCharacteristicUUIDs(obj,suuid)

            uuids=[];
            if isKey(obj.CharacteristicUUIDToName,suuid)
                uuids=string(obj.CharacteristicUUIDToName(suuid).keys);
            end
        end

        function names=getAllCharacteristicNames(obj,suuid)

            names=[];
            if isKey(obj.CharacteristicUUIDToName,suuid)
                names=string(obj.CharacteristicUUIDToName(suuid).values);
            end
        end

        function info=getServiceInfoByUUID(obj,uuid)



            uuid=obj.getShortestUUID(upper(uuid));

            name="Custom";
            if isKey(obj.ServiceUUIDToName,uuid)
                name=string(obj.ServiceUUIDToName(uuid));
            end
            info.UUID=uuid;
            info.Name=name;
        end

        function info=getCharacteristicInfoByUUID(obj,suuid,uuid)



            uuid=obj.getShortestUUID(upper(uuid));

            name="Custom";
            if isKey(obj.CharacteristicUUIDToName,suuid)
                map=obj.CharacteristicUUIDToName(suuid);
                if isKey(map,uuid)
                    name=string(map(uuid));
                end
            end
            info.UUID=uuid;
            info.Name=name;
        end

        function info=getDescriptorInfoByUUID(obj,uuid)



            uuid=obj.getShortestUUID(upper(uuid));

            name="Custom";
            if isKey(obj.DescriptorUUIDToName,uuid)
                name=string(obj.DescriptorUUIDToName(uuid));
            end
            info.UUID=uuid;
            info.Name=name;
        end
    end

    methods(Access=private)
        function[found,uuid]=getUUID(obj,validmap,value)


            found=false;
            uuid=[];


            if isnumeric(value)&&~isempty(value)&&~isnan(value)&&~isinf(value)

                value=sprintf("%04x",value);
            end

            if ischar(value)
                value=string(value);
            end

            if~isstring(value)
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:invalidUUIDType');
            end


            if lower(value)=="custom"
                matlabshared.blelib.internal.localizedError('MATLAB:ble:ble:invalidUUIDNameCustom');
            end

            try


                name=validatestring(value,validmap.values);
                found=true;
                index=cellfun(@(x)isequal(x,name),validmap.values);
                allUUIDs=validmap.keys;
                uuid=obj.get128BitUUID(string(allUUIDs{index}));
            catch e

                if strcmp(e.identifier,'MATLAB:ambiguousStringChoice')
                    throwAsCaller(e);
                end
                value=upper(string(value));

                svc=regexp(value,"(?<=^0000)[0-F]{4}$",'match');
                if~isempty(svc)
                    value=svc;
                else

                    svc=regexp(value,"(?<=^0000)[0-F]{4}(?="+obj.BaseUUID+"$)",'match');
                    if~isempty(svc)
                        value=svc;
                    end
                end

                svc=regexp(value,"^[0-F]{4}$",'once');
                if(strlength(value)==4)&&~isempty(svc)
                    found=true;
                    uuid=obj.get128BitUUID(value);
                else

                    if regexp(value,"^[0-F]{8}-[0-F]{4}-[0-F]{4}-[0-F]{4}-[0-F]{12}$")
                        found=true;
                        uuid=value;
                    end
                end
            end
        end
    end
end