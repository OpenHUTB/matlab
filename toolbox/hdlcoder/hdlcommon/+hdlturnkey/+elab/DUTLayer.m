


classdef DUTLayer<handle





    properties


        DUTCompName='';


        DUTOrigBaseRate=0;
        CodegenRateScaling=1;
        DUTClockReportData=[];
        DUTExtraDelayNumber=0;


        DUTInportNames={};
        DUTOutportNames={};


        MinimizeClkEnableActive;

    end

    properties(Access=private)


        hCodegenIOPortList=[];


        hModelIOToCodegenIOMap=[];


        hIOPortToSignalMap=[];


        hElab=[];

    end

    methods

        function obj=DUTLayer(hElab)


            obj.hElab=hElab;

        end

        function elaborateDUTLayer(obj,hN)



            hDI=obj.hElab.hTurnkey.hD;
            obj.MinimizeClkEnableActive=false;


            if hDI.isxPCTargetBoard||hDI.isIPCoreGen

                if hDI.isxPCTargetBoard

                    enbPortName='pci_enable';
                else
                    enbPortName='dut_enable';
                end


                elaborateEnabledDUTNetwork(obj,hN,enbPortName);
            else

                elaborateDUTInstantiationComp(obj,hN);
            end
        end

        function getDUTCodeGenPIRInfo(obj)

            hDI=obj.hElab.hTurnkey.hD;

            obj.hCodegenIOPortList=hdlturnkey.data.IOPortList;


            p=pir;
            obj.DUTCompName=p.getTopNetwork.Name;
            obj.hCodegenIOPortList.buildIOPortList(p,hDI);





            if obj.hElab.hTurnkey.hStream.isFrameToSampleMode
                obj.hCodegenIOPortList.modifyIOPortList(p);
                hStreamCell=obj.hElab.hTurnkey.hStream.getAssignedAXI4StreamInterface;
                for ii=1:length(hStreamCell)
                    hInterface=hStreamCell{ii};
                    if hInterface.isFrameToSample
                        hInterface.modifySubPortsForFrameToSample(obj.hCodegenIOPortList);
                    end
                end
            end


            obj.hModelIOToCodegenIOMap=hdlturnkey.elab.ModelCodegenIOMultiMap;

            modelIOPortList=obj.hElab.hTurnkey.hTable.hIOPortList;
            obj.hModelIOToCodegenIOMap.buildModelIOToCodegenIOMap(modelIOPortList,obj.hCodegenIOPortList,p,obj.hElab.hTurnkey);


            obj.DUTOrigBaseRate=p.getOrigDutBaseRate;
            obj.CodegenRateScaling=p.getDutBaseRateScalingFactor;
            obj.DUTClockReportData=p.getClockReportData;


            obj.DUTExtraDelayNumber=0;
            if p.isDelayBalancable
                hN=p.getTopNetwork;
                outs=hN.NumberOfPirOutputPorts;
                if outs>0


                    obj.DUTExtraDelayNumber=p.getDutExtraLatency(0);
                end
            else




            end



            hTurnkey=obj.hElab.hTurnkey;
            if hTurnkey.hD.isIPCoreGen
                dutST=p.getDutSampleTimes;
                dutST=dutST(dutST>0);
                dutST=dutST(dutST~=Inf);
                if hTurnkey.hStream.isAXI4VDMAMode


                    if length(dutST)>1
                        error(message('hdlcommon:workflow:StreamSingleRate'));
                    end
                end
            end
        end

        function hIOPort=getCodegenIOPort(obj,portName)

            hIOPort=obj.hCodegenIOPortList.getIOPort(portName);
        end

        function hCodegenIOPortList=getCodegenIOPortList(obj)
            hCodegenIOPortList=obj.hCodegenIOPortList;
        end

        function status=isCombinationalLogic(obj)




            status=~isempty(obj.hCodegenIOPortList)&&...
            (obj.hCodegenIOPortList.NumClock==0||...
            obj.hCodegenIOPortList.NumClockEnb==0);
        end

        function codegenPortNames=getCodegenPortNameList(obj,modelPortName)





            codegenPortNames=obj.hModelIOToCodegenIOMap.getCodegenPortNameList(modelPortName);
        end

        function codegenPortName=getCodegenPortNameFromAddrFlattenedPortName(obj,addrFlattenedPortName)





            codegenPortName=obj.hModelIOToCodegenIOMap.getCodegenPortNameFromAddrFlattenedPortName(addrFlattenedPortName);
        end

        function codegenPortSignal=getCodegenPirSignal(obj,codegenPortName)


            codegenPortSignal=obj.hIOPortToSignalMap(codegenPortName);
        end

        function codegenPortSignals=getCodegenPirSignalForPort(obj,modelPortName)


            codegenPortNames=getCodegenPortNameList(obj,modelPortName);
            dimLen=length(codegenPortNames);
            codegenPortSignals=cell(dimLen,1);
            for ii=1:dimLen
                codegenPortSignals{ii}=getCodegenPirSignal(obj,codegenPortNames{ii});
            end
        end

        function status=isClockInDUT(obj)

            status=(obj.hCodegenIOPortList.NumClock>0);
        end

        function status=isResetInDUT(obj)

            status=(obj.hCodegenIOPortList.NumReset>0);
        end

    end

    methods(Access=protected,Hidden=true)

        function elaborateDUTInstantiationComp(obj,hN)





            obj.hIOPortToSignalMap=containers.Map();

            obj.DUTInportNames={};
            hInSignals=handle([]);

            for ii=1:length(obj.hCodegenIOPortList.InputPortNameList)
                portName=obj.hCodegenIOPortList.InputPortNameList{ii};
                hIOPort=obj.hCodegenIOPortList.getIOPort(portName);
                if~isClockPorts(obj,hIOPort)
                    obj.DUTInportNames{end+1}=portName;%#ok<*AGROW>
                    hNewSig=hIOPort.addPirSignal(hN);
                    hInSignals(end+1)=hNewSig;




                    obj.hIOPortToSignalMap(portName)=hNewSig;
                end
            end

            outputPortLength=length(obj.hCodegenIOPortList.OutputPortNameList);
            obj.DUTOutportNames=cell(outputPortLength,1);
            hOutSignals=hdlhandles(outputPortLength,1);

            for ii=1:outputPortLength
                portName=obj.hCodegenIOPortList.OutputPortNameList{ii};
                hIOPort=obj.hCodegenIOPortList.getIOPort(portName);
                obj.DUTOutportNames{ii}=portName;
                hNewSig=hIOPort.addPirSignal(hN);
                hOutSignals(ii)=hNewSig;




                obj.hIOPortToSignalMap(portName)=hNewSig;
            end


            if obj.hCodegenIOPortList.NumClock==0
                addClockPort='off';
            else
                addClockPort='on';
            end

            if obj.hCodegenIOPortList.NumClockEnb==0
                addClockEnablePort='off';
            else
                addClockEnablePort='on';
            end

            if obj.hCodegenIOPortList.NumReset==0
                addResetPort='off';
            else
                addResetPort='on';
            end


            hBlackBoxC=pirelab.getInstantiationComp(...
            'Network',hN,...
            'Name',obj.DUTCompName,...
            'InportNames',obj.DUTInportNames,...
            'OutportNames',obj.DUTOutportNames,...
            'InportSignals',hInSignals,...
            'OutportSignals',hOutSignals,...
            'AddClockPort',addClockPort,...
            'AddClockEnablePort',addClockEnablePort,...
            'AddResetPort',addResetPort,...
            'ClockInputPort',hdlgetparameter('clockname'),...
            'ClockEnableInputPort',hdlgetparameter('clockenablename'),...
            'ResetInputPort',hdlgetparameter('resetname'));


            hasBidirectional=false;

            for ii=1:length(obj.DUTInportNames)
                codegenPortName=obj.DUTInportNames{ii};
                hCodegenIOPort=obj.hCodegenIOPortList.getIOPort(codegenPortName);
                if hCodegenIOPort.Bidirectional
                    hasBidirectional=true;

                    obj.validateIPCoreGenInterface(codegenPortName);
                    hBlackBoxC.setInPortBidirectional((ii-1),hCodegenIOPort.Bidirectional);
                end
            end
            for ii=1:length(obj.DUTOutportNames)
                codegenPortName=obj.DUTOutportNames{ii};
                hCodegenIOPort=obj.hCodegenIOPortList.getIOPort(codegenPortName);
                if hCodegenIOPort.Bidirectional
                    hasBidirectional=true;

                    obj.validateIPCoreGenInterface(codegenPortName);
                    hBlackBoxC.setOutPortBidirectional((ii-1),hCodegenIOPort.Bidirectional);
                end
            end

            if hasBidirectional
                if~obj.hElab.hTurnkey.hD.isTurnkeyWorkflow&&~obj.hElab.hTurnkey.hD.isIPCoreGen


                    workflowName=obj.hElab.hTurnkey.hD.get('Workflow');
                    error(message('hdlcommon:workflow:BidiSupport',workflowName));
                elseif obj.hElab.hTurnkey.hD.isIPCoreGen&&obj.hElab.hTurnkey.hD.isISE


                    error(message('hdlcommon:workflow:BidiXilISE'));
                end
            end

        end

        function validateIPCoreGenInterface(obj,codegenPortName)


            if obj.hElab.hTurnkey.hD.isIPCoreGen
                modelPortName=obj.hModelIOToCodegenIOMap.getModelPortName(codegenPortName);
                hInterface=obj.hElab.hTurnkey.hTable.hTableMap.getInterface(modelPortName);



                if~(hInterface.isIPInterface&&hInterface.isIPExternalInterface...
                    &&~hInterface.isIPExternalIOInterface)
                    interfaceStr=hInterface.getTableCellInterfaceStr(modelPortName);


                    error(message('hdlcommon:workflow:BidiIPCoreGen',interfaceStr,modelPortName));
                end
            end
        end

        function elaborateEnabledDUTNetwork(obj,hN,enbPortName)









            hDUTNet=pirelab.createNewNetwork(...
            'PirInstance',obj.hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_dut',obj.hElab.TopNetName)...
            );


            elaborateDUTInstantiationComp(obj,hDUTNet);
            hDUTCompIOPortToSignalMap=obj.hIOPortToSignalMap;



            obj.hIOPortToSignalMap=containers.Map();


            hDUTNetInSignals=handle([]);






            if obj.hCodegenIOPortList.NumClockEnb>0


                ufix1Type=pir_ufixpt_t(1,0);
                hEnbSignal=hN.addSignal(ufix1Type,enbPortName);
                hDUTNetInSignals(end+1)=hEnbSignal;
                obj.hIOPortToSignalMap(enbPortName)=hEnbSignal;


                hDUTNet.addInputPort(enbPortName);
                hDUTNetEnbSignal=hDUTNet.addSignal(ufix1Type,enbPortName);
                hDUTNetEnbSignal.addDriver(hDUTNet,hDUTNet.NumberOfPirInputPorts-1);


                [~,clkenb,~]=hDUTNet.getClockBundle(hEnbSignal,1,1,0);


                pirelab.getWireComp(hDUTNet,hDUTNetEnbSignal,clkenb);



                obj.hElab.setInternalSignal('dut_enable',hEnbSignal);

            else














                if(obj.hCodegenIOPortList.NumClock>0)













                    obj.MinimizeClkEnableActive=true;


                    if(obj.hElab.hTurnkey.isCoProcessorMode)
                        error(message('hdlcommon:workflow:MinClkNtSuppFrCoprocess'));
                    end
                end
            end

            inputPortLength=length(obj.DUTInportNames);
            for ii=1:inputPortLength
                portName=obj.DUTInportNames{ii};

                hDUTNet.addInputPort(portName);
                hDUTSig=hDUTCompIOPortToSignalMap(portName);
                hDUTSig.addDriver(hDUTNet,hDUTNet.NumberOfPirInputPorts-1);

                hIOPort=obj.hCodegenIOPortList.getIOPort(portName);
                hTopNewSig=hIOPort.addPirSignal(hN);
                hDUTNetInSignals(end+1)=hTopNewSig;

                obj.hIOPortToSignalMap(portName)=hTopNewSig;

            end


            outputPortLength=length(obj.DUTOutportNames);
            hDUTNetOutSignals=hdlhandles(outputPortLength,1);

            for ii=1:outputPortLength
                portName=obj.DUTOutportNames{ii};

                hDUTNet.addOutputPort(portName);
                hDUTSig=hDUTCompIOPortToSignalMap(portName);
                hDUTSig.addReceiver(hDUTNet,hDUTNet.NumberOfPirOutputPorts-1);

                hIOPort=obj.hCodegenIOPortList.getIOPort(portName);
                hTopNewSig=hIOPort.addPirSignal(hN);
                hDUTNetOutSignals(ii)=hTopNewSig;

                obj.hIOPortToSignalMap(portName)=hTopNewSig;
            end


            pirelab.instantiateNetwork(hN,hDUTNet,hDUTNetInSignals,...
            hDUTNetOutSignals,sprintf('%s_dut_inst',obj.hElab.TopNetName));

        end

        function isClockPort=isClockPorts(~,hIOPort)
            portKind=hIOPort.PortKind;
            isClockPort=...
            strcmpi(portKind,'clock')||...
            strcmpi(portKind,'reset')||...
            strcmpi(portKind,'clock_enable');
        end

        function isEnbPort=isEnbPort(~,hIOPort)
            portKind=hIOPort.PortKind;
            isEnbPort=strcmpi(portKind,'clock_enable');
        end

    end


end



