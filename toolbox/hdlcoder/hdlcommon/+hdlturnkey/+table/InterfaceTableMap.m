


classdef InterfaceTableMap<handle


    properties


        hTable=[];


    end

    properties(Access=private)


        IOPortInterfaceMap=[];


        IOPortBitRangeMap=[];


        IOPortInterfaceOptionMap=[];


        IOPortInterfaceUserSpecMap=[];
        IOPortBitRangeUserSpecMap=[];
        IOPortInterfaceOptionSpecMap=[];


        hInterfaceIOMap=[];



        BackupIOPortInterfaceStrMap=[];

        BackupIOPortBitRangeStrMap=[];

        BackupIOPortInterfaceOptionMap=[];

    end

    methods

        function obj=InterfaceTableMap(hTable)


            obj.hTable=hTable;

            obj.IOPortInterfaceMap=containers.Map();
            obj.IOPortBitRangeMap=containers.Map();
            obj.IOPortInterfaceOptionMap=containers.Map();

            obj.IOPortInterfaceUserSpecMap=containers.Map();
            obj.IOPortBitRangeUserSpecMap=containers.Map();
            obj.IOPortInterfaceOptionSpecMap=containers.Map();

            obj.hInterfaceIOMap=hdlturnkey.table.InterfaceIOMultiMap;

            obj.BackupIOPortInterfaceStrMap=containers.Map();
            obj.BackupIOPortBitRangeStrMap=containers.Map();
            obj.BackupIOPortInterfaceOptionMap=containers.Map();
        end

        function initialTableMap(obj)

            for ii=1:length(obj.hTable.hIOPortList.InputPortNameList)
                portName=obj.hTable.hIOPortList.InputPortNameList{ii};
                obj.initialTableMapOnPort(portName);
            end
            for ii=1:length(obj.hTable.hIOPortList.OutputPortNameList)
                portName=obj.hTable.hIOPortList.OutputPortNameList{ii};
                obj.initialTableMapOnPort(portName);
            end
        end

        function initialTableMapOnPort(obj,portName)

            hInterfaceList=getInterfaceList(obj.hTable);
            hEmptyInterface=hInterfaceList.getEmptyInterface;
            obj.setInterface(portName,hEmptyInterface);


            obj.setInterfaceUserSpec(portName,false);


            obj.initialBitRangeData(portName);


            obj.initialInterfaceOption(portName);
        end

        function initialBitRangeData(obj,portName)

            obj.setBitRangeData(portName,{});

            obj.setBitRangeUserSpec(portName,false);
        end

        function initialInterfaceOption(obj,portName)

            obj.setInterfaceOption(portName,{});

            obj.setInterfaceOptionUserSpec(portName,false);
        end

        function assignInterface(obj,portName,hInterface,interfaceStr)


            if nargin<4
                interfaceStr=hInterface.InterfaceID;
            end
            hInterface.assignInterface(portName,interfaceStr,obj);
        end

        function assignBitRange(obj,portName,bitRangeStr)


            hInterface=obj.getInterface(portName);
            hInterface.assignBitRange(portName,bitRangeStr,obj);
        end

        function assignInterfaceOption(obj,portName,optParamPVPair)


            hInterface=obj.getInterface(portName);
            hInterface.assignInterfaceOption(portName,optParamPVPair,obj);
        end


        function interfaceStr=getInterfaceStr(obj,portName)

            hInterface=obj.getInterface(portName);
            interfaceStr=hInterface.getTableCellInterfaceStr(portName);
        end
        function interfaceIdx=getInterfaceIdx(obj,portName)

            interfaceStr=obj.getInterfaceStr(portName);
            interfaceChoiceStr=obj.hTable.getTableCellInterfaceChoice(portName);

            cmpresult=strcmp(interfaceStr,interfaceChoiceStr);
            idxList=0:length(interfaceChoiceStr)-1;
            interfaceIdx=idxList(cmpresult);
        end
        function bitRangeStr=getBitRangeStr(obj,portName)

            hInterface=obj.getInterface(portName);
            bitRangeStr=hInterface.getTableCellBitRangeStr(portName,obj);
        end
        function interfaceOptStr=getInterfaceOptionStr(obj,portName)

            hInterface=obj.getInterface(portName);
            interfaceOptStr=hInterface.getTableCellInterfaceOptionStr(portName,obj);
        end


        function backupInterfaceStr(obj,portName,interfaceStr)

            obj.BackupIOPortInterfaceStrMap(portName)=interfaceStr;
        end
        function interfaceStr=getBackupInterfaceStr(obj,portName)

            interfaceStr=obj.BackupIOPortInterfaceStrMap(portName);
        end

        function backupBitRangeStr(obj,portName,bitrangeStr)

            obj.BackupIOPortBitRangeStrMap(portName)=bitrangeStr;
        end
        function bitrangeStr=getBackupBitRangeStr(obj,portName)

            bitrangeStr=obj.BackupIOPortBitRangeStrMap(portName);
        end

        function backupInterfaceOption(obj,portName,optionPVPair)

            obj.BackupIOPortInterfaceOptionMap(portName)=optionPVPair;
        end
        function optionPVPair=getBackupInterfaceOption(obj,portName)

            optionPVPair=obj.BackupIOPortInterfaceOptionMap(portName);
        end

        function isa=isBitRangeComboBox(obj,portName)

            hInterface=obj.getInterface(portName);
            isa=hInterface.isBitRangeComboBox(portName,obj);
        end

        function isa=showInterfaceOptionPushButton(obj,hIOPort)
            hInterface=obj.getInterface(hIOPort.PortName);
            isa=hInterface.showInterfaceOptionPushButton(hIOPort,obj);
        end
        function bitRangeIdx=getBitRangeIdx(obj,portName)

            if obj.isBitRangeComboBox(portName)
                bitRangeStr=obj.getBitRangeStr(portName);
                bitRangeChoiceStr=obj.getBitRangeChoice(portName);

                cmpresult=strcmp(bitRangeStr,bitRangeChoiceStr);
                idxList=0:length(bitRangeChoiceStr)-1;
                bitRangeIdx=idxList(cmpresult);
            else
                hInterface=obj.getInterface(portName);
                error(message('hdlcommon:workflow:InvalidBitRangeFunction',...
                hInterface.InterfaceID));
            end
        end
        function bitRangeChoice=getBitRangeChoice(obj,portName)

            hInterface=obj.getInterface(portName);
            if obj.isBitRangeComboBox(portName)
                bitRangeChoice=hInterface.getBitRangeChoice(portName,obj);
            else
                bitRangeChoice={getBitRangeStr};
            end
        end


        function setInterface(obj,portName,hInterface)
            obj.IOPortInterfaceMap(portName)=hInterface;
        end
        function hInterface=getInterface(obj,portName)
            hInterface=obj.IOPortInterfaceMap(portName);
        end
        function iskey=isInterfaceMapKey(obj,portName)
            iskey=obj.IOPortInterfaceMap.isKey(portName);
        end
        function setBitRangeData(obj,portName,bitRangeData)
            obj.IOPortBitRangeMap(portName)=bitRangeData;
        end
        function bitRangeData=getBitRangeData(obj,portName)
            bitRangeData=obj.IOPortBitRangeMap(portName);
        end
        function setInterfaceOption(obj,portName,optionPVPair)
            obj.IOPortInterfaceOptionMap(portName)=optionPVPair;
        end
        function optionPVPair=getInterfaceOption(obj,portName)
            optionPVPair=obj.IOPortInterfaceOptionMap(portName);
        end


        function isUserSpec=isInterfaceUserSpec(obj,portName)
            isUserSpec=obj.IOPortInterfaceUserSpecMap(portName);
        end
        function isUserSpec=isBitRangeUserSpec(obj,portName)
            isUserSpec=obj.IOPortBitRangeUserSpecMap(portName);
        end
        function isUserSpec=isInterfaceOptionUserSpec(obj,portName)
            isUserSpec=obj.IOPortInterfaceOptionSpecMap(portName);
        end
        function setInterfaceUserSpec(obj,portName,isUserSpec)
            obj.IOPortInterfaceUserSpecMap(portName)=isUserSpec;
        end
        function setBitRangeUserSpec(obj,portName,isUserSpec)
            obj.IOPortBitRangeUserSpecMap(portName)=isUserSpec;
        end
        function setInterfaceOptionUserSpec(obj,portName,isUserSpec)
            obj.IOPortInterfaceOptionSpecMap(portName)=isUserSpec;
        end


        function buildInterfaceIOMap(obj)
            obj.hInterfaceIOMap.buildInterfaceIOMap(obj.hTable.hIOPortList,obj);
        end
        function portNameList=getConnectedPortList(obj,interfaceID)
            portNameList=obj.hInterfaceIOMap.getPortNameList(interfaceID);
        end
        function isAssigned=isAssignedInterface(obj,interfaceID)
            isAssigned=obj.hInterfaceIOMap.isKey(interfaceID);
        end
        function interfaceIDs=getAssignedInterfaces(obj)
            interfaceIDs=obj.hInterfaceIOMap.keys;
        end

    end

end

