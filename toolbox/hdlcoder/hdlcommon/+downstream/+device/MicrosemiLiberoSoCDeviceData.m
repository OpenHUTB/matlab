




classdef MicrosemiLiberoSoCDeviceData<downstream.device.DeviceData


    properties

        ToolPath='';
        deviceMap=[];
        nameMap=[];

    end


    methods

        function obj=MicrosemiLiberoSoCDeviceData(hDevice)

            obj=obj@downstream.device.DeviceData(hDevice);



            obj.nameMap=containers.Map();
            obj.nameMap('SmartFusion2')='SmartFusion2';

            obj.deviceMap=containers.Map();
        end

        function familyList=listFamily(obj)

            familyIDList=fields(obj.TheDeviceData);
            familyLength=length(familyIDList);
            familyList=cell(familyLength,1);
            for ii=1:familyLength
                familyStruct=obj.TheDeviceData.(familyIDList{ii});
                familyList{ii}=familyStruct.FamilyName;
            end
        end

    end

end
