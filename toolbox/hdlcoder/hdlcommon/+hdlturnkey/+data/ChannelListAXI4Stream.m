


classdef ChannelListAXI4Stream<hdlturnkey.data.ChannelListAXI4StreamBase


    properties

    end

    methods(Access=public)

        function obj=ChannelListAXI4Stream(interfaceID,...
            interfacePortLabel,...
            masterChannelNumber,...
            slaveChannelNumber)

            obj=obj@hdlturnkey.data.ChannelListAXI4StreamBase(interfaceID,...
            interfacePortLabel,...
            masterChannelNumber,...
            slaveChannelNumber);

        end


        function hChannel=createChannel(obj,channelDirType,...
            userMasterDrivenPortList,userSlaveDrivenPortList)



            if channelDirType==hdlturnkey.IOType.INOUT
                hChannel=[];
                return;
            end


            [channelID,channelIdx,channelPortLabel]=...
            obj.getNewChannelID(channelDirType);
            hChannel=hdlturnkey.data.ChannelAXI4Stream(...
            channelID,channelIdx,channelPortLabel);


            obj.addChannel(channelID,hChannel);


            hChannel.ChannelDirType=channelDirType;


            if hChannel.ChannelDirType==hdlturnkey.IOType.IN


                for ii=1:length(userMasterDrivenPortList)
                    portCell=userMasterDrivenPortList{ii};
                    hChannel.addPort(portCell{:},hdlturnkey.IOType.IN);
                end

                for ii=1:length(userSlaveDrivenPortList)
                    portCell=userSlaveDrivenPortList{ii};
                    hChannel.addPort(portCell{:},hdlturnkey.IOType.OUT);
                end
            else


                for ii=1:length(userMasterDrivenPortList)
                    portCell=userMasterDrivenPortList{ii};
                    hChannel.addPort(portCell{:},hdlturnkey.IOType.OUT);
                end

                for ii=1:length(userSlaveDrivenPortList)
                    portCell=userSlaveDrivenPortList{ii};
                    hChannel.addPort(portCell{:},hdlturnkey.IOType.IN);
                end
            end

        end


        function subPortIDStr=allocateSubPort(obj,portName,hTableMap)


            hChannel=obj.getChannelFromPortName(portName);


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            if hIOPort.isVector||hIOPort.isMatrix


                subPortIDStr='Data';
                return;
            end



            subPortIDStr=hChannel.allocateSubPortRegExp(hIOPort);


            if hChannel.isEmptyPortID(subPortIDStr)
                modelPortDir=hIOPort.PortType;
                if hChannel.ChannelDirType==modelPortDir

                    hDataPort=hChannel.getDataPort;
                    if hDataPort.isAssigned
                        subPortIDStr=hChannel.getEmptyPortID;
                    else
                        subPortIDStr=hDataPort.getPortIDDispStr;
                    end
                else

                    hReadyPort=hChannel.getReadyPort;
                    if hReadyPort.isAssigned
                        subPortIDStr=hChannel.getEmptyPortID;
                    else
                        subPortIDStr=hReadyPort.getPortIDDispStr;
                    end
                end
            end


            try
                obj.validateSubPort(portName,subPortIDStr,hTableMap);
            catch ME %#ok<NASGU>
                subPortIDStr=hChannel.getEmptyPortID;
            end

        end

        function validateSubPort(obj,portName,bitRangeStr,hTableMap)

            hChannel=obj.getChannelFromPortName(portName);







            hChannel.validateSubPort(portName,bitRangeStr,hTableMap);

        end


        function isa=isFrameMode(obj,hInterface)

            isa=false;
            channelIDlist=obj.getChanneIDList;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.getChannel(channelID);
                if hChannel.isAnySubPortAssigned&&...
                    hChannel.isFrameMode(hInterface)
                    isa=true;
                    break;
                end
            end
        end

        function isa=isFrameToSample(obj)

            isa=false;
            channelIDlist=obj.getChanneIDList;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.getChannel(channelID);
                if hChannel.isAnySubPortAssigned&&...
                    hChannel.isFrameToSample
                    isa=true;
                    break;
                end
            end
        end

    end

end



