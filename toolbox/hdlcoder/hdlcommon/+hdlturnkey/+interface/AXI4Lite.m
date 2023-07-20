



classdef AXI4Lite<hdlturnkey.interface.AXI4SlaveBase


    properties

    end

    properties(Constant,Hidden)
        DefaultInterfaceID='AXI4-Lite';

        BusPortLabel='AXI4_Lite';
        BusNameMPD='S_AXI';
        BusProtocolMPD='AXI4LITE';
        BusProtocol='AXI4-Lite';


        PIRNetworkName='axi_lite';
    end

    methods

        function obj=AXI4Lite(varargin)


            interfaceID=hdlturnkey.interface.AXI4Lite.DefaultInterfaceID;
            obj=obj@hdlturnkey.interface.AXI4SlaveBase(interfaceID,varargin{:});



            obj.SupportedLiberoFamily={'PolarFire','PolarFireSoC'};
        end

        function isa=isAXI4LiteInterface(obj)
            isa=true;
        end
    end


    methods

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
            {'AWADDR',obj.AddrWidth,''},...
            {'AWVALID',1,''},...
            {'WDATA',32,''},...
            {'WSTRB',4,''},...
            {'WVALID',1,''},...
            {'BREADY',1,''},...
            {'ARADDR',obj.AddrWidth,''},...
            {'ARVALID',1,''},...
            {'RREADY',1,''},...
            };
            BusOutPortList={...
            {'AWREADY',1,''},...
            {'WREADY',1,''},...
            {'BRESP',2,''},...
            {'BVALID',1,''},...
            {'ARREADY',1,''},...
            {'RDATA',32,''},...
            {'RRESP',2,''},...
            {'RVALID',1,''},...
            };
        end

        function elaborateAXI4SlaveIP(obj,hN,hElab,hIPInSignals,hIPOutSignals,readDelayCount)


            ufix1Type=pir_ufixpt_t(1,0);
            ufix2Type=pir_ufixpt_t(2,0);
            ufix14Type=pir_ufixpt_t(14,0);
            addrPirType=pir_ufixpt_t(obj.AddrWidth,0);
            ufix32Type=pir_ufixpt_t(32,0);
            readDelayValue=readDelayCount;


            hIOIPNet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_axi_lite_module',hElab.TopNetName)...
            );


            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hIOIPNet,...
            'InportNames',[obj.InportNames(2:end),{'data_read'}],...
            'InportWidths',[obj.InportWidths(2:end),{32}],...
            'OutportNames',[obj.OutportNames,{'data_write','addr_sel','wr_enb','rd_enb','reset_internal'}],...
            'OutportWidths',[obj.OutportWidths,{32,14,1,1,1}]);

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;


            port_aresetn=hIPInportSignals(1);
            port_awaddr=hIPInportSignals(2);
            port_awvalid=hIPInportSignals(3);
            port_wdata=hIPInportSignals(4);
            port_wstrb=hIPInportSignals(5);
            port_wvalid=hIPInportSignals(6);
            port_bbready=hIPInportSignals(7);
            port_araddr=hIPInportSignals(8);
            port_arvalid=hIPInportSignals(9);
            port_rready=hIPInportSignals(10);
            data_read=hIPInportSignals(11);

            port_awready=hIPOutportSignals(1);
            port_wready=hIPOutportSignals(2);
            port_bresp=hIPOutportSignals(3);
            port_bvalid=hIPOutportSignals(4);
            port_arready=hIPOutportSignals(5);
            port_rdata=hIPOutportSignals(6);
            port_rresp=hIPOutportSignals(7);
            port_rvalid=hIPOutportSignals(8);
            data_write=hIPOutportSignals(9);
            addr_sel=hIPOutportSignals(10);
            wr_enb=hIPOutportSignals(11);
            rd_enb=hIPOutportSignals(12);
            reset_internal=hIPOutportSignals(13);



            [~,clkenb,reset]=hIOIPNet.getClockBundle(port_awaddr,1,1,0);
            pirelab.getBitwiseOpComp(hIOIPNet,port_aresetn,reset,'NOT');
            const_1=hIOIPNet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hIOIPNet,const_1,1);
            pirelab.getWireComp(hIOIPNet,const_1,clkenb);


            aw_transfer=hIOIPNet.addSignal(ufix1Type,'aw_transfer');
            w_transfer=hIOIPNet.addSignal(ufix1Type,'w_transfer');
            ar_transfer=hIOIPNet.addSignal(ufix1Type,'ar_transfer');
            rvalid_int=hIOIPNet.addSignal(ufix1Type,'rvalid_int');
            ar_transfer_del=hIOIPNet.addSignal(ufix1Type,'ar_transfer_del');

            waddr=hIOIPNet.addSignal(addrPirType,'waddr');
            wdata=hIOIPNet.addSignal(ufix32Type,'wdata');
            waddr_sel=hIOIPNet.addSignal(ufix14Type,'waddr_sel');
            raddr_sel=hIOIPNet.addSignal(ufix14Type,'raddr_sel');


            hIOIPNet.addComponent2(...
            'kind','cgireml',...
            'Name',sprintf('axi_lite'),...
            'InputSignals',[port_awvalid,port_wvalid,port_bbready,port_arvalid,port_rready],...
            'OutputSignals',[port_awready,port_wready,port_bvalid,port_arready,rvalid_int,...
            aw_transfer,w_transfer,ar_transfer],...
            'EMLFileName','hdleml_axi_lite'...
            );


            const_0_2=hIOIPNet.addSignal(ufix2Type,'const_0_2');
            pirelab.getConstComp(hIOIPNet,const_0_2,0);
            pirelab.getWireComp(hIOIPNet,const_0_2,port_bresp);
            pirelab.getWireComp(hIOIPNet,const_0_2,port_rresp);


            pirelab.getIntDelayComp(hIOIPNet,rvalid_int,port_rvalid,readDelayValue,'reg_rvalid_int');
            pirelab.getIntDelayComp(hIOIPNet,ar_transfer,ar_transfer_del,readDelayValue,'reg_ar_transfer_del');


            pirelab.getUnitDelayEnabledComp(hIOIPNet,port_awaddr,waddr,aw_transfer,'reg_waddr');
            pirelab.getUnitDelayEnabledComp(hIOIPNet,port_wdata,wdata,w_transfer,'reg_wdata');


            pirelab.getUnitDelayEnabledComp(hIOIPNet,data_read,port_rdata,ar_transfer_del,'reg_rdata');







            pirelab.getBitSliceComp(hIOIPNet,waddr,waddr_sel,15,2);
            pirelab.getBitSliceComp(hIOIPNet,port_araddr,raddr_sel,15,2);
            pirelab.getSwitchComp(hIOIPNet,[raddr_sel,waddr_sel],addr_sel,ar_transfer,'switch1','==',1);


            pirelab.getWireComp(hIOIPNet,ar_transfer,rd_enb);
            pirelab.getWireComp(hIOIPNet,wdata,data_write);


            wstrb_reduce=hIOIPNet.addSignal(ufix1Type,'wstrb_reduce');
            w_transfer_and_wstrb=hIOIPNet.addSignal(ufix1Type,'w_transfer_and_wstrb');
            pirelab.getBitReduceComp(hIOIPNet,port_wstrb,wstrb_reduce,'and');
            pirelab.getBitwiseOpComp(hIOIPNet,[w_transfer,wstrb_reduce],w_transfer_and_wstrb,'AND');
            pirelab.getUnitDelayComp(hIOIPNet,w_transfer_and_wstrb,wr_enb,'reg_wr_enb');


            obj.elaborateSoftResetLogic(hIOIPNet,hElab,waddr_sel,wr_enb,wdata,reset,reset_internal);


            pirelab.instantiateNetwork(hN,hIOIPNet,hIPInSignals,...
            hIPOutSignals,sprintf('%s_axi_lite_module_inst',hElab.TopNetName));

        end

    end


    methods

    end



    methods


        function printPCorePortsMPD(obj,fid)


            busPortLabel=obj.BusPortLabel;
            busNameMPD=obj.BusNameMPD;

            fprintf(fid,'PORT %s_ACLK = "", DIR = I, SIGIS = CLK, ASSIGNMENT = REQUIRE, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_ARESETN = ARESETN, DIR = I, SIGIS = RST, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_AWADDR = AWADDR, DIR = I, VEC = [%d:0], ENDIAN = LITTLE, BUS = %s\n',busPortLabel,obj.AddrWidth-1,busNameMPD);
            fprintf(fid,'PORT %s_AWVALID = AWVALID, DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_AWREADY = AWREADY, DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_WDATA = WDATA, DIR = I, VEC = [31:0], ENDIAN = LITTLE, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_WSTRB = WSTRB, DIR = I, VEC = [3:0], ENDIAN = LITTLE, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_WVALID = WVALID, DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_WREADY = WREADY, DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_BRESP = BRESP, DIR = O, VEC = [1:0], BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_BVALID = BVALID, DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_BREADY = BREADY, DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_ARADDR = ARADDR, DIR = I, VEC = [%d:0], ENDIAN = LITTLE, BUS = %s\n',busPortLabel,obj.AddrWidth-1,busNameMPD);
            fprintf(fid,'PORT %s_ARVALID = ARVALID, DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_ARREADY = ARREADY, DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_RDATA = RDATA, DIR = O, VEC = [31:0], ENDIAN = LITTLE, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_RRESP = RRESP, DIR = O, VEC = [1:0], BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_RVALID = RVALID, DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_RREADY = RREADY, DIR = I, BUS = %s\n',busPortLabel,busNameMPD);


        end

        function generatePCoreLiberoTCL(obj,fid,~,topModuleFile)

            if(~obj.isEmptyAXI4SlaveInterface)
                fprintf(fid,'## AXI4-Lite Bus\n');
                busNameMPD=lower(obj.BusNameMPD);

                inPortList=obj.buildLiberoPorts(obj.PortList.Inports,'Input');
                outPortList=obj.buildLiberoPorts(obj.PortList.Outports,'Output');
                portList=[...
                inPortList,...
                outPortList,...
                ];
                hdlturnkey.tool.generateLiberoTclInterfaceDefinition(fid,busNameMPD,hdlturnkey.IOType.IN,'AXI4_Lite',portList,topModuleFile);

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


    end

end







