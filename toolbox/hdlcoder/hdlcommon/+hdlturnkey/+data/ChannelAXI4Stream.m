



classdef ChannelAXI4Stream<hdlturnkey.data.ChannelAXI4StreamBase


    properties(Access=protected)


        hValidPort=[];
        hTLASTPort=[];


        hSCBusPort=[];


    end


    methods(Access=public)

        function obj=ChannelAXI4Stream(channelID,channelIdx,channelPortLabel)

            obj=obj@hdlturnkey.data.ChannelAXI4StreamBase(channelID,channelIdx,channelPortLabel);

            obj.hValidPort=[];
            obj.hTLASTPort=[];
            obj.hSCBusPort=[];

        end


        function hPort=addPort(obj,subPortID,portName,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType)



            hPort=addPort@hdlturnkey.data.Channel(obj,subPortID,portName,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType);


            if strcmpi(portType,'data')
                obj.hDataPort=hPort;
            elseif strcmpi(portType,'valid')
                obj.hValidPort=hPort;
            elseif strcmpi(portType,'ready')
                obj.hReadyPort=hPort;
            elseif strcmpi(portType,'tlast')
                obj.hTLASTPort=hPort;
            elseif strcmpi(portType,'ctrl')
                obj.hSCBusPort=hPort;
            end

        end

        function hPort=getValidPort(obj)
            hPort=obj.hValidPort;
        end
        function hPort=getTLASTPort(obj)
            hPort=obj.hTLASTPort;
        end
        function hPort=getSCBusPort(obj)
            hPort=obj.hSCBusPort;
        end

        function isa=isValidPort(obj,hPort)
            isa=obj.hValidPort==hPort;
        end
        function isa=isTLASTPort(obj,hPort)
            isa=obj.hTLASTPort==hPort;
        end
        function isa=isSCBusPort(obj,hPort)
            isa=obj.hSCBusPort==hPort;
        end

        function isa=isTLASTPortAssigned(obj)
            hPort=obj.getTLASTPort;
            if isempty(hPort)
                isa=false;
            else
                isa=hPort.isAssigned;
            end
        end
        function isa=isSampleControlBusAssigned(obj)
            hPort=obj.getSCBusPort;
            if isempty(hPort)
                isa=false;
            else
                isa=hPort.isAssigned;
            end
        end

        function isa=isFrameMode(obj,hInterface)
            isa=false;

            hIOPort=obj.hDataPort.getAssignedPort;
            isFrameMode=~strcmp(hInterface.SamplePackingDimension,'All');
            if~(obj.hDataPort.isAssigned&&isFrameMode)


                return;
            end


            isa=isFrameMode&&hIOPort.isVector&&~hIOPort.isComplex;


            if(hIOPort.isVector||hIOPort.isMatrix)&&obj.isFrameToSample
                isa=true;
            end
        end

        function isa=isFrameToSample(obj)

            hIOPort=obj.hDataPort.getAssignedPort;
            isa=hIOPort.isStreamedPort;
        end

        function cleanPortAssignment(obj)

            cleanPortAssignment@hdlturnkey.data.Channel(obj);
        end

        function isa=isFrameModePort(obj,hTable)
            isa=false;
            subPortIDList=obj.getPortIDList;
            for ii=1:length(subPortIDList)
                subPortID=subPortIDList{ii};
                hPort=obj.getPort(subPortID);
                if hPort.IsRequiredPort&&hPort.isAssigned&&...
                    ~obj.isEmptyPort(hPort)
                    portName=hPort.getAssignedPortName;
                    hInterface=hTable.hTableMap.getInterface(portName);
                    if hInterface.isAXI4StreamInterface
                        isFrameMode=obj.isFrameMode(hInterface);
                        if isFrameMode
                            isa=true;
                            return;
                        end
                    end
                end
            end
        end


        function validateSubPort(obj,portName,bitRangeStr,hTableMap)







            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            if hIOPort.isVector||hIOPort.isMatrix
                return;
            end


            validateSubPort@hdlturnkey.data.Channel(obj,portName,bitRangeStr,hTableMap);


            subPortID=bitRangeStr;
            hSubPort=obj.getPort(subPortID);
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            FlattenPortWidth=hIOPort.getFlattenedPortWidth;


            if obj.isDataPort(hSubPort)&&...
                obj.RDOverrideDataBitwidth>0
                [~,~,requiredPortWidth]=obj.getPortWidth(hSubPort);
                if FlattenPortWidth>requiredPortWidth
                    error(message('hdlcommon:interface:SubPortNotFitRDOverride',...
                    obj.ChannelID,requiredPortWidth,portName,FlattenPortWidth));
                end
            end


            if obj.hDataPort.isAssigned&&...
                (strcmpi(hSubPort.PortType,'tstrb')||...
                strcmpi(hSubPort.PortType,'tkeep'))
                assignedPortWidth=hIOPort.WordLength;
                subPortName=hSubPort.ExternalPortName;
                [~,~,requiredPortWidth]=obj.getPortWidth(hSubPort);
                if assignedPortWidth>requiredPortWidth
                    [~,~,dataPortWidth]=obj.getPortWidth(obj.hDataPort);
                    error(message('hdlcommon:interface:TSTRBPortWidthTooLong',...
                    subPortName,obj.ChannelID,dataPortWidth,subPortName,requiredPortWidth));
                end
            end

        end

        function validateCell=validateFullTable(obj,validateCell,hTable)



            validateCell=validateFullTable@hdlturnkey.data.Channel(obj,validateCell,hTable);




            subport=obj.hDataPort;
            portName=subport.getAssignedPortName;
            hInterface=hTable.hTableMap.getInterface(portName);
            if obj.isFrameMode(hInterface)

                obj.SamplePackingDimension=hInterface.SamplePackingDimension;
                dataPortWidth=obj.getPortWidth(obj.hDataPort);
                FlattenPortWidth=obj.hDataPort.getAssignedPortWidth;
                iscomplex=0;
            else
                [~,~,dataPortWidth,iscomplex]=obj.getPortWidth(obj.hDataPort);
                [assignedPortWidth,assignedPortDimension]=obj.hDataPort.getAssignedPortWidth;
                FlattenPortWidth=assignedPortWidth*assignedPortDimension;
            end
            cmdDisplay=hTable.hTurnkey.hD.cmdDisplay;
            if FlattenPortWidth<dataPortWidth
                if obj.RDOverrideDataBitwidth>0

                    validateCell{end+1}=downstream.tool.generateWarningWithStruct(...
                    message('hdlcommon:interface:TDATAPortWidthRDOverride',...
                    obj.ChannelID,dataPortWidth,dataPortWidth),cmdDisplay);
                else
                    if~iscomplex
                        validateCell{end+1}=downstream.tool.generateWarningWithStruct(...
                        message('hdlcommon:interface:TDATAPortWidth',...
                        obj.ChannelID,dataPortWidth),cmdDisplay);
                    else

                        validateCell{end+1}=downstream.tool.generateWarningWithStruct(...
                        message('hdlcommon:interface:TDATAPortWidthComplex',...
                        obj.ChannelID,dataPortWidth),cmdDisplay);
                    end
                end
            end

            subPortIDList=obj.getPortIDList;
            for ii=1:length(subPortIDList)
                subPortID=subPortIDList{ii};
                hSubPort=obj.getPort(subPortID);
                if hSubPort.isAssigned&&~obj.isEmptyPort(hSubPort)


                    if strcmpi(hSubPort.PortType,'tstrb')||...
                        strcmpi(hSubPort.PortType,'tkeep')
                        portName=hSubPort.ExternalPortName;
                        [~,~,requiredPortWidth]=obj.getPortWidth(hSubPort);
                        assignedPortWidth=hSubPort.getAssignedPortWidth;
                        if assignedPortWidth>requiredPortWidth
                            error(message('hdlcommon:interface:TSTRBPortWidthTooLong',...
                            portName,obj.ChannelID,dataPortWidth,portName,requiredPortWidth));
                        elseif assignedPortWidth<requiredPortWidth
                            validateCell{end+1}=downstream.tool.generateWarningWithStruct(...
                            message('hdlcommon:interface:TSTRBPortWidth',...
                            portName,portName,obj.ChannelID,requiredPortWidth),cmdDisplay);%#ok<*AGROW>
                        end
                    end
                end
            end
        end


        function[portWidth,portDimension,totwidth,isComplex]=getPortWidth(obj,hSubPort,PackingMode)
            isComplex=false;
            if nargin<3
                PackingMode='';
            end
            if obj.isDataPort(hSubPort)

                [portWidth,portDimension,totwidth,isComplex]=obj.getDataPortWidth(hSubPort,PackingMode);

            elseif strcmpi(hSubPort.PortType,'tstrb')||...
                strcmpi(hSubPort.PortType,'tkeep')

                if obj.hDataPort.isAssigned
                    [portWidth,portDimension,totwidth]=obj.getPortWidth(obj.hDataPort,PackingMode);
                    totwidth=ceil(totwidth/8);
                else
                    portWidth=hSubPort.hDataType.getMaxWordLength;
                    portDimension=1;
                    totwidth=portWidth;
                end

            else
                if hSubPort.isAssigned
                    [portWidth,portDimension]=hSubPort.getAssignedPortWidth;
                else
                    portWidth=hSubPort.hDataType.getMaxWordLength;
                    portDimension=1;
                end
                totwidth=portWidth*portDimension;
            end
        end

        function isa=isStandardPortGroup(obj,hSubPort)

            isa=obj.isDataPort(hSubPort)||...
            obj.isValidPort(hSubPort)||...
            obj.isReadyPort(hSubPort);
        end

        function isa=isRequiredUserPortGroup(obj,hSubPort)

            isa=obj.isDataPort(hSubPort)||...
            obj.isValidPort(hSubPort);
        end

        function isa=isSlaveRequiredExtPortGroup(obj,hSubPort)


            isa=isStandardPortGroup(obj,hSubPort);
        end

        function isa=isMasterRequiredExtPortGroup(obj,hSubPort)


            isa=obj.isSlaveRequiredExtPortGroup(hSubPort)||...
            obj.isTLASTPort(hSubPort);
        end

        function assignCodeGenerationSubPort(obj,portName,subPortID,codegenIOPortList)



            if obj.ModelPortSubPortMap.isKey(portName)
                oldSubPortID=obj.ModelPortSubPortMap(portName);
                hPort=obj.getPort(oldSubPortID);
                hPort.removePortAssignment(portName);
            end


            hPort=obj.getPort(subPortID);
            hPort.setCodeGenerationPortAssignment(portName,codegenIOPortList);
            obj.ModelPortSubPortMap(portName)=subPortID;
        end

    end
end



