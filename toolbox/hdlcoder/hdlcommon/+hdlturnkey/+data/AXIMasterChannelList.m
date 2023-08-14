

classdef AXIMasterChannelList<hdlturnkey.data.ChannelList


    properties(Access=public)

    end

    properties(Access=protected)



        BaseChannelID='';



        InterfacePortLabel='';


        PopulateUnused;


        DataWidthMatch;
    end

    properties(Hidden)

        AXIDataTotalWidth=32;
    end

    properties(Constant,Access=protected)

        WriteChannelNamePostFix='Write';
        ReadChannelNamePostFix='Read';
        WriteChannelPortPostFix='Wr';
        ReadChannelPortPostFix='Rd';

    end

    methods(Access=public)

        function obj=AXIMasterChannelList(interfaceID,interfacePortLabel,populateUnused,dataWidthMatch)

            obj=obj@hdlturnkey.data.ChannelList();


            obj.BaseChannelID=interfaceID;
            obj.InterfacePortLabel=interfacePortLabel;

            obj.PopulateUnused=populateUnused;
            obj.DataWidthMatch=dataWidthMatch;
        end


        function hChannel=createChannel(obj,channelDirType,...
            userInPortList,userOutPortList)



            if channelDirType==hdlturnkey.IOType.INOUT
                hChannel=[];
                return;
            end


            [channelID,channelPortLabel]=...
            obj.getNewChannelID(channelDirType);
            hChannel=hdlturnkey.data.AXIMasterChannel(...
            channelID,channelPortLabel);


            obj.addChannel(channelID,hChannel);


            hChannel.ChannelDirType=channelDirType;


            for ii=1:length(userInPortList)
                portCell=userInPortList{ii};
                hChannel.addPortWithDefault(portCell{:},hdlturnkey.IOType.IN);
            end

            for ii=1:length(userOutPortList)
                portCell=userOutPortList{ii};
                hChannel.addPortWithDefault(portCell{:},hdlturnkey.IOType.OUT);
            end
        end


        function subPortID=allocateSubPort(obj,portName,hTableMap)


            hChannel=obj.getChannelFromPortName(portName);
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);


            subPortID=hChannel.allocateSubPortRegExp(hIOPort);


            try
                hChannel.validateSubPort(portName,subPortID,hTableMap);
            catch ME %#ok<NASGU>
                subPortID=hChannel.getEmptyPortID;
            end
        end


        function determineAXIWidths(obj)


            channelIDList=obj.getAssignedChannels;
            AXIIDWidthsList=[];
            AXIRIDWidth=[];
            AXIWIDWidth=[];
            for ii=1:numel(channelIDList)
                hUsedChannel=obj.getChannel(channelIDList{ii});
                hUsedChannel.determineAXIWidths;
                hUsedChannel.determineAXIIDWidths;
                if hUsedChannel.IsAXIIDPortAssigned
                    AXIIDWidthsList(end+1)=hUsedChannel.AXIIDWidth;%#ok<AGROW>
                    if hUsedChannel.ChannelDirType==hdlturnkey.IOType.IN
                        AXIRIDWidth=hUsedChannel.AXIIDWidth;
                    else
                        AXIWIDWidth=hUsedChannel.AXIIDWidth;
                    end
                end
            end



            AXIIDWidth=unique(AXIIDWidthsList);
            if~isempty(AXIIDWidthsList)&&numel(AXIIDWidth)~=1
                error(message('hdlcommon:interface:AXIMasterIDWidthMismatch',AXIRIDWidth,AXIWIDWidth));
            end


            channelIDList=obj.getElaboratedChannels;
            for ii=1:numel(channelIDList)
                hChannel=obj.getChannel(channelIDList{ii});
                if~hChannel.isAnySubPortAssigned


                    hChannel.inheritAXIWidths(hUsedChannel);
                end

                if obj.DataWidthMatch
                    if~isequal(hChannel.AXIDataTotalWidth,hUsedChannel.AXIDataTotalWidth)
                        error(message('hdlcommon:interface:AXIMasterDataWidthMismatch'));
                    end
                end

                if~isempty(AXIIDWidth)
                    hChannel.inheritAXIIDWidths(AXIIDWidth);
                end
            end

            obj.AXIDataTotalWidth=hUsedChannel.AXIDataTotalWidth;
        end


        function list=getElaboratedChannels(obj)
            list=obj.getAssignedChannels;
            if~isempty(list)&&obj.PopulateUnused


                list=obj.getChanneIDList;
            end
        end
    end

    methods(Access=protected)


        function[channelID,channelPortLabel]=getNewChannelID(obj,channelDirType)


            switch(channelDirType)
            case hdlturnkey.IOType.IN
                portPostfix=obj.ReadChannelPortPostFix;
                namePostFix=obj.ReadChannelNamePostFix;
            case hdlturnkey.IOType.OUT
                portPostfix=obj.WriteChannelPortPostFix;
                namePostFix=obj.WriteChannelNamePostFix;
            end

            channelID=sprintf('%s %s',obj.BaseChannelID,namePostFix);
            channelPortLabel=sprintf('%s_%s',obj.InterfacePortLabel,portPostfix);


            if obj.isExistingChannel(channelID)
                error(message('hdlcommon:interface:DuplicateChannelID',...
                channelID));
            end
        end
    end
end



