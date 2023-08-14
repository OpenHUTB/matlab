


classdef SoftwareInterfaceEmpty<hdlturnkey.swinterface.SoftwareInterfaceBase


    properties(Access=protected)
        AddInterfaceMethod='';
    end

    methods

        function obj=SoftwareInterfaceEmpty(interfaceID)


            obj=obj@hdlturnkey.swinterface.SoftwareInterfaceBase(interfaceID);
        end

        function isa=isEmptyInterface(~)
            isa=true;
        end
    end


    methods
        function validateCell=generateDeviceTreeNodes(~,~)

            validateCell={};
        end
    end


    methods
        function validateCell=generateModelDriver(obj,hModelGen)
            obj.stubAllPorts(hModelGen);

            validateCell={};
            inPortList=obj.hIOPortList.InputPortNameList;
            outPortList=obj.hIOPortList.OutputPortNameList;
            portListStr=strjoin([inPortList,outPortList],', ');
            msg=message('hdlcommon:interface:NoDriverSWModelGen',portListStr,obj.InterfaceID);
            validateCell{end+1}=downstream.tool.generateNoteWithStruct(msg,hModelGen.isCommandLineDisplay);
        end

        function validateCell=generateHostModelDriver(obj,hModelGen)
            obj.stubAllPorts(hModelGen);

            validateCell={};
            inPortList=obj.hIOPortList.InputPortNameList;
            outPortList=obj.hIOPortList.OutputPortNameList;
            portListStr=strjoin([inPortList,outPortList],', ');
            msg=message('hdlcommon:interface:NoDriverHostModelGen',portListStr,obj.InterfaceID);
            validateCell{end+1}=downstream.tool.generateNoteWithStruct(msg,hModelGen.isCommandLineDisplay);
        end
    end


    methods
        function validateCell=generateScriptDriver(obj,hScriptGen)

            validateCell={};
            inPortList=obj.hIOPortList.InputPortNameList;
            outPortList=obj.hIOPortList.OutputPortNameList;
            portListStr=strjoin([inPortList,outPortList],', ');
            msg=message('hdlcommon:interface:NoDriverSWScriptGen',portListStr,obj.InterfaceID);
            validateCell{end+1}=downstream.tool.generateNoteWithStruct(msg,hScriptGen.isCommandLineDisplay);
        end

        function validateCell=generateInterfaceAccessCommand(~,~)

            validateCell={};
        end
    end
end