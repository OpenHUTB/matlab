


classdef ClockModuleSpeedgoat<hdlturnkey.ClockModule


    properties(Hidden=true)

        IO331Boards=false;
    end

    properties(SetAccess=private,GetAccess=public)


        DCMInPortName='';

        DCMOutPortName='';

        DCMInPortFPGAPin='';
        DCMOutPortFPGAPin='';

        FrequencyRangeMin=0;
        FrequencyRangeMax=0;
    end

    methods

        function obj=ClockModuleSpeedgoat(varargin)









            p=inputParser;
            p.addParameter('DCMInPortName','');
            p.addParameter('DCMOutPortName','');
            p.addParameter('DCMInPortFPGAPin','');
            p.addParameter('DCMOutPortFPGAPin','');
            p.addParameter('FrequencyRangeMin',0);
            p.addParameter('FrequencyRangeMax',0);

            p.parse(varargin{1:12});
            inputArgs=p.Results;

            obj=obj@hdlturnkey.ClockModule(varargin{13:end});

            obj.DCMInPortName=inputArgs.DCMInPortName;
            obj.DCMOutPortName=inputArgs.DCMOutPortName;
            obj.DCMInPortFPGAPin=inputArgs.DCMInPortFPGAPin;
            obj.DCMOutPortFPGAPin=inputArgs.DCMOutPortFPGAPin;
            obj.FrequencyRangeMin=inputArgs.FrequencyRangeMin;
            obj.FrequencyRangeMax=inputArgs.FrequencyRangeMax;

        end

        function frequency=getClockConstraintTargetFrequency(obj)
            frequency=obj.ClockOutputMHz;
        end
        function elaborateClockModule(obj,hN,hElab)


            ufix1Type=pir_ufixpt_t(1,0);


            if obj.DefaultOutputMHz~=0&&obj.ClockOutputMHz~=obj.ClockInputMHz&&...
                obj.CLKFX_MULTIPLY==0&&obj.CLKFX_DIVIDE==0
                setClockModuleOutputFreq(obj,hElab.hTurnkey.hD,obj.DefaultOutputMHz);
            end


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


            hDCMInSignal=hN.addSignal(ufix1Type,obj.DCMInPortName);
            hN.addInputPort(obj.DCMInPortName);
            hDCMInSignal.addDriver(hN,hN.NumberOfPirInputPorts-1);

            hDCMOutSignal=hN.addSignal(ufix1Type,obj.DCMOutPortName);
            hN.addOutputPort(obj.DCMOutPortName);
            hDCMOutSignal.addReceiver(hN,hN.NumberOfPirOutputPorts-1);


            [clock,clkenb,reset]=hN.getClockBundle(hClockSignal,1,1,0);


            const_1=hN.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hN,const_1,1);
            pirelab.getWireComp(hN,const_1,clkenb);


            [reset_cmin,reset_cmout]=obj.elabResetLogic(hN,reset);








            networkName=sprintf('%s_clock_module',hElab.TopNetName);
            obj.XilinxDCMFiles={};
            if obj.IO331Boards
                hCMNet=getClockModuleNetworkIO331(obj,hN,hElab,networkName);
            else
                hCMNet=obj.getClockModuleNetwork(hN,hElab,networkName);
            end






            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hCMNet,...
            'InportNames',{'fpga_clkin'},...
            'InportWidths',{1},...
            'OutportNames',{'fpga_clk'},...
            'OutportWidths',{1});

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;
            fpga_clkin=hIPInportSignals(1);
            fpga_clk=hIPOutportSignals(1);

            ibufg_out=hCMNet.addSignal(ufix1Type,'ibufg_out');
            pirtarget.getIBUFGComp(hCMNet,fpga_clkin,ibufg_out);
            pirtarget.getBUFGComp(hCMNet,ibufg_out,fpga_clk,'FPGA_CLK_BUFG');

            hInSignals=[hDCMInSignal,reset_cmin,hClockSignal];
            hOutSignals=[hDCMOutSignal,reset_cmout,clock];


            pirelab.instantiateNetwork(hN,hCMNet,hInSignals,hOutSignals,sprintf('%s_inst',networkName));





















        end

        function generateClockConstrain(obj,fid)


            if~obj.ClockTypeDiff
                clockPortName=obj.ClockPortName;
            else
                clockPortName=obj.ClockPortName{1};
            end

            clockGroupName=sprintf('TN_%s',clockPortName);
            timeSpecName=sprintf('TS_%s','FPGA_CLK');







            clockInputMHz=getClockConstraintTargetFrequency(obj);




            fprintf(fid,'NET "%s" TNM_NET = "%s";\n',clockPortName,clockGroupName);








            fprintf(fid,'TIMESPEC "%s" = PERIOD "%s" %d MHz;\n',timeSpecName,clockGroupName,clockInputMHz);

            clockInputNsStr=num2str(1000/clockInputMHz);
            fprintf(fid,'OFFSET = IN %s ns BEFORE "%s";\n',clockInputNsStr,clockPortName);
            fprintf(fid,'OFFSET = OUT %s ns AFTER "%s";\n',clockInputNsStr,clockPortName);
            fprintf(fid,'TIMESPEC "TS_P2P" = FROM "PADS" TO "PADS" %s ns;\n',clockInputNsStr);

        end

        function constrainCell=extraPinMappingConstrain(obj,constrainCell)

            pinMapping={obj.DCMInPortName,obj.DCMInPortFPGAPin};
            if~isempty(obj.ClockIOConstrain)
                pinMapping=[pinMapping,obj.ClockIOConstrain];%#ok<*AGROW>
            end
            constrainCell{end+1}=pinMapping;
            pinMapping={obj.DCMOutPortName,obj.DCMOutPortFPGAPin};
            if~isempty(obj.ClockIOConstrain)
                pinMapping=[pinMapping,obj.ClockIOConstrain];%#ok<*AGROW>
            end
            constrainCell{end+1}=pinMapping;
        end


        function setClockModuleOutputFreq(obj,hDI,dcmOutputFreq)


            if strcmp(hDI.get('Board'),'Speedgoat IO331-6')


                isADAssigned=false;
                interfaceIDList=hDI.hTurnkey.hTable.hTableMap.getAssignedInterfaces;
                for ii=1:length(interfaceIDList)
                    interfaceID=interfaceIDList{ii};
                    hInterface=hDI.hTurnkey.getInterface(interfaceID);
                    if hInterface.isADBasedInterface
                        isADAssigned=true;
                        break;
                    end
                end

                if isADAssigned&&dcmOutputFreq>75
                    error(message('hdlcoder:ClockModule:IO3316ADFreqLimit',...
                    hDI.get('Board'),interfaceID));
                end
            end


            obj.CLKFX_MULTIPLY=0;
            obj.CLKFX_DIVIDE=0;


            if dcmOutputFreq~=obj.ClockInputMHz


                obj.calculateDCMFXParameter(hDI,dcmOutputFreq);
            end



            obj.ClockOutputMHz=dcmOutputFreq;
        end


        function calculateDCMFXParameter(obj,hDI,dcmOutputFreq)

            if dcmOutputFreq>obj.FrequencyRangeMax||...
                dcmOutputFreq<obj.FrequencyRangeMin
                error(message('hdlcoder:ClockModule:DCMOutputFrequencyOutOfRange',...
                hDI.hTurnkey.hBoard.BoardName,obj.FrequencyRangeMin,obj.FrequencyRangeMax));
            end

            fpgaFamily=hDI.hTurnkey.hBoard.FPGAFamily;
            switch fpgaFamily
            case{'Virtex2','Virtex4','Spartan6'}
                CLKFX_MULTIPLY_min=2;
                CLKFX_MULTIPLY_max=32;
                CLKFX_DIVIDE_min=1;
                CLKFX_DIVIDE_max=32;

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

        function hClockNet=getClockModuleNetworkIO331(obj,hN,hElab,networkName)






















            if obj.CLKFX_MULTIPLY>0&&obj.CLKFX_DIVIDE>0&&obj.ClockInputMHz>0
                dcmFXMul=obj.CLKFX_MULTIPLY;
                dcmFXDiv=obj.CLKFX_DIVIDE;
                dcmClkInPeriod=1000/obj.ClockInputMHz;
            else
                dcmFXMul=2;
                dcmFXDiv=2;
                dcmClkInPeriod=1000/obj.ClockInputMHz;
            end

            topNet=hN;
            pirInstance=hElab.BoardPirInstance;
            dcmName='DCM_SP';
            ufix1Type=pir_ufixpt_t(1,0);


            hClockNet=pirelab.createNewNetwork(...
            'PirInstance',pirInstance,...
            'Network',topNet,...
            'Name',networkName,...
            'InportNames',{'clkin','resetin'},...
            'InportTypes',[ufix1Type,ufix1Type],...
            'OutportNames',{'sysclk','sysreset'},...
            'OutportTypes',[ufix1Type,ufix1Type]);


            clkin=hClockNet.PirInputSignals(1);
            resetin=hClockNet.PirInputSignals(2);
            hInSignals=clkin;


            hClockNet.addCustomLibraryPackage('UNISIM','vcomponents');


            sysclk=hClockNet.PirOutputSignals(1);
            sysreset=hClockNet.PirOutputSignals(2);


            ibufg_out=hClockNet.addSignal(ufix1Type,'ibufg_out');
            pirtarget.getIBUFGComp(hClockNet,hInSignals,ibufg_out);


            const_1=hClockNet.addSignal(ufix1Type,'const_1');
            const_0=hClockNet.addSignal(ufix1Type,'const_0');
            pirelab.getConstComp(hClockNet,const_1,1);
            pirelab.getConstComp(hClockNet,const_0,0);


            dcm_out=hClockNet.addSignal(ufix1Type,'dcm_out');
            locked=hClockNet.addSignal(ufix1Type,'locked');
            psen=hClockNet.addSignal(ufix1Type,'psen');
            pirelab.getWireComp(hClockNet,const_0,psen);
            bufg_out=hClockNet.addSignal(ufix1Type,'bufg_out');
            dcmfx_out=hClockNet.addSignal(ufix1Type,'dcmfx_out');
            dcmfx180_out=hClockNet.addSignal(ufix1Type,'dcmfx180_out');
            hInSignals=[ibufg_out,bufg_out,resetin,psen];
            hOutSignals=[dcm_out,dcmfx_out,dcmfx180_out,locked];
            pirtarget.getDCMDoubleRateComp(hClockNet,hInSignals,hOutSignals,dcmName,dcmFXMul,dcmFXDiv,dcmClkInPeriod);


            pirtarget.getBUFGComp(hClockNet,dcm_out,bufg_out);


            hInSignals=[dcmfx_out,dcmfx180_out,const_1,const_1,...
            const_0,const_0,const_0];
            hOutSignals=sysclk;
            pirtarget.getODDR2Comp(hClockNet,hInSignals,hOutSignals);


            pirelab.getBitwiseOpComp(hClockNet,locked,sysreset,'NOT');

        end


    end
end





