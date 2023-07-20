function sps=PWMGenerator2LevelInit(block,ModulatorType,SamplingTechnique,ModulatorMode,nF,Fc,MinMax,Pc,ShowCarrierOutport,ModulatingSignals,m,Freq,Phase,Ts)





    sps=[];

    P=Simulink.Mask.get(block);
    nF=P.getParameter('nF').Value;







    switch get_param(bdroot(block),'SimulationStatus')
    case 'initializing'
        Erreur.identifier='SpecializedPowerSystems:PWMGeneratorBlock2Level:ParameterError';
        BK=strrep(block,newline,char(32));

        if Fc<=0
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The carrier frequency must be >0',BK);
            psberror(Erreur);
            return
        end

        if MinMax(2)<=MinMax(1)
            Erreur.message=sprintf('Parameter error in the ''%s'' Carrier minimum value must be less than maximum value.',BK);
            psberror(Erreur);
            return
        end

        switch ModulatorMode
        case 'Synchronized'
            if nF<1
                Erreur.message=sprintf('Parameter error in the ''%s'' block: The switching ratio must be >=1',BK);
                psberror(Erreur);
                return
            end
        end

        if ModulatingSignals==1
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
        end

        switch SamplingTechnique
        case 'Asymmetrical regular (double edge)'
            Tsampling=1/Fc/2;
            if mod(Tsampling,Ts)~=0&&Ts~=0
                Erreur.message=sprintf('Invalid parameter in the ''%s'' block: In order to use the regular sampling techniques, the generator sample time must be an integer submultiple of the sampling period.\n The sampling period = Carrier period/2 = ''%f'' s',BK,Tsampling);
                psberror(Erreur);
                return
            end
        case 'Symmetrical regular (single edge)'
            Tsampling=1/Fc;
            if mod(Tsampling,Ts)~=0&&Ts~=0
                Erreur.message=sprintf('Invalid parameter in the ''%s'' block: In order to use the regular sampling techniques, the generator sample time must be an integer submultiple of the sampling period.\n The sampling period = Carrier period = ''%f'' s',BK,Tsampling);
                psberror(Erreur);
                return
            end
        end

    end



    sps.ModulatorMode=ModulatorMode;

    switch SamplingTechnique
    case 'Natural'
        sps.SamplingTechnique=1;
    case 'Asymmetrical regular (double edge)'
        sps.SamplingTechnique=2;
    case 'Symmetrical regular (single edge)'
        sps.SamplingTechnique=3;
    end

    sps.nF=nF;
    sps.Fc=Fc;
    sps.Pc=Pc;
    sps.m=m;
    sps.Freq=2*pi*Freq;

    sps.UrefInport_PortDimensions=1;
    sps.SinWave_Phase=Phase*pi/180;
    sps.SelectorHalfBridgeOut_PortSize=1;
    sps.SelectorFullBridgeIn_PortSize=1;

    switch ModulatorType

    case 'Single-phase half-bridge (2 pulses)'

        sps.ModulatorType=1;
        sps.SelectorHalfBridgeOut_Index=1;
        sps.SelectorFullBridgeOut_Index=1;
        sps.SelectorPout_PortSize=2;
        sps.SelectorPout_Index=[1,2];
        sps.SelectorStatePulse_PortSize=1;
        sps.SelectorStatePulse_Index=[1,1,1];

    case 'Single-phase full-bridge (4 pulses)'

        sps.ModulatorType=2;
        sps.SelectorHalfBridgeOut_Index=[1,1];
        sps.SelectorFullBridgeOut_Index=[1,2];
        sps.SelectorPout_PortSize=4;
        sps.SelectorPout_Index=[1,3,2,4];
        sps.SelectorStatePulse_PortSize=2;
        sps.SelectorStatePulse_Index=[1,2,2];

    case 'Single-phase full-bridge - Bipolar modulation (4 pulses)'

        sps.ModulatorType=3;
        sps.SelectorHalfBridgeOut_Index=[1,1];
        sps.SelectorFullBridgeOut_Index=[1,2];
        sps.SelectorPout_PortSize=4;
        sps.SelectorPout_Index=[1,3,2,4];
        sps.SelectorStatePulse_PortSize=2;
        sps.SelectorStatePulse_Index=[1,2,2];

    case 'Three-phase bridge (6 pulses)'

        sps.ModulatorType=4;
        sps.UrefInport_PortDimensions=3;
        sps.SinWave_Phase=[0,-2*pi/3,2*pi/3]+Phase*pi/180;
        sps.SelectorHalfBridgeOut_PortSize=3;
        sps.SelectorHalfBridgeOut_Index=[1,2,3];
        sps.SelectorFullBridgeIn_PortSize=3;
        sps.SelectorFullBridgeOut_Index=[1,2,2];
        sps.SelectorPout_PortSize=6;
        sps.SelectorPout_Index=[1,4,2,5,3,6];
        sps.SelectorStatePulse_PortSize=3;
        sps.SelectorStatePulse_Index=[1,2,3];
    end

    sps.CmdModulatingSignals=1;
    if ModulatingSignals==1
        switch ModulatorMode
        case 'Unsynchronized'
            sps.CmdModulatingSignals=2;
        end
        switch ModulatorType
        case 'Single-phase full-bridge - Bipolar modulation (4 pulses)'
            sps.CmdModulatingSignals=2;
        end
    end



    WantInternal=ModulatingSignals;

    Cr_IsOutport=strcmp('Outport',get_param([block,'/m'],'BlockType'));
    if ShowCarrierOutport
        if~Cr_IsOutport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','BlockType','Terminator','Outport','noprompt');
        end
    else
        if Cr_IsOutport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','m','BlockType','Outport','Terminator','noprompt')
        end
    end

    Uref_IsInport=strcmp('Inport',get_param([block,'/Uref'],'BlockType'));
    wt_IsInport=strcmp('Inport',get_param([block,'/wt'],'BlockType'));

    switch ModulatorMode

    case 'Synchronized'

        sps.ModulatingSignals=1;
        if~Uref_IsInport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Uref','BlockType','Ground','Inport','noprompt');
            set_param([block,'/Uref'],'SampleTime','Ts')
            set_param([block,'/Uref'],'PortDimensions','sps.UrefInport_PortDimensions')
        end
        if~wt_IsInport
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name','wt','BlockType','Ground','Inport','noprompt');
            set_param([block,'/wt'],'SampleTime','Ts')
        end

    case 'Unsynchronized'

        sps.ModulatingSignals=2;
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



    if ModulatingSignals==1
        UpdateVariant([block,'/','Reference signal'],'Internal');
    else
        UpdateVariant([block,'/','Reference signal'],'External');
    end

    switch ModulatorType
    case 'Single-phase half-bridge (2 pulses)'
        UpdateVariant([block,'/','Modulator type'],'OneThreePhaseBridge');
    case 'Single-phase full-bridge (4 pulses)'
        UpdateVariant([block,'/','Modulator type'],'FullBridgeUnipolar');
    case 'Single-phase full-bridge - Bipolar modulation (4 pulses)'
        UpdateVariant([block,'/','Modulator type'],'FullBridgeBipolar');
    case 'Three-phase bridge (6 pulses)'
        UpdateVariant([block,'/','Modulator type'],'OneThreePhaseBridge');
    end

    switch ModulatorMode

    case 'Synchronized'

        switch SamplingTechnique
        case 'Natural'
            UpdateVariant([block,'/','Sampling'],'SyncNatural');
        case 'Asymmetrical regular (double edge)'
            UpdateVariant([block,'/','Sampling'],'SyncAsymmetrical');
        case 'Symmetrical regular (single edge)'
            UpdateVariant([block,'/','Sampling'],'SyncSymmetrical');
        end

        UpdateVariant([block,'/','Reference signal'],'External');

    case 'Unsynchronized'

        switch SamplingTechnique
        case 'Natural'
            UpdateVariant([block,'/','Sampling'],'UnsyncNatural');
        case 'Asymmetrical regular (double edge)'
            UpdateVariant([block,'/','Sampling'],'UnsyncAsymmetrical');
            sps.SampleTimeZOH_AsymSampling=[1,mod(1-Pc/180,1)]*1/Fc/2;
        case 'Symmetrical regular (single edge)'
            UpdateVariant([block,'/','Sampling'],'UnsyncSymmetrical');
            sps.SampleTimeZOH_SymSampling=[1,mod(1-Pc/360,1)]*1/Fc;
        end

        ME=get_param(block,'MaskEnables');
        ME{10}='on';
        set_param(block,'MaskEnables',ME);
    end


    function UpdateVariant(block,Variant)

        if~isequal(get_param(block,'LabelModeActiveChoice'),Variant)
            set_param(block,'LabelModeActiveChoice',Variant);
        end