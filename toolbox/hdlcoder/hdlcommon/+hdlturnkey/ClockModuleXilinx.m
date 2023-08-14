


classdef ClockModuleXilinx<hdlturnkey.ClockModule

    properties(Access=private,Transient=true)
        initizledXilixPath='';
    end

    methods

        function obj=ClockModuleXilinx(varargin)
            obj=obj@hdlturnkey.ClockModule(varargin{:});
        end

        function constrainCell=extraPinMappingConstrain(~,constrainCell)

            constrainCell=constrainCell;%#ok<ASGSL>
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


            [reset_cmin,reset_cmout]=obj.elabResetLogic(hN,reset);


            if~obj.ClockTypeDiff
                hInSignals=[hClockSignal,reset_cmin];
                hOutSignals=[clock,reset_cmout];
            else
                hInSignals=[hClockSignal,hClockSignal_N,reset_cmin];
                hOutSignals=[clock,reset_cmout];
            end
            networkName=sprintf('%s_clock_module',hElab.TopNetName);

            obj.XilinxDCMFiles={};

            hCMNet=obj.getClockModuleNetwork(hN,hElab,networkName);
            pirelab.instantiateNetwork(hN,hCMNet,hInSignals,hOutSignals,sprintf('%s_inst',networkName));

        end


        function setClockModuleOutputFreq(obj,hDI,dcmOutputFreq)


            obj.CLKFX_MULTIPLY=0;
            obj.CLKFX_DIVIDE=0;


            if dcmOutputFreq~=obj.ClockInputMHz

                if obj.SkipDCMGeneration


                    boardName=hDI.hTurnkey.hBoard.BoardName;
                    error(message('hdlcoder:ClockModule:DCMNotSupported',boardName));
                end

                obj.calculateDCMFXParameter(hDI,dcmOutputFreq);
            end



            obj.ClockOutputMHz=dcmOutputFreq;
        end


        function calculateDCMFXParameter(obj,hDI,dcmOutputFreq)

            fpgaFamily=hDI.hTurnkey.hBoard.FPGAFamily;
            switch fpgaFamily
            case{'Spartan-3A DSP','Spartan3A and Spartan3AN','Spartan3E','Spartan6','Spartan6 Lower Power',...
                'Virtex2','Virtex4','Virtex5','Spartan3'}
                CLKFX_MULTIPLY_min=2;
                CLKFX_MULTIPLY_max=32;
                CLKFX_DIVIDE_min=1;
                CLKFX_DIVIDE_max=32;

            case{'Virtex6','Virtex7','Kintex7','Artix7','Zynq'}
                CLKFX_MULTIPLY_min=5;
                CLKFX_MULTIPLY_max=64;
                CLKFX_DIVIDE_min=1;
                CLKFX_DIVIDE_max=128;

            otherwise
                error(message('hdlcoder:ClockModule:UnsupportedCMFamily',fpgaFamily));
            end

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
            hdldisp(message('hdlcoder:hdldisp:SpeedgoatParams',...
            sprintf('%d',obj.CLKFX_MULTIPLY),...
            sprintf('%d',obj.CLKFX_DIVIDE)));
        end

    end

end


