


classdef ProtocolLayer<handle




    properties


    end

    properties


        hElab=[];

    end

    properties(Access=private)


    end

    methods

        function obj=ProtocolLayer(hElab)


            obj.hElab=hElab;

        end

        function elaborateProtocolLayer(obj,hN)



            hDI=obj.hElab.hTurnkey.hD;

            if hDI.isxPCTargetBoard||hDI.isIPCoreGen

                if hDI.hTurnkey.hStream.isAXI4VDMAMode
                    hDUTEnb=elaborateStreamControllerNetwork(obj,hN);
                    elaborateVDMAControllerNetwork(obj,hN,hDUTEnb);

                elseif hDI.hTurnkey.isCoProcessorMode

                    elaborateCoProcessorControllerNetwork(obj,hN);

                else


                    wireDUTEnableDirectly(obj,hN);
                end


                if(obj.hElab.hTurnkey.hD.hIP.getDUTCEOut)

                    ce_outList=obj.hElab.hDUTLayer.getCodegenIOPortList.CEOutPortNameList;
                    for i=1:length(ce_outList)
                        DUTCEOutName=sprintf('dut_%s',ce_outList{i});
                        ufix1Type=pir_ufixpt_t(1,0);
                        hDUTCEOut=hN.addSignal(ufix1Type,DUTCEOutName);
                        hN.addOutputPort(DUTCEOutName);
                        hDUTCEOut.addReceiver(hN,hN.NumberOfPirOutputPorts-1);
                        hDUTCEOutSignal=obj.hElab.getCodegenPirSignal(ce_outList{i});
                        obj.hElab.setInternalSignal(DUTCEOutName,hDUTCEOut);
                        pirelab.getWireComp(hN,hDUTCEOutSignal,hDUTCEOut);
                    end
                end
            end
        end

        function registerAddressAuto(obj)



















            hDI=obj.hElab.hTurnkey.hD;

            if hDI.isxPCTargetBoard||hDI.isIPCoreGen

                if obj.hElab.hTurnkey.hStream.isAXI4VDMAMode



                    default_num_of_col=1920;
                    default_num_of_row=1080;

                    hBus=obj.hElab.getDefaultBusInterface;
                    hBaseAddr=hBus.hBaseAddr;


                    hAddr=hBaseAddr.registerAddressAuto('vdma_num_of_col',...
                    hdlturnkey.data.AddrType.ELAB);
                    hAddr.InitValue=default_num_of_col;
                    hAddr.DescName='IPCore_NumOfColumn';
                    hAddr.Description='video size, number of column, by default 1920';


                    hAddr=hBaseAddr.registerAddressAuto('vdma_num_of_row',...
                    hdlturnkey.data.AddrType.ELAB);
                    hAddr.InitValue=default_num_of_row;
                    hAddr.DescName='IPCore_NumOfRow';
                    hAddr.Description='video size, number of row, by default 1080';
                elseif obj.hElab.hTurnkey.isCoProcessorMode

                    hBus=obj.hElab.getDefaultBusInterface;
                    hBaseAddr=hBus.hBaseAddr;


                    hAddr=hBaseAddr.registerAddressAuto('cop_in_strobe',...
                    hdlturnkey.data.AddrType.ELAB);
                    hAddr.DescName='IPCore_Strobe';
                    hAddr.Description='write 1 to bit 0 after write all input data';

                    hAddr=hBaseAddr.registerAddressAuto('cop_out_ready',...
                    hdlturnkey.data.AddrType.ELAB,hdlturnkey.IOType.OUT);
                    hAddr.DescName='IPCore_Ready';
                    hAddr.Description='wait until bit 0 is 1 before read output data';
                end

            end
        end

    end

    methods(Access=protected,Hidden=true)

        function hDUTEnb=elaborateStreamControllerNetwork(obj,hN)



            ufix1Type=pir_ufixpt_t(1,0);
            fifo_in_read=hN.addSignal(ufix1Type,'fifo_in_read');
            fifo_in_empty=hN.addSignal(ufix1Type,'fifo_in_empty');
            fifo_out_write=hN.addSignal(ufix1Type,'fifo_out_write');
            fifo_out_full=hN.addSignal(ufix1Type,'fifo_out_full');

            obj.hElab.setInternalSignal('fifo_in_read',fifo_in_read);
            obj.hElab.setInternalSignal('fifo_in_empty',fifo_in_empty);
            obj.hElab.setInternalSignal('fifo_out_write',fifo_out_write);
            obj.hElab.setInternalSignal('fifo_out_full',fifo_out_full);


            extra_delay=obj.hElab.hDUTLayer.DUTExtraDelayNumber;


            hDUTEnb=hN.addSignal(ufix1Type,'dut_enable');
            hCNTEnb=hN.addSignal(ufix1Type,'cnt_enable');
            hEndStream=hN.addSignal(ufix1Type,'end_of_stream');
            topInSignals=[fifo_in_empty,fifo_out_full,hEndStream];
            topOutSignals=[fifo_in_read,fifo_out_write,hDUTEnb,hCNTEnb];
            hPirInstance=obj.hElab.BoardPirInstance;
            networkName=sprintf('%s_sctrl',obj.hElab.TopNetName);
            hStreamNet=pirtarget.getStreamControllerNetwork(...
            hN,topInSignals,topOutSignals,hPirInstance,networkName,extra_delay);


            pirelab.instantiateNetwork(hN,hStreamNet,topInSignals,topOutSignals,...
            sprintf('%s_sctrl_inst',obj.hElab.TopNetName));

            if~obj.hElab.hDUTLayer.isCombinationalLogic


                obj.hElab.connectSignalTo('dut_enable',hDUTEnb);
            end


            obj.hElab.setInternalSignal('end_of_stream',hEndStream);
            obj.hElab.setInternalSignal('cnt_enable',hCNTEnb);

        end

        function elaborateVDMAControllerNetwork(obj,hN,hDUTEnb)



            ufix1Type=pir_ufixpt_t(1,0);
            ufix11Type=pir_ufixpt_t(11,0);
            fifo_in_sof=hN.addSignal(ufix1Type,'fifo_in_sof');
            fifo_in_eol=hN.addSignal(ufix1Type,'fifo_in_eol');
            fifo_out_sof=hN.addSignal(ufix1Type,'fifo_out_sof');
            fifo_out_eol=hN.addSignal(ufix1Type,'fifo_out_eol');

            obj.hElab.setInternalSignal('fifo_in_sof',fifo_in_sof);
            obj.hElab.setInternalSignal('fifo_in_eol',fifo_in_eol);
            obj.hElab.setInternalSignal('fifo_out_sof',fifo_out_sof);
            obj.hElab.setInternalSignal('fifo_out_eol',fifo_out_eol);


            extra_delay=obj.hElab.hDUTLayer.DUTExtraDelayNumber;


            vdma_num_of_col=hN.addSignal(ufix11Type,'vdma_num_of_col');
            vdma_num_of_row=hN.addSignal(ufix11Type,'vdma_num_of_row');




            hBus=obj.hElab.getDefaultBusInterface;


            hAddr=hBus.getBaseAddrWithName('vdma_num_of_col');
            hAddr.assignScheduledElab(vdma_num_of_col,hdlturnkey.data.DecoderType.WRITE)


            hAddr=hBus.getBaseAddrWithName('vdma_num_of_row');
            hAddr.assignScheduledElab(vdma_num_of_row,hdlturnkey.data.DecoderType.WRITE)


            hEndStream=obj.hElab.getInternalSignal('end_of_stream');
            hCNTEnb=obj.hElab.getInternalSignal('cnt_enable');
            topInSignals=[hDUTEnb,hCNTEnb,vdma_num_of_col,vdma_num_of_row];
            topOutSignals=[fifo_out_sof,fifo_out_eol,hEndStream];
            hPirInstance=obj.hElab.BoardPirInstance;
            networkName=sprintf('%s_vsctrl',obj.hElab.TopNetName);
            hStreamNet=pirtarget.getVDMAControllerNetwork(...
            hN,topInSignals,topOutSignals,hPirInstance,networkName,...
            extra_delay);


            pirelab.instantiateNetwork(hN,hStreamNet,topInSignals,topOutSignals,...
            sprintf('%s_vsctrl_inst',obj.hElab.TopNetName));

        end

        function elaborateCoProcessorControllerNetwork(obj,hN)


            ufix1Type=pir_ufixpt_t(1,0);
            hInStrobe=hN.addSignal(ufix1Type,'cop_in_strobe');
            hOutReady=hN.addSignal(ufix1Type,'cop_out_ready');
            hCOPEnb=hN.addSignal(ufix1Type,'cop_enable');
            hDUTEnb=hN.addSignal(ufix1Type,'cop_dut_enable');
            hRegStb=hN.addSignal(ufix1Type,'cop_reg_strobe');


            cntCycle=calculateCoProcessorCycleNumber(obj);
            cntLimitBitWidth=floor(log2(cntCycle))+1;
            cntLimitFi=fi(cntCycle,0,cntLimitBitWidth,0,hdlfimath);


            topInSignals=[hInStrobe,hCOPEnb];
            topOutSignals=[hOutReady,hDUTEnb,hRegStb];
            hPir=obj.hElab.BoardPirInstance;
            networkName=sprintf('%s_cop',obj.hElab.TopNetName);
            pirtarget.getCoprocessorControllerNetwork(...
            hN,hPir,topInSignals,topOutSignals,networkName,cntLimitFi);




            hBus=obj.hElab.getDefaultBusInterface;


            hStrobeAddr=hBus.getBaseAddrWithName('cop_in_strobe');

            hReadyAddr=hBus.getBaseAddrWithName('cop_out_ready');


            hStrobeAddr.assignScheduledElab(hInStrobe,hdlturnkey.data.DecoderType.STROBE)

            hReadyAddr.assignScheduledElab(hOutReady,hdlturnkey.data.DecoderType.READ)


            scheduleBusEnableSignal(obj,hN,hCOPEnb);

            if obj.hElab.hDUTLayer.isCombinationalLogic





                obj.hElab.setInternalSignal('cop_reg_strobe',hRegStb);

            else






                obj.hElab.setInternalSignal('cop_reg_strobe',hInStrobe);



                obj.hElab.connectSignalTo('dut_enable',hDUTEnb);
            end

        end

        function copCycle=calculateCoProcessorCycleNumber(obj)





            allportRate=0;
            hDUTL=obj.hElab.hDUTLayer;
            for ii=1:length(hDUTL.DUTInportNames)
                portName=hDUTL.DUTInportNames{ii};
                hIOPort=hDUTL.getCodegenIOPort(portName);
                portRate=hIOPort.PortRate;
                allportRate=validatePortRate(obj,portName,portRate,allportRate);
            end
            for ii=1:length(hDUTL.DUTOutportNames)
                portName=hDUTL.DUTOutportNames{ii};
                hIOPort=hDUTL.getCodegenIOPort(portName);
                portRate=hIOPort.PortRate;
                allportRate=validatePortRate(obj,portName,portRate,allportRate);
            end


            dutBaseRate=hDUTL.DUTOrigBaseRate;
            codegenRateScaling=hDUTL.CodegenRateScaling;


            baseRateScaling=allportRate/dutBaseRate;



            copCycle=baseRateScaling*codegenRateScaling;

        end

        function allportRate=validatePortRate(~,portName,portRate,allportRate)
            if portRate<=0
                error(message('hdlcommon:workflow:InvalidPortRate',...
                sprintf('%g',portRate),portName));
            end
            if allportRate==0
                allportRate=portRate;
            else
                if allportRate~=portRate
                    error(message('hdlcommon:workflow:MismatchPortRate',portName));
                end
            end
        end

        function wireDUTEnableDirectly(obj,hN)




            [interfaceNeedDutEnbWiring,dut_enb_signal]=obj.runInterfaceSpecificDUTEnableConnection(hN);



            if obj.hElab.hDUTLayer.isCombinationalLogic

                return;
            end


            if interfaceNeedDutEnbWiring


                ufix1Type=pir_ufixpt_t(1,0);
                axi_enable=hN.addSignal(ufix1Type,'axi_enable');
                scheduleBusEnableSignal(obj,hN,axi_enable);


                hDUTEnbSignal=obj.hElab.getInternalSignal('dut_enable');
                pirelab.getBitwiseOpComp(hN,[axi_enable,dut_enb_signal],hDUTEnbSignal,'AND');

            else

                hDUTEnbSignal=obj.hElab.getInternalSignal('dut_enable');


                scheduleBusEnableSignal(obj,hN,hDUTEnbSignal);

            end
        end

        function scheduleBusEnableSignal(obj,hN,hEnbSignal)

            hBus=obj.hElab.getDefaultBusInterface;

            if(hBus.isEmptyAXI4SlaveInterface)



                if(obj.hElab.hTurnkey.hD.hIP.getDUTClockEnable)

                    DUTClkEnableName='dut_clk_enable';
                    ufix1Type=pir_ufixpt_t(1,0);
                    hDUTClkEnable=hN.addSignal(ufix1Type,DUTClkEnableName);
                    hN.addInputPort(DUTClkEnableName);
                    hDUTClkEnable.addDriver(hN,hN.NumberOfPirInputPorts-1);
                    hDUTEnbSignal=obj.hElab.getInternalSignal('dut_enable');
                    pirelab.getWireComp(hN,hDUTClkEnable,hDUTEnbSignal);
                else

                    pirelab.getConstComp(hN,hEnbSignal,1);
                end
            else

                hAddr=hBus.hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.ENABLE);
                if~isempty(hAddr)
                    hAddr.assignScheduledElab(hEnbSignal,hdlturnkey.data.DecoderType.WRITE);
                end
            end

        end

        function[needDutEnbWiring,dut_enb_signal]=runInterfaceSpecificDUTEnableConnection(obj,hN)




            needDutEnbWiring=false;
            dut_enb_signal=[];
            interfaceIDList=obj.hElab.hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hElab.hTurnkey.getInterface(interfaceID);

                if(hInterface.isInterfaceInUse(obj.hElab.hTurnkey))

                    [isNeeded,dut_enb_signal_from_interface]=...
                    hInterface.scheduleDUTEnableWiring(hN,obj.hElab);
                    if isNeeded
                        needDutEnbWiring=true;




                        if obj.hElab.hDUTLayer.MinimizeClkEnableActive
                            error(message('hdlcommon:workflow:MinClkNtSuppFrAXI4Stream',interfaceID));
                        end

                        if isempty(dut_enb_signal)
                            dut_enb_signal=dut_enb_signal_from_interface;
                        else

                            ufix1Type=pir_ufixpt_t(1,0);
                            dut_enb_signal_out=hN.addSignal(ufix1Type,'dut_enable_signal');
                            pirelab.getBitwiseOpComp(hN,...
                            [dut_enb_signal,dut_enb_signal_from_interface],dut_enb_signal_out,'AND');
                            dut_enb_signal=dut_enb_signal_out;
                        end
                    end
                end
            end
        end
    end


end



