


classdef ClockModuleIP<hdlturnkey.ClockModule


    properties
        ClockConnection='';
        ResetConnection='';
        ClockMinMHz=0;
        ClockMaxMHz=0;
        ClockNum=1;
        ClockModuleInstance='clk_wiz_0';
        ClockModuleComponent='';
    end

    properties(Access=protected)

HasProcessorConnection

        DeviceTreeClockNode='';
    end

    properties(Dependent)
        Adjustable;
        ShowTask;
    end

    properties(Constant,Hidden)
        ClockExampleStr='hRD.addClockInterface(''ClockConnection'', ''clk_wiz_0/clk_out1'', ''ResetConnection'', ''proc_sys_reset_0/peripheral_aresetn'')';


        ClockExampleStrFull='hRD.addClockInterface(''ClockConnection'', ''clk_wiz_0/clk_out1'', ''ResetConnection'', ''proc_sys_reset_0/peripheral_aresetn'', ''DefaultFrequencyMHz'', 100, ''MinFrequencyMHz'', 10, ''MaxFrequencyMHz'', 200, ''ClockNumber'', 1, ''ClockModuleInstance'', ''clk_wiz_0'')';
    end

    methods

        function obj=ClockModuleIP(varargin)



            obj=obj@hdlturnkey.ClockModule(...
            'ClockPortName','IPCORE_CLK',...
            'ResetPortName','IPCORE_RESETN',...
            'InternalReset',false,...
            'ResetActiveLow',true);




            p=inputParser;

            p.addParameter('IsGenericIP',false);
            p.addParameter('ClockConnection',obj.ClockConnection);
            p.addParameter('ResetConnection',obj.ResetConnection);
            p.addParameter('DefaultFrequencyMHz',obj.ClockInputMHz);
            p.addParameter('MinFrequencyMHz',obj.ClockMinMHz);
            p.addParameter('MaxFrequencyMHz',obj.ClockMaxMHz);
            p.addParameter('ClockNumber',obj.ClockNum);
            p.addParameter('ClockModuleInstance','clk_wiz_0');
            p.addParameter('ClockModuleComponent',obj.ClockModuleComponent);
            p.addParameter('HasProcessorConnection',false);
            p.addParameter('DeviceTreeClockNode','');

            p.parse(varargin{:});
            inputArgs=p.Results;




            obj.validateInputParameters(inputArgs);





            obj.ClockConnection=inputArgs.ClockConnection;
            obj.ResetConnection=inputArgs.ResetConnection;
            obj.DefaultOutputMHz=inputArgs.DefaultFrequencyMHz;
            obj.ClockOutputMHz=inputArgs.DefaultFrequencyMHz;
            obj.ClockInputMHz=inputArgs.DefaultFrequencyMHz;


            if(inputArgs.MinFrequencyMHz==0&&inputArgs.MaxFrequencyMHz==0)
                obj.ClockMinMHz=obj.ClockOutputMHz;
                obj.ClockMaxMHz=obj.ClockOutputMHz;
            else
                freqGrtMax=inputArgs.DefaultFrequencyMHz<inputArgs.MinFrequencyMHz;
                freqLtMin=inputArgs.DefaultFrequencyMHz>inputArgs.MaxFrequencyMHz;
                if(freqGrtMax||freqLtMin)
                    error(message('hdlcommon:interface:ClockInterfaceFreqOutOfRange',...
                    sprintf('%g',inputArgs.MinFrequencyMHz),...
                    sprintf('%g',inputArgs.MaxFrequencyMHz),...
                    sprintf('%g',inputArgs.DefaultFrequencyMHz)));
                end
                obj.ClockMinMHz=inputArgs.MinFrequencyMHz;
                obj.ClockMaxMHz=inputArgs.MaxFrequencyMHz;
            end
            obj.ClockNum=inputArgs.ClockNumber;
            obj.ClockModuleInstance=inputArgs.ClockModuleInstance;
            obj.ClockModuleComponent=inputArgs.ClockModuleComponent;

            obj.HasProcessorConnection=inputArgs.HasProcessorConnection;
            obj.DeviceTreeClockNode=inputArgs.DeviceTreeClockNode;
        end

        function validateInputParameters(obj,inputArgs)
            if~inputArgs.IsGenericIP

                hdlturnkey.plugin.validateRequiredParameter(...
                inputArgs.ClockConnection,'ClockConnection',obj.ClockExampleStr);
                hdlturnkey.plugin.validateRequiredParameter(...
                inputArgs.ResetConnection,'ResetConnection',obj.ClockExampleStr);
            end


            hdlturnkey.plugin.validateNonNegDoubleProperty(...
            inputArgs.DefaultFrequencyMHz,'DefaultFrequencyMHz',obj.ClockExampleStrFull);
            hdlturnkey.plugin.validateNonNegDoubleProperty(...
            inputArgs.MinFrequencyMHz,'MinFrequencyMHz',obj.ClockExampleStrFull);
            hdlturnkey.plugin.validateNonNegDoubleProperty(...
            inputArgs.MaxFrequencyMHz,'MaxFrequencyMHz',obj.ClockExampleStrFull);















            if inputArgs.MinFrequencyMHz~=inputArgs.MaxFrequencyMHz


                hdlturnkey.plugin.validateNonNegIntegerProperty(...
                inputArgs.ClockNumber,'ClockNumber',obj.ClockExampleStrFull);
                hdlturnkey.plugin.validateStringProperty(...
                inputArgs.ClockModuleInstance,'ClockModuleInstance',obj.ClockExampleStrFull);
            end

            if(inputArgs.MinFrequencyMHz>inputArgs.MaxFrequencyMHz)
                error(message('hdlcommon:interface:ClockInterfaceMinMaxFreq'));
            end
        end

        function elaborateClockModule(obj,hN,hElab)






            if(~obj.isIPCoreClockNeeded(hElab))
                return;
            end

            ufix1Type=pir_ufixpt_t(1,0);


            hClockSignal=hN.addSignal(ufix1Type,obj.ClockPortName);
            hN.addInputPort(obj.ClockPortName);
            hClockSignal.addDriver(hN,hN.NumberOfPirInputPorts-1);


            [clock,clkenb,reset_global]=hN.getClockBundle(hClockSignal,1,1,0);


            pirelab.getWireComp(hN,hClockSignal,clock);


            const_1=hN.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hN,const_1,1);
            pirelab.getWireComp(hN,const_1,clkenb);

            if(strcmp(hdlfeature('IPCoreResetSync'),'on'))


                reset_before_sync=hN.addSignal(ufix1Type,'reset_before_sync');
                obj.elabResetSyncLogic(hN,hElab,reset_before_sync,reset_global);



                [reset_cmin,reset_cmout]=obj.elabResetLogic(hN,reset_before_sync);
            else
                [reset_cmin,reset_cmout]=obj.elabResetLogic(hN,reset_global);
            end

            pirelab.getWireComp(hN,reset_cmin,reset_cmout);

        end

        function generateClockConstrain(obj,fid)%#ok<INUSD>
        end

        function constrainCell=generateFPGAPinConstrain(obj)%#ok<MANU>

            constrainCell={};
        end

        function frequency=getClockConstraintTargetFrequency(obj)%#ok<MANU>
            frequency=0;
        end

        function constrainCell=extraPinMappingConstrain(~,constrainCell)
        end

        function setClockModuleOutputFreq(obj,val)

            if~isfinite(val)||~isreal(val)||val<0
                error(message('hdlcommon:interface:ClockInterfaceFreqNonNegative'));
            end







            if~obj.Adjustable&&obj.DefaultOutputMHz>0&&val~=obj.DefaultOutputMHz
                error(message('hdlcommon:interface:ClockInterfaceFreqNotAdjustable'));
            end


            if obj.ClockMinMHz~=0&&obj.ClockMaxMHz~=0
                if val<obj.ClockMinMHz||val>obj.ClockMaxMHz
                    error(message('hdlcommon:interface:ClockInterfaceFreqOutOfRange',...
                    sprintf('%g',obj.ClockMinMHz),...
                    sprintf('%g',obj.ClockMaxMHz),...
                    sprintf('%g',val)));
                end
            end

            obj.ClockOutputMHz=val;
        end

        function val=get.ShowTask(obj)
            if obj.ClockMinMHz==0&&obj.ClockMaxMHz==0&&obj.ClockOutputMHz==0
                val=false;
            else
                val=true;
            end
        end

        function val=get.Adjustable(obj)
            val=(obj.ClockMinMHz~=obj.ClockMaxMHz);
        end

        function generateVivadoTclConnectClockReset(obj,hDI,fid)


            if(obj.isIPCoreClockNeeded(hDI.hTurnkey.hElab))
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclClockResetConnection',fid,obj.ClockConnection,obj.ResetConnection);
            end
        end

        function generateQuartusTclConnectClockReset(obj,hDI,fid)


            if(obj.isIPCoreClockNeeded(hDI.hTurnkey.hElab))
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclClockResetConnection',fid,obj.ClockConnection,obj.ResetConnection);
            end
        end

        function generateVivadoTclSetClockFreq(obj,hDI,fid)


            if obj.Adjustable&&obj.ClockOutputMHz~=0&&obj.isIPCoreClockNeeded(hDI.hTurnkey.hElab)
                if hDI.hTurnkey.isVersalPlatform


                    pluginGenTclCmd='Plugin_Tcl_Vivado.getTclSetClockFreqVersal';
                else
                    pluginGenTclCmd='Plugin_Tcl_Vivado.getTclSetClockFreq';
                end

                downstream.tool.runInPlugin(hDI,pluginGenTclCmd,fid,obj.ClockNum,obj.ClockOutputMHz,obj.ClockModuleInstance);
            end
        end

        function generateLiberoTclSetClockFreq(obj,hDI,fid,isPFSOC,topSmartDesign)
            fprintf(fid,'# Update output frequency on clock wizard based on target frequency\n');
            if obj.isIPCoreClockNeeded(hDI.hTurnkey.hElab)






                if isPFSOC
                    fprintf(fid,'configure_core -component_name {%s} -params {"GL0_0_OUT_FREQ:%d"}\n',obj.ClockModuleComponent,obj.ClockOutputMHz);
                else
                    fprintf(fid,'sd_configure_core_instance -sd_name {%s} -instance_name {%s} -params {"GL0_OUT_0_FREQ:%d"} -validate_rules 0\n',topSmartDesign,obj.ClockModuleInstance,obj.ClockOutputMHz);
                end
            end
        end

        function generateQuartusTclSetClockFreq(obj,hDI,fid)


            if obj.Adjustable&&obj.ClockOutputMHz~=0&&obj.isIPCoreClockNeeded(hDI.hTurnkey.hElab)
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Quartus.getTclSetClockFreq',fid,obj.ClockNum,obj.ClockOutputMHz,obj.ClockModuleInstance);
            end
        end

        function interfaceNeedsClock=isClockNeededForAnyInterface(~,hElab)

            interfaceNeedsClock=false;
            if(~getDefaultBusInterface(hElab).isEmptyAXI4SlaveInterface)


                interfaceNeedsClock=true;
            else


                interfaceIDList=hElab.hTurnkey.getSupportedInterfaceIDList;
                for ii=1:length(interfaceIDList)
                    interfaceID=interfaceIDList{ii};
                    hInterface=hElab.hTurnkey.getInterface(interfaceID);


                    if hElab.hTurnkey.isAssignedInterface(interfaceID)&&...
                        hInterface.isIPInterface&&...
                        hInterface.isIPCoreClockNeeded
                        interfaceNeedsClock=true;
                        break;
                    end
                end
            end
        end

        function needsClock=isIPCoreClockNeeded(obj,hElab)




            needsClock=(hElab.hDUTLayer.isClockInDUT||...
            obj.isClockNeededForAnyInterface(hElab));
        end
    end
end


