classdef IPTestbenchLayer<handle

    properties


        IPCoreCompName=[];


        IPCoreOrigBaseRate=0;
        IPCoreCodegenRateScaling=1;
        IPCoreExtraDelayNumber=0;


        IPCoreInportNames={};
        IPCoreOutportNames={};
    end

    properties(Access=private)


        hIPCoreGenIOPortList=[];

        hModelIOToCodegenIOMap=[];


        hIOPortToSignalMap=[];


        hIPTestbenchElab=[];
    end

    methods

        function obj=IPTestbenchLayer(hIPTestbenchElab)
            obj.hIPTestbenchElab=hIPTestbenchElab;
        end

        function getIPCoreCodeGenPIRInfo(obj)

            hDI=obj.hIPTestbenchElab.hIPTB.hIP.hD;

            obj.hIPCoreGenIOPortList=hdlturnkey.data.IOPortList;


            p=pir;
            obj.IPCoreCompName=p.getTopNetwork.Name;
            obj.hIPCoreGenIOPortList.buildIOPortList(p,hDI);


            obj.IPCoreOrigBaseRate=p.getOrigDutBaseRate;
            obj.IPCoreCodegenRateScaling=p.getDutBaseRateScalingFactor;
        end

        function elaborateIPTestbenchLayer(obj,hN)



            obj.hIOPortToSignalMap=containers.Map();

            obj.IPCoreInportNames={};
            hInSignals=handle([]);

            for ii=1:length(obj.hIPCoreGenIOPortList.InputPortNameList)
                portName=obj.hIPCoreGenIOPortList.InputPortNameList{ii};
                hIOPort=obj.hIPCoreGenIOPortList.getIOPort(portName);
                if~isClockPorts(obj,hIOPort)
                    obj.IPCoreInportNames{end+1}=portName;%#ok<*AGROW>
                    hNewSig=hIOPort.addPirSignal(hN);
                    hInSignals(end+1)=hNewSig;

                    obj.hIOPortToSignalMap(portName)=hNewSig;
                end
            end

            outputPortLength=length(obj.hIPCoreGenIOPortList.OutputPortNameList);
            obj.IPCoreOutportNames=cell(outputPortLength,1);
            hOutSignals=hdlhandles(outputPortLength,1);

            for ii=1:outputPortLength
                portName=obj.hIPCoreGenIOPortList.OutputPortNameList{ii};
                hIOPort=obj.hIPCoreGenIOPortList.getIOPort(portName);
                obj.IPCoreOutportNames{ii}=portName;
                hNewSig=hIOPort.addPirSignal(hN);
                hOutSignals(ii)=hNewSig;

                obj.hIOPortToSignalMap(portName)=hNewSig;
            end


            if obj.hIPCoreGenIOPortList.NumClock==0
                addClockPort='off';
            else
                addClockPort='on';
            end

            if obj.hIPCoreGenIOPortList.NumClockEnb==0
                addClockEnablePort='off';
            else
                addClockEnablePort='on';
            end

            if obj.hIPCoreGenIOPortList.NumReset==0
                addResetPort='off';
            else
                addResetPort='on';
            end


            hBlackBoxC=pirelab.getInstantiationComp(...
            'Network',hN,...
            'Name',obj.IPCoreCompName,...
            'InportNames',obj.IPCoreInportNames,...
            'OutportNames',obj.IPCoreOutportNames,...
            'InportSignals',hInSignals,...
            'OutportSignals',hOutSignals,...
            'AddClockPort',addClockPort,...
            'AddClockEnablePort',addClockEnablePort,...
            'AddResetPort',addResetPort,...
            'ClockInputPort',hdlgetparameter('clockname'),...
            'ClockEnableInputPort',hdlgetparameter('clockenablename'),...
            'ResetInputPort',hdlgetparameter('resetname'),...
            'VHDLArchitectureName',hdlgetparameter('vhdl_architecture_name'));


            createPortsForIPTestbench(obj,hInSignals,hOutSignals,hN);
        end

        function createPortsForIPTestbench(~,inData,outData,topN)

            [clk,clk_enb,clk_rst]=topN.getClockBundle(inData(1),1,1,0);

            h_enbn=topN.addSignal(pir_ufixpt_t(1,0),'enable_n');
            pirelab.getBitwiseOpComp(topN,clk_enb,h_enbn,'NOT');
            h_rstn=topN.addSignal(pir_ufixpt_t(1,0),'reset_n');
            pirelab.getBitwiseOpComp(topN,clk_rst,h_rstn,'NOT');

            h_rst_internal=topN.addSignal(pir_ufixpt_t(1,0),'reset_internal');
            pirelab.getBitwiseOpComp(topN,[h_rstn,h_enbn],h_rst_internal,'XOR');

            for ii=1:length(inData)
                hsig=inData(ii);
                if strfind(hsig.Name,'IPCORE_CLK')
                    pirelab.getWireComp(topN,clk,hsig);
                elseif strfind(hsig.Name,'IPCORE_RESETN')
                    pirelab.getWireComp(topN,h_rst_internal,hsig);
                elseif strfind(hsig.Name,'AXI4_Lite_ARESETN')

                    pirelab.getWireComp(topN,h_rst_internal,hsig);
                elseif strfind(hsig.Name,'AXI4_')
                    pirelab.getConstComp(topN,hsig,0);
                else
                    hsig2=topN.addSignal(pir_sfixpt_t(16,-10),sprintf('%s',hsig.Name));
                    pirelab.getDTCComp(topN,hsig2,hsig,'Floor','Wrap','SI');
                    topN.addInputPort('data',hsig.Name);

                    hsig2.addDriver(topN,ii-3);
                end
            end

            for ii=1:length(outData)
                hsig=outData(ii);
                if strfind(hsig.Name,'AXI4_')

                    hsig.Preserve(1);
                elseif strfind(hsig.Name,'y_out')
                    hsig2=topN.addSignal(pir_sfixpt_t(35,-20),sprintf('%s',hsig.Name));
                    pirelab.getDTCComp(topN,hsig,hsig2,'Floor','Wrap','SI');
                    topN.addOutputPort('data',hsig.Name);

                    hsig2.addReceiver(topN,ii-1);
                elseif strfind(hsig.Name,'delayed_xout')
                    hsig2=topN.addSignal(pir_sfixpt_t(16,-10),sprintf('%s',hsig.Name));
                    pirelab.getDTCComp(topN,hsig,hsig2,'Floor','Wrap','SI');
                    topN.addOutputPort('data',hsig.Name);

                    hsig2.addReceiver(topN,ii-1);
                end
            end
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

