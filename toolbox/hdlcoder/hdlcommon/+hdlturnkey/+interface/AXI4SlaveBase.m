


classdef(Abstract)AXI4SlaveBase<hdlturnkey.interface.AddressBased&...
    hdlturnkey.interface.IPWorkflowBase


    properties

        AddrWidth=16;


        ClockConnection='';
        ResetConnection='';
        MasterConnection='';
        BaseAddress='';
        MasterAddressSpace='';
        EnabledByDefault=true;


        HasProcessorConnection=true;
        DeviceTreeBusNode='';
    end

    properties(Dependent,Hidden)
AddressRange
ShiftRegisterDecoder
BitPacking
BytePacking
    end

    properties(Hidden,SetAccess=protected)


        AXI4ReadDelay=0;
        AXI4IORegCount=0;
    end

    properties(Abstract,Hidden,Constant)
DefaultInterfaceID

BusPortLabel
BusNameMPD
BusProtocolMPD
BusProtocol


PIRNetworkName
    end

    properties(Access=protected)

PortList
    end

    properties(Hidden=true)

        AXI4SlaveExampleStr=...
        [sprintf('\nhRD.addAXI4SlaveInterface( ...\n'),...
        sprintf('    ''InterfaceConnection'',       axi_interconnect_0/M00_AXI, ...\n'),...
        sprintf('    ''BaseAddress'',               0x40010000, ...\n'),...
        sprintf('    ''IDWidth'',                   12, ...\n')];


        EnableReadback='inherit';
    end

    methods

        function obj=AXI4SlaveBase(interfaceID,varargin)


            obj=obj@hdlturnkey.interface.AddressBased(interfaceID);

            obj.parseInputs(varargin);
            obj.validateInterfaceParameter;



            obj.isFixedInWrapper=false;


            obj.setupInterfaceAssignment;
        end

        function isa=isAXI4SlaveInterface(~)
            isa=true;
        end

    end


    methods

        function addrRange=get.AddressRange(obj)
            addrRange=obj.getAddrUpperBound+1;
        end

        function isShiftDecoder=get.ShiftRegisterDecoder(obj)
            isShiftDecoder=obj.hIPCoreAddr.ShiftRegisterDecoder;
        end

        function isBitPacking=get.BitPacking(obj)
            isBitPacking=obj.hIPCoreAddr.BitPacking;
        end

        function isBytePacking=get.BytePacking(obj)
            isBytePacking=obj.hIPCoreAddr.BytePacking;
        end

    end


    methods(Access=protected)

        function parseInputs(obj,args)
            p=inputParser;


            p.addParameter('InterfaceID',obj.InterfaceID);
            p.addParameter('ClockConnection',obj.ClockConnection);
            p.addParameter('ResetConnection',obj.ResetConnection);
            p.addParameter('MasterConnection',obj.MasterConnection);
            p.addParameter('BaseAddress',obj.BaseAddress);
            p.addParameter('MasterAddressSpace',obj.MasterAddressSpace);
            p.addParameter('EnabledByDefault',obj.EnabledByDefault);
            p.addParameter('ShiftRegisterDecoder',false);
            p.addParameter('BitPacking',false);
            p.addParameter('BytePacking',false);


            p.addParameter('HasProcessorConnection',obj.HasProcessorConnection);
            p.addParameter('DeviceTreeBusNode',obj.DeviceTreeBusNode);
            p.addParameter('SoftwareInterface',obj.SoftwareInterface);


            p.addParameter('AXI4SlaveExampleStr',obj.AXI4SlaveExampleStr);
            p.addParameter('IsGenericIP',obj.IsGenericIP);

            p.parse(args{:});
            inputArgs=p.Results;

            obj.InterfaceID=inputArgs.InterfaceID;
            obj.ClockConnection=inputArgs.ClockConnection;
            obj.ResetConnection=inputArgs.ResetConnection;
            obj.MasterConnection=inputArgs.MasterConnection;
            obj.BaseAddress=inputArgs.BaseAddress;
            obj.MasterAddressSpace=inputArgs.MasterAddressSpace;
            obj.EnabledByDefault=inputArgs.EnabledByDefault;
            obj.HasProcessorConnection=inputArgs.HasProcessorConnection;
            obj.DeviceTreeBusNode=inputArgs.DeviceTreeBusNode;
            obj.SoftwareInterface=inputArgs.SoftwareInterface;
            obj.AXI4SlaveExampleStr=inputArgs.AXI4SlaveExampleStr;
            obj.IsGenericIP=inputArgs.IsGenericIP;


            obj.hBaseAddr.ShiftRegisterDecoder=inputArgs.ShiftRegisterDecoder;
            obj.hIPCoreAddr.ShiftRegisterDecoder=inputArgs.ShiftRegisterDecoder;


            obj.hBaseAddr.BitPacking=inputArgs.BitPacking;
            obj.hIPCoreAddr.BitPacking=inputArgs.BitPacking;


            obj.hBaseAddr.BytePacking=inputArgs.BytePacking;
            obj.hIPCoreAddr.BytePacking=inputArgs.BytePacking;
        end

        function validateInterfaceParameter(obj)



            hdlturnkey.plugin.validateStringProperty(...
            obj.InterfaceID,'InterfaceID',obj.AXI4SlaveExampleStr);

            if~obj.IsGenericIP


                hdlturnkey.plugin.validateRequiredParameter(...
                obj.MasterConnection,'InterfaceConnection',obj.AXI4SlaveExampleStr);
                hdlturnkey.plugin.validateCellStringPropertyNonEmpty(...
                obj.MasterConnection,'InterfaceConnection',obj.AXI4SlaveExampleStr);



                hdlturnkey.plugin.validateRequiredParameter(...
                obj.BaseAddress,'BaseAddress',obj.AXI4SlaveExampleStr);
                hdlturnkey.plugin.validateCellStringPropertyNonEmpty(...
                obj.BaseAddress,'BaseAddress',obj.AXI4SlaveExampleStr);
            end



            hdlturnkey.plugin.validateBooleanProperty(...
            obj.HasProcessorConnection,'HasProcessorConnection',obj.AXI4SlaveExampleStr);


            obj.validateDeviceTreeNodeName(obj.DeviceTreeBusNode,'DeviceTreeBusNode',obj.AXI4SlaveExampleStr);
            if~isempty(obj.DeviceTreeBusNode)&&~obj.HasProcessorConnection


                error(message('hdlcommon:plugin:InvalidInterfaceDeviceTree','DeviceTreeBusNode','HasProcessorConnection'));
            end

        end

        function setupInterfaceAssignment(obj)



            obj.hBaseAddr.AddressLowerBound=0;
            obj.hBaseAddr.AddressUpperBound=63;

            obj.hIPCoreAddr.AddressLowerBound=64;
            obj.hIPCoreAddr.AddressUpperBound=16383;
        end
    end

    methods
        function validateInterfaceForTool(obj,toolName)

            if obj.isToolISE(toolName)

                if(iscell(obj.MasterConnection)||iscell(obj.BaseAddress))
                    error(message('hdlcommon:plugin:ISENotSupportMultiMast'));
                end
            elseif obj.isToolVivado(toolName)



                hdlturnkey.plugin.validateStringPropertyNonEmpty(...
                obj.MasterConnection,'InterfaceConnection',obj.AXI4SlaveExampleStr);

                hdlturnkey.plugin.validateRequiredParameter(...
                obj.MasterAddressSpace,'MasterAddressSpace',obj.AXI4SlaveExampleStr);

                hdlturnkey.plugin.validateCellStringPropertyNonEmpty(...
                obj.MasterAddressSpace,'MasterAddressSpace',obj.AXI4SlaveExampleStr);




                exampleStr='hRD.addAXI4SlaveInterface(''InterfaceConnection'', ''axi_interconnect_0/M00_AXI'', ''BaseAddress'', {''0x40010000'', ''0x40010000''}, ''MasterAddressSpace'', {''processing_system7_0/Data'', ''hdlverifier_axi_manager_0/axi4m''}, ''IDWidth'', 13)';
                if(iscell(obj.MasterAddressSpace)&&iscell(obj.BaseAddress))
                    if~(length(obj.MasterAddressSpace)==length(obj.BaseAddress))
                        error(message('hdlcommon:plugin:PropertiesLengthNotEqualVivado',...
                        exampleStr));
                    end
                end
            elseif(obj.isToolQuartus(toolName)||obj.isToolQuartusPro(toolName))



                hdlturnkey.plugin.validateCellStringPropertyNonEmpty(...
                obj.MasterConnection,'InterfaceConnection',obj.AXI4SlaveExampleStr);




                exampleStr='hRD.addAXI4SlaveInterface(''InterfaceConnection'', {''hps_0.h2f_axi_master'',''master_0.master''}, ''BaseAddress'', {''0x0000_0000'', ''0x0000_0000''}, ''IDWidth'', 13)';
                if(iscell(obj.MasterConnection)&&iscell(obj.BaseAddress))
                    if~(length(obj.MasterConnection)==length(obj.BaseAddress))
                        error(message('hdlcommon:plugin:PropertiesLengthNotEqualQuartus',...
                        exampleStr));
                    end
                end
            end
        end

        function validateInterfaceForReferenceDesign(obj,hRD)



            if hRD.isDeviceTreeGenerationEnabled&&obj.HasProcessorConnection
                if isempty(obj.DeviceTreeBusNode)
                    warning(message('hdlcommon:plugin:DeviceTreeNodesMissing',hRD.ReferenceDesignName,obj.InterfaceID,'DeviceTreeBusNode'));
                end
            end
        end
    end


    methods

        function validatePortForInterfaceShared(~,hIOPort,~,interfaceStr)





            if hIOPort.isComplex
                error(message('hdlcommon:workflow:UnsupportedComplexPort',interfaceStr,hIOPort.PortName));
            end
        end

        function validatePortForInterface(obj,hIOPort,~)


            portName=hIOPort.PortName;
            if hIOPort.isBus
                hDataType=hIOPort.Type;
                validateSubPortForBus(obj,portName,hDataType);
            else
                validatePortSmallerThan32bit(obj,hIOPort.WordLength,portName);
            end

        end

        function validateSubPortForBus(obj,portName,hDataType)


            if(isa(hDataType,'hdlturnkey.data.TypeBus'))

                busMemberIDList=hDataType.getMemberIDList;
                for idx=1:length(busMemberIDList)
                    memberName=busMemberIDList{idx};
                    memberType=hDataType.getMemberType(memberName);
                    validateSubPortForBus(obj,memberName,memberType);
                end
            else



                if isa(hDataType.BaseType,'hdlcoder.tp_complex')
                    error(message('hdlcommon:workflow:UnsupportedComplexPort',obj.InterfaceID,portName));
                end
                portWidth=hDataType.BaseType.WordLength;
                validatePortSmallerThan32bit(obj,portWidth,portName);
            end

        end

        function validatePortSmallerThan32bit(obj,portWidth,portName)

            if strcmp(hdlfeature('AXI4SlaveWideData'),'off')||obj.ShiftRegisterDecoder
                if portWidth>32
                    error(message('hdlcommon:workflow:BaseBitWidthNotFit',obj.InterfaceID,portName));
                end
            end
        end

    end


    methods(Abstract)

        [BusInportList,BusOutPortList]=getExternalPortList(obj)




        elaborateAXI4SlaveIP(obj,hN,hElab,hIPInSignals,hIPOutSignals,readDelayCount)
    end

    methods

        function registerAddress(obj,~)



            hAddr=obj.hBaseAddr.registerAddress(0,hdlturnkey.data.AddrType.RESET,'axi_reset');
            hAddr.DescName='IPCore_Reset';
            hAddr.Description='write 0x1 to bit 0 to reset IP core';



            hAddr=obj.hBaseAddr.registerAddress(1,hdlturnkey.data.AddrType.ENABLE,'axi_enable');
            hAddr.DescName='IPCore_Enable';
            if obj.EnabledByDefault
                hAddr.InitValue=1;
                hAddr.Description='enabled (by default) when bit 0 is 0x1';
            else
                hAddr.InitValue=0;
                hAddr.Description='disabled (by default) when bit 0 is 0x0';
            end
        end

        function populateExternalPorts(obj)



            [BusInportList,BusOutPortList]=...
            obj.getExternalPortList;

            numBusInports=numel(BusInportList);
            obj.InportNames=cell(1,numBusInports);
            obj.InportWidths=cell(1,numBusInports);
            for ii=1:numBusInports
                obj.InportNames{ii}=sprintf('%s_%s',obj.BusPortLabel,BusInportList{ii}{1});
                obj.InportWidths{ii}=BusInportList{ii}{2};
                InPortList.(BusInportList{ii}{1}).Width=BusInportList{ii}{2};
                InPortList.(BusInportList{ii}{1}).Type=BusInportList{ii}{3};
                InPortList.(BusInportList{ii}{1}).Index=ii;
            end

            numBusOutports=numel(BusOutPortList);
            obj.OutportNames=cell(1,numBusOutports);
            obj.OutportWidths=cell(1,numBusOutports);
            for ii=1:numBusOutports
                obj.OutportNames{ii}=sprintf('%s_%s',obj.BusPortLabel,BusOutPortList{ii}{1});
                obj.OutportWidths{ii}=BusOutPortList{ii}{2};
                OutPortList.(BusOutPortList{ii}{1}).Width=BusOutPortList{ii}{2};
                OutPortList.(BusOutPortList{ii}{1}).Type=BusOutPortList{ii}{3};
                OutPortList.(BusOutPortList{ii}{1}).Index=ii;
            end

            tPortList.Inports=InPortList;
            tPortList.Outports=OutPortList;
            obj.PortList=tPortList;
        end

        function elaborate(obj,hN,hElab)





            obj.populateExternalPorts;


            hAXITopNetSignal=obj.addInterfacePort(hN);
            hAXINetInstInSigs=hAXITopNetSignal.hInportSignals;
            hAXINetInstOutSigs=hAXITopNetSignal.hOutportSignals;


            hAXINet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_%s',hElab.TopNetName,obj.PIRNetworkName)...
            );


            hAXINetSignal=obj.addInterfacePort(hAXINet);
            hAXINetInSigs=hAXINetSignal.hInportSignals;


            pirelab.instantiateNetwork(hN,hAXINet,hAXINetInstInSigs,...
            hAXINetInstOutSigs,sprintf('%s_%s_inst',hElab.TopNetName,obj.PIRNetworkName));


            s_ACLK=hAXINetInSigs(obj.PortList.Inports.('ACLK').Index);
            s_AWADDR=hAXINetInSigs(obj.PortList.Inports.('AWADDR').Index);

            [clock,clkenb,~]=hAXINet.getClockBundle(s_AWADDR,1,1,0);
            pirelab.getWireComp(hAXINet,s_ACLK,clock);
            ufix1Type=pir_ufixpt_t(1,0);
            const_1=hAXINet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hAXINet,const_1,1);
            pirelab.getWireComp(hAXINet,const_1,clkenb);


            hTopInportSignals=hAXINetSignal.hInportSignals;
            hTopOutportSignals=hAXINetSignal.hOutportSignals;
            ufix32Type=pir_ufixpt_t(32,0);
            ufix14Type=pir_ufixpt_t(14,0);


            top_data_write=hAXINet.addSignal(ufix32Type,'top_data_write');
            top_data_read=hAXINet.addSignal(ufix32Type,'top_data_read');
            top_addr_sel=hAXINet.addSignal(ufix14Type,'top_addr_sel');
            top_wr_enb=hAXINet.addSignal(ufix1Type,'top_wr_enb');
            top_rd_enb=hAXINet.addSignal(ufix1Type,'top_rd_enb');
            top_reset_internal=hAXINet.addSignal(ufix1Type,'top_reset_internal');

            hIPInSignals=[hTopInportSignals(2:end),top_data_read];
            hIPOutSignals=[hTopOutportSignals,top_data_write,top_addr_sel,top_wr_enb,top_rd_enb,top_reset_internal];

            hIPSignals.hInportSignals=[top_data_write,top_addr_sel,top_wr_enb,top_rd_enb];
            hIPSignals.hOutportSignals=top_data_read;











            [muxCounter,readDelayCount]=obj.connectInterfacePort(hAXINet,hElab,hIPSignals);




            obj.AXI4ReadDelay=readDelayCount;




            obj.AXI4IORegCount=muxCounter;


            obj.elaborateAXI4SlaveIP(hAXINet,hElab,hIPInSignals,hIPOutSignals,readDelayCount);


            hDI=hElab.hTurnkey.hD;
            hClockModule=hDI.getClockModule;
            if hClockModule.InternalReset
                reset_internal=hClockModule.InternalResetSignal;
            else
                error(message('hdlcommon:workflow:UnableConnectSoftReset',obj.DefaultInterfaceID));
            end

            pirtarget.connectSignals(hElab,...
            {top_reset_internal},{reset_internal},'reset_internal');

        end

        function[muxCounter,readDelayCount]=connectInterfacePort(obj,hN,hElab,hIPSignals)



            scheduleDUTAddrElab(obj,hElab);


            topInSignals=hIPSignals.hInportSignals;
            topOutSignals=hIPSignals.hOutportSignals;
            hAddrLists=[obj.hBaseAddr,obj.hIPCoreAddr];
            networkName=sprintf('%s_addr_decoder',hElab.TopNetName);
            [hDecoderNet,muxCounter,readDelayCount]=pirtarget.getAddrDecoderNetwork(...
            hN,topInSignals,topOutSignals,hElab,hAddrLists,networkName);





            ufix1Type=pir_ufixpt_t(1,0);
            [~,clkenb,~]=hDecoderNet.getClockBundle(topInSignals(1),1,1,0);
            const_1=hDecoderNet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hDecoderNet,const_1,1);
            pirelab.getWireComp(hDecoderNet,const_1,clkenb);

        end

    end


    methods

    end



    methods


        function generatePCoreMPD(obj,fid,~)


            busNameMPD=obj.BusNameMPD;
            busProtocolMPD=obj.BusProtocolMPD;




            fprintf(fid,'## %s Slave\n',obj.DefaultInterfaceID);
            fprintf(fid,'BUS_INTERFACE BUS = %s, BUS_STD = AXI, BUS_TYPE = SLAVE\n',busNameMPD);
            fprintf(fid,'## Generics for VHDL or Parameters for Verilog\n');
            fprintf(fid,'PARAMETER C_%s_BASEADDR = 0xffffffff, DT = std_logic_vector(31 downto 0), ADDR_TYPE = REGISTER, ASSIGNMENT = REQUIRE, PAIR = C_%s_HIGHADDR, ADDRESS = BASE, MIN_SIZE = 0x1000, TYPE = NON_HDL, BUS = %s\n',busNameMPD,busNameMPD,busNameMPD);
            fprintf(fid,'PARAMETER C_%s_HIGHADDR = 0x00000000, DT = std_logic_vector(31 downto 0), ADDR_TYPE = REGISTER, ASSIGNMENT = REQUIRE, PAIR = C_%s_BASEADDR, ADDRESS = HIGH, TYPE = NON_HDL, BUS = %s\n',busNameMPD,busNameMPD,busNameMPD);
            fprintf(fid,'PARAMETER C_%s_PROTOCOL = %s, DT = STRING, ASSIGNMENT = CONSTANT, TYPE = NON_HDL, BUS = %s\n',busNameMPD,busProtocolMPD,busNameMPD);
            fprintf(fid,'## Ports\n');


            obj.printPCorePortsMPD(fid);

            fprintf(fid,'\n');


        end

        function printPCorePortsMPD(obj,fid)
            obj.printPCorePorts(fid,obj.PortList.Inports,'in');
            obj.printPCorePorts(fid,obj.PortList.Outports,'out');
        end

        function printPCorePorts(obj,fid,portList,dir)
            busPortLabel=obj.BusPortLabel;
            busNameMPD=obj.BusNameMPD;

            portNames=fields(portList);
            numBusPorts=numel(portNames);
            for ii=1:numBusPorts
                portName=portNames{ii};
                portWidth=portList.(portName).Width;
                portType=portList.(portName).Type;

                switch(portType)
                case ''
                    IFName=portName;
                    ExtraInfo='';
                case 'RST'
                    IFName=portName;
                    ExtraInfo='SIGIS = RST, ';
                case 'CLK'
                    IFName='""';
                    ExtraInfo='SIGIS = CLK, ASSIGNMENT = REQUIRE, ';
                end

                if strcmpi(dir,'out')
                    DirStr='O';
                else
                    DirStr='I';
                end

                fprintf(fid,'PORT %s_%s = %s, DIR = %s, ',busPortLabel,portName,IFName,DirStr);
                fprintf(fid,ExtraInfo);

                if portWidth>1
                    fprintf(fid,'VEC = [%d:0], ENDIAN = LITTLE, ',portWidth-1);
                end

                fprintf(fid,'BUS = %s\n',busNameMPD);
            end
        end

        function ipMHSStr=generateRDInsertIPEDKMHS(obj,ipMHSStr)
            baseAddress=obj.BaseAddress;
            highAddress=[baseAddress(1:end-4),'FFFF'];
            interfaceName=obj.MasterConnection;
            clockConnection=obj.ClockConnection;
            busPortLabel=obj.BusPortLabel;
            busNameMPD=obj.BusNameMPD;


            ipMHSStr=sprintf('%sPARAMETER C_S_AXI_BASEADDR = %s\n',ipMHSStr,baseAddress);
            ipMHSStr=sprintf('%sPARAMETER C_S_AXI_HIGHADDR = %s\n',ipMHSStr,highAddress);
            ipMHSStr=sprintf('%sBUS_INTERFACE %s = %s\n',ipMHSStr,busNameMPD,interfaceName);


            ipMHSStr=sprintf('%sPORT %s_ACLK = %s\n',ipMHSStr,busPortLabel,clockConnection);
        end


        function generateIPInterfaceVivadoTcl(obj,fid,hElab)
            if(~obj.isEmptyAXI4SlaveInterface)

                hDI=hElab.hTurnkey.hD;

                busPortLabel=obj.BusPortLabel;
                addrRange=obj.getAddrUpperBound+1;

                fprintf(fid,'# %s Slave\n',busPortLabel);


                interfaceName=busPortLabel;
                hdlturnkey.tool.generateVivadoTclInterfaceDefinition(hDI,fid,interfaceName,...
                'xilinx.com:interface:aximm_rtl:1.0','xilinx.com:interface:aximm:1.0');


                obj.printVivadoPorts(hDI,fid,interfaceName,obj.PortList.Inports);
                obj.printVivadoPorts(hDI,fid,interfaceName,obj.PortList.Outports);


                clockInterfaceName=sprintf('%s_signal_clock',busPortLabel);
                clockPortName=sprintf('%s_ACLK',busPortLabel);
                clockXilinxPortName='CLK';
                hdlturnkey.tool.generateVivadoTclInterfaceDefinition(hDI,fid,clockInterfaceName,...
                'xilinx.com:signal:clock_rtl:1.0','xilinx.com:signal:clock:1.0');
                hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,clockInterfaceName,...
                clockXilinxPortName,clockPortName);


                resetInterfaceName=sprintf('%s_signal_reset',busPortLabel);
                resetPortName=sprintf('%s_ARESETN',busPortLabel);
                resetXilinxPortName='RST';
                hdlturnkey.tool.generateVivadoTclInterfaceDefinition(hDI,fid,resetInterfaceName,...
                'xilinx.com:signal:reset_rtl:1.0','xilinx.com:signal:reset:1.0');
                hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,resetInterfaceName,...
                resetXilinxPortName,resetPortName)


                hdlturnkey.tool.generateVivadoTclParameter(hDI,fid,clockInterfaceName,'ASSOCIATED_BUSIF',interfaceName);
                hdlturnkey.tool.generateVivadoTclParameter(hDI,fid,clockInterfaceName,'ASSOCIATED_RESET',resetPortName);
                hdlturnkey.tool.generateVivadoTclParameter(hDI,fid,resetInterfaceName,'POLARITY','ACTIVE_LOW');


                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclMemoryMap',...
                fid,interfaceName,addrRange);

                fprintf(fid,'\n');
            end
        end

        function printVivadoPorts(~,hDI,fid,interfaceName,portList)
            portNames=fields(portList);
            numBusPorts=numel(portNames);
            for ii=1:numBusPorts
                portName=portNames{ii};
                portType=portList.(portName).Type;

                switch(portType)
                case ''
                    hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,interfaceName,portName);

                case 'RST'
                case 'CLK'
                end
            end
        end

        function generateRDInsertIPVivadoTcl(obj,fid,hTool)
            interfaceName=obj.BusPortLabel;
            addrRange=obj.getAddrUpperBound+1;


            hDI=hTool.hETool.hIP.hD;
            hRD=hDI.hIP.getReferenceDesignPlugin;
            hBoard=hTool.hETool.hIP.getBoardObject;
            isInsertJTAGAXI=hRD.getJTAGAXIParameterValue;
            isInsertEthernetAXI=hRD.getEthernetAXIParameterValue;
            isInsertAXI=isInsertJTAGAXI||isInsertEthernetAXI;

            isInsertEthernetFDC=strcmp(hRD.getFDCParameterValue{:},'Ethernet');


            fdcports=hTool.hETool.hIP.hD.hTurnkey.hTable.hTableMap.getConnectedPortList('FPGA Data Capture');

            etherFDCinuse=~isempty(fdcports)&&isInsertEthernetFDC;

            isAXI4InterfaceInUse=hRD.hasDynamicAXI4SlaveInterface;
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclClockResetAXIConnection',fid,interfaceName,obj.ClockConnection,obj.ResetConnection);



            if(isInsertEthernetAXI&&~etherFDCinuse)
                hClockModule=hDI.getClockModule;
                DUTTargetFreq=hClockModule.ClockOutputMHz;
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclInstantiateEtherMac',fid,obj.ClockConnection,obj.ResetConnection,1,DUTTargetFreq,isInsertEthernetAXI,hBoard,hRD,hDI.getProjectFolder);
            end


            if isInsertJTAGAXI
                hClockModule=hDI.getClockModule;
                DUTTargetFreq=hClockModule.ClockOutputMHz;
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclInterfaceConnectionWithJTAGAXIMaster',fid,obj.ClockConnection,obj.ResetConnection,interfaceName,obj.MasterConnection,isAXI4InterfaceInUse,DUTTargetFreq);
            elseif isInsertEthernetAXI
                hClockModule=hDI.getClockModule;
                DUTTargetFreq=hClockModule.ClockOutputMHz;
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclInterfaceConnectionWithEthernetAXIMaster',fid,obj.ClockConnection,obj.ResetConnection,interfaceName,obj.MasterConnection,isAXI4InterfaceInUse,DUTTargetFreq,hBoard);
            else
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclInterfaceConnection',fid,interfaceName,obj.MasterConnection);
            end



            segTgt=sprintf('$HDLCODERIPINST/%s/reg0',interfaceName);
            if iscell(obj.BaseAddress)


                for ii=1:length(obj.BaseAddress)
                    baseAddr=obj.BaseAddress{ii};
                    masterAddrSpace=obj.MasterAddressSpace{ii};
                    obj.generateRDInsertIPVivadoTclAddrSeg(hDI,fid,baseAddr,addrRange,masterAddrSpace,segTgt,isInsertAXI,isAXI4InterfaceInUse);
                end
            else


                baseAddr=obj.BaseAddress;
                masterAddrSpace=obj.MasterAddressSpace;
                obj.generateRDInsertIPVivadoTclAddrSeg(hDI,fid,baseAddr,addrRange,masterAddrSpace,segTgt,isInsertAXI,isAXI4InterfaceInUse);
            end
        end

        function generateRDInsertIPVivadoTclAddrSeg(obj,hDI,fid,baseAddr,addrRange,masterAddrSpace,segTgt,isInsertAXI,isAXI4InterfaceInUse)%#ok<INUSL>

            segOffset=sscanf(baseAddr,'0x%lx');
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclCreateAddrSeg',fid,addrRange,segOffset,masterAddrSpace,segTgt,'${HDLCODERIPINST}_reg0');
            if isInsertAXI
                masterAddrSpace='hdlverifier_axi_mngr/axi4m';
                if~isAXI4InterfaceInUse
                    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclCreateAddrSeg',fid,addrRange,segOffset,masterAddrSpace,segTgt,'${HDLCODERIPINST}_reg0');
                end
            end
        end





    end



    methods(Access=public,Hidden)
        function hSoftwareInterface=getDefaultSoftwareInterface(obj,hTurnkey)
            hRD=hTurnkey.hD.hIP.getReferenceDesignPlugin;
            hasMATLABAXIMasterConnection=hRD.getJTAGAXIParameterValue;
            hasEthernetAXIManagerConnection=hRD.getEthernetAXIParameterValue;

            if obj.HasProcessorConnection||hasMATLABAXIMasterConnection||hasEthernetAXIManagerConnection


                hSoftwareInterface=hdlturnkey.swinterface.AXI4SlaveSoftware.getInstance(obj,hTurnkey);
            else

                hSoftwareInterface=getDefaultSoftwareInterface@hdlturnkey.interface.AddressBased(obj,hTurnkey);
            end


        end

        function hHostInterface=getDefaultHostInterface(obj,hTurnkey)
            hRD=hTurnkey.hD.hIP.getReferenceDesignPlugin;
            hasMATLABAXIMasterConnection=hRD.getJTAGAXIParameterValue;
            hasEthernetAXIManagerConnection=hRD.getEthernetAXIParameterValue;

            if obj.HasProcessorConnection||hasMATLABAXIMasterConnection||hasEthernetAXIManagerConnection


                hHostInterface=hdlturnkey.swinterface.AXI4SlaveSoftware.getHostInstance(obj,hTurnkey);
            else

                hHostInterface=getDefaultHostInterface@hdlturnkey.interface.AddressBased(obj,hTurnkey);
            end


        end

    end

end
