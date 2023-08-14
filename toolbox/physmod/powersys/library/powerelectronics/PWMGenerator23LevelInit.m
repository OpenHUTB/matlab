function[WantBlockChoice,Ts,sps]=PWMGenerator23LevelInit(varargin)




    sps=[];

    [block,ModulatorType,ModulatorMode,nF,Fc,ModulatingSignals,m,Freq,Phase,Ts,PortSize]=varargin{1:end};

    if PortSize==2
        Index1=[1,2];
        Index2=[1,3,2,4];
        Index3=[1,4,2,5,3,6];
    else
        Index1=1:4;
        Index2=1:8;
        Index3=1:12;
    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);



    if Init

        Erreur.identifier='SpecializedPowerSystems:PWMGeneratorBlock:ParameterError';
        BK=strrep(block,newline,char(32));

        if Fc<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The carrier frequency must be >0',BK);
            psberror(Erreur);
            return
        end

        if nF<1
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The switching ratio must be >=1',BK);
            psberror(Erreur);
            return
        end

        if m<0||m>1
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The modulation index m must be 0 <= m < =1',BK);
            psberror(Erreur);
            return
        end

        if Freq<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The frequency of output voltage must be >0',BK);
            psberror(Erreur);
            return
        end



        sps.ModulatorType=ModulatorType;
        sps.ModulatorMode=ModulatorMode;

        sps.nF=nF;
        sps.Fc=Fc;
        sps.ModulatingSignals=ModulatingSignals;
        sps.m=m;
        sps.Freq=2*pi*Freq;

        if ModulatorType==1

            sps.UrefInport_PortDimensions=1;
            sps.SinWave_Phase=Phase*pi/180;
            sps.SelectorHalfBridgeOut_PortSize=1;
            sps.SelectorHalfBridgeOut_Index=1;
            sps.SelectorFullBridgeIn_PortSize=1;
            sps.SelectorFullBridgeOut_Index=1;
            sps.SelectorPout_PortSize=PortSize;
            sps.SelectorPout_Index=Index1;
            sps.SelectorStatePulse_PortSize=1;
            sps.SelectorStatePulse_Index=[1,1,1];

        elseif ModulatorType==2

            sps.UrefInport_PortDimensions=1;
            sps.SinWave_Phase=Phase*pi/180;
            sps.SelectorHalfBridgeOut_PortSize=1;
            sps.SelectorHalfBridgeOut_Index=[1,1];
            sps.SelectorFullBridgeIn_PortSize=1;
            sps.SelectorFullBridgeOut_Index=[1,2];
            sps.SelectorPout_PortSize=PortSize*2;
            sps.SelectorPout_Index=Index2;
            sps.SelectorStatePulse_PortSize=2;
            sps.SelectorStatePulse_Index=[1,2,2];

        else

            sps.UrefInport_PortDimensions=3;
            sps.SinWave_Phase=[0,-2*pi/3,2*pi/3]+Phase*pi/180;
            sps.SelectorHalfBridgeOut_PortSize=3;
            sps.SelectorHalfBridgeOut_Index=[1,2,3];
            sps.SelectorFullBridgeIn_PortSize=3;
            sps.SelectorFullBridgeOut_Index=[1,2,2];
            sps.SelectorPout_PortSize=PortSize*3;
            sps.SelectorPout_Index=Index3;
            sps.SelectorStatePulse_PortSize=3;
            sps.SelectorStatePulse_Index=[1,2,3];

        end

        if(ModulatingSignals==1&&ModulatorMode==2)
            sps.CmdModulatingSignals=2;
        else
            sps.CmdModulatingSignals=1;
        end

    end



    WantInternal=ModulatingSignals;
    if ModulatorMode==1
        WantSynchronized=1;
    else
        WantSynchronized=0;
    end

    Uref_IsInport=strcmp('Inport',get_param([block,'/Uref'],'BlockType'));
    wt_IsInport=strcmp('Inport',get_param([block,'/wt'],'BlockType'));

    if WantSynchronized
        if~Uref_IsInport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Uref','BlockType','Ground','Inport','noprompt');
            set_param([block,'/Uref'],'SampleTime','Ts')
            set_param([block,'/Uref'],'PortDimensions','sps.UrefInport_PortDimensions')
        end
        if~wt_IsInport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','wt','BlockType','Ground','Inport','noprompt');
            set_param([block,'/wt'],'SampleTime','Ts')
        end
    else
        if wt_IsInport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','wt','BlockType','Inport','Ground','noprompt');
        end
        if WantInternal
            if Uref_IsInport
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Uref','BlockType','Inport','Ground','noprompt');
            end
        else
            if~Uref_IsInport
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Uref','BlockType','Ground','Inport','noprompt');
                set_param([block,'/Uref'],'SampleTime','Ts')
                set_param([block,'/Uref'],'PortDimensions','sps.UrefInport_PortDimensions')
            end
        end
    end

    PWMGenerator3LevelCback(block)