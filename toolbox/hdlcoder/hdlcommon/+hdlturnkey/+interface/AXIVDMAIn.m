


classdef AXIVDMAIn<hdlturnkey.interface.StreamingBasedVDMA&...
    hdlturnkey.interface.IPWorkflowBase


    properties


        PairedInterfaceID='AXI4-Stream Video Out';

    end

    properties(Constant)
        BusPortLabel='AXI_Stream_Video_In';
        BusNameMPD='AXI_Stream_Video_In';
        BusProtocol='AXI4-Stream Video';
    end

    methods

        function obj=AXIVDMAIn()


            interfaceID='AXI4-Stream Video In';
            obj=obj@hdlturnkey.interface.StreamingBasedVDMA(interfaceID);


            obj.InterfaceType=hdlturnkey.IOType.IN;


            obj.SupportedTool={'Xilinx ISE'};


            obj.InportNames={...


            sprintf('%s_TVALID',obj.BusPortLabel),...
            sprintf('%s_TDATA',obj.BusPortLabel),...
            sprintf('%s_TSTRB',obj.BusPortLabel),...
            sprintf('%s_TLAST',obj.BusPortLabel),...
            sprintf('%s_TUSER',obj.BusPortLabel),...
            sprintf('%s_TDEST',obj.BusPortLabel),...
            };
            obj.InportWidths={1,32,4,1,1,1};
            obj.OutportNames={...
            sprintf('%s_TREADY',obj.BusPortLabel),...
            };
            obj.OutportWidths={1};

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

        function elaborate(obj,hN,hElab)



            hInterfaceSignal=obj.addInterfacePort(hN);



            obj.elaborateStreamIn(hN,hElab,hInterfaceSignal);

        end

        function elaborateStreamIn(obj,hN,hElab,hInterfaceSignal)


            ufix1Type=pir_ufixpt_t(1,0);
            ufix32Type=pir_ufixpt_t(32,0);


            hTopInportSignals=hInterfaceSignal.hInportSignals;
            hTopOutportSignals=hInterfaceSignal.hOutportSignals;


            hIOIPNet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_vstream_in',hElab.TopNetName)...
            );


            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hIOIPNet,...
            'InportNames',[obj.InportNames,{'fifo_read'}],...
            'InportWidths',[obj.InportWidths,{1}],...
            'OutportNames',[obj.OutportNames,{'fifo_empty','fifo_data','fifo_sof','fifo_eol'}],...
            'OutportWidths',[obj.OutportWidths,{1,32,1,1}]);

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;




            port_tvalid=hIPInportSignals(1);
            port_tdata=hIPInportSignals(2);

            port_tlast=hIPInportSignals(4);
            port_tuser=hIPInportSignals(5);

            fifo_read=hIPInportSignals(7);

            port_tready=hIPOutportSignals(1);
            fifo_empty=hIPOutportSignals(2);
            fifo_data=hIPOutportSignals(3);
            fifo_sof=hIPOutportSignals(4);
            fifo_eol=hIPOutportSignals(5);





            [~,clkenb,~]=hIOIPNet.getClockBundle(port_tvalid,1,1,0);


            const_1=hIOIPNet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hIOIPNet,const_1,1);
            pirelab.getWireComp(hIOIPNet,const_1,clkenb);


            fifo_data_in=hIOIPNet.addSignal(ufix32Type,'fifo_data_in');
            fifo_sof_in=hIOIPNet.addSignal(ufix1Type,'fifo_sof_in');
            fifo_eol_in=hIOIPNet.addSignal(ufix1Type,'fifo_eol_in');
            fifo_write=hIOIPNet.addSignal(ufix1Type,'fifo_write');
            transfer=hIOIPNet.addSignal(ufix1Type,'transfer');
            cache_enb=hIOIPNet.addSignal(ufix1Type,'cache_enb');
            cache_use=hIOIPNet.addSignal(ufix1Type,'cache_use');
            fifo_full=hIOIPNet.addSignal(ufix1Type,'fifo_full');


            hIOIPNet.addComponent2(...
            'kind','cgireml',...
            'Name',sprintf('vstream_in'),...
            'InputSignals',[port_tvalid,fifo_full],...
            'OutputSignals',[port_tready,fifo_write,transfer,cache_enb,cache_use],...
            'EMLFileName','hdleml_axistream_in'...
            );


            fifoSize=4;


            obj.getRegisterCacheLogic(hIOIPNet,port_tdata,transfer,cache_enb,cache_use,fifo_data_in);
            InSignals=[fifo_data_in,fifo_write,fifo_read];
            OutSignals=[fifo_data,fifo_empty,fifo_full];
            obj.getStreamingFIFOComp(hIOIPNet,InSignals,OutSignals,fifoSize,sprintf('%s_fifo_data',hElab.TopNetName));


            obj.getRegisterCacheLogic(hIOIPNet,port_tuser,transfer,cache_enb,cache_use,fifo_sof_in);
            InSignals=[fifo_sof_in,fifo_write,fifo_read];
            OutSignals=fifo_sof;
            obj.getStreamingFIFOComp(hIOIPNet,InSignals,OutSignals,fifoSize,sprintf('%s_fifo_sof',hElab.TopNetName),false);


            obj.getRegisterCacheLogic(hIOIPNet,port_tlast,transfer,cache_enb,cache_use,fifo_eol_in);
            InSignals=[fifo_eol_in,fifo_write,fifo_read];
            OutSignals=fifo_eol;
            obj.getStreamingFIFOComp(hIOIPNet,InSignals,OutSignals,fifoSize,sprintf('%s_fifo_eol',hElab.TopNetName),false);




            top_fifo_data_in=hN.addSignal(ufix32Type,'top_fifo_data_in');


            top_fifo_read=hN.addSignal(ufix1Type,'top_fifo_read');
            top_fifo_empty=hN.addSignal(ufix1Type,'top_fifo_empty');
            top_fifo_sof_in=hN.addSignal(ufix1Type,'top_fifo_sof_in');
            top_fifo_eol_in=hN.addSignal(ufix1Type,'top_fifo_eol_in');
            hElab.connectSignalFrom('fifo_in_read',top_fifo_read);
            hElab.connectSignalTo('fifo_in_empty',top_fifo_empty);
            hElab.connectSignalTo('fifo_in_sof',top_fifo_sof_in);
            hElab.connectSignalTo('fifo_in_eol',top_fifo_eol_in);


            hIPInSignals=[hTopInportSignals,top_fifo_read];
            hIPOutSignals=[hTopOutportSignals,top_fifo_empty,top_fifo_data_in,top_fifo_sof_in,top_fifo_eol_in];
            pirelab.instantiateNetwork(hN,hIOIPNet,hIPInSignals,...
            hIPOutSignals,sprintf('%s_vstream_in_inst',hElab.TopNetName));






            portName=obj.hVDMAPort.getAssignedDataPort;


            hDUTPortSignals=hElab.getCodegenPirSignalForPort(portName);
            dutPortSignal=hDUTPortSignals{1};


            pirelab.getDTCComp(hN,top_fifo_data_in,dutPortSignal,'Floor','Wrap','SI');

        end

    end


    methods

    end



    methods

        function generatePCoreMPD(obj,fid,~)


            busPortLabel=obj.BusPortLabel;
            busNameMPD=obj.BusNameMPD;


            fprintf(fid,'## %s\n',obj.InterfaceID);
            fprintf(fid,'BUS_INTERFACE BUS = %s, BUS_STD = AXIS, BUS_TYPE = TARGET\n',busNameMPD);
            fprintf(fid,'## Generics for VHDL or Parameters for Verilog\n');
            fprintf(fid,'PARAMETER C_%s_PROTOCOL = GENERIC, DT = STRING, TYPE = NON_HDL, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'## Ports\n');


            fprintf(fid,'PORT %s_TVALID = TVALID, DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TREADY = TREADY, DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TDATA  = TDATA,  DIR = I, VEC = [31:0], BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TSTRB  = TSTRB,  DIR = I, VEC = [3:0],  BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TUSER  = TUSER,  DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TLAST  = TLAST,  DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TDEST  = TDEST,  DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'\n');
        end
    end

end







