function[ST,Ts,WantBlockChoice]=TransformerBlocksInit(TypeOfWindings,block,NominalPower,Winding1Connection,Winding1,Winding2Connection,Winding2,Winding3Connection,SetSaturation,Saturation,WantHysteresis,SetInitialFlux,InitialFluxes,UNITS,DataFile,RmLm)













    WantBlockChoice='Linear';

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;
    LocallyWantDSS=0;

    switch TypeOfWindings

    case 'Two Windings Inductance Matrix'


        [ST.w1x,ST.w1y,ST.g1x,ST.g1y,ST.w2x,ST.w2y,ST.g2x,ST.g2y,ST.satx,ST.saty]=ThreePhaseTransformer2Icon(Winding1Connection,Winding2Connection,0);

        ThreePhaseTransformersCback('Two Windings Inductance Matrix',block,'AccessToNeutrals',1);
        ThreePhaseTransformersCback('Two Windings Inductance Matrix',block,'AccessToNeutrals',2);
        power_initmask();

        ST.label1.xy=[-100,-120];
        ST.label2.xy=[+70,-120];

        switch Winding1Connection
        case 1
            ST.label1.name='Y';
        case 2
            ST.label1.name='Yn';
        case 3
            ST.label1.name='Yg';
        case 4
            ST.label1.name='D1';
        case 5
            ST.label1.name='D11';
        end
        switch Winding2Connection
        case 1
            ST.label2.name='Y';
        case 2
            ST.label2.name='Yn';
        case 3
            ST.label2.name='Yg';
        case 4
            ST.label2.name='D1';
        case 5
            ST.label2.name='D11';
        end

        return

    case 'Three Windings Inductance Matrix'


        [ST.w1x,ST.w1y,ST.g1x,ST.g1y,ST.w2x,ST.w2y,ST.g2x,ST.g2y,ST.w3x,ST.w3y,ST.g3x,ST.g3y,ST.satx,ST.saty,ST.p]=ThreePhaseTransformer3Icon(Winding1Connection,Winding2Connection,Winding3Connection,0);

        ThreePhaseTransformersCback('Two Windings Inductance Matrix',block,'AccessToNeutrals',1);
        ThreePhaseTransformersCback('Two Windings Inductance Matrix',block,'AccessToNeutrals',2);
        ThreePhaseTransformersCback('Two Windings Inductance Matrix',block,'AccessToNeutrals',3);
        power_initmask();

        ST.label1.xy=[-120,50];
        ST.label2.xy=[+60,150];
        ST.label3.xy=[+60,-140];

        switch Winding1Connection
        case 1
            ST.label1.name='Y';
        case 2
            ST.label1.name='Yn';
        case 3
            ST.label1.name='Yg';
        case 4
            ST.label1.name='D1';
        case 5
            ST.label1.name='D11';
        end
        switch Winding2Connection
        case 1
            ST.label2.name='Y';
        case 2
            ST.label2.name='Yn';
        case 3
            ST.label2.name='Yg';
        case 4
            ST.label2.name='D1';
        case 5
            ST.label2.name='D11';
        end
        switch Winding3Connection
        case 1
            ST.label3.name='Y';
        case 2
            ST.label3.name='Yn';
        case 3
            ST.label3.name='Yg';
        case 4
            ST.label3.name='D1';
        case 5
            ST.label3.name='D11';
        end

        return

    case 'Single Phase'

        NumberOfInternalModels=1;
        SaturableTransformerCback(block,'winding 3');
        [ST.p1,ST.p2,ST.p3,ST.p4,ST.p5,ST.p6,ST.p7,ST.p8,ST.mot,ST.t1]=SaturableTransformerIcon(Winding3Connection);

        BaseVoltage=Winding1(1);


        if length(SetInitialFlux)==2
            InitialFluxes=[SetInitialFlux(2),0,0];
        else


            switch UNITS
            case 2
                Base=BaseValues(NominalPower,NumberOfInternalModels,BaseVoltage);
                InitialFluxes(1)=InitialFluxes(1)/Base.Flux;
            end
        end

        IM=get_param(block,'DiscreteSolver');
        if PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end

    case 'Single Phase Linear'

        NumberOfInternalModels=1;
        LinearTransformerCback(block,'winding 3');
        BaseVoltage=Winding1(1);

    case 'Multi-Windings'

        NumberOfInternalModels=1;
        NumberOfTaps=Winding1Connection;
        TappedWindings=Winding2Connection;


        NWindingsTransformerCback(block,0,'Callback');

        NWindingsTransformerCback(block,0,'selected units');

        [ST.lx,ST.ly,ST.rx,ST.ry,ST.hlx,ST.hly,ST.hrx,ST.hry]=NWindingsTransformerIcon;

        if TappedWindings==2
            BaseVoltage=Winding1(1)/(NumberOfTaps+1);
        else
            BaseVoltage=Winding1(1);
        end

        IM=get_param(block,'DiscreteSolver');
        if PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end

    case 'Two Windings'

        NumberOfInternalModels=3;

        ThreePhaseTransformersCback(TypeOfWindings,block,'AccessToNeutrals',1);
        ThreePhaseTransformersCback(TypeOfWindings,block,'AccessToNeutrals',2);

        [ST.w1x,ST.w1y,ST.g1x,ST.g1y,ST.w2x,ST.w2y,ST.g2x,ST.g2y,ST.satx,ST.saty]=ThreePhaseTransformer2Icon(Winding1Connection,Winding2Connection,SetSaturation);

        if Winding1Connection<=3
            BaseVoltage=Winding1(1)/sqrt(3);
        else
            BaseVoltage=Winding1(1);
        end

        ST.label1.xy=[-100,-120];
        ST.label2.xy=[+70,-120];

        switch Winding1Connection
        case 1
            ST.label1.name='Y';
        case 2
            ST.label1.name='Yn';
        case 3
            ST.label1.name='Yg';
        case 4
            ST.label1.name='D1';
        case 5
            ST.label1.name='D11';
        end
        switch Winding2Connection
        case 1
            ST.label2.name='Y';
        case 2
            ST.label2.name='Yn';
        case 3
            ST.label2.name='Yg';
        case 4
            ST.label2.name='D1';
        case 5
            ST.label2.name='D11';
        end

        IM=get_param(block,'DiscreteSolver');
        if PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end

    case 'Three Windings'

        NumberOfInternalModels=3;

        ThreePhaseTransformersCback(TypeOfWindings,block,'AccessToNeutrals',1);
        ThreePhaseTransformersCback(TypeOfWindings,block,'AccessToNeutrals',2);
        ThreePhaseTransformersCback(TypeOfWindings,block,'AccessToNeutrals',3);

        [ST.w1x,ST.w1y,ST.g1x,ST.g1y,ST.w2x,ST.w2y,ST.g2x,ST.g2y,ST.w3x,ST.w3y,ST.g3x,ST.g3y,ST.satx,ST.saty,ST.p]=ThreePhaseTransformer3Icon(Winding1Connection,Winding2Connection,Winding3Connection,SetSaturation);

        if Winding1Connection<=3
            BaseVoltage=Winding1(1)/sqrt(3);
        else
            BaseVoltage=Winding1(1);
        end

        ST.label1.xy=[-120,50];
        ST.label2.xy=[+60,150];
        ST.label3.xy=[+60,-140];

        switch Winding1Connection
        case 1
            ST.label1.name='Y';
        case 2
            ST.label1.name='Yn';
        case 3
            ST.label1.name='Yg';
        case 4
            ST.label1.name='D1';
        case 5
            ST.label1.name='D11';
        end
        switch Winding2Connection
        case 1
            ST.label2.name='Y';
        case 2
            ST.label2.name='Yn';
        case 3
            ST.label2.name='Yg';
        case 4
            ST.label2.name='D1';
        case 5
            ST.label2.name='D11';
        end
        switch Winding3Connection
        case 1
            ST.label3.name='Y';
        case 2
            ST.label3.name='Yn';
        case 3
            ST.label3.name='Yg';
        case 4
            ST.label3.name='D1';
        case 5
            ST.label3.name='D11';
        end

        IM=get_param(block,'DiscreteSolver');
        if PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end

    case 'Zigzag'

        NumberOfInternalModels=3;

        ZigzagTransformerCback(block,'AccessToNeutrals');

        [ST.pzx1,ST.pzy1,ST.pzx2,ST.pzy2,ST.pzx3,ST.pzy3,ST.px1,ST.py1,ST.px2,ST.py2,ST.pgx1,ST.pgy1,ST.pgx2,ST.pgy2,ST.pgx3,ST.pgy3,ST.pgx4,ST.pgy4,ST.satx,ST.saty]=powericon('ZigzagTransformerIcon',Winding2,Winding2Connection,SetSaturation);

        alpha_deg=abs(Winding2(2));
        BaseVoltage=Winding1/sqrt(3)*sin(2*pi/3-alpha_deg*pi/180)/sin(pi/3);

        IM=get_param(block,'DiscreteSolver');
        if PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end

    end

    Base=BaseValues(NominalPower,NumberOfInternalModels,BaseVoltage);

    if UNITS==1
        ST.Rm=RmLm(1);
        ST.Lm=RmLm(2);
    else
        ST.Rm=RmLm(1)*Base.Resistance;
        ST.Lm=RmLm(2)*Base.Impedance;
    end

    if LocallyWantDSS&&WantHysteresis
        LocallyWantDSS=0;
    end

    if SetSaturation

        [ST.InitialFlux1,ST.InitialFlux2,ST.InitialFlux3,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,UNITS,InitialFluxes,Base);

        switch TypeOfWindings
        case 'Multi-Windings'
            if TappedWindings==2
                SaturationCurrent=SaturationCurrent*(NumberOfTaps+1)^2;
            end
        end
        if PowerguiInfo.WantDSS||LocallyWantDSS
            for i=2:size(Saturation,1)
                if Saturation(i,1)<=Saturation((i-1),1)||Saturation(i,2)<=Saturation((i-1),2)
                    message=[
                    'The specifed saturation characteristic for block ',block,' must be strictly increasing. ',...
                    'A problem has been detected with pair no.',num2str(i)];
                    erreur.message=message;
                    erreur.identifier='SimscapePowerSystemsST:BlockParameterError';
                    psberror(erreur)
                end

            end
        end

        if WantHysteresis


            if~contains(DataFile,'.mat')
                DataFile=[DataFile,'.mat'];
            end

            if~exist(DataFile,'file')


                HT=[];
                Base.Current=1;
                Base.Flux=1;

                SimulationStatus=get_param(bdroot(block),'SimulationStatus');
                if isequal('initializing',SimulationStatus)
                    Erreur.message=['Undefined hysteresis MAT file ''',DataFile,''' in block: ',block];
                    Erreur.identifier='SpecializedPowerSystems:TransformerBlocks:UndefinedMATfile';
                    psberror(Erreur.message,Erreur.identifier);
                end

            else

                [InitialFlux1_pu,ST.Tolerances,HT,ST.UpperFlux,ST.LowerFlux,ST.Current]=inithysteresis(DataFile,Base.Flux,Base.Current,ST.InitialFlux1);
                HT=InitialTrajectory(HT,InitialFlux1_pu,1);
                if HT.UnitsPopup==2



                    Base.Current=1;
                    Base.Flux=1;
                end

            end

            ST.HT=HT;
            ST.BaseCurrent=Base.Current;
            ST.BaseFlux=Base.Flux;


            ST.SaturationCurrent=[];
            ST.SaturationFlux=[];

        else

            ST.SaturationCurrent=SaturationCurrent;
            ST.SaturationFlux=SaturationFlux;


            ST.Tolerances=[];
            ST.UpperFlux=[];
            ST.LowerFlux=[];
            ST.Current=[];
            ST.HT=[];
            ST.BaseCurrent=[];
            ST.BaseFlux=[];

        end

    end

    switch TypeOfWindings
    case 'Multi-Windings'
        ST.InitialFlux1=InitialFluxes(1);
        if SetInitialFlux&&UNITS==2
            ST.InitialFlux1=InitialFluxes(1)*Base.Flux;
        end
    end



    switch get_param(block,'Measurements')
    case{'Flux and excitation current ( Imag + IRm )',...
        'Flux and magnetization current ( Imag )',...
        'Fluxes and excitation currents ( Imag + IRm )',...
        'Fluxes and excitation currents (Imag + IRm)',...
        'Fluxes and magnetization currents ( Imag )',...
        'Fluxes and magnetization currents (Imag)',...
        'All measurements (V I Flux)',...
        'All measurements (V I Fluxes)',...
        'Magnetization current',...
        'All voltages and currents'}
        MesureFlux=1;
    otherwise
        MesureFlux=0;
    end

    if isequal(bdroot(block),'powerlib')
        return
    end

    LinearFlux=0;


    Multimeter=~isempty(find_system(bdroot(block),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','Functional','FollowLinks','on','MaskType','Multimeter'));

    if(PowerguiInfo.WantDSS||LocallyWantDSS)&&~strcmp(TypeOfWindings,'Single Phase Linear')&&SetSaturation
        WantBlockChoice='Discrete_DSS';
    else

        if SetSaturation

            if PowerguiInfo.Discrete
                WantBlockChoice='Discrete';
                if WantHysteresis
                    WantBlockChoice=[WantBlockChoice,' Hysteresis'];
                end
                if strcmp(get_param(block,'BreakLoop'),'on')
                    WantBlockChoice=[WantBlockChoice,' Break Loop'];
                end
            else
                WantBlockChoice='Continuous';
                if WantHysteresis
                    WantBlockChoice=[WantBlockChoice,' Hysteresis'];
                end
            end

        else

            WantBlockChoice='Linear';
            if MesureFlux&&Multimeter
                WantBlockChoice='Linear flux';
                switch TypeOfWindings
                case{'Two Windings','Three Windings'}
                    switch get_param(block,'CoreType')
                    case 'Three-limb core (core-type)'
                        WantBlockChoice='Linear flux 3 Limb';
                    end
                end
                LinearFlux=1;
                if RmLm(2)==inf
                    if PowerguiInfo.Phasor
                        WantBlockChoice='NaNFluxphasor';
                    else
                        WantBlockChoice='NaNFlux';
                    end
                end
            end

        end

    end

    IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');

    for i=1:NumberOfInternalModels

        i_str=num2str(i);


        FromBlockIsaGround=strcmp(get_param([block,'/From',i_str],'BlockType'),'Ground');
        switch WantBlockChoice

        case 'Linear'

            if~FromBlockIsaGround
                replace_block(block,'Followlinks','on','Name',['From',i_str],'BlockType','From','Ground','noprompt');
            end

        otherwise

            if FromBlockIsaGround
                replace_block(block,'Followlinks','on','Name',['From',i_str],'BlockType','Ground','From','noprompt');
            end
            SetNewGotoTag([block,'/From',i_str],IsLibrary);

        end


        FromBlockIsaGround=strcmp(get_param([block,'/I_exc',i_str],'BlockType'),'Ground');

        if(PowerguiInfo.WantDSS||LocallyWantDSS)&&SetSaturation



            if FromBlockIsaGround
                replace_block(block,'Followlinks','on','Name',['I_exc',i_str],'BlockType','Ground','From','noprompt');
            end
            SetNewGotoTag([block,'/I_exc',i_str],IsLibrary);

        else

            if LinearFlux
                if FromBlockIsaGround
                    replace_block(block,'Followlinks','on','Name',['I_exc',i_str],'BlockType','Ground','From','noprompt');
                end
                SetNewGotoTag([block,'/I_exc',i_str],IsLibrary);
            else
                if~FromBlockIsaGround
                    replace_block(block,'Followlinks','on','Name',['I_exc',i_str],'BlockType','From','Ground','noprompt');
                end
            end

        end


        GotoblockIsATerminator=strcmp(get_param([block,'/Goto1',i_str],'BlockType'),'Terminator');
        if SetSaturation

            if GotoblockIsATerminator
                replace_block(block,'Followlinks','on','Name',['Goto1',i_str],'BlockType','Terminator','Goto','noprompt');
            end
            SetNewGotoTag([block,'/Goto1',i_str],IsLibrary);

        else

            if~GotoblockIsATerminator
                replace_block(block,'Followlinks','on','Name',['Goto1',i_str],'BlockType','Goto','Terminator','noprompt');
            end

        end


        GotoblockIsATerminator=strcmp(get_param([block,'/Goto2',i_str],'BlockType'),'Terminator');
        if LinearFlux||(SetSaturation&&MesureFlux&&Multimeter)

            if GotoblockIsATerminator
                replace_block(block,'Followlinks','on','Name',['Goto2',i_str],'BlockType','Terminator','Goto','noprompt');
            end
            SetNewGotoTag([block,'/Goto2',i_str],IsLibrary);

        else

            if~GotoblockIsATerminator
                replace_block(block,'Followlinks','on','Name',['Goto2',i_str],'BlockType','Goto','Terminator','noprompt');
            end

        end

    end

    [WantBlockChoice,ST]=SPSrl('userblock','TransformerBlocks',bdroot(block),WantBlockChoice,ST);
    power_initmask();