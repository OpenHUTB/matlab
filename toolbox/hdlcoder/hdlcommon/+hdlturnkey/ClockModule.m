


classdef ClockModule<handle


    properties

        ClockPortName='';
        ClockInputMHz=0;
        ClockTypeDiff=false;
        ClockFPGAPin='';
        ClockIOConstrain={}
        ResetPortName='';
        ResetActiveLow=false;
        ResetFPGAPin='';
        ResetIOConstrain={};









        InternalReset=false;
        InternalResetSignal=[];


        SkipDCMGeneration=false;


        DefaultOutputMHz=0;

    end

    properties(SetAccess=protected,GetAccess=public)
        ClockOutputMHz=0;
        XilinxDCMFiles={};


        CLKFX_MULTIPLY=0;
        CLKFX_DIVIDE=0;
    end

    methods(Abstract)
        constrainCell=extraPinMappingConstrain(obj,constrainCell);
        setClockModuleOutputFreq(obj,hDI,dcmOutputFreq);
        elaborateClockModule(obj,hN,hElab);
        frequency=getClockConstraintTargetFrequency(obj);
    end

    methods
        function obj=ClockModule(varargin)

            p=inputParser;
            p.addParameter('ClockPortName','');
            p.addParameter('ClockInputMHz',0);
            p.addParameter('ClockType','');
            p.addParameter('ClockFPGAPin','');
            p.addParameter('ClockIOConstrain',{});
            p.addParameter('ResetPortName','');
            p.addParameter('ResetActiveLow',false);
            p.addParameter('ResetFPGAPin','');
            p.addParameter('ResetIOConstrain',{});
            p.addParameter('InternalReset',false);
            p.addParameter('SkipDCMGeneration',false);
            p.addParameter('DefaultOutputMHz',0);

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj.ClockPortName=inputArgs.ClockPortName;
            obj.ClockInputMHz=inputArgs.ClockInputMHz;
            obj.ClockFPGAPin=inputArgs.ClockFPGAPin;
            obj.ClockIOConstrain=inputArgs.ClockIOConstrain;
            obj.ResetPortName=inputArgs.ResetPortName;
            obj.ResetActiveLow=inputArgs.ResetActiveLow;
            obj.ResetFPGAPin=inputArgs.ResetFPGAPin;
            obj.ResetIOConstrain=inputArgs.ResetIOConstrain;
            obj.InternalReset=inputArgs.InternalReset;
            obj.SkipDCMGeneration=inputArgs.SkipDCMGeneration;
            obj.DefaultOutputMHz=inputArgs.DefaultOutputMHz;

            if strcmpi(inputArgs.ClockType,'DIFF')
                obj.ClockTypeDiff=true;
            else
                obj.ClockTypeDiff=false;
            end






            if obj.DefaultOutputMHz==0
                obj.ClockOutputMHz=obj.ClockInputMHz;
            else
                obj.ClockOutputMHz=obj.DefaultOutputMHz;
            end
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




        end

        function constrainCell=generateFPGAPinConstrain(obj)

            constrainCell={};



            if~obj.ClockTypeDiff
                pinMapping={obj.ClockPortName,obj.ClockFPGAPin};
                if~isempty(obj.ClockIOConstrain)
                    pinMapping=[pinMapping,obj.ClockIOConstrain];
                end
                constrainCell{end+1}=pinMapping;
            else

                for ii=1:length(obj.ClockFPGAPin)
                    pinMapping={obj.ClockPortName{ii},obj.ClockFPGAPin{ii}};
                    if~isempty(obj.ClockIOConstrain)
                        pinMapping=[pinMapping,obj.ClockIOConstrain];%#ok<*AGROW>
                    end
                    constrainCell{end+1}=pinMapping;
                end
            end

            constrainCell=extraPinMappingConstrain(obj,constrainCell);


            if~isempty(obj.ResetPortName)
                if isempty(obj.ResetFPGAPin)
                    error(message('hdlcommon:workflow:MissingResetPin'));
                end
                pinMapping={obj.ResetPortName,obj.ResetFPGAPin};
                if~isempty(obj.ResetIOConstrain)
                    pinMapping=[pinMapping,obj.ResetIOConstrain];
                end
                constrainCell{end+1}=pinMapping;
            end
        end

        function hCMNet=getClockModuleNetwork(obj,hN,hElab,networkName)



            if obj.CLKFX_MULTIPLY>0&&obj.CLKFX_DIVIDE>0&&obj.ClockInputMHz>0
                dcmFXMul=obj.CLKFX_MULTIPLY;
                dcmFXDiv=obj.CLKFX_DIVIDE;
                dcmClkInPeriod=1000/obj.ClockInputMHz;
            else
                dcmFXMul=0;
                dcmFXDiv=0;
                dcmClkInPeriod=0;
            end

            fpgaFamily=hElab.hTurnkey.hBoard.FPGAFamily;
            isDiff=obj.ClockTypeDiff;
            skipDCM=obj.SkipDCMGeneration;

            hCMNet=pirtarget.getClockModuleDCMNetwork(hN,hElab.BoardPirInstance,...
            networkName,fpgaFamily,isDiff,dcmFXMul,dcmFXDiv,dcmClkInPeriod,skipDCM);

        end

        function[reset_cmin,reset_cmout]=elabResetLogic(obj,hN,reset)

            ufix1Type=pir_ufixpt_t(1,0);





            if obj.InternalReset



                reset_internal=hN.addSignal(ufix1Type,'reset_internal');
                obj.InternalResetSignal=reset_internal;



                reset_cmout=hN.addSignal(ufix1Type,'reset_cmout');
                pirelab.getBitwiseOpComp(hN,...
                [reset_cmout,reset_internal],reset,'OR');
            else





                reset_cmout=reset;
            end


            reset_cmin=hN.addSignal(ufix1Type,'reset_cm');
            if~isempty(obj.ResetPortName)



                ufix1Type=pir_ufixpt_t(1,0);
                hResetSignal=hN.addSignal(ufix1Type,obj.ResetPortName);
                hN.addInputPort(obj.ResetPortName);
                hResetSignal.addDriver(hN,hN.NumberOfPirInputPorts-1);

                if obj.ResetActiveLow

                    pirelab.getBitwiseOpComp(hN,hResetSignal,reset_cmin,'NOT');
                else
                    pirelab.getWireComp(hN,hResetSignal,reset_cmin);
                end

            else

                const_0=hN.addSignal(ufix1Type,'const_0');
                pirelab.getConstComp(hN,const_0,0);
                pirelab.getWireComp(hN,const_0,reset_cmin);
            end

        end

        function elabResetSyncLogic(obj,hN,hElab,reset_before_sync,reset_global)%#ok<INUSL>
            ufix1Type=pir_ufixpt_t(1,0);


            hResetSyncNet=pirelab.createNewNetwork(...
            'PirInstance',hElab.BoardPirInstance,...
            'Network',hN,...
            'Name',sprintf('%s_reset_sync',hElab.TopNetName)...
            );


            hIPPortSignal=pirelab.addIOPortToNetwork(...
            'Network',hResetSyncNet,...
            'InportNames',{'reset_in'},...
            'InportWidths',{1},...
            'OutportNames',{'reset_out'},...
            'OutportWidths',{1});

            hIPInportSignals=hIPPortSignal.hInportSignals;
            hIPOutportSignals=hIPPortSignal.hOutportSignals;


            port_reset_in=hIPInportSignals(1);
            port_reset_out=hIPOutportSignals(1);





            [~,clkenb,reset]=hResetSyncNet.getClockBundle(port_reset_in,1,1,0);
            pirelab.getWireComp(hResetSyncNet,port_reset_in,reset);
            const_1=hResetSyncNet.addSignal(ufix1Type,'const_1');
            pirelab.getConstComp(hResetSyncNet,const_1,1);
            pirelab.getWireComp(hResetSyncNet,const_1,clkenb);


            reset_pipe=hResetSyncNet.addSignal(ufix1Type,'reset_pipe');


            const_0=hResetSyncNet.addSignal(ufix1Type,'const_0');
            pirelab.getConstComp(hResetSyncNet,const_0,0);

            pirelab.getUnitDelayComp(hResetSyncNet,const_0,reset_pipe,'reg_reset_pipe',1);
            pirelab.getUnitDelayComp(hResetSyncNet,reset_pipe,port_reset_out,'reg_reset_delay',1);


            pirelab.instantiateNetwork(hN,hResetSyncNet,reset_before_sync,...
            reset_global,sprintf('%s_reset_sync_inst',hElab.TopNetName));

        end
    end
end




