


classdef(Abstract)ChannelBased<hdlturnkey.interface.InterfaceBase


    properties(Access=protected)

        hChannelList=[];


        InputPropertyList={};
    end

    methods

        function obj=ChannelBased(interfaceID)

            obj=obj@hdlturnkey.interface.InterfaceBase(interfaceID);
        end

    end


    methods

        function validatePortForInterfaceShared(~,hIOPort,~,interfaceStr)





            if hIOPort.isComplex
                error(message('hdlcommon:workflow:UnsupportedComplexPort',interfaceStr,hIOPort.PortName));
            end
        end

        function cleanInterfaceAssignment(obj,hTable)

            obj.hChannelList.cleanPortAssignment(obj,hTable);
        end

        function cleanInterfaceChannelAssignment(obj)


            obj.hChannelList.cleanChannelAssignment;
        end

    end


    methods


        function isa=isBitRangeComboBox(~,portName,hTableMap)%#ok<INUSD>
            isa=true;
        end

        function bitRangeChoice=getBitRangeChoice(obj,portName,hTableMap)

            hChannel=obj.hChannelList.getChannelFromPortName(portName);
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            if hIOPort.PortType==hdlturnkey.IOType.IN
                bitRangeChoice=hChannel.getInputPortIDList;
            else
                bitRangeChoice=hChannel.getOutputPortIDList;
            end
        end

        function[needError,msgObj]=validateRequiredInterface(obj,~)

            needError=false;
            msgObj=[];
            if obj.IsRequired&&...
                ~obj.hChannelList.isAllChannelAssigned
                channelStr=obj.hChannelList.getAllChannelIDStr;
                msgObj=message('hdlcommon:hdlturnkey:RequiredInterfaceNotAssignedP',...
                channelStr);
                needError=true;
            end
        end

        function validateCell=validateFullTable(obj,validateCell,hTable)

            validateCell=obj.hChannelList.validateFullTable(validateCell,hTable);
        end

        function result=showInInterfaceChoice(~,hTurnkey)

            result=~hTurnkey.isCoProcessorMode;
        end

    end


    methods

        function interfaceStr=getTableCellInterfaceStr(obj,portName)

            hChannel=obj.hChannelList.getChannelFromPortName(portName);
            interfaceStr=hChannel.ChannelID;
        end

        function[inputInterfaceStrList,outputInterfaceStrList]=getTableInterfaceStrList(obj)


            [inputInterfaceStrList,outputInterfaceStrList]=...
            obj.hChannelList.getInOutChannelIDList;
        end

        function bitrangeStr=getTableCellBitRangeStr(~,portName,hTableMap)

            bitrangeStr=hTableMap.getBitRangeData(portName);
        end

    end


    methods
        function allocateUserSpecBitRange(obj,portName,hTableMap)



            subPortID=hTableMap.getBitRangeData(portName);

            obj.hChannelList.assignSubPort(portName,subPortID,hTableMap);
        end

        function allocateDefaultBitRange(obj,portName,hTableMap)





            subPortID=obj.hChannelList.allocateSubPort(portName,hTableMap);

            obj.hChannelList.assignSubPort(portName,subPortID,hTableMap);

            hTableMap.setBitRangeData(portName,subPortID);
        end

    end


    methods

        function initializeInterfaceElaborationBegin(obj)











            channelIDlist=obj.hChannelList.getChanneIDList;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);


                hChannel.initializeChannelElaboration;
            end
        end

    end

    methods(Access=protected)

        function connectInterfacePort(obj,hN,hElab,portName,hTopUserSignals,userPortIOType,hChannel)



            obj.saveCodegenPortNameList(hElab,portName,hChannel);


            hDUTPortSignals=hElab.getCodegenPirSignalForPort(portName);
            for ii=1:length(hDUTPortSignals)
                dutPortSignal=hDUTPortSignals{ii};
                if iscell(hTopUserSignals)
                    hTopUserSignal=hTopUserSignals{ii};
                else
                    hTopUserSignal=hTopUserSignals(ii);
                end

                if isequal(userPortIOType,hdlturnkey.IOType.OUT)
                    pirelab.getDTCComp(hN,hTopUserSignal,dutPortSignal,'Floor','Wrap','SI');
                else
                    pirelab.getDTCComp(hN,dutPortSignal,hTopUserSignal,'Floor','Wrap','SI');
                end
            end
        end

        function connectFrameInterfacePort(obj,hN,hElab,portName,hTopUserSignals,...
            userPortIOType,hChannel)





            obj.saveCodegenPortNameList(hElab,portName,hChannel);


            hDUTPortSignals=hElab.getCodegenPirSignalForPort(portName);




            if hChannel.isFrameToSample
                looplength=length(hDUTPortSignals)-1;

                if isequal(userPortIOType,hdlturnkey.IOType.OUT)
                    pirelab.getDTCComp(hN,hTopUserSignals{end},hDUTPortSignals{end},'Floor','Wrap','SI');
                else
                    pirelab.getDTCComp(hN,hDUTPortSignals{end},hTopUserSignals{end},'Floor','Wrap','SI');
                end
            else
                looplength=length(hDUTPortSignals);
            end
            for ii=1:looplength
                dutPortSignal=hDUTPortSignals{ii};
                hTopUserSignal=hTopUserSignals{ii};

                if isequal(userPortIOType,hdlturnkey.IOType.OUT)
                    pirelab.getDTCComp(hN,dutPortSignal,hTopUserSignal,'Floor','Wrap','SI');
                else
                    pirelab.getDTCComp(hN,hTopUserSignal,dutPortSignal,'Floor','Wrap','SI');
                end
            end

        end

        function saveCodegenPortNameList(~,hElab,dutPortName,hChannel)


            codegenPortNames=hElab.getCodegenPortNameList(dutPortName);
            hChannel.addCodeGenPortNamesToList(codegenPortNames);
        end

    end


    methods

    end


    methods

        function list=getAssignedChannelIDList(obj)

            list=obj.hChannelList.getAssignedChannels;
        end

        function hChannel=getChannel(obj,channelID)
            hChannel=obj.hChannelList.getChannel(channelID);
        end
    end

    methods(Static)


        [portName,portWidth,hSubPort,PortDimension,totalWidth,isComplex]=getExternalPortInfo(hChannel,extPortCell,hElab)


        populateExternalInputPort(hChannel,portName,portWidth,portDimension,totalWidth,isComplex,portIdx,hElab)


        populateExternalOutputPort(hChannel,portName,portWidth,portDimension,totalWidth,isComplex,portIdx,hElab)


        elabExternalPortForSampleMode(hN,hChannel)
        elabExternalPortForFrameMode(hN,hChannel)


        populateExternalChannelPort(hN,hChannel,MasterInputPortList,MasterOutputPortList,...
        SlaveInputPortList,SlaveOutputPortList,hElab)

    end

end


