classdef(Sealed=false)HardwareBase<matlab.mixin.SetGet

























    properties(Access='public')



        Name='';



        DeviceID='Custom Processor->Custom Processor';



        IOInterface={};
    end

    properties(Access='private')
DeviceFamily
    end

    properties(Access='public',Hidden)
        MathWorksDeviceType='Custom Processor->Custom Processor';
        Target=[];
    end

    methods
        function set.DeviceID(h,deviceID)
            validateattributes(deviceID,{'char','string'},{});
            deviceID=char(deviceID);
            oldDeviceID=h.DeviceID;
            h.DeviceID=deviceID;
            if~h.validate
                h.DeviceID=oldDeviceID;
                list=h.getListOfSupportedDeviceIDs;
                error(message('codertarget:targetapi:HardwareDeviceInvalid',list));
            end
            h.updateMathWorksDeviceType;
        end
    end

    methods(Access='public')
        function h=HardwareBase(hardwareName,devID)
            hardwareName=convertStringsToChars(hardwareName);
            h.Name=hardwareName;
            if nargin>1
                h.DeviceID=convertStringsToChars(devID);
            end
        end

        function register(h,directory)

        end

        function obj=addNewSerialInterface(h,interfaceName)







            interfaceName=convertStringsToChars(interfaceName);
            if isempty(embedded.getObjectArrayElementByName(interfaceName,h.IOInterface))
                obj=embedded.SerialInterface(interfaceName);
                if~isempty(obj)
                    h.IOInterface=h.append(h.IOInterface,obj);
                end
            else
                error(message('codertarget:targetapi:IOInterfaceAlreadyExists',interfaceName));
            end
        end
        function obj=addNewEthernetInterface(h,interfaceName)
            interfaceName=convertStringsToChars(interfaceName);







            if isempty(embedded.getObjectArrayElementByName(interfaceName,h.IOInterface))
                obj=embedded.EthernetInterface(interfaceName);
                if~isempty(obj)
                    h.IOInterface=h.append(h.IOInterface,obj);
                end
            else
                error(message('codertarget:targetapi:IOInterfaceAlreadyExists',interfaceName));
            end
        end
        function deleteSerialInterface(h,interfaceName)
            interfaceName=convertStringsToChars(interfaceName);




            idx=embedded.getObjectArrayElementIndexByName(interfaceName,h.IOInterface);
            if~isequal(idx,0)
                h.IOInterface(idx)=[];
            else
                error(message('codertarget:targetapi:NotSerialInterface',interfaceName));
            end
        end
        function deleteEthernetInterface(h,interfaceName)
            interfaceName=convertStringsToChars(interfaceName);




            idx=embedded.getObjectArrayElementIndexByName(interfaceName,h.IOInterface);
            if~isequal(idx,0)
                h.IOInterface(idx)=[];
            else
                error(message('codertarget:targetapi:NotEthernetInterface',interfaceName));
            end
        end
        function deserialize(hwObj,filename)

















        end
    end
    methods(Access='public',Hidden=true)
        function list=getListOfSupportedDeviceIDs(~)
            supportedDeviceIDs=embedded.getSupportedDeviceIDs;
            list=supportedDeviceIDs{1};
            for i=2:numel(supportedDeviceIDs)-1
                list=[list,', ',supportedDeviceIDs{i}];%#ok<AGROW>
            end
            if numel(supportedDeviceIDs)>1
                list=[list,' and ',supportedDeviceIDs{end}];
            end
        end
        function obj=addNewIOInterface(h,interfaceName,interfaceType)
            narginchk(3,3);
            interfaceName=convertStringsToChars(interfaceName);
            interfaceType=convertStringsToChars(interfaceType);
            assert(ischar(interfaceName),...
            'Interface name must be a string or a character array');
            assert(ischar(interfaceType),...
            'Interface type must be a string or a character array');
            switch(interfaceType)
            case 'Ethernet'
                obj=h.addNewEthernetInterface(interfaceName);
            case 'Serial'
                obj=h.addNewSerialInterface(interfaceName);
            otherwise
                assert(false,['Unknown interface type: ',interfaceType]);
            end
        end
        function obj=getIOInterface(h,interfaceName)

            if nargin==1
                obj=h.IOInterface;
            elseif nargin==2
                interfaceName=convertStringsToChars(interfaceName);
                obj=embedded.getObjectArrayElementByName(interfaceName,h.IOInterface);
                if~isempty(obj)
                    obj={obj};
                end
            end
        end
        function tf=validate(h)
            supportedDeviceIDs=embedded.getSupportedDeviceIDs();
            tf=~isempty(h.DeviceID)&&ismember(h.DeviceID,supportedDeviceIDs);
        end
    end
    methods(Hidden=true,Static)
        function array=append(array,obj)
            if~isempty(obj)
                if iscell(array)
                    array{end+1}=obj;
                elseif isempty(array)
                    array=obj;
                else
                    array(end+1)=obj;
                end
            end
        end
    end
    methods(Access=private)
        function serialize(h,directory)
            directory=convertStringsToChars(directory);
            infoObj=codertarget.Info;
            docObj=infoObj.createDocument('productinfo');
            infoObj.setElement(docObj,'name',h.Name);
            infoObj.setElement(docObj,'deviceid',h.DeviceID);
            serialStruct={};ethernetStruct={};
            for i=1:numel(h.IOInterface)
                if isa(h.IOInterface{i},'embedded.EthernetInterface')
                    ethernetStruct{end+1}=h.IOInterface{i}.structurize();%#ok<AGROW>
                elseif isa(h.IOInterface{i},'embedded.SerialInterface')
                    serialStruct{end+1}=h.IOInterface{i}.structurize();%#ok<AGROW>
                end
            end
            infoObj.setElement(docObj,'serialTransport',serialStruct);
            infoObj.setElement(docObj,'ethernetTransport',ethernetStruct);
            filename=fullfile(directory,...
            [embedded.makeValidFileName(h.Name),'.xml']);
            filename=codertarget.utils.replacePathSep(filename);
            infoObj.write(filename,docObj);
        end
        function updateMathWorksDeviceType(h)
            switch(~isempty(strfind(h.DeviceID,'ARM Cortex')))
            case true
                h.MathWorksDeviceType='ARM Compatible->ARM Cortex';
            otherwise
                h.MathWorksDeviceType=h.DeviceID;
            end
        end
    end
end

