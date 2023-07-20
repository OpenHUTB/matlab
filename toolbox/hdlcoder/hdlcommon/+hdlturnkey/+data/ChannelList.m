


classdef(Abstract)ChannelList<handle







    properties(Access=protected)


        ChannelMap=[];




        PortChannelMap=[];

    end

    methods(Access=public)

        function obj=ChannelList()

            obj.ChannelMap=containers.Map();
            obj.PortChannelMap=containers.Map();
        end


        function hChannel=createChannel(obj,channelID)
            hChannel=hdlturnkey.data.Channel(channelID);
            obj.addChannel(channelID,hChannel);
        end


        function cleanPortAssignment(obj,hStreamIF,hTable)



            channelIDlist=obj.getChanneIDList;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.getChannel(channelID);
                hChannel.cleanPortAssignment;
            end



            portNameList=obj.getAssignedPortList;
            for ii=1:length(portNameList)
                portName=portNameList{ii};



                hInterface=hTable.hTableMap.getInterface(portName);
                if~isequal(hInterface,hStreamIF)
                    obj.PortChannelMap.remove(portName);
                end
            end
        end

        function cleanChannelAssignment(obj)


            obj.PortChannelMap=containers.Map();
        end


        function hChannel=getChannel(obj,channelID)

            hChannel=obj.ChannelMap(channelID);
        end
        function isa=isExistingChannel(obj,channelID)
            isa=obj.ChannelMap.isKey(channelID);
        end
        function list=getChanneIDList(obj)
            list=obj.ChannelMap.keys;
        end
        function addChannel(obj,channelID,hChannel)

            obj.ChannelMap(channelID)=hChannel;
        end


        function hChannel=getChannelFromPortName(obj,portName)

            hChannel=obj.PortChannelMap(portName);
        end
        function list=getAssignedPortList(obj)
            list=obj.PortChannelMap.keys;
        end


        function list=getAssignedChannels(obj)

            list={};
            channelIDlist=obj.getChanneIDList;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.getChannel(channelID);

                if hChannel.isAnySubPortAssigned
                    list{end+1}=channelID;%#ok<AGROW>
                end
            end
        end

        function isa=isAllChannelAssigned(obj)

            assignedList=obj.getAssignedChannels;
            isa=length(assignedList)==length(obj.getChanneIDList);
        end

        function has=hasChannelAssigned(obj)

            assignedList=obj.getAssignedChannels;
            has=~isempty(assignedList);
        end


        function assignChannel(obj,portName,hChannel)

            obj.PortChannelMap(portName)=hChannel;
        end


        function assignSubPort(obj,portName,subPortID,hTableMap)

            hChannel=obj.getChannelFromPortName(portName);
            hChannel.assignSubPort(portName,subPortID,hTableMap);
        end

        function validateSubPort(obj,portName,bitRangeStr,hTableMap)

            hChannel=obj.getChannelFromPortName(portName);
            hChannel.validateSubPort(portName,bitRangeStr,hTableMap);
        end

        function validateCell=validateFullTable(obj,validateCell,hTable)

            channelIDlist=obj.getChanneIDList;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.getChannel(channelID);
                if hChannel.isAnySubPortAssigned
                    validateCell=hChannel.validateFullTable(validateCell,hTable);
                end
            end
        end


        function[inputChannelIDList,outputChannelIDList]=...
            getInOutChannelIDList(obj)

            channelIDList=obj.getChanneIDList;
            inputChannelIDList=channelIDList;
            outputChannelIDList=channelIDList;
        end

        function channelStr=getAllChannelIDStr(obj)
            channelStr='';
            channelIDlist=obj.getChanneIDList;
            channelLen=length(channelIDlist);

            if channelLen==1
                channelStr=sprintf('"%s"',channelIDlist{1});
                return;
            end

            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                if ii==length(channelIDlist)
                    channelStr=sprintf('%sand "%s"',channelStr,channelID);
                else
                    channelStr=sprintf('%s"%s", ',channelStr,channelID);
                end
            end
        end
    end
end



