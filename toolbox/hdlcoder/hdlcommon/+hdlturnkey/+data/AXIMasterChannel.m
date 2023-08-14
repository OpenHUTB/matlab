

classdef AXIMasterChannel<hdlturnkey.data.Channel

    properties(Access=public,Hidden=true)


        ChannelPortLabel='';


        ExtTopInportSignals=handle([]);
        ExtTopOutportSignals=handle([]);


        ChannelNetInportSignals=handle([]);
        ChannelNetOutportSignals=handle([]);


        hMasterNet=handle([]);
    end

    properties(Hidden)
        DataWidthFixed=[];
        LenWidthFixed=[];
        NumDataBytes=4;
        AXIDataWidth=32
        AXIDataDimension=1;
        AXIDataTotalWidth=32;
        AXIIDWidth=1;
        AXIMasterToSlaveBusPort=[];
        AXIMasterToSlaveIDPortName=[];
    end

    properties(Dependent)
IsAXIIDPortAssigned
    end

    properties(Hidden,Constant)


        AXIReadMasterToSlaveIDName='rd_arid';
        AXIWriteMasterToSlaveIDName='wr_awid';


        AXIReadMasterToSlaveBusName='Read Master to Slave Bus';
        AXIWriteMasterToSlaveBusName='Write Master to Slave Bus';
    end

    properties(Access=public,Hidden=true)


        ExtInportNames={};
        ExtOutportNames={};
        ExtInportWidths={};
        ExtOutportWidths={};
        ExtInportDimensions={};
        ExtOutportDimensions={};
        ExtInportWidthsFlattened={};
        ExtOutportWidthsFlattened={};
        ExtInportDimensionsFlattened={};
        ExtOutportDimensionsFlattened={};


        ExtInportList={};
        ExtOutportList={};


        UserInportNames={};
        UserOutportNames={};
        UserInportWidths={};
        UserOutportWidths={};
        UserInportDimensions={};
        UserOutportDimensions={};



        UserInportList={};
        UserOutportList={};


        UserAssignedInportPorts={};
        UserAssignedOutportPorts={};


        UserTopInportSignals=handle([]);
        UserTopOutportSignals=handle([]);

    end

    properties(Access=protected)


        BusMemberIsAssignedMap=[];

    end

    methods

        function obj=AXIMasterChannel(channelID,channelPortLabel)

            obj=obj@hdlturnkey.data.Channel(channelID);
            obj.ChannelPortLabel=channelPortLabel;
            obj.BusMemberIsAssignedMap=containers.Map();
        end


        function hPort=addPort(obj,subPortID,subPortTag,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType)



            hPort=addPort@hdlturnkey.data.Channel(obj,subPortID,'',...
            hDataType,isRequiredPort,portType,portRegExp,portDirType);
            hPort.ExternalPortName=subPortTag;
        end

        function hPort=addPortWithDefault(obj,subPortID,subPortTag,...
            hDataType,isRequiredPort,portType,portRegExp,defaultVal,portDirType)


            hPort=addPort(obj,subPortID,subPortTag,...
            hDataType,isRequiredPort,portType,portRegExp,portDirType);


            hPort.DefaultValue=defaultVal;

        end


        function populateBusPortList(obj,busInPortList,busOutPortList)
            obj.ExtInportNames={};
            obj.ExtOutportNames={};
            obj.ExtInportWidths={};
            obj.ExtOutportWidths={};
            obj.ExtInportDimensions={};
            obj.ExtOutportDimensions={};
            obj.ExtInportList={};
            obj.ExtOutportList={};
            obj.ExtInportWidthsFlattened={};
            obj.ExtOutportWidthsFlattened={};
            obj.ExtInportDimensionsFlattened={};
            obj.ExtOutportDimensionsFlattened={};



            numBusInports=numel(busInPortList);
            obj.ExtInportNames=cell(1,numBusInports);
            obj.ExtInportWidths=cell(1,numBusInports);
            obj.ExtInportDimensions=cell(1,numBusInports);
            obj.ExtInportWidthsFlattened=cell(1,numBusInports);
            obj.ExtInportDimensionsFlattened=cell(1,numBusInports);

            for ii=1:numBusInports
                obj.ExtInportNames{ii}=sprintf('%s_%s',obj.ChannelPortLabel,busInPortList{ii}{1});
                obj.ExtInportWidths{ii}=busInPortList{ii}{2};
                obj.ExtInportDimensions{ii}=busInPortList{ii}{3};


                if(obj.ExtInportDimensions{ii}>1)
                    obj.ExtInportWidthsFlattened{ii}=busInPortList{ii}{2}*busInPortList{ii}{3};
                    obj.ExtInportDimensionsFlattened{ii}=1;
                else
                    obj.ExtInportWidthsFlattened{ii}=busInPortList{ii}{2};
                    obj.ExtInportDimensionsFlattened{ii}=busInPortList{ii}{3};
                end

                obj.ExtInportList.(busInPortList{ii}{1}).Width=busInPortList{ii}{2};
                obj.ExtInportList.(busInPortList{ii}{1}).Dimension=busInPortList{ii}{3};
                obj.ExtInportList.(busInPortList{ii}{1}).Index=ii;
            end

            numBusOutports=numel(busOutPortList);
            obj.ExtOutportNames=cell(1,numBusOutports);
            obj.ExtOutportWidths=cell(1,numBusOutports);
            obj.ExtOutportDimensions=cell(1,numBusOutports);
            for ii=1:numBusOutports
                obj.ExtOutportNames{ii}=sprintf('%s_%s',obj.ChannelPortLabel,busOutPortList{ii}{1});
                obj.ExtOutportWidths{ii}=busOutPortList{ii}{2};
                obj.ExtOutportDimensions{ii}=busOutPortList{ii}{3};


                if(obj.ExtOutportDimensions{ii}>1)
                    obj.ExtOutportWidthsFlattened{ii}=busOutPortList{ii}{2}*busOutPortList{ii}{3};
                    obj.ExtOutportDimensionsFlattened{ii}=1;
                else
                    obj.ExtOutportWidthsFlattened{ii}=busOutPortList{ii}{2};
                    obj.ExtOutportDimensionsFlattened{ii}=busOutPortList{ii}{3};
                end

                obj.ExtOutportList.(busOutPortList{ii}{1}).Width=busOutPortList{ii}{2};
                obj.ExtOutportList.(busOutPortList{ii}{1}).Dimension=busOutPortList{ii}{3};
                obj.ExtOutportList.(busOutPortList{ii}{1}).Index=ii;
            end
        end
        function determineAXIIDWidths(obj)




            if obj.IsAXIIDPortAssigned
                hDataType=obj.AXIMasterToSlaveBusPort.Type.getMemberType(obj.AXIMasterToSlaveIDPortName);





                if hDataType.Signed||~hDataType.isInteger
                    error(message('hdlcommon:interface:AXIMasterIDDataType',obj.AXIMasterToSlaveIDPortName,...
                    obj.AXIMasterToSlaveBusPort.PortName,hDataType.SLType));
                elseif hDataType.WordLength>32
                    error(message('hdlcommon:interface:AXIMasterIDWidthGreaterThan32bit',obj.AXIMasterToSlaveIDPortName,...
                    obj.AXIMasterToSlaveBusPort.PortName,hDataType.WordLength));
                end
                obj.AXIIDWidth=hDataType.WordLength;
            end
        end

        function isAXIIDPortAssigned=get.IsAXIIDPortAssigned(obj)


            [obj.AXIMasterToSlaveBusPort,obj.AXIMasterToSlaveIDPortName]=obj.getAssignedAXIMasterToSlavePort;
            if~isempty(obj.AXIMasterToSlaveBusPort)
                isAXIIDPortAssigned=obj.AXIMasterToSlaveBusPort.Type.isMemberType(obj.AXIMasterToSlaveIDPortName);
            else
                isAXIIDPortAssigned=false;
            end
        end

        function[hAssignedPort,IDPortName]=getAssignedAXIMasterToSlavePort(obj)


            if obj.ChannelDirType==hdlturnkey.IOType.IN

                IDPortName=obj.AXIReadMasterToSlaveIDName;
                hSubPort=obj.getPort(obj.AXIReadMasterToSlaveBusName);
            else

                IDPortName=obj.AXIWriteMasterToSlaveIDName;
                hSubPort=obj.getPort(obj.AXIWriteMasterToSlaveBusName);
            end
            hAssignedPort=hSubPort.getAssignedPort;
        end

        function inheritAXIIDWidths(obj,AXIIDWidth)
            obj.AXIIDWidth=AXIIDWidth;
        end

        function determineAXIWidths(obj)





            dataPort=obj.getSubPortByType('DATA');
            [dataWidth,portDimension]=obj.getPortWidth(dataPort);


            if(portDimension==1)
                obj.AXIDataWidth=hdlturnkey.data.upgradeWidthToPowerOfTwo(dataWidth);
                obj.AXIDataDimension=portDimension;
            else
                obj.AXIDataWidth=dataWidth;
                obj.AXIDataDimension=portDimension;
            end


            obj.AXIDataTotalWidth=obj.AXIDataWidth*obj.AXIDataDimension;
            total_num_bytes=2^ceil(log2(ceil(obj.AXIDataTotalWidth/8)));
            obj.NumDataBytes=total_num_bytes;

        end

        function inheritAXIWidths(obj,hSourceChannel)
            obj.NumDataBytes=hSourceChannel.NumDataBytes;
            obj.AXIDataWidth=hSourceChannel.AXIDataWidth;
            obj.AXIDataDimension=hSourceChannel.AXIDataDimension;
            obj.AXIDataTotalWidth=hSourceChannel.AXIDataTotalWidth;
        end


        function userInportSignal=getUserInportSignal(obj,portType,isBusMember)

            if nargin<3
                isBusMember=false;
            end

            if isBusMember
                isAssigned=obj.getBusMemberIsAssigned(portType);
            else
                hSubPort=obj.getSubPortByType(portType);
                isAssigned=hSubPort.isAssigned;
            end

            if isAssigned
                userInportSignal=obj.ChannelNetInportSignals(obj.getUserInportPortIdx(portType));
            else
                error(message('hdlcommon:interface:RequestUnassignedUserPort',portType));
            end
        end

        function userOutportSignal=getUserOutportSignal(obj,portType,isBusMember)
            if nargin<3
                isBusMember=false;
            end

            if isBusMember
                isAssigned=obj.getBusMemberIsAssigned(portType);
            else
                hSubPort=obj.getSubPortByType(portType);
                isAssigned=hSubPort.isAssigned;
            end

            if isAssigned
                userOutportSignal=obj.ChannelNetOutportSignals(obj.getUserOutportPortIdx(portType));
            else
                error(message('hdlcommon:interface:RequestUnassignedUserPort',portType));
            end
        end


        function signal=getExtInportSignal(obj,portType)
            signal=obj.ChannelNetInportSignals(obj.getExtInportPortIdx(portType));
        end

        function signal=getExtOutportSignal(obj,portType)
            signal=obj.ChannelNetOutportSignals(obj.getExtOutportPortIdx(portType));
        end

        function signal=getUserInportTopSignal(obj,portType)
            signal=obj.UserTopInportSignals(obj.UserInportList.(portType).Index);
        end

        function signal=getUserOutportTopSignal(obj,portType)
            signal=obj.UserTopOutportSignals(obj.UserOutportList.(portType).Index);
        end


        function index=getExtInportPortIdx(obj,portType)
            index=obj.ExtInportList.(portType).Index;
        end

        function index=getExtOutportPortIdx(obj,portType)
            index=obj.ExtOutportList.(portType).Index;
        end

        function index=getUserInportPortIdx(obj,portType)
            index=length(obj.ExtInportNames)+...
            obj.UserInportList.(portType).Index;
        end

        function index=getUserOutportPortIdx(obj,portType)
            index=length(obj.ExtOutportNames)+...
            obj.UserOutportList.(portType).Index;
        end


        function cleanPortAssignment(obj)

            cleanPortAssignment@hdlturnkey.data.Channel(obj);


            obj.BusMemberIsAssignedMap=containers.Map();

        end

        function isAssigned=getBusMemberIsAssigned(obj,memberID)
            if obj.BusMemberIsAssignedMap.isKey(memberID)
                isAssigned=obj.BusMemberIsAssignedMap(memberID);
            else
                isAssigned=false;
            end
        end

        function assignSubPort(obj,portName,subPortID,hTableMap)



            assignSubPort@hdlturnkey.data.Channel(obj,portName,subPortID,hTableMap);


            hSubPort=obj.getPort(subPortID);
            hSubPortType=hSubPort.hDataType;
            if hSubPortType.isBusType

                hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
                hIOPortType=hIOPort.Type;
                hIOPortMemberIDList=hIOPortType.getMemberIDList;


                hSubPortMemberIDList=hSubPortType.getMemberIDList;
                for ii=1:length(hSubPortMemberIDList)
                    hSubPortMemberID=hSubPortMemberIDList{ii};
                    isAssigned=any(strcmp(hSubPortMemberID,hIOPortMemberIDList));
                    if isAssigned
                        obj.BusMemberIsAssignedMap(hSubPortMemberID)=true;
                    end
                end
            end
        end




        function[portWidth,portDimension]=getPortWidth(obj,hSubPort)

            if hSubPort.isAssigned
                [portWidth,portDimension]=hSubPort.getAssignedPortWidth;
            else
                if obj.isDataPort(hSubPort)

                    portWidth=obj.AXIDataWidth;
                    portDimension=obj.AXIDataDimension;
                else

                    portWidth=hSubPort.hDataType.getMaxWordLength;
                    portDimension=1;
                end
            end
        end

        function[memberWidth,memberDimension]=getBusMemberWidth(obj,hSubPort,memberID)



            memberWidth=0;
            memberDimension=1;

            hSubPortType=hSubPort.hDataType;
            if hSubPortType.isBusType
                if obj.getBusMemberIsAssigned(memberID)
                    hIOPort=hSubPort.getAssignedPort;
                    hIOPortType=hIOPort.Type;

                    hSubPortMemberType=hSubPortType.getMemberType(memberID);
                    hIOPortMemberType=hIOPortType.getMemberType(memberID);

                    if hSubPortMemberType.isFlexibleWidth
                        memberWidth=hIOPortMemberType.getWordLength;
                    else
                        memberWidth=hSubPortMemberType.getWordLength;
                    end
                else


                    hSubPortMemberType=hSubPortType.getMemberType(memberID);
                    memberWidth=hSubPortMemberType.getWordLength;
                end
            else

            end
        end

        function isAssigned=isSubPortAssigned(obj,portType)
            hSubPort=getSubPortByType(obj,portType);
            isAssigned=hSubPort.isAssigned;
        end

        function isAssigned=isDataPort(~,hSubPort)
            isAssigned=isequal(hSubPort.PortType,'DATA');
        end

        function hSubPort=getSubPortByType(obj,portType)
            for ii=1:length(obj.SubPortIDList)
                subPortID=obj.SubPortIDList{ii};
                hSubPort=obj.getPort(subPortID);
                if isequal(hSubPort.PortType,portType)
                    return;
                end
            end
            hSubPort=[];
        end

    end

    methods(Static)

    end


end


