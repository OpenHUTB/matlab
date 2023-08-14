




classdef AXI4<hdlturnkey.interface.AXI4SlaveBase


    properties

        IDWidth=12;
        LenWidth=8;
        FIFOSize=16;
        FIFOFullThreshold=0;
        FinFIFOSize=0;
    end

    properties(Constant,Hidden)
        DefaultInterfaceID='AXI4';

        BusPortLabel='AXI4';
        BusNameMPD='S_AXI';
        BusProtocolMPD='AXI4';
        BusProtocol='AXI4';


        PIRNetworkName='axi4';
    end

    methods

        function obj=AXI4(varargin)


            interfaceID=hdlturnkey.interface.AXI4.DefaultInterfaceID;
            obj=obj@hdlturnkey.interface.AXI4SlaveBase(interfaceID,varargin{:});
        end

        function isa=isAXI4Interface(obj)
            isa=true;
        end

    end


    methods(Access=protected)
        function parseInputs(obj,args)


            p=inputParser;
            p.KeepUnmatched=true;

            p.addParameter('AddrWidth',obj.AddrWidth);
            p.addParameter('IDWidth',obj.IDWidth);
            p.addParameter('LenWidth',obj.LenWidth);

            p.parse(args{:});
            inputArgs=p.Results;

            obj.AddrWidth=inputArgs.AddrWidth;
            obj.IDWidth=inputArgs.IDWidth;
            obj.LenWidth=inputArgs.LenWidth;



            parseInputs@hdlturnkey.interface.AXI4SlaveBase(obj,{p.Unmatched});
        end

        function validateInterfaceParameter(obj)

            validateInterfaceParameter@hdlturnkey.interface.AXI4SlaveBase(obj);


            hdlturnkey.plugin.validateIntegerProperty(...
            obj.IDWidth,'IDWidth',obj.AXI4SlaveExampleStr);
        end
    end


    methods

    end


    methods

    end


    methods

    end


    methods

        function[BusInportList,BusOutPortList]=getExternalPortList(obj)

            BusInportList={...
            {'ACLK',1,'CLK'},...
            {'ARESETN',1,'RST'},...
            {'AWID',obj.IDWidth,''},...
            {'AWADDR',obj.AddrWidth,''},...
            {'AWLEN',obj.LenWidth,''},...
            {'AWSIZE',3,''},...
            {'AWBURST',2,''},...
            {'AWLOCK',1,''},...
            {'AWCACHE',4,''},...
            {'AWPROT',3,''},...
            {'AWVALID',1,''},...
            {'WDATA',32,''},...
            {'WSTRB',4,''},...
            {'WLAST',1,''},...
            {'WVALID',1,''},...
            {'BREADY',1,''},...
            {'ARID',obj.IDWidth,''},...
            {'ARADDR',obj.AddrWidth,''},...
            {'ARLEN',obj.LenWidth,''},...
            {'ARSIZE',3,''},...
            {'ARBURST',2,''},...
            {'ARLOCK',1,''},...
            {'ARCACHE',4,''},...
            {'ARPROT',3,''},...
            {'ARVALID',1,''},...
            {'RREADY',1,''},...
            };
            BusOutPortList={...
            {'AWREADY',1,''},...
            {'WREADY',1,''},...
            {'BID',obj.IDWidth,''},...
            {'BRESP',2,''},...
            {'BVALID',1,''},...
            {'ARREADY',1,''},...
            {'RID',obj.IDWidth,''},...
            {'RDATA',32,''},...
            {'RRESP',2,''},...
            {'RLAST',1,''},...
            {'RVALID',1,''},...
            };
        end

        function elaborateAXI4SlaveIP(obj,hN,hElab,hIPInSignals,hIPOutSignals,readDelayCount)


            ufix1Type=pir_ufixpt_t(1,0);
            ufix2Type=pir_ufixpt_t(2,0);
            ufix14Type=pir_ufixpt_t(14,0);
            ufix32Type=pir_ufixpt_t(32,0);
            ufixAddrType=pir_ufixpt_t(obj.AddrWidth,0);
            ufixIdType=pir_ufixpt_t(obj.IDWidth,0);
            readDelayValue=readDelayCount;


            hIOIPNet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_axi4_module',hElab.TopNetName)...
            );


            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hIOIPNet,...
            'InportNames',[obj.InportNames(2:end),{'data_read'}],...
            'InportWidths',[obj.InportWidths(2:end),{32}],...
            'OutportNames',[obj.OutportNames,{'data_write','addr_sel','wr_enb','rd_enb','reset_internal'}],...
            'OutportWidths',[obj.OutportWidths,{32,14,1,1,1}]);

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;


            port_aresetn=hIPInportSignals(obj.PortList.Inports.('ARESETN').Index-1);
            port_awid=hIPInportSignals(obj.PortList.Inports.('AWID').Index-1);
            port_awaddr=hIPInportSignals(obj.PortList.Inports.('AWADDR').Index-1);
            port_awburst=hIPInportSignals(obj.PortList.Inports.('AWBURST').Index-1);
            port_awvalid=hIPInportSignals(obj.PortList.Inports.('AWVALID').Index-1);
            port_wdata=hIPInportSignals(obj.PortList.Inports.('WDATA').Index-1);
            port_wlast=hIPInportSignals(obj.PortList.Inports.('WLAST').Index-1);
            port_wstrb=hIPInportSignals(obj.PortList.Inports.('WSTRB').Index-1);
            port_wvalid=hIPInportSignals(obj.PortList.Inports.('WVALID').Index-1);
            port_bready=hIPInportSignals(obj.PortList.Inports.('BREADY').Index-1);
            port_arid=hIPInportSignals(obj.PortList.Inports.('ARID').Index-1);
            port_araddr=hIPInportSignals(obj.PortList.Inports.('ARADDR').Index-1);
            port_arlen=hIPInportSignals(obj.PortList.Inports.('ARLEN').Index-1);
            port_arburst=hIPInportSignals(obj.PortList.Inports.('ARBURST').Index-1);
            port_arvalid=hIPInportSignals(obj.PortList.Inports.('ARVALID').Index-1);
            port_rready=hIPInportSignals(obj.PortList.Inports.('RREADY').Index-1);
            data_read=hIPInportSignals(end);

            port_awready=hIPOutportSignals(obj.PortList.Outports.('AWREADY').Index);
            port_wready=hIPOutportSignals(obj.PortList.Outports.('WREADY').Index);
            port_bid=hIPOutportSignals(obj.PortList.Outports.('BID').Index);
            port_bresp=hIPOutportSignals(obj.PortList.Outports.('BRESP').Index);
            port_bvalid=hIPOutportSignals(obj.PortList.Outports.('BVALID').Index);
            port_arready=hIPOutportSignals(obj.PortList.Outports.('ARREADY').Index);
            port_rid=hIPOutportSignals(obj.PortList.Outports.('RID').Index);
            port_rdata=hIPOutportSignals(obj.PortList.Outports.('RDATA').Index);
            port_rresp=hIPOutportSignals(obj.PortList.Outports.('RRESP').Index);
            port_rlast=hIPOutportSignals(obj.PortList.Outports.('RLAST').Index);
            port_rvalid=hIPOutportSignals(obj.PortList.Outports.('RVALID').Index);
            data_write=hIPOutportSignals(end-4);
            addr_sel=hIPOutportSignals(end-3);
            wr_enb=hIPOutportSignals(end-2);
            rd_enb=hIPOutportSignals(end-1);
            reset_internal=hIPOutportSignals(end);



            [~,clkenb,reset]=hIOIPNet.getClockBundle(port_awaddr,1,1,0);
            pirelab.getBitwiseOpComp(hIOIPNet,port_aresetn,reset,'NOT');
            const_1=hIOIPNet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hIOIPNet,const_1,1);
            pirelab.getWireComp(hIOIPNet,const_1,clkenb);


            aw_transfer=hIOIPNet.addSignal(ufix1Type,'aw_transfer');
            w_transfer=hIOIPNet.addSignal(ufix1Type,'w_transfer');
            ar_transfer=hIOIPNet.addSignal(ufix1Type,'ar_transfer');
            ar_transfer_del=hIOIPNet.addSignal(ufix1Type,'ar_transfer_del');
            rd_active=hIOIPNet.addSignal(ufix1Type,'rd_active');

            waddr_int=hIOIPNet.addSignal(ufixAddrType,'waddr_int');
            waddr_r=hIOIPNet.addSignal(ufixAddrType,'waddr_r');
            waddr=hIOIPNet.addSignal(ufixAddrType,'waddr');

            raddr_r=hIOIPNet.addSignal(ufixAddrType,'raddr_r');

            wdata_int=hIOIPNet.addSignal(ufix32Type,'wdata_int');
            wdata=hIOIPNet.addSignal(ufix32Type,'wdata');
            waddr_sel=hIOIPNet.addSignal(ufix14Type,'waddr_sel');
            raddr_sel=hIOIPNet.addSignal(ufix14Type,'raddr_sel');

            rid_int=hIOIPNet.addSignal(ufixIdType,'rid_int');
            rid_int_del=hIOIPNet.addSignal(ufixIdType,'rid_int_del');
            rlast_int=hIOIPNet.addSignal(ufix1Type,'rlast_int');
            rlast_int_del=hIOIPNet.addSignal(ufix1Type,'rlast_int_del');

            fifo_empty_data=hIOIPNet.addSignal(ufix1Type,'fifo_empty_data');
            fifo_afull_data=hIOIPNet.addSignal(ufix1Type,'fifo_afull_data');


            hIOIPNet.addComponent2(...
            'kind','cgireml',...
            'Name',sprintf('axi4'),...
            'InputSignals',[port_awid,port_awaddr,port_awburst,port_awvalid,...
            port_wlast,port_wvalid,...
            port_bready,...
            port_arid,port_araddr,port_arlen,port_arburst,port_arvalid,...
            fifo_afull_data],...
            'OutputSignals',[port_awready,waddr_int,...
            port_wready,...
            port_bid,port_bvalid,...
            raddr_r,port_arready,...
            rid_int,rlast_int,...
            aw_transfer,w_transfer,ar_transfer,rd_active],...
            'EMLFileName','hdleml_axi4',...
            'EMLParams',{obj.AddrWidth,obj.IDWidth,obj.LenWidth}...
            );


            const_0_2=hIOIPNet.addSignal(ufix2Type,'const_0_2');
            pirelab.getConstComp(hIOIPNet,const_0_2,0);
            pirelab.getWireComp(hIOIPNet,const_0_2,port_bresp);
            pirelab.getWireComp(hIOIPNet,const_0_2,port_rresp);


            pirelab.getUnitDelayEnabledComp(hIOIPNet,waddr_int,waddr_r,aw_transfer,'reg_waddr_in');

            pirelab.getUnitDelayComp(hIOIPNet,waddr_r,waddr,'reg_waddr');


            pirelab.getUnitDelayComp(hIOIPNet,port_wdata,wdata_int,'reg_wdata_in');

            pirelab.getUnitDelayEnabledComp(hIOIPNet,wdata_int,wdata,w_transfer,'reg_wdata');

            ramCorePrefix=sprintf('%s_',hElab.TopNetName);


            pirelab.getIntDelayComp(hIOIPNet,rlast_int,rlast_int_del,readDelayValue,'reg_rlast_int_del');


            pirelab.getIntDelayComp(hIOIPNet,rid_int,rid_int_del,readDelayValue,'reg_rid_int_del');


            pirelab.getIntDelayComp(hIOIPNet,ar_transfer,ar_transfer_del,readDelayValue,'reg_ar_transfer_del');


            obj.FIFOFullThreshold=readDelayValue+2;


            if(obj.FIFOFullThreshold>7)
                obj.FinFIFOSize=bitsll(obj.FIFOFullThreshold,2);
            else
                obj.FinFIFOSize=16;
            end


            DataFIFOInSignals=[data_read,ar_transfer_del,port_rready];
            DataFIFOOutSignals=[port_rdata,fifo_empty_data,fifo_afull_data];
            pirelab.getFIFOFWFTComp(hIOIPNet,DataFIFOInSignals,DataFIFOOutSignals,obj.FinFIFOSize,...
            sprintf('%s_rdfifo_data',hElab.TopNetName),ramCorePrefix,true,obj.FIFOFullThreshold);
            pirelab.getBitwiseOpComp(hIOIPNet,fifo_empty_data,port_rvalid,'NOT');


            LastFIFOInSignals=[rlast_int_del,ar_transfer_del,port_rready];
            LastFIFOOutSignals=port_rlast;
            pirelab.getFIFOFWFTComp(hIOIPNet,LastFIFOInSignals,LastFIFOOutSignals,obj.FinFIFOSize,...
            sprintf('%s_rdfifo_last',hElab.TopNetName),ramCorePrefix,false,obj.FIFOFullThreshold);


            RidFIFOInSignals=[rid_int_del,ar_transfer_del,port_rready];
            RidFIFOOutSignals=port_rid;
            pirelab.getFIFOFWFTComp(hIOIPNet,RidFIFOInSignals,RidFIFOOutSignals,obj.FinFIFOSize,...
            sprintf('%s_rdfifo_rid',hElab.TopNetName),ramCorePrefix,false,obj.FIFOFullThreshold);



            pirelab.getBitSliceComp(hIOIPNet,waddr,waddr_sel,15,2);
            pirelab.getBitSliceComp(hIOIPNet,raddr_r,raddr_sel,15,2);
            pirelab.getSwitchComp(hIOIPNet,[raddr_sel,waddr_sel],addr_sel,rd_active,'switch1','==',1);


            pirelab.getWireComp(hIOIPNet,ar_transfer_del,rd_enb);
            pirelab.getWireComp(hIOIPNet,wdata,data_write);


            wstrb_reduce=hIOIPNet.addSignal(ufix1Type,'wstrb_reduce');
            wstrb_reduce_reg=hIOIPNet.addSignal(ufix1Type,'wstrb_reduce_reg');
            w_transfer_and_wstrb=hIOIPNet.addSignal(ufix1Type,'w_transfer_and_wstrb');
            pirelab.getBitReduceComp(hIOIPNet,port_wstrb,wstrb_reduce,'and');
            pirelab.getUnitDelayComp(hIOIPNet,wstrb_reduce,wstrb_reduce_reg,'reg_wstrb_reduce');
            pirelab.getBitwiseOpComp(hIOIPNet,[w_transfer,wstrb_reduce_reg],w_transfer_and_wstrb,'AND');
            pirelab.getUnitDelayComp(hIOIPNet,w_transfer_and_wstrb,wr_enb,'reg_wr_enb');


            obj.elaborateSoftResetLogic(hIOIPNet,hElab,waddr_sel,wr_enb,wdata,reset,reset_internal);



            pirelab.instantiateNetwork(hN,hIOIPNet,hIPInSignals,...
            hIPOutSignals,sprintf('%s_axi4_module_inst',hElab.TopNetName));


        end

    end


    methods

    end



    methods





        function generatePCoreQsysTCL(obj,fid,~)

            if(~obj.isEmptyAXI4SlaveInterface)
                fprintf(fid,'## AXI4 Bus\n');

                busNameMPD=lower(obj.BusNameMPD);


                proplist={...
                {'clockRate','0'},...
                {'ENABLED','true'},...
                {'EXPORT_OF','""'},...
                {'PORT_NAME_MAP','""'},...
                {'CMSIS_SVD_VARIABLES','""'},...
                {'SVD_ADDRESS_GROUP','""'},...
                };
                portlist={
                {'AXI4_ACLK','clk','Input','1'},...
                };
                hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,'axi_clk',hdlturnkey.IOType.IN,'clock',proplist,portlist);


                proplist={...
                {'associatedClock','axi_clk'},...
                {'synchronousEdges','DEASSERT'},...
                {'ENABLED','true'},...
                {'EXPORT_OF','""'},...
                {'PORT_NAME_MAP','""'},...
                {'CMSIS_SVD_VARIABLES','""'},...
                {'SVD_ADDRESS_GROUP','""'},...
                };
                portlist={
                {'AXI4_ARESETN','reset_n','Input','1'},...
                };
                hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,'axi_reset',hdlturnkey.IOType.IN,'reset',proplist,portlist);


                proplist={...
                {'associatedClock','axi_clk'},...
                {'associatedReset','axi_reset'},...
                {'readAcceptanceCapability','1'},...
                {'writeAcceptanceCapability','1'},...
                {'combinedAcceptanceCapability','1'},...
                {'readDataReorderingDepth','1'},...
                {'bridgesToMaster','""'},...
                {'ENABLED','true'},...
                {'EXPORT_OF','""'},...
                {'PORT_NAME_MAP','""'},...
                {'CMSIS_SVD_VARIABLES','""'},...
                {'SVD_ADDRESS_GROUP','""'},...
                };
                inPortList=obj.buildQsysPorts(obj.PortList.Inports,'Input');
                outPortList=obj.buildQsysPorts(obj.PortList.Outports,'Output');
                portList=[...
                inPortList,...
                outPortList,...
                ];
                hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,busNameMPD,hdlturnkey.IOType.IN,'axi4',proplist,portList);
            end
        end

        function qsysPorts=buildQsysPorts(obj,portList,dir)
            busPortLabel=obj.BusPortLabel;

            portNames=fields(portList);
            numBusPorts=numel(portNames);
            qsysPorts={};
            for ii=1:numBusPorts
                portName=portNames{ii};
                portWidth=portList.(portName).Width;
                portType=portList.(portName).Type;
                switch(portType)
                case{'RST','CLK'}
                    continue;
                otherwise
                end
                qsysPorts{end+1}={...
                sprintf('%s_%s',busPortLabel,portName),...
                lower(portName),...
                dir,...
                num2str(portWidth)
                };%#ok<*AGROW>
            end
        end

        function generatePCoreLiberoTCL(obj,fid,~,topModuleFile)

            if(~obj.isEmptyAXI4SlaveInterface)
                fprintf(fid,'## AXI4 Bus\n');
                busNameMPD=lower(obj.BusNameMPD);



                inPortList=obj.buildLiberoPorts(obj.PortList.Inports,'Input');
                outPortList=obj.buildLiberoPorts(obj.PortList.Outports,'Output');
                portList=[...
                inPortList,...
                outPortList,...
                ];
                hdlturnkey.tool.generateLiberoTclInterfaceDefinition(fid,busNameMPD,hdlturnkey.IOType.IN,'axi4',portList,topModuleFile);
            end
        end

        function liberoPorts=buildLiberoPorts(obj,portList,dir)
            busPortLabel=obj.BusPortLabel;

            portNames=fields(portList);
            numBusPorts=numel(portNames);
            liberoPorts={};
            for ii=1:numBusPorts
                portName=portNames{ii};
                portWidth=portList.(portName).Width;
                portType=portList.(portName).Type;
                switch(portType)
                case{'RST','CLK'}
                    continue;
                otherwise
                end
                liberoPorts{end+1}={...
                sprintf('%s_%s',busPortLabel,portName),...
                lower(portName),...
                dir,...
                num2str(portWidth)
                };%#ok<*AGROW>
            end
        end

        function generateRDInsertIPQsysTcl(obj,fid,hTool)



            hDI=hTool.hETool.hIP.hD;
            hRD=hDI.hIP.getReferenceDesignPlugin;
            isInsertJTAGAXI=hRD.getJTAGAXIParameterValue;
            isAXI4InterfaceInUse=hRD.hasDynamicAXI4SlaveInterface;

            if isInsertJTAGAXI


                hClockModule=hDI.getClockModule;
                DUTTargetFreq=hClockModule.ClockOutputMHz;
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysConnectionwithJTAGAXIMaster',...
                fid,obj.ClockConnection,obj.ResetConnection,isAXI4InterfaceInUse,DUTTargetFreq);
            end
            if iscell(obj.MasterConnection)
                for ii=1:length(obj.MasterConnection)



                    MastrConnec=obj.MasterConnection{ii};
                    BaseAddr=obj.BaseAddress{ii};
                    obj.generateRDInsertIPQuartusTclMasterConnection(hDI,fid,MastrConnec,BaseAddr,isInsertJTAGAXI,isAXI4InterfaceInUse);
                end
            else
                MastrConnec=obj.MasterConnection;
                BaseAddr=obj.BaseAddress;
                obj.generateRDInsertIPQuartusTclMasterConnection(hDI,fid,MastrConnec,BaseAddr,isInsertJTAGAXI,isAXI4InterfaceInUse);
            end
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysAddConnection',fid,obj.ClockConnection,'${HDLCODERIPINST}.axi_clk');
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysAddConnection',fid,obj.ResetConnection,'${HDLCODERIPINST}.axi_reset');
        end

        function generateRDInsertIPQuartusTclMasterConnection(obj,hDI,fid,MastrConnec,BaseAddr,isInsertJTAGAXI,isAXI4InterfaceInUse)%#ok<INUSL>

            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysAddConnection',fid,MastrConnec,'${HDLCODERIPINST}.s_axi');
            connectionName=sprintf('%s/${HDLCODERIPINST}.s_axi',MastrConnec);

            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysSetConnectionParam',fid,connectionName,'baseAddress',BaseAddr);


            if isInsertJTAGAXI&&~isAXI4InterfaceInUse
                connectionName='AXI_Manager_0.axm_m0/${HDLCODERIPINST}.s_axi';
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclQsysSetConnectionParam',fid,connectionName,'baseAddress',BaseAddr);
            end
        end

    end

end










