


classdef AlteraPLL<hdlturnkey.ClockModule


    methods

        function obj=AlteraPLL(varargin)
            obj=obj@hdlturnkey.ClockModule(varargin{:});
        end

        function constrainCell=extraPinMappingConstrain(~,constrainCell)

            constrainCell=constrainCell;%#ok<ASGSL>
        end


        function setClockModuleOutputFreq(obj,hDI,dcmOutputFreq)

            if~hDI.isMLHDLC
                targetcodegen.alteradspbadriver.checkFrequency(hDI.getModelName,dcmOutputFreq);
            end


            obj.CLKFX_MULTIPLY=1;
            obj.CLKFX_DIVIDE=1;

            if dcmOutputFreq~=obj.ClockInputMHz
                dcmOutputFreqMin=5;
                dcmOutputFreqMax=400;
                if dcmOutputFreq>dcmOutputFreqMax||dcmOutputFreq<dcmOutputFreqMin
                    error(message('hdlcoder:ClockModule:AltpllOutputFrequencyOutOfRange',hDI.hTurnkey.hBoard.BoardName));
                end

                CLKFX_MULTIPLY_min=1;
                CLKFX_MULTIPLY_max=256;
                CLKFX_DIVIDE_min=1;
                CLKFX_DIVIDE_max=256;

                dcmInputFreq=obj.ClockInputMHz;

                closestFreq=0;
                exactMatch=false;

                for ii=CLKFX_MULTIPLY_min:CLKFX_MULTIPLY_max
                    for jj=CLKFX_DIVIDE_min:CLKFX_DIVIDE_max
                        dcmFXout=dcmInputFreq*(ii/jj);
                        if dcmFXout==dcmOutputFreq
                            exactMatch=true;
                            obj.CLKFX_MULTIPLY=ii;
                            obj.CLKFX_DIVIDE=jj;
                            break;
                        elseif(dcmFXout>dcmOutputFreqMax)||(dcmFXout<dcmOutputFreqMin)
                            continue;
                        elseif abs(dcmFXout-dcmOutputFreq)<abs(closestFreq-dcmOutputFreq)
                            closestFreq=dcmFXout;
                            obj.CLKFX_MULTIPLY=ii;
                            obj.CLKFX_DIVIDE=jj;
                        end
                    end

                    if exactMatch
                        break;
                    end
                end

                if~exactMatch
                    hdldisp(message('hdlcoder:hdldisp:ClockMatch',sprintf('%0.3f',closestFreq)));
                end
                hdldisp(message('hdlcoder:hdldisp:AlteraClockParams',...
                sprintf('%d',obj.CLKFX_MULTIPLY),...
                sprintf('%d',obj.CLKFX_DIVIDE)));
            end

            obj.ClockOutputMHz=dcmOutputFreq;
        end

        function frequency=getClockConstraintTargetFrequency(obj)
            frequency=obj.ClockInputMHz;
        end

        function elaborateClockModule(obj,hN,hElab)


            ufix1Type=pir_ufixpt_t(1,0);


            if~obj.ClockTypeDiff
                hClockSignal=hN.addSignal(ufix1Type,obj.ClockPortName);
                hN.addInputPort(obj.ClockPortName);
                hClockSignal.addDriver(hN,hN.NumberOfPirInputPorts-1);
            else

                clockPortName_P=obj.ClockPortName{1};
                clockPortName_N=obj.ClockPortName{2};
                hClockSignal=hN.addSignal(ufix1Type,clockPortName_P);
                hClockSignal_N=hN.addSignal(ufix1Type,clockPortName_N);
                hN.addInputPort(clockPortName_P);
                hClockSignal.addDriver(hN,hN.NumberOfPirInputPorts-1);
                hN.addInputPort(clockPortName_N);
                hClockSignal_N.addDriver(hN,hN.NumberOfPirInputPorts-1);
            end


            [clock,clkenb,reset]=hN.getClockBundle(hClockSignal,1,1,0);


            const_1=hN.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hN,const_1,1);
            pirelab.getWireComp(hN,const_1,clkenb);





            if obj.InternalReset



                reset_internal=hN.addSignal(ufix1Type,'reset_internal');
                obj.InternalResetSignal=reset_internal;



                reset_cmout=hN.addSignal(ufix1Type,'reset_cmout');
                pirelab.getBitwiseOpComp(hN,...
                [reset_cmout,reset_internal],reset,'OR');
            else





                reset_cmout=reset;
            end


            reset_cm=hN.addSignal(ufix1Type,'reset_cm');
            if~isempty(obj.ResetPortName)



                ufix1Type=pir_ufixpt_t(1,0);
                hResetSignal=hN.addSignal(ufix1Type,obj.ResetPortName);
                hN.addInputPort(obj.ResetPortName);
                hResetSignal.addDriver(hN,hN.NumberOfPirInputPorts-1);

                if obj.ResetActiveLow

                    pirelab.getBitwiseOpComp(hN,hResetSignal,reset_cm,'NOT');
                else
                    pirelab.getWireComp(hN,hResetSignal,reset_cm);
                end

            else

                const_0=hN.addSignal(ufix1Type,'const_0');
                pirelab.getConstComp(hN,const_0,0);
                pirelab.getWireComp(hN,const_0,reset_cm);
            end


            if~obj.ClockTypeDiff
                hInSignals=[hClockSignal,reset_cm];
                hOutSignals=[clock,reset_cmout];
            else
                hInSignals=[hClockSignal,hClockSignal_N,reset_cm];
                hOutSignals=[clock,reset_cmout];
            end
            networkName=sprintf('%s_clock_module',hElab.TopNetName);

            obj.XilinxDCMFiles={};

            fpgaFamily=hElab.hTurnkey.hBoard.FPGAFamily;

            hCMNet=getClockModuleNetwork(obj,hN,hElab,networkName,fpgaFamily);
            pirelab.instantiateNetwork(hN,hCMNet,hInSignals,hOutSignals,sprintf('%s_inst',networkName));
        end

        function generateClockConstrain(obj,fid)


            if~obj.ClockTypeDiff
                clockPortName=obj.ClockPortName;
            else
                clockPortName=obj.ClockPortName{1};
            end


            clkPeriodInNs=1e3/obj.ClockInputMHz;

            fprintf(fid,...
            'create_clock -name %s -period %fns -waveform {0.0ns %fns} [get_ports {%s}]\n',...
            clockPortName,clkPeriodInNs,clkPeriodInNs/2,clockPortName);
            fprintf(fid,...
            'derive_pll_clocks\n');
            fprintf(fid,...
            'derive_clock_uncertainty\n');
        end

        function constrainCell=generateFPGAPinConstrain(obj)
            constrainCell=generateFPGAPinConstrain@hdlturnkey.ClockModule(obj);
            if obj.ClockTypeDiff
                for ii=1:length(obj.ClockFPGAPin)
                    constrainCell{ii}{end+1}='IO_STANDARD "LVDS"';
                end
            end
        end

        function hCMNet=getClockModuleNetwork(obj,hN,hElab,networkName,fpgaFamily)



            if obj.CLKFX_MULTIPLY>0&&obj.CLKFX_DIVIDE>0&&obj.ClockInputMHz>0
                dcmFXMul=obj.CLKFX_MULTIPLY;
                dcmFXDiv=obj.CLKFX_DIVIDE;
            else
                dcmFXMul=1;
                dcmFXDiv=1;
            end

            dcmClkInPeriod=1e6/obj.ClockInputMHz;

            hCMNet=pirtarget.getAlteraPLLNetwork(hN,hElab.BoardPirInstance,networkName,...
            fpgaFamily,obj.ClockTypeDiff,dcmFXMul,dcmFXDiv,dcmClkInPeriod);

        end
    end
end




