


classdef InterfaceIOMultiMap<handle




    properties

        hInterfaceToIOPortMap=[];

    end

    methods

        function obj=InterfaceIOMultiMap()

            obj.hInterfaceToIOPortMap=containers.Map();
        end

        function buildInterfaceIOMap(obj,hIOPortList,hTableMap)

            obj.hInterfaceToIOPortMap=containers.Map();

            for ii=1:length(hIOPortList.InputPortNameList)
                portName=hIOPortList.InputPortNameList{ii};
                obj.buildInterfaceIOMapOnPort(portName,hTableMap)
            end

            for ii=1:length(hIOPortList.OutputPortNameList)
                portName=hIOPortList.OutputPortNameList{ii};
                obj.buildInterfaceIOMapOnPort(portName,hTableMap)
            end
        end

        function portNameList=getPortNameList(obj,interfaceID)
            if obj.isKey(interfaceID)
                portNameList=obj.hInterfaceToIOPortMap(interfaceID);
            else
                portNameList={};
            end
        end

        function iskey=isKey(obj,interfaceID)
            iskey=obj.hInterfaceToIOPortMap.isKey(interfaceID);
        end

        function keys=keys(obj)
            keys=obj.hInterfaceToIOPortMap.keys;
        end

    end

    methods(Access=private)

        function buildInterfaceIOMapOnPort(obj,portName,hTableMap)

            hInterface=hTableMap.getInterface(portName);
            interfaceID=hInterface.InterfaceID;

            if obj.isKey(interfaceID)
                IOPortCell=obj.hInterfaceToIOPortMap(interfaceID);
            else
                IOPortCell={};
            end
            IOPortCell{end+1}=portName;

            obj.hInterfaceToIOPortMap(interfaceID)=IOPortCell;
        end

    end

end

