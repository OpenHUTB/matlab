


classdef InterruptBase<hdlturnkey.interface.InterfaceIOBase


    properties
        EnableAddr=4;
        ClearAddr=5;
        StatusAddr=6;
        ActiveLow=true;
    end

    methods(Abstract)
        hInterface=getBusInterface(obj,hElab);
    end

    methods

        function obj=InterruptBase(varargin)

            p=inputParser;
            p.addParameter('ActiveLow',true);
            p.addParameter('InterfaceID','Interrupt From FPGA');

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj=obj@hdlturnkey.interface.InterfaceIOBase(...
            inputArgs.InterfaceID,...
            'OUT',...
            1);


            obj.ActiveLow=inputArgs.ActiveLow;


            obj.InportNames={};
            obj.InportWidths={};
            if obj.ActiveLow
                obj.OutportNames={'INTA_n'};
            else
                obj.OutportNames={'INTA'};
            end
            obj.OutportWidths={1};

        end

    end


    methods

    end


    methods

        function result=showInInterfaceChoice(~,hTurnkey)




            result=~hTurnkey.isCoProcessorMode;
        end

        function validatePortForInterface(obj,hIOPort,hTableMap)



            portWidth=hIOPort.WordLength;
            interfaceWidth=obj.ChannelWidth;
            if portWidth>interfaceWidth
                error(message('hdlcommon:workflow:BitWidthNotFit',obj.InterfaceID,obj.ChannelWidth,hIOPort.PortName,portWidth));
            end

            hTurnkey=hTableMap.hTable.hTurnkey;

            if hTurnkey.isCoProcessorMode
                currentMode=hTurnkey.hD.get('ExecutionMode');
                freerunMode=hTurnkey.hExecMode.FreeRun;
                copModeMsg=message('HDLShared:hdldialog:HDLWAInputFPGAExecutionModeStr');
                copModeName=copModeMsg.getString;
                error(message('hdlcommon:workflow:CopNotSupported',...
                obj.InterfaceID,currentMode,copModeName,freerunMode));
            end

        end

    end


    methods

    end


    methods

    end


    methods

        function registerAddress(obj,hElab)



            hInterface=obj.getBusInterface(hElab);
            if isempty(hInterface)
                return;
            end
            hBaseAddr=hInterface.hBaseAddr;


            hBaseAddr.registerAddress(obj.EnableAddr,hdlturnkey.data.AddrType.INTENB,'IntEnb');


            hBaseAddr.registerAddress(obj.ClearAddr,hdlturnkey.data.AddrType.INTCLR,'IntClr');


            hBaseAddr.registerAddress(obj.StatusAddr,hdlturnkey.data.AddrType.INTSTA,'IntSta',hdlturnkey.IOType.OUT);

        end

        function elaborate(obj,hN,hElab)



            if hElab.hTurnkey.hTable.hTableMap.isAssignedInterface(obj.InterfaceID)

                hInterfaceSignal=obj.addInterfacePort(hN);

                hIPSignals=obj.elaborateIOIP(hN,hElab,hInterfaceSignal);


                obj.connectInterfacePort(hN,hElab,hIPSignals);
            else

                hInterfaceSignal=obj.addInterfacePort(hN);

                int_out=hInterfaceSignal.hOutportSignals;
                ufix1Type=pir_ufixpt_t(1,0);
                const_1=hN.addSignal(ufix1Type,'const_1');
                pirelab.getConstComp(hN,const_1,1);
                pirelab.getWireComp(hN,const_1,int_out);
            end

        end

        function hIPSignals=elaborateIOIP(obj,hN,hElab,hInterfaceSignal)



            ufix1Type=pir_ufixpt_t(1,0);
            interrupt_in=hN.addSignal(ufix1Type,'interrupt_in');
            interrupt_enb=hN.addSignal(ufix1Type,'interrupt_enb');
            interrupt_clr=hN.addSignal(ufix1Type,'interrupt_clr');
            interrupt_sta=hN.addSignal(ufix1Type,'interrupt_sta');

            hInportSignals=hInterfaceSignal.hInportSignals;
            hOutportSignals=hInterfaceSignal.hOutportSignals;


            hIntNet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_interrupt',hElab.TopNetName)...
            );


            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hIntNet,...
            'InportNames',[obj.InportNames,{'int_in','int_enb','int_clr'}],...
            'InportWidths',[obj.InportWidths,{1,1,1}],...
            'OutportNames',[obj.OutportNames,{'int_sta'}],...
            'OutportWidths',[obj.OutportWidths,{1}]);

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;

            int_in=hIPInportSignals(1);
            int_enb=hIPInportSignals(2);
            int_clr=hIPInportSignals(3);
            int_out=hIPOutportSignals(1);
            int_sta=hIPOutportSignals(2);



            edge_detect=hIntNet.addSignal(ufix1Type,'edge_detect');
            pirtarget.getRisingEdgeDetectionComp(hIntNet,int_in,edge_detect);


            int_enb_gate=hIntNet.addSignal(ufix1Type,'int_enb_gate');
            pirelab.getBitwiseOpComp(hIntNet,[edge_detect,int_enb],int_enb_gate,'AND');


            int_or=hIntNet.addSignal(ufix1Type,'int_or');
            int_reg=hIntNet.addSignal(ufix1Type,'int_reg');
            pirelab.getBitwiseOpComp(hIntNet,[int_reg,int_enb_gate],int_or,'OR');
            pirelab.getUnitDelayResettableComp(hIntNet,int_or,int_reg,int_clr,'int_reset',0,false,true);


            if obj.ActiveLow

                int_not=hIntNet.addSignal(ufix1Type,'int_not');
                pirelab.getBitwiseOpComp(hIntNet,int_reg,int_not,'NOT');


                pirelab.getUnitDelayComp(hIntNet,int_not,int_out);

            else
                pirelab.getWireComp(hIntNet,int_reg,int_out);
            end


            pirelab.getWireComp(hIntNet,int_reg,int_sta);


            hIPInSignals=[hInportSignals,interrupt_in,interrupt_enb,interrupt_clr];
            hIPOutSignals=[hOutportSignals,interrupt_sta];
            pirelab.instantiateNetwork(hN,hIntNet,hIPInSignals,...
            hIPOutSignals,sprintf('%s_interrupt_inst',hElab.TopNetName));


            hIPSignals.hInportSignals=[];
            hIPSignals.hOutportSignals=interrupt_in;



            hInterface=obj.getBusInterface(hElab);
            if isempty(hInterface)
                return;
            end


            hBaseAddr=hInterface.hBaseAddr;

            hAddr=hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.INTENB);
            hAddr.assignScheduledElab(interrupt_enb,hdlturnkey.data.DecoderType.WRITE)

            hAddr=hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.INTCLR);
            hAddr.assignScheduledElab(interrupt_clr,hdlturnkey.data.DecoderType.STROBE)

            hAddr=hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.INTSTA);
            hAddr.assignScheduledElab(interrupt_sta,hdlturnkey.data.DecoderType.READ)

        end

    end


    methods

    end
end


