


classdef AXIVDMAOut<hdlturnkey.interface.StreamingBasedVDMA&...
    hdlturnkey.interface.IPWorkflowBase


    properties


        PairedInterfaceID='AXI4-Stream Video In';

    end

    properties(Constant)
        BusPortLabel='AXI_Stream_Video_Out';
        BusNameMPD='AXI_Stream_Video_Out';
        BusProtocol='AXI4-Stream Video';
    end

    methods

        function obj=AXIVDMAOut()


            interfaceID='AXI4-Stream Video Out';
            obj=obj@hdlturnkey.interface.StreamingBasedVDMA(interfaceID);


            obj.InterfaceType=hdlturnkey.IOType.OUT;


            obj.SupportedTool={'Xilinx ISE'};


            obj.InportNames={...


            sprintf('%s_TREADY',obj.BusPortLabel),...
            };
            obj.InportWidths={1};
            obj.OutportNames={...
            sprintf('%s_TVALID',obj.BusPortLabel),...
            sprintf('%s_TDATA',obj.BusPortLabel),...
            sprintf('%s_TSTRB',obj.BusPortLabel),...
            sprintf('%s_TLAST',obj.BusPortLabel),...
            sprintf('%s_TUSER',obj.BusPortLabel),...
            sprintf('%s_TDEST',obj.BusPortLabel),...
            };
            obj.OutportWidths={1,32,4,1,1,1};

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



            obj.elaborateStreamOut(hN,hElab,hInterfaceSignal);

        end

        function elaborateStreamOut(obj,hN,hElab,hInterfaceSignal)


            ufix1Type=pir_ufixpt_t(1,0);
            ufix4Type=pir_ufixpt_t(4,0);
            ufix32Type=pir_ufixpt_t(32,0);


            hTopInportSignals=hInterfaceSignal.hInportSignals;
            hTopOutportSignals=hInterfaceSignal.hOutportSignals;


            hIOIPNet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_vstream_out',hElab.TopNetName)...
            );


            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hIOIPNet,...
            'InportNames',[obj.InportNames,{'fifo_write','fifo_data','fifo_sof','fifo_eol'}],...
            'InportWidths',[obj.InportWidths,{1,32,1,1}],...
            'OutportNames',[obj.OutportNames,{'fifo_full'}],...
            'OutportWidths',[obj.OutportWidths,{1}]);

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;




            port_tready=hIPInportSignals(1);
            fifo_write=hIPInportSignals(2);
            fifo_data=hIPInportSignals(3);
            fifo_sof=hIPInportSignals(4);
            fifo_eol=hIPInportSignals(5);

            port_tvalid=hIPOutportSignals(1);
            port_tdata=hIPOutportSignals(2);
            port_tstrb=hIPOutportSignals(3);
            port_tlast=hIPOutportSignals(4);
            port_tuser=hIPOutportSignals(5);
            port_tdest=hIPOutportSignals(6);
            fifo_full=hIPOutportSignals(7);





            [~,clkenb,~]=hIOIPNet.getClockBundle(port_tready,1,1,0);


            const_1=hIOIPNet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hIOIPNet,const_1,1);
            pirelab.getWireComp(hIOIPNet,const_1,clkenb);


            const_strb=hIOIPNet.addSignal(ufix4Type,'const_strb');
            pirelab.getConstComp(hIOIPNet,const_strb,15);
            pirelab.getWireComp(hIOIPNet,const_strb,port_tstrb);
            pirelab.getWireComp(hIOIPNet,const_1,port_tdest);


            fifo_read=hIOIPNet.addSignal(ufix1Type,'fifo_read');
            fifo_data_out=hIOIPNet.addSignal(ufix32Type,'fifo_data_out');
            fifo_sof_out=hIOIPNet.addSignal(ufix1Type,'fifo_sof_out');
            fifo_eol_out=hIOIPNet.addSignal(ufix1Type,'fifo_eol_out');
            transfer=hIOIPNet.addSignal(ufix1Type,'transfer');
            cache_enb=hIOIPNet.addSignal(ufix1Type,'cache_enb');
            cache_use=hIOIPNet.addSignal(ufix1Type,'cache_use');
            fifo_empty=hIOIPNet.addSignal(ufix1Type,'fifo_empty');


            hIOIPNet.addComponent2(...
            'kind','cgireml',...
            'Name',sprintf('vstream_out'),...
            'InputSignals',[port_tready,fifo_empty],...
            'OutputSignals',[port_tvalid,fifo_read,transfer,cache_enb,cache_use],...
            'EMLFileName','hdleml_axistream_out'...
            );


            fifoSize=4;


            obj.getRegisterCacheLogic(hIOIPNet,fifo_data_out,transfer,cache_enb,cache_use,port_tdata);
            InSignals=[fifo_data,fifo_write,fifo_read];
            OutSignals=[fifo_data_out,fifo_empty,fifo_full];
            obj.getStreamingFIFOComp(hIOIPNet,InSignals,OutSignals,fifoSize,sprintf('%s_fifo_data',hElab.TopNetName));


            obj.getRegisterCacheLogic(hIOIPNet,fifo_sof_out,transfer,cache_enb,cache_use,port_tuser);
            InSignals=[fifo_sof,fifo_write,fifo_read];
            OutSignals=fifo_sof_out;
            obj.getStreamingFIFOComp(hIOIPNet,InSignals,OutSignals,fifoSize,sprintf('%s_fifo_sof',hElab.TopNetName),false);


            obj.getRegisterCacheLogic(hIOIPNet,fifo_eol_out,transfer,cache_enb,cache_use,port_tlast);
            InSignals=[fifo_eol,fifo_write,fifo_read];
            OutSignals=fifo_eol_out;
            obj.getStreamingFIFOComp(hIOIPNet,InSignals,OutSignals,fifoSize,sprintf('%s_fifo_eol',hElab.TopNetName),false);




            top_fifo_data_out=hN.addSignal(ufix32Type,'top_fifo_data_out');


            top_fifo_write=hN.addSignal(ufix1Type,'top_fifo_write');
            top_fifo_full=hN.addSignal(ufix1Type,'top_fifo_full');
            top_fifo_sof_out=hN.addSignal(ufix1Type,'top_fifo_sof_out');
            top_fifo_eol_out=hN.addSignal(ufix1Type,'top_fifo_eol_out');
            hElab.connectSignalFrom('fifo_out_write',top_fifo_write);
            hElab.connectSignalTo('fifo_out_full',top_fifo_full);
            hElab.connectSignalFrom('fifo_out_sof',top_fifo_sof_out);
            hElab.connectSignalFrom('fifo_out_eol',top_fifo_eol_out);


            hIPInSignals=[hTopInportSignals,top_fifo_write,top_fifo_data_out,top_fifo_sof_out,top_fifo_eol_out];
            hIPOutSignals=[hTopOutportSignals,top_fifo_full];
            pirelab.instantiateNetwork(hN,hIOIPNet,hIPInSignals,...
            hIPOutSignals,sprintf('%s_vstream_out_inst',hElab.TopNetName));






            portName=obj.hVDMAPort.getAssignedDataPort;


            hDUTPortSignals=hElab.getCodegenPirSignalForPort(portName);
            dutPortSignal=hDUTPortSignals{1};


            pirelab.getDTCComp(hN,dutPortSignal,top_fifo_data_out,'Floor','Wrap','SI');

        end

    end


    methods

    end



    methods

        function generatePCoreMPD(obj,fid,~)


            busPortLabel=obj.BusPortLabel;
            busNameMPD=obj.BusNameMPD;


            fprintf(fid,'## %s\n',obj.InterfaceID);
            fprintf(fid,'BUS_INTERFACE BUS = %s, BUS_STD = AXIS, BUS_TYPE = INITIATOR\n',busNameMPD);
            fprintf(fid,'## Generics for VHDL or Parameters for Verilog\n');
            fprintf(fid,'PARAMETER C_%s_PROTOCOL = GENERIC, DT = STRING, TYPE = NON_HDL, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'## Ports\n');


            fprintf(fid,'PORT %s_TVALID = TVALID, DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TREADY = TREADY, DIR = I, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TDATA = TDATA,   DIR = O, VEC = [31:0], BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TSTRB = TSTRB,   DIR = O, VEC = [3:0],  BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TUSER = TUSER,   DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TLAST = TLAST,   DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'PORT %s_TDEST = TDEST,   DIR = O, BUS = %s\n',busPortLabel,busNameMPD);
            fprintf(fid,'\n');
        end
    end

end








