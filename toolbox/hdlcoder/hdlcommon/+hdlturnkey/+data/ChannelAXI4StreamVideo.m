


classdef ChannelAXI4StreamVideo<hdlturnkey.data.ChannelAXI4StreamBase


    methods(Access=public)

        function obj=ChannelAXI4StreamVideo(channelID,channelIdx,channelPortLabel)

            obj=obj@hdlturnkey.data.ChannelAXI4StreamBase(channelID,channelIdx,channelPortLabel);

        end


        function hPort=addPort(obj,subPortID,portName,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType)



            hPort=addPort@hdlturnkey.data.Channel(obj,subPortID,portName,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType);


            if strcmpi(portType,'data')
                obj.hDataPort=hPort;
            elseif strcmpi(portType,'ready')
                obj.hReadyPort=hPort;
            end

        end


        function validateSubPort(obj,portName,bitRangeStr,hTableMap)



            validateSubPort@hdlturnkey.data.Channel(obj,portName,bitRangeStr,hTableMap);


            subPortID=bitRangeStr;
            hSubPort=obj.getPort(subPortID);
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);


            if obj.isDataPort(hSubPort)&&...
                obj.RDOverrideDataBitwidth>0
                [~,~,requiredPortWidth]=obj.getPortWidth(hSubPort);
                assignedPortWidth=hIOPort.WordLength;
                if assignedPortWidth>requiredPortWidth
                    error(message('hdlcommon:interface:SubPortNotFitRDOverride',...
                    obj.ChannelID,requiredPortWidth,portName,assignedPortWidth));
                end
            end

        end

        function validateCell=validateFullTable(obj,validateCell,hTable)



            validateCell=validateFullTable@hdlturnkey.data.Channel(obj,validateCell,hTable);




            [~,~,dataPortWidth]=obj.getPortWidth(obj.hDataPort);
            assignedPortWidth=obj.hDataPort.getAssignedPortWidth;

            cmdDisplay=hTable.hTurnkey.hD.cmdDisplay;
            if assignedPortWidth<dataPortWidth
                if obj.RDOverrideDataBitwidth>0

                    validateCell{end+1}=downstream.tool.generateWarningWithStruct(...
                    message('hdlcommon:interface:TDATAPortWidthRDOverride',...
                    obj.ChannelID,dataPortWidth,dataPortWidth),cmdDisplay);
                else
                    validateCell{end+1}=downstream.tool.generateWarningWithStruct(...
                    message('hdlcommon:interface:TDATAPortWidth',...
                    obj.ChannelID,dataPortWidth),cmdDisplay);
                end
            end

        end


        function[portWidth,portDimension,totalPortWidth,isComplex]=getPortWidth(obj,hSubPort,PackingMode)
            isComplex=false;
            if nargin<3
                PackingMode='';
            end
            if obj.isDataPort(hSubPort)

                [portWidth,portDimension,totalPortWidth,isComplex]=obj.getDataPortWidth(hSubPort,PackingMode);

            else
                if hSubPort.isAssigned
                    [portWidth,portDimension]=hSubPort.getAssignedPortWidth;
                else
                    portWidth=hSubPort.hDataType.getMaxWordLength;
                    portDimension=1;
                end
                totalPortWidth=portWidth*portDimension;
            end
        end

    end
end



