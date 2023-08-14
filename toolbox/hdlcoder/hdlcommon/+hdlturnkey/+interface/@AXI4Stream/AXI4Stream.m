



classdef AXI4Stream<hdlturnkey.interface.AXI4StreamBase


    properties(Constant)
        DefaultInterfaceID='AXI4-Stream';
    end

    properties(SetAccess=protected)
        TLASTRegisterAddress double
    end

    properties(Hidden)

        HasDMAConnection=false;
        DeviceTreeMasterChannelDMANode='';
        DeviceTreeSlaveChannelDMANode='';


        DMABaseAddress='';
        MasterChannelDMAIRQNumber=0;
        SlaveChannelDMAIRQNumber=0;
    end

    properties(Access=protected)


        hTDataType=[];
        hUfix1Type=[];
        hSampleBusType=[];

        hTSTRBType=[];
        hTKEEPType=[];
        hTIDType=[];
        hTDESTType=[];
        hTUSERType=[];

    end

    properties(Hidden=true,Constant)

        AXI4StreamExampleStr=...
        [sprintf('\nhRD.addAXI4StreamInterface( ...\n'),...
        sprintf('    ''InterfaceID'',              ''AXI4-Stream'', ...\n'),...
        sprintf('    ''MasterChannelEnable'',      true, ...\n'),...
        sprintf('    ''SlaveChannelEnable'',       true, ...\n'),...
        sprintf('    ''MasterChannelConnection'', ''axi_dma_0/S_AXIS_S2MM'', ...\n'),...
        sprintf('    ''SlaveChannelConnection'',  ''axi_dma_0/M_AXIS_MM2S'', ...\n'),...
        sprintf('    ''MasterChannelDataWidth'',   32, ...\n'),...
        sprintf('    ''SlaveChannelDataWidth'',    32, ...\n')];
    end

    methods

        function obj=AXI4Stream(varargin)



            propList={...
            {'InterfaceID',hdlturnkey.interface.AXI4Stream.DefaultInterfaceID},...
            {'MasterChannelEnable',true},...
            {'SlaveChannelEnable',true},...
...
            {'MasterChannelConnection',''},...
            {'SlaveChannelConnection',''},...
            {'MasterChannelDataWidth',0},...
            {'SlaveChannelDataWidth',0},...
            {'MasterChannelMaxDataWidth',4096},...
            {'SlaveChannelMaxDataWidth',4096},...
...
            {'SoftwareInterface',[]},...
            {'HasDMAConnection',false},...
            {'DeviceTreeMasterChannelDMANode',''},...
            {'DeviceTreeSlaveChannelDMANode',''},...
...
            {'DMABaseAddress',''},...
            {'MasterChannelDMAIRQNumber',0},...
            {'SlaveChannelDMAIRQNumber',0},...
...
            {'MasterChannelNumber',0},...
            {'SlaveChannelNumber',0},...
...
            {'InterfacePortLabel',''},...
            {'IsRequired',true},...
            {'IsGenericIP',false},...
            };


            p=downstream.tool.parseInputProperties(propList,varargin{:});
            inputArgs=p.Results;


            interfaceID=inputArgs.InterfaceID;
            obj=obj@hdlturnkey.interface.AXI4StreamBase(interfaceID);


            obj.InputPropertyList=propList;
            obj.assignPropertyValueShared(p);


            obj.validateInterfaceParameter;


            obj.SupportedTool={'Xilinx Vivado','Altera QUARTUS II','Intel Quartus Pro'};


            obj.setupInterfaceAssignment;



            obj.isDefaultBusInterfaceRequired=true;
        end

        function isa=isAXI4StreamInterface(~)
            isa=true;
        end


        function isa=isAXI4StreamMasterDataPort(obj,portName,hTableMap)
            hChannel=obj.hChannelList.getChannelFromPortName(portName);
            biRangStr=obj.getTableCellBitRangeStr(portName,hTableMap);
            subPort=hChannel.getPort(biRangStr);

            isa=hChannel.isDataPort(subPort)&&(hChannel.ChannelDirType==hdlturnkey.IOType.OUT);
        end

        function isa=isAXI4StreamSlaveVectorPort(obj,portName,hTableMap)
            hChannel=obj.hChannelList.getChannelFromPortName(portName);
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);



            isa=hIOPort.isVector&&~hIOPort.isComplex&&(hChannel.ChannelDirType==hdlturnkey.IOType.IN);
        end
    end


    methods

        function setupInterfaceAssignment(obj)



            obj.hChannelList=hdlturnkey.data.ChannelListAXI4Stream(...
            obj.InterfaceID,...
            obj.InterfacePortLabel,...
            obj.MasterChannelNumber,...
            obj.SlaveChannelNumber);


            obj.populateSubPorts;
        end

        function registerAddressAuto(obj,hElab)





            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);

                if hChannel.ChannelDirType==hdlturnkey.IOType.OUT
                    if~(hChannel.isSampleControlBusAssigned||hChannel.isTLASTPortAssigned)




                        if hChannel.isFrameMode(obj)

                            hDataPort=hChannel.getDataPort;
                            hIOPort=hDataPort.getAssignedPort;


                            defaultPacketSize=prod(hIOPort.Dimension);
                        else
                            defaultPacketSize=obj.DefaultPacketSize;
                        end








                        hBus=obj.getDefaultBusInterface(hElab);
                        hBaseAddr=hBus.hBaseAddr;
                        registerID=sprintf('packet_size_%s',lower(hChannel.ChannelPortLabel));
                        hAddr=hBaseAddr.registerAddressAuto(registerID,hdlturnkey.data.AddrType.ELAB);

                        hAddr.InitValue=defaultPacketSize;
                        hAddr.DescName=sprintf('IPCore_PacketSize_%s',hChannel.ChannelPortLabel);
                        hAddr.Description=sprintf('Packet size for %s interface, the default value is %d. The TLAST output signal of the %s interface is generated based on the packet size.',...
                        hChannel.ChannelID,defaultPacketSize,hChannel.ChannelID);



                        obj.TLASTRegisterAddress=hdlturnkey.data.Address.convertAddrInternalToExternal(hAddr.AddressStart);
                    end
                end

            end
        end

        function validateInterfaceForReferenceDesign(obj,hRD)



            if hRD.isDeviceTreeGenerationEnabled&&obj.HasDMAConnection
                if obj.MasterChannelEnable&&isempty(obj.DeviceTreeMasterChannelDMANode)
                    warning(message('hdlcommon:plugin:DeviceTreeNodesMissing',hRD.ReferenceDesignName,obj.InterfaceID,'DeviceTreeMasterChannelDMANode'));
                end

                if obj.SlaveChannelEnable&&isempty(obj.DeviceTreeMasterChannelDMANode)
                    warning(message('hdlcommon:plugin:DeviceTreeNodesMissing',hRD.ReferenceDesignName,obj.InterfaceID,'DeviceTreeSlaveChannelDMANode'));
                end
            end
        end

    end

    methods(Access=protected)


        populateSubPorts(obj)
        validateComplexPort(obj,hIOPort,hTableMap,interfaceStr)

    end


    methods

        function validatePortForInterfaceShared(~,~,~,~)



        end

        function validatePortForInterface(obj,hIOPort,hTableMap,interfaceStr)




            if hIOPort.isComplex
                validateComplexPort(obj,hIOPort,hTableMap,interfaceStr);
            end




            if hIOPort.isTunable
                error(message('hdlcommon:interface:AXIStreamTunableParam',...
                interfaceStr,hIOPort.PortName));
            elseif hIOPort.isTestPoint

                error(message('hdlcommon:interface:AXIStreamTestPoint',...
                interfaceStr,hIOPort.PortName));
            end

            if(hIOPort.isMatrix&&~hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode)


                error(message('hdlcommon:interface:PortTypeNotMatchMatrixF2S',...
                interfaceStr));
            end

            if hIOPort.isVector||hIOPort.isMatrix



                hChannel=obj.hChannelList.getStreamChannel(interfaceStr);
                channelDirType=hChannel.ChannelDirType;
                portDirType=hIOPort.PortType;
                if channelDirType~=portDirType
                    if(hIOPort.isMatrix)
                        error(message('hdlcommon:interface:PortTypeNotMatchMatrix',interfaceStr,...
                        downstream.tool.getPortDirTypeStr(channelDirType),...
                        downstream.tool.getPortDirTypeStr(portDirType),hIOPort.PortName));
                    else
                        error(message('hdlcommon:interface:PortTypeNotMatchVector',interfaceStr,...
                        downstream.tool.getPortDirTypeStr(channelDirType),...
                        downstream.tool.getPortDirTypeStr(portDirType),hIOPort.PortName));
                    end

                end



                if(hIOPort.isStreamedPort)
                    hSubPort=hChannel.getPort('Data');
                    if hSubPort.isAssigned&&...
                        ~hSubPort.isAssignedPortName(hIOPort.PortName)
                        oldPortName=hSubPort.getAssignedPortName;
                        error(message('hdlcommon:interface:SubPortAssigned','Data',...
                        hIOPort.PortName,oldPortName));
                    end
                end
            else

            end



            if hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode&&~hIOPort.isStreamedPort
                error(message('hdlcommon:workflow:UnsupportedCombinedFrameModes',interfaceStr));
            end
        end

        function isa=isBitRangeComboBox(~,portName,hTableMap)
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            if hIOPort.isVector||hIOPort.isMatrix


                isa=false;
            else
                isa=true;
            end
        end

        function isa=isFrameMode(obj)
            isa=obj.hChannelList.isFrameMode(obj);
        end

        function isa=isFrameToSample(obj)
            isa=obj.hChannelList.isFrameToSample;
        end

        function isa=hasMatrixPortAssigned(obj)
            isa=false;

            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                hDataPort=hChannel.getDataPort;
                if(hDataPort.isAssigned)
                    hIOPort=hDataPort.getAssignedPort;
                    if hIOPort.isMatrix
                        isa=true;
                        break;
                    end
                end
            end

        end

        function allocateUserSpecInterfaceOption(obj,portName,hTableMap)
            hChannel=obj.hChannelList.getChannelFromPortName(portName);

            if(hChannel.ChannelDirType==hdlturnkey.IOType.OUT&&~hChannel.isFrameMode(obj))

                [defaultSize,~]=obj.parseInterfaceOption(portName,hTableMap,'DefaultFrameLength','1024');
                obj.DefaultPacketSize=defaultSize;
            end
        end

        function[optValue,optValueName]=parseInterfaceOption(obj,portName,hTableMap,option,defaultValue)


            interfaceOpt=hTableMap.getInterfaceOption(portName);

            if isempty(interfaceOpt)
                optValue=defaultValue;
                optValueName=option;
                return;
            end


            p=inputParser;

            optionIDList=obj.getInterfaceOptionList(portName,hTableMap);
            index=1;
            for i=1:length(optionIDList)
                if(strcmp(optionIDList{i},option))
                    p.addParameter(optionIDList{i},defaultValue);
                else
                    p.addParameter(optionIDList{i},'0');
                end
                p.parse(interfaceOpt{index:index+1});
                index=index+2;
            end

            interfaceOpt=p.Results;
            optValueName=getfield(interfaceOpt,option);%#ok<GFLD> 
            if~strcmp(option,'SamplePackingDimension')&&~strcmp(option,'PackingMode')
                try
                    optValue=evalin('base',optValueName);
                catch me
                    error(message('hdlcommon:workflow:InvalidInterfaceOption',optValueName,option));
                end
            else
                optValue=optValueName;
            end
        end

        function assignInterfaceOption(obj,portName,interfaceOpt,hTableMap)%#ok<*INUSD,*INUSL>


            hChannel=obj.hChannelList.getChannelFromPortName(portName);

            if(hChannel.ChannelDirType~=hdlturnkey.IOType.OUT)
                isDefaultFramelengthoptionExist=~isempty(find(strcmp('DefaultFrameLength',interfaceOpt),1));
                isRegisterInitialValueoptionExist=~isempty(find(strcmp('RegisterInitialValue',interfaceOpt),1));

                if isDefaultFramelengthoptionExist||isRegisterInitialValueoptionExist
                    error(message('hdlcommon:workflow:InvalidInterfaceOptionForChannel',portName,interfaceOpt{1},obj.hChannelList.getChanneIDList{1}));
                end
            elseif(~obj.isAXI4StreamMasterDataPort(portName,hTableMap))
                error(message('hdlcommon:workflow:InvalidInterfaceOptionForPort',portName,interfaceOpt{1},hChannel.getPortIDList{2},obj.InterfaceID));
            end


            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            if hIOPort.isVector&&~hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode

                interfaceStr=hTableMap.getInterfaceStr(portName);
                SamplePackingDimensionIndex=find(strcmp(interfaceOpt,'SamplePackingDimension'));
                SamplePackingDimension=interfaceOpt{SamplePackingDimensionIndex+1};
                if strcmp(SamplePackingDimension,'All')
                    obj.validateVectorPortSampleMode(hIOPort,hTableMap,interfaceStr);
                end

                PackingModeidx=find(strcmp(interfaceOpt,'PackingMode'));
                PackingMode=interfaceOpt{PackingModeidx+1};
                obj.PackingMode=PackingMode;
                obj.SamplePackingDimension=SamplePackingDimension;
            end

            hTableMap.setInterfaceOption(portName,interfaceOpt);
        end

        function optionIDList=getInterfaceOptionList(obj,portName,hTableMap)
            optionIDList={};




            if(obj.isAXI4StreamMasterDataPort(portName,hTableMap)&&(~obj.isTLASTPortAssignedMaster||...
                hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode))
                optionIDList={'DefaultFrameLength'};
            end

            if hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode


                return;
            end
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            if hIOPort.isVector
                if~isempty(optionIDList)
                    optionIDList{end+1}='SamplePackingDimension';
                else
                    optionIDList={'SamplePackingDimension'};
                end
                optionIDList{end+1}='PackingMode';
            end
        end

        function optionValue=getInterfaceOptionValue(obj,portName,optionID)

            switch optionID
            case 'DefaultFrameLength'
                optionValue=obj.DefaultPacketSize;
            case 'SamplePackingDimension'
                optionValue={'None','All'};
            case 'PackingMode'
                optionValue={'Bit Aligned','Power of 2 Aligned'};
            otherwise
                optionValue=[];
            end
        end

        function optionStr=getInterfaceOptionStr(obj,optionID)


            switch optionID
            case 'DefaultFrameLength'
                optionStr='Default frame length';
            case 'SamplePackingDimension'
                optionStr='Sample packing dimension';
            case 'PackingMode'
                optionStr='Packing mode';
            otherwise
                optionStr=optionID;
            end
        end

        function modifySubPortsForFrameToSample(obj,codegenIOPortList)

            channelIDlist=obj.hChannelList.getAssignedChannels;
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);


                if hChannel.ChannelDirType==hdlturnkey.IOType.OUT

                    codegenPortNameList=codegenIOPortList.InputPortNameList;
                else
                    codegenPortNameList=codegenIOPortList.OutputPortNameList;
                end

                for jj=1:length(codegenPortNameList)
                    codegenPortName=codegenPortNameList{jj};
                    hCodeGenIOPort=codegenIOPortList.getIOPort(codegenPortName);
                    if strcmp(hCodeGenIOPort.IOInterface,channelID)
                        if strcmp(hCodeGenIOPort.IOInterfaceMapping,'Ready')
                            hChannel.assignCodeGenerationSubPort(hCodeGenIOPort.PortName,'Ready',codegenIOPortList);
                            break;
                        end
                    end
                end
            end
        end
    end

    methods

        validateCell=validateFullTable(obj,validateCell,hTable)
    end

    methods(Access=protected)

        validateVectorPortFrameMode(obj,hIOPort,hTableMap,interfaceStr)
        validateVectorPortSampleMode(obj,hIOPort,hTableMap,interfaceStr)
    end


    methods(Access=protected)


        populateExternalPorts(obj,hN,hChannel,hElab)


        populateUserPorts(obj,hN,hChannel,hElab)


        elaborateStreamModule(obj,hN,hElab,hChannel,multiRateCountEnable,multiRateCountValue)


        elaborateStreamSlave(obj,hElab,hChannel,...
        hStreamNet,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)


        elaborateStreamMaster(obj,hElab,hChannel,...
        hStreamNet,hStreamNetInportSignals,hStreamNetOutportSignals,multiRateCountEnable,multiRateCountValue)

    end


    methods(Access=public,Hidden)
        function hSoftwareInterface=getDefaultSoftwareInterface(obj,hTurnkey)
            if obj.HasDMAConnection


                hSoftwareInterface=hdlturnkey.swinterface.AXI4StreamSoftware.getInstance(obj,hTurnkey);
            else

                hSoftwareInterface=getDefaultSoftwareInterface@hdlturnkey.interface.AXI4StreamBase(obj,hTurnkey);
            end
        end

        function hSoftwareInterface=getDefaultHostInterface(obj,hTurnkey)
            if obj.HasDMAConnection&&~strcmp(hTurnkey.hD.hIP.getHostTargetInterface,'JTAG AXI Manager (HDL Verifier)')


                hSoftwareInterface=hdlturnkey.swinterface.AXI4StreamSoftware.getInstance(obj,hTurnkey);
            else

                hSoftwareInterface=getDefaultHostInterface@hdlturnkey.interface.AXI4StreamBase(obj,hTurnkey);
            end
        end
    end


    methods(Access=protected)


        validateInterfaceParameter(obj)

        function result=isNonDefaultDMASetting(obj)
            result=obj.HasDMAConnection||...
            ~isempty(obj.DMABaseAddress)||obj.MasterChannelDMAIRQNumber>0||obj.SlaveChannelDMAIRQNumber>0;
        end

    end

    methods(Static)

        function isa=isSideBandPortGroup(hSubPort)

            isa=any(strcmp(hSubPort.PortType,{'tstrb','tkeep','tid','tdest','tuser'}));
        end

    end
end






