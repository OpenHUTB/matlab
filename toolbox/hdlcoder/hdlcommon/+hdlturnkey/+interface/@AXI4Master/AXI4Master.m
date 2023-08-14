



classdef AXI4Master<hdlturnkey.interface.ChannelBased&...
    hdlturnkey.interface.IPWorkflowBase


    properties(Constant)
        DefaultInterfaceID='AXI4 Master';
    end

    properties(GetAccess=public,SetAccess=protected)






        MaxDataWidth=0;
        AddrWidth=0;

        ReadSupport=false;
        WriteSupport=false;

        DefaultReadBaseAddr=0;
        DefaultWriteBaseAddr=0;

        InterfaceConnection='';
        TargetAddressSegments={};

        isDefaultBaseAddrAssigned=false;
    end

    properties(Access=protected)


        hDataType=[];
        hAddrType=[];
        hLenType=[];
        hUfix1Type=[];
        hUfix2Type=[];

        hWriteOutBusType=[];
        hWriteInBusType=[];
        hReadOutBusType=[];
        hReadInBusType=[];

        RamCorePrefix='';

    end

    properties(Hidden=true)






        IDWidth=0;
        MaxLenWidth=0;
        AXILenWidth=0;

        PopulateUnused=false;


        DataWidthMatch=true;



        ReadOutstanding=0;
        WriteOutstanding=0;





        AXIAxCACHEValue=0;







        MaxReadyToValidLatency=1;


        ReadInputFIFODepth=8;
        ReadRequestFIFODepth=4;
        WriteInputFIFODepth=16;
        WriteOutputFIFODepth=8;


        ResetHoldAccumWidth=32;

    end

    properties(Access=protected)


        InterfacePortLabel='';

    end

    properties(Hidden=true,Constant)

        ExampleStr=...
        [sprintf('\nhRD.addAXI4MasterInterface( ...\n'),...
        sprintf('    ''InterfaceID'',          ''AXI4 Master'', ...\n'),...
        sprintf('    ''ReadSupport'',           true, ...\n'),...
        sprintf('    ''WriteSupport'',          true, ...\n'),...
        sprintf('    ''MaxDataWidth'',          32, ...\n'),...
        sprintf('    ''AddrWidth'',             32, ...\n'),...
        sprintf('    ''DefaultReadBaseAddr'',   hex2dec(''40000000''), ...\n'),...
        sprintf('    ''DefaultWriteBaseAddr'',   hex2dec(''41000000''), ...\n'),...
        sprintf('    ''InterfaceConnection'',   ''axi_interconnect_0/S00_AXI'', ...\n'),...
        sprintf('    ''TargetAddressSegments'', {{''mig_7series_0/memmap/memaddr'',hex2dec(''40000000''),hex2dec(''40000000'')}});\n')];

    end

    methods

        function obj=AXI4Master(varargin)



            propList={...
            {'InterfaceID',hdlturnkey.interface.AXI4Master.DefaultInterfaceID},...
            {'ReadSupport',true},...
            {'WriteSupport',true},...
            {'MaxDataWidth',1024},...
            {'AddrWidth',32},...
            {'DefaultReadBaseAddr',0},...
            {'DefaultWriteBaseAddr',0},...
            {'InterfaceConnection',''},...
            {'TargetAddressSegments',{}},...
...
            {'IDWidth',1},...
            {'MaxLenWidth',32},...
            {'AXILenWidth',8},...
            {'PopulateUnused',true},...
            {'InterfacePortLabel',''},...
            {'IsRequired',true},...
            {'IsGenericIP',false},...
            {'ReadOutstanding',1},...
            {'WriteOutstanding',1},...
            {'AXIAxCACHEValue',3},...
            {'SoftwareInterface',[]},...
            };


            p=downstream.tool.parseInputProperties(propList,varargin{:});
            inputArgs=p.Results;


            interfaceID=inputArgs.InterfaceID;
            obj=obj@hdlturnkey.interface.ChannelBased(interfaceID);


            propsUserDefined=setdiff(p.Parameters,p.UsingDefaults);

            obj.isDefaultBaseAddrAssigned=~isempty(intersect(propsUserDefined,{'DefaultReadBaseAddr','DefaultWriteBaseAddr'}));


            obj.InputPropertyList=propList;
            obj.assignPropertyValueShared(inputArgs);

            obj.validateInterfaceParameter;


            obj.InterfaceType=hdlturnkey.IOType.INOUT;


            obj.SupportedTool={'Xilinx Vivado','Altera QUARTUS II','Intel Quartus Pro','Microchip Libero SoC'};


            obj.setupInterfaceAssignment;



            obj.isDefaultBusInterfaceRequired=true;


            obj.HelpDocID='help.step.AXI4Master.targetinterfaceoptions';
        end

        function assignPropertyValueShared(obj,inputArgs)


            for ii=1:numel(obj.InputPropertyList)
                prop=obj.InputPropertyList{ii};
                propName=prop{1};
                if strcmpi(propName,'InterfaceID')
                    continue;
                end
                obj.(propName)=inputArgs.(propName);
            end


            if obj.IsGenericIP
                obj.IsRequired=false;
            end


            if isempty(obj.InterfacePortLabel)
                obj.InterfacePortLabel=regexprep(obj.InterfaceID,'[\W]*','_');
            end
        end

        function isa=isAXI4MasterInterface(~)
            isa=true;
        end

        function isa=isAXI4MasterReadDataPort(obj,portName,hTableMap)
            hChannel=obj.hChannelList.getChannelFromPortName(portName);
            biRangStr=obj.getTableCellBitRangeStr(portName,hTableMap);
            subPort=hChannel.getPort(biRangStr);

            isa=hChannel.isDataPort(subPort)&&(hChannel.ChannelDirType==hdlturnkey.IOType.IN);
        end

        function isa=isAXI4MasterWriteDataPort(obj,portName,hTableMap)
            hChannel=obj.hChannelList.getChannelFromPortName(portName);
            biRangStr=obj.getTableCellBitRangeStr(portName,hTableMap);
            subPort=hChannel.getPort(biRangStr);

            isa=hChannel.isDataPort(subPort)&&(hChannel.ChannelDirType==hdlturnkey.IOType.OUT);
        end
    end


    methods
        function setupInterfaceAssignment(obj)




            obj.hChannelList=hdlturnkey.data.AXIMasterChannelList(obj.InterfaceID,obj.InterfacePortLabel,...
            obj.PopulateUnused,obj.DataWidthMatch);

            obj.populateSubPorts;

        end

        function registerAddressAuto(obj,hElab)











            channelIDlist=obj.hChannelList.getAssignedChannels;
            if isempty(channelIDlist)
                return;
            end


            obj.hChannelList.determineAXIWidths;


            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);



                switch hChannel.ChannelDirType
                case hdlturnkey.IOType.IN

                    hSubPort=hChannel.getSubPortByType('rd_m2s');
                    memberID='rd_addr';
                case hdlturnkey.IOType.OUT

                    hSubPort=hChannel.getSubPortByType('wr_m2s');
                    memberID='wr_addr';
                end
                [baseAddrWordLength,baseAddrVectorSize]=...
                hChannel.getBusMemberWidth(hSubPort,memberID);


                hBus=obj.getDefaultBusInterface(hElab);
                hBaseAddr=hBus.hBaseAddr;
                hAddr=hBaseAddr.registerAddressAuto(...
                sprintf('%s_base_address',hChannel.ChannelPortLabel),...
                hdlturnkey.data.AddrType.ELAB,hdlturnkey.IOType.IN,...
                baseAddrVectorSize,baseAddrWordLength);


                switch hChannel.ChannelDirType
                case hdlturnkey.IOType.IN

                    hAddr.InitValue=obj.DefaultReadBaseAddr;
                case hdlturnkey.IOType.OUT

                    hAddr.InitValue=obj.DefaultWriteBaseAddr;
                end

                hAddr.DescName=sprintf('%s_BaseAddr',hChannel.ChannelPortLabel);
                hAddr.Description=sprintf(...
                'Base Address offset for %s (Default Base Address: hex2dec(%s))',...
                hChannel.ChannelID,num2str(dec2hex(hAddr.InitValue)));
            end
        end

        function validatePortForInterface(obj,hIOPort,~,interfaceStr)

            IOPortFlattenedPortWidth=hIOPort.getFlattenedPortWidth;

            if hIOPort.isTestPoint

                error(message('hdlcommon:interface:AXIMasterTestPoint',interfaceStr,hIOPort.PortName));
            elseif IOPortFlattenedPortWidth>obj.MaxDataWidth
                if obj.IsGenericIP








                    error(message('hdlcommon:workflow:VectorPortBitWidthLargerThan1024Bits',interfaceStr,hIOPort.PortName,IOPortFlattenedPortWidth));
                else


                    error(message('hdlcommon:workflow:VectorPortBitWidthLargerThanMaxDataWidth',interfaceStr,hIOPort.PortName,IOPortFlattenedPortWidth,obj.MaxDataWidth));
                end
            end
        end


        function validatePortForInterfaceShared(~,hIOPort,hTableMap,interfaceStr)





            if hIOPort.isComplex
                error(message('hdlcommon:workflow:UnsupportedComplexPort',interfaceStr,hIOPort.PortName));
            end


            if hIOPort.isHalf
                error(message('hdlcommon:workflow:HalfPortUnsupported',interfaceStr,hIOPort.PortName));
            end


            if hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode
                error(message('hdlcommon:workflow:UnsupportedFramePort',...
                interfaceStr,hIOPort.PortName));
            end
        end

        function[needError,msgObj]=validateRequiredInterface(obj,~)

            needError=false;
            msgObj=[];
            if obj.IsRequired&&...
                ~obj.hChannelList.hasChannelAssigned
                channelStr=obj.hChannelList.getAllChannelIDStr;
                msgObj=message('hdlcommon:hdlturnkey:RequiredInterfaceNotAssignedP',...
                channelStr);
                needError=true;
            end
        end
    end


    methods(Access=protected)
        populateSubPorts(obj);
    end


    methods

        function assignInterface(obj,portName,interfaceStr,hTableMap)

            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);


            hChannel=obj.hChannelList.getChannel(interfaceStr);


            obj.validatePortForInterfaceShared(hIOPort,hTableMap,interfaceStr);
            obj.validatePortForInterface(hIOPort,hTableMap,interfaceStr);



            previousObj=hTableMap.getInterface(portName);
            if isequal(obj,previousObj)
                previousChannel=obj.hChannelList.getChannelFromPortName(portName);
                if isequal(hChannel,previousChannel)
                    return;
                end
            end

            hTableMap.setInterface(portName,obj);

            hTableMap.initialBitRangeData(portName);


            obj.hChannelList.assignChannel(portName,hChannel);
        end

        function assignBitRange(obj,portName,bitRangeStr,hTableMap)


            obj.hChannelList.validateSubPort(portName,bitRangeStr,hTableMap);

            obj.hChannelList.assignSubPort(portName,bitRangeStr,hTableMap);
            hTableMap.setBitRangeData(portName,bitRangeStr);
        end

        function assignInterfaceOption(obj,portName,interfaceOpt,hTableMap)%#ok<*INUSD,*INUSL>


            if(~obj.isAXI4MasterReadDataPort(portName,hTableMap)&&...
                ~obj.isAXI4MasterWriteDataPort(portName,hTableMap))
                hChannel=obj.hChannelList.getChannelFromPortName(portName);
                error(message('hdlcommon:workflow:InvalidInterfaceOptionForPort',portName,interfaceOpt{1},hChannel.getPortIDList{2},obj.InterfaceID));
            end

            hTableMap.setInterfaceOption(portName,interfaceOpt);
        end

        function allocateUserSpecInterfaceOption(obj,portName,hTableMap)

            if(obj.isAXI4MasterReadDataPort(portName,hTableMap))

                [defaultReadAddr,~]=obj.parseInterfaceOption(portName,hTableMap,'DefaultReadBaseAddress','0');
                obj.DefaultReadBaseAddr=defaultReadAddr;
                if(mod(obj.DefaultReadBaseAddr,4)~=0)
                    error(message('hdlcommon:workflow:InvalidAddress','DefaultReadBaseAddress'));
                end
            elseif(obj.isAXI4MasterWriteDataPort(portName,hTableMap))

                [defaultWriteAddr,~]=obj.parseInterfaceOption(portName,hTableMap,'DefaultWriteBaseAddress','0');
                obj.DefaultWriteBaseAddr=defaultWriteAddr;
                if(mod(obj.DefaultWriteBaseAddr,4)~=0)
                    error(message('hdlcommon:workflow:InvalidAddress','DefaultWriteBaseAddress'));
                end
            end
        end

        function optionIDList=getInterfaceOptionList(obj,portName,hTableMap)


            optionIDList={};

            if(~obj.isDefaultBaseAddrAssigned)
                if(obj.isAXI4MasterReadDataPort(portName,hTableMap))
                    optionIDList={'DefaultReadBaseAddress'};
                elseif(obj.isAXI4MasterWriteDataPort(portName,hTableMap))
                    optionIDList={'DefaultWriteBaseAddress'};
                end
            end
        end

        function optionValue=getInterfaceOptionValue(obj,portName,optionID)

            switch optionID
            case 'DefaultReadBaseAddress'
                optionValue=obj.DefaultReadBaseAddr;
            case 'DefaultWriteBaseAddress'
                optionValue=obj.DefaultWriteBaseAddr;
            otherwise
                optionValue=[];
            end
        end

        function optionStr=getInterfaceOptionStr(obj,optionID)


            switch optionID
            case 'DefaultReadBaseAddress'
                optionStr='Default read base address';
            case 'DefaultWriteBaseAddress'
                optionStr='Default write base address';
            otherwise
                optionStr=optionID;
            end
        end
    end


    methods

    end


    methods

    end


    methods

        function elaborate(obj,hN,hElab)



            channelIDlist=obj.hChannelList.getElaboratedChannels;
            if isempty(channelIDlist)
                return;
            end




            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                obj.populateExternalPorts(hN,hChannel);
            end


            obj.RamCorePrefix=sprintf('%s_',hElab.TopNetName);



            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                obj.elaborateAXIMasterModule(hN,hElab,hChannel);


                hChannel.validateCodeGenPortRate(hElab.hDUTLayer);
            end

        end

    end

    methods(Access=protected)


        populateExternalPorts(obj,hN,hChannel)


        elaborateAXIMasterModule(obj,hN,hElab,hChannel)


        elaborateReadMaster(obj,hElab,hChannel,hN);


        elaborateWriteMaster(obj,hElab,hChannel,hN);


        portsNewWidth=upgradeWidth(obj,portsNums,portsDims,portsOldWidth);

        function full_addr=getFullAddr(obj,hElab,hChannel,hN,user_addr)

            ufixAddrType=user_addr.Type;
            base_addr=hN.addSignal(ufixAddrType,'base_addr');
            full_addr=hN.addSignal(ufixAddrType,'full_addr');


            hBus=obj.getDefaultBusInterface(hElab);
            registerID=sprintf('%s_base_address',hChannel.ChannelPortLabel);
            hAddr=hBus.getBaseAddrWithName(registerID);
            hAddr.assignScheduledElab(base_addr,hdlturnkey.data.DecoderType.WRITE)


            pirelab.getAddComp(hN,[user_addr,base_addr],full_addr,'Floor','wrap','addr_adder',ufixAddrType,'++');
        end

        function len_val=getLenVal(obj,hN,user_len)%#ok<INUSL>

            ufix1Type=pir_ufixpt_t(1,0);
            ufixLenType=user_len.Type;
            len_val=hN.addSignal(ufixLenType,'len_val');


            const_len_dec=hN.addSignal(ufix1Type,'const_len_dec');
            pirelab.getConstComp(hN,const_len_dec,1);
            pirelab.getAddComp(hN,[user_len,const_len_dec],len_val,'Floor','Saturate','len_decrement',ufixLenType,'+-');
        end

        function[in_burst,soft_reset_pending]=registerResetHoldSignals(obj,hN,hChannel,hElab)





            ufix1Type=pir_ufixpt_t(1,0);


            channelName=lower(hChannel.ChannelPortLabel);
            inBurstSignalName=sprintf('in_burst_%s',channelName);
            in_burst=hN.addSignal(ufix1Type,inBurstSignalName);
            hElab.setInternalSignal(inBurstSignalName,in_burst);


            hBus=obj.getDefaultBusInterface(hElab);
            hBus.addSoftResetHoldInBurstSignal(inBurstSignalName);





            soft_reset_pending=hN.addSignal(ufix1Type,'soft_reset_pending');
            hBus.addSoftResetHoldResetPendingSignal(inBurstSignalName,soft_reset_pending);
        end

    end


    methods

    end



    methods


        function generateIPInterfaceVivadoTcl(obj,fid,hElab)


            hDI=hElab.hTurnkey.hD;

            channelIDlist=obj.hChannelList.getElaboratedChannels;

            if~isempty(channelIDlist)

                interfaceName=obj.InterfacePortLabel;
                hdlturnkey.tool.generateVivadoTclInterfaceDefinition(hDI,fid,interfaceName,...
                'xilinx.com:interface:aximm_rtl:1.0','xilinx.com:interface:aximm:1.0');


                hdlturnkey.tool.generateVivadoTclInterfaceMode(hDI,fid,interfaceName,hdlturnkey.IOType.OUT)

            end

            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                obj.generateIPCoreVivadoTclOnChannel(fid,hChannel,interfaceName,hDI);
            end


            addrWidth=obj.AddrWidth;
            dataWidth=obj.hChannelList.AXIDataTotalWidth;
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclCreateAddrSpace',fid,interfaceName,addrWidth,dataWidth);

        end

        function generateIPCoreVivadoTclOnChannel(~,fid,hChannel,interfaceName,hDI)

            fprintf(fid,'# %s\n',hChannel.ChannelID);



            portIDs=fields(hChannel.ExtInportList);
            for ii=1:numel(portIDs)
                portID=portIDs{ii};
                portName=hChannel.ExtInportNames{hChannel.ExtInportList.(portID).Index};
                hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,interfaceName,portID,portName);
            end

            portIDs=fields(hChannel.ExtOutportList);
            for ii=1:numel(portIDs)
                portID=portIDs{ii};
                portName=hChannel.ExtOutportNames{hChannel.ExtOutportList.(portID).Index};
                hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,interfaceName,portID,portName);
            end

            fprintf(fid,'\n');
        end

        function interfaceStr=generateIPClockVivadoTcl(obj,interfaceStr)



            channelIDlist=obj.hChannelList.getElaboratedChannels;
            if~isempty(channelIDlist)
                interfaceName=obj.InterfacePortLabel;
                if isempty(interfaceStr)
                    interfaceStr=interfaceName;
                else
                    interfaceStr=sprintf('%s:%s',interfaceStr,interfaceName);
                end
            end
        end

        function generateRDInsertIPVivadoTcl(obj,fid,hTool)



            hDI=hTool.hETool.hIP.hD;

            channelIDlist=obj.hChannelList.getElaboratedChannels;
            if~isempty(channelIDlist)
                interfaceName=obj.InterfacePortLabel;
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclInterfaceConnection',fid,interfaceName,obj.InterfaceConnection);

                for ii=1:numel(obj.TargetAddressSegments)
                    segTgt=obj.TargetAddressSegments{ii}{1};
                    segOffset=obj.TargetAddressSegments{ii}{2};
                    segRange=obj.TargetAddressSegments{ii}{3};
                    segAddrSpace=sprintf('$HDLCODERIPINST/%s',interfaceName);
                    segName=sprintf('${HDLCODERIPINST}_%s',strrep(segTgt,'/','_'));
                    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclCreateAddrSeg',fid,segRange,segOffset,segAddrSpace,segTgt,segName);
                end
            end
        end

        function generatePCoreQsysTCL(obj,fid,~)


            fprintf(fid,'## AXI4 Master\n');


            channelIDlist=obj.hChannelList.getElaboratedChannels;
            portList={};
            for ii=1:length(channelIDlist)
                channelID=channelIDlist{ii};
                hChannel=obj.hChannelList.getChannel(channelID);
                portList=obj.buildChannelQsysPorts(hChannel,portList);
            end

            proplist={...
            {'associatedClock','ip_clk'},...
            {'associatedReset','ip_rst'},...
            {'readIssuingCapability',num2str(obj.ReadOutstanding)},...
            {'writeIssuingCapability',num2str(obj.WriteOutstanding)},...
            {'combinedIssuingCapability',num2str(obj.ReadOutstanding+obj.WriteOutstanding)},...
            {'ENABLED','true'},...
            {'EXPORT_OF','""'},...
            {'PORT_NAME_MAP','""'},...
            {'CMSIS_SVD_VARIABLES','""'},...
            {'SVD_ADDRESS_GROUP','""'},...
            };

            hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,obj.InterfacePortLabel,hdlturnkey.IOType.OUT,'axi4',proplist,portList);
        end


        function qsysPorts=buildChannelQsysPorts(~,hChannel,qsysPorts)
            busPortLabel=hChannel.ChannelPortLabel;
            for dir={'Input','Output'}
                dirStr=dir{:};
                switch dirStr
                case 'Input'
                    portList=hChannel.ExtInportList;
                case 'Output'
                    portList=hChannel.ExtOutportList;
                end
                portNames=fields(portList);
                numBusPorts=numel(portNames);
                for ii=1:numBusPorts
                    portName=portNames{ii};
                    portWidth=portList.(portName).Width*portList.(portName).Dimension;
                    qsysPorts{end+1}={...
                    sprintf('%s_%s',busPortLabel,portName),...
                    lower(portName),...
                    dirStr,...
                    num2str(portWidth)
                    };%#ok<*AGROW>
                end
            end
        end

        function generatePCoreLiberoTCL(obj,fid,~,topModuleFile)

            if(~obj.isEmptyAXI4SlaveInterface)
                fprintf(fid,'## AXI4 Master\n');


                channelIDlist=obj.hChannelList.getElaboratedChannels;
                portList={};
                for ii=1:length(channelIDlist)
                    channelID=channelIDlist{ii};
                    hChannel=obj.hChannelList.getChannel(channelID);
                    portList=obj.buildChannelLiberoPorts(hChannel,portList);
                end

                hdlturnkey.tool.generateLiberoTclInterfaceDefinition(fid,obj.InterfacePortLabel,hdlturnkey.IOType.OUT,'axi4_master',portList,topModuleFile);
            end
        end



        function liberoPorts=buildChannelLiberoPorts(~,hChannel,liberoPorts)
            busPortLabel=hChannel.ChannelPortLabel;
            for dir={'Input','Output'}
                dirStr=dir{:};
                switch dirStr
                case 'Input'
                    portList=hChannel.ExtInportList;
                case 'Output'
                    portList=hChannel.ExtOutportList;
                end
                portNames=fields(portList);
                numBusPorts=numel(portNames);
                for ii=1:numBusPorts
                    portName=portNames{ii};
                    portWidth=portList.(portName).Width*portList.(portName).Dimension;
                    liberoPorts{end+1}={...
                    sprintf('%s_%s',busPortLabel,portName),...
                    lower(portName),...
                    dirStr,...
                    num2str(portWidth)
                    };%#ok<*AGROW>
                end
            end
        end
        function generateRDInsertIPQsysTcl(obj,fid,hTool)



            hDI=hTool.hETool.hIP.hD;

            channelIDlist=obj.hChannelList.getElaboratedChannels;
            if~isempty(channelIDlist)
                connectionStart=sprintf('${HDLCODERIPINST}.%s',obj.InterfacePortLabel);
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysAddConnection',fid,connectionStart,obj.InterfaceConnection);
            end
        end

    end


    methods

    end


    methods(Access=protected)


        validateInterfaceParameter(obj)

    end

end








