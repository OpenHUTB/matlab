


classdef(Abstract)ChannelListAXI4StreamBase<hdlturnkey.data.ChannelList



    properties(Access=protected)




        BaseChannelID='';




        InterfacePortLabel='';


        MasterChannelNumber=0;
        SlaveChannelNumber=0;


        MasterChannelCounter=0;
        SlaveChannelCounter=0;

    end

    properties(Constant,Access=protected)


        MasterChannelNamePostFix='Master';
        SlaveChannelNamePostFix='Slave';
        MasterChannelPortLabelPostFix='Master';
        SlaveChannelPortLabelPostFix='Slave';

    end

    methods

        function obj=ChannelListAXI4StreamBase(interfaceID,...
            interfacePortLabel,...
            masterChannelNumber,...
            slaveChannelNumber)

            obj=obj@hdlturnkey.data.ChannelList();


            obj.BaseChannelID=interfaceID;


            obj.InterfacePortLabel=interfacePortLabel;


            obj.MasterChannelNumber=masterChannelNumber;
            obj.SlaveChannelNumber=slaveChannelNumber;


            obj.MasterChannelCounter=0;
            obj.SlaveChannelCounter=0;

        end

        function validateCell=validateFullTable(obj,validateCell,hTable)




            validateCell=validateFullTable@hdlturnkey.data.ChannelList(obj,validateCell,hTable);




            channelIDlist=obj.getChanneIDList;
            isReadyMapped=false;
            mappedChannelID='';
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.getChannel(channelID);
                hReadyPort=hChannel.getReadyPort;
                if hReadyPort.isAssigned
                    isReadyMapped=true;
                    mappedChannelID=channelID;
                    break;
                end
            end
            if isReadyMapped
                for ii=1:length(channelIDlist)
                    channelID=channelIDlist{ii};
                    hChannel=obj.getChannel(channelID);
                    if~hChannel.isAnySubPortAssigned

                        continue;
                    end
                    hReadyPort=hChannel.getReadyPort;
                    if~hReadyPort.isAssigned
                        readyPortID=hReadyPort.PortID;
                        cmdDisplay=hTable.hTurnkey.hD.cmdDisplay;
                        validateCell{end+1}=downstream.tool.generateErrorWithStruct(...
                        message('hdlcommon:interface:ReadyPortAllInterface',...
                        readyPortID,channelID,readyPortID,mappedChannelID,...
                        readyPortID,channelID),cmdDisplay);%#ok<AGROW>
                        break;
                    end
                end
            end
        end

    end

    methods(Access=protected)


        function[channelID,channelIdx,channelPortLabel]=getNewChannelID(obj,channelDirType)



            if channelDirType==hdlturnkey.IOType.IN
                nameDirStr=obj.SlaveChannelNamePostFix;
                labelDirStr=obj.SlaveChannelPortLabelPostFix;
                obj.SlaveChannelCounter=obj.SlaveChannelCounter+1;
                channelIdx=obj.SlaveChannelCounter;
                maxChannelNumber=obj.SlaveChannelNumber;
                dirMsgStr='input';
            else
                nameDirStr=obj.MasterChannelNamePostFix;
                labelDirStr=obj.MasterChannelPortLabelPostFix;
                obj.MasterChannelCounter=obj.MasterChannelCounter+1;
                channelIdx=obj.MasterChannelCounter;
                maxChannelNumber=obj.MasterChannelNumber;
                dirMsgStr='output';
            end


            if channelIdx>maxChannelNumber
                error(message('hdlcommon:interface:ChannelNumMaximum',...
                obj.BaseChannelID,maxChannelNumber,dirMsgStr));
            end


            if channelIdx==1
                channelID=sprintf('%s %s',obj.BaseChannelID,nameDirStr);
                channelPortLabel=sprintf('%s_%s',obj.InterfacePortLabel,labelDirStr);
            else
                channelID=sprintf('%s %s%d',obj.BaseChannelID,...
                nameDirStr,channelIdx);
                channelPortLabel=sprintf('%s_%s%d',obj.InterfacePortLabel,...
                labelDirStr,channelIdx);
            end


            if obj.isExistingChannel(channelID)
                error(message('hdlcommon:interface:DuplicateChannelID',...
                channelID));
            end
        end

    end

    methods


        function hChannel=getStreamChannel(obj,interfaceStr)

            if obj.isExistingChannel(interfaceStr)
                hChannel=obj.getChannel(interfaceStr);
            else
                error(message('hdlcommon:interface:StreamInvalidChannel',...
                interfaceStr,obj.BaseChannelID));
            end
        end

    end

end



