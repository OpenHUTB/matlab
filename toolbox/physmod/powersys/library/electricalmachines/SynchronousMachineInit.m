function varargout=SynchronousMachineInit(block,varargin)


















    [TsPowergui,TsBlock,MechanicalLoad,Units,RotorType,NominalParameters,Mechanical,PolePairs,InitialConditions,SimulateSaturation,Saturation,IterativeModel,MeasurementBus]=varargin{1:13};



    PowerguiInfo=getPowerguiInfo(bdroot(block),block);


    Ts=PowerguiInfo.Ts;


    if TsPowergui~=0



        Ts=TsPowergui;
    end
    if TsBlock~=-1

        Ts=TsBlock;
    end



    PmInput=strcmp(MechanicalLoad,'Mechanical power Pm');
    LocallyWantDSS=0;

    if PowerguiInfo.Continuous

        WantBlockChoice{1}='Continuous';

        switch MechanicalLoad
        case 'Mechanical rotational port'
            WantBlockChoice{2}='Shaft input';
        otherwise
            if PmInput
                WantBlockChoice{2}='Continuous Pm input';
            else
                WantBlockChoice{2}='Continuous w input';
            end
        end
    end

    IM='';
    if PowerguiInfo.Discrete

        switch IterativeModel
        case 'Forward Euler'
            IM=IterativeModel;
        otherwise
            IM=get_param(block,'IterativeDiscreteModel');
        end

        switch IM
        case{'Backward Euler robust','Trapezoidal robust'}
            LocallyWantDSS=1;
        otherwise
            LocallyWantDSS=0;
        end

        if PowerguiInfo.WantDSS||LocallyWantDSS
            if SimulateSaturation
                WantBlockChoice{1}='Discrete robust saturation';
            else
                WantBlockChoice{1}='Discrete robust';
            end
            Ts=PowerguiInfo.Ts;

        else

            switch IM
            case 'Forward Euler'
                WantBlockChoice{1}='Discrete';
            otherwise
                WantBlockChoice{1}='Discrete trapezoidal';
            end

        end

        switch MechanicalLoad
        case 'Mechanical rotational port'
            switch IM
            case 'Forward Euler'
                WantBlockChoice{2}='Shaft input BAL';
            otherwise
                WantBlockChoice{2}='Shaft input';
            end
        otherwise
            if PmInput
                switch IM
                case 'Forward Euler'
                    WantBlockChoice{2}='Discrete Pm input';
                otherwise
                    WantBlockChoice{2}='Discrete Pm input trapezoidal';
                end
            else
                WantBlockChoice{2}='Discrete w input';
            end
        end

    end

    if PowerguiInfo.Phasor

        WantBlockChoice{1}='Phasor';

        switch MechanicalLoad
        case 'Mechanical rotational port'
            WantBlockChoice{2}='Shaft input';
        otherwise
            if PmInput
                WantBlockChoice{2}='Phasor Pm input';
            else
                WantBlockChoice{2}='Phasor w input';
            end
        end
    end

    if PowerguiInfo.DiscretePhasor

        WantBlockChoice{1}='Discrete phasor';
        switch MechanicalLoad
        case 'Mechanical rotational port'
            WantBlockChoice{2}='Shaft input';
        otherwise
            if PmInput
                WantBlockChoice{2}='Discrete phasor Pm input';
            else
                WantBlockChoice{2}='Discrete phasor w input';
            end
        end
    end

    if MeasurementBus
        WantBlockChoice{3}='Uniform';
    else
        switch Units
        case 'per unit fundamental parameters'
            WantBlockChoice{3}='Measurement puf';
        case 'per unit standard parameters'
            WantBlockChoice{3}='Measurement pu';
        case 'SI fundamental parameters'
            WantBlockChoice{3}='Measurement SI';
        end

    end



    X.p1=-60;
    Y.p1=-10;
    X.p2=60;
    Y.p2=80;
    X.p3=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0]*1.2;
    Y.p3=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30]*1.2+15;
    X.p4=[23,48];
    Y.p4=[27,27]+15;
    X.p5=[36,48];
    Y.p5=[15,15];
    X.p6=[23,48];
    Y.p6=[-27,-27]+15;
    X.p7=[0,-9,-18,-24,-16,-16,-24,-18,-9,0,9,18,24,16,16,24,18,9,0];
    Y.p7=[-30,-29,-24,-18,-18,18,18,24,29,30,29,24,18,18,-18,-18,-24,-29,-30]+15;
    X.p8=[0,0,40];
    Y.p8=[50,68,68];
    X.p9=[-35,-25];
    Y.p9=[50,40];



    if PowerguiInfo.Discrete
        if PowerguiInfo.WantDSS||LocallyWantDSS
            psbloadfunction(block,'gotofromDSS','Initialize');
        else
            psbloadfunction(block,'gotofromNoDSS','Initialize');
        end
    elseif PowerguiInfo.DiscretePhasor
        psbloadfunction(block,'gotofromDSS','Initialize');
    else
        psbloadfunction(block,'gotofromNoDSS','Initialize');
    end




    SynchronousMachineCback(block,Units,'UpdateBlock');

    switch MechanicalLoad
    case 'Mechanical power Pm'
        SM.PortLabel='Pm';
    case 'Mechanical rotational port'
        SM.PortLabel=' ';
    otherwise
        SM.PortLabel='w';
        Mechanical=[1,1,1];

    end

    if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
        varargout={Ts,SM,WantBlockChoice,X,Y};
        return
    end




    if SimulateSaturation

        if size(Saturation,1)~=2
            message=['In mask of ''',block,''' block:',newline,...
            'Saturation data must be a 2-by-N array for N points.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        if Saturation(1,1)==0&&Saturation(2,1)==0
            Saturation=Saturation(:,2:end);
        end

    end



    switch Units

    case{'SI fundamental parameters','per unit fundamental parameters'}

        [Stator,Field,Dampers1,Dampers2]=varargin{14:17};

        switch RotorType
        case 'Salient-pole'
            Dampers=[Dampers1,0,inf];
        case 'Round'
            Dampers=Dampers2;
        end

    case 'per unit standard parameters'

        [StatorResistance,Reactances1,Reactances2,dAxisTimeConstants,qAxisTimeConstants,TimeConstants1,TimeConstants2,TimeConstants3,TimeConstants4,TimeConstants5,TimeConstants6,TimeConstants7,TimeConstants8]=varargin{14:26};

        sit=strcmp(RotorType,'Round')+strcmp(qAxisTimeConstants,'Short-circuit')*2+strcmp(dAxisTimeConstants,'Short-circuit')*4;
        switch sit
        case 0,MaskParameter1=Reactances2;MaskParameter2=TimeConstants1;
        case 1,MaskParameter1=Reactances1;MaskParameter2=TimeConstants2;
        case 2,MaskParameter1=Reactances2;MaskParameter2=TimeConstants3;
        case 3,MaskParameter1=Reactances1;MaskParameter2=TimeConstants4;
        case 4,MaskParameter1=Reactances2;MaskParameter2=TimeConstants5;
        case 5,MaskParameter1=Reactances1;MaskParameter2=TimeConstants6;
        case 6,MaskParameter1=Reactances2;MaskParameter2=TimeConstants7;
        case 7,MaskParameter1=Reactances1;MaskParameter2=TimeConstants8;
        end
        MaskParameter3=StatorResistance;

    end



    switch Units
    case 'per unit fundamental parameters'
        if length(Stator)==5
            Xc=Stator(5);
        else
            Xc=0;
        end
    end



    switch Units
    case 'SI fundamental parameters'
        [NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,Saturation,Xc]=SynchronousMachineSItoPU(block,NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,SimulateSaturation,Saturation,PolePairs);
    end



    switch Units
    case 'per unit standard parameters'
        [NominalParameters,Stator,Field,Dampers,Mechanical,InitialConditions,~,Saturation,Xc]=SynchronousMachineConvert(NominalParameters,MaskParameter1,MaskParameter2,MaskParameter3,Mechanical,InitialConditions,SimulateSaturation,Saturation,sit,block);
    end



    SM=SynchronousMachineParam(MechanicalLoad,NominalParameters,Stator,Field,Dampers,Mechanical,PolePairs,InitialConditions,SimulateSaturation,Saturation,0,Units,1,RotorType,IM,PowerguiInfo.LoadFlowFrequency,Xc);

    if PowerguiInfo.DiscretePhasor

        SM.VfGain=[];
        SM.DSSmethod=[];
        SM.phiqd0_d=[];
    end

    if PowerguiInfo.Discrete||PowerguiInfo.DiscretePhasor

        if PowerguiInfo.WantDSS||LocallyWantDSS||PowerguiInfo.DiscretePhasor

            switch Units
            case 'SI fundamental parameters'
                SM.VfGain=1/SM.vfn;
            otherwise
                SM.VfGain=1;
            end

            if strcmp(IM,'Trapezoidal robust')||PowerguiInfo.WantDSS

                SM.DSSmethod=2;
            else
                SM.DSSmethod=1;
            end

            if PowerguiInfo.DiscretePhasor,SM.DSSmethod=2;end


            dw=InitialConditions(1);
            wr=1+dw/100;

            W=zeros(SM.nState,SM.nState);
            W(1,2)=wr;
            W(2,1)=-wr;
            A=-(W+SM.RLinv)*SM.web;









            Bu=-A*SM.phiqd0;
            switch SM.DSSmethod
            case 1

                SM.phiqd0_d=(eye(SM.nState,SM.nState)-Ts*A)*SM.phiqd0/Ts-Bu;

            case 2

                SM.phiqd0_d=(eye(SM.nState,SM.nState)-Ts/2*A)*SM.phiqd0/Ts-Bu/2;

            end



            if PowerguiInfo.DiscretePhasor,SM.phiqd0_d=SM.phiqd0_d(3:end);end

        end
    end



    [WantBlockChoice,SM]=SPSrl('userblock','SynchronousMachine',bdroot(block),WantBlockChoice,SM);
    power_initmask();




    PolePairsAreDifferent=~isequal(PolePairs,Mechanical(3));

    switch MechanicalLoad
    case 'Mechanical power Pm'

        if PolePairsAreDifferent

            PolePairs=Mechanical(3);
            if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
                set_param(block,'PolePairs',mat2str(PolePairs));
            end
        end

        SM.PortLabel='Pm';

    case 'Mechanical rotational port'

        if PolePairsAreDifferent

            PolePairs=Mechanical(3);
            if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
                set_param(block,'PolePairs',mat2str(PolePairs));
            end
        end

        SM.PortLabel=' ';

    otherwise

        if PolePairsAreDifferent

            Mechanical(3)=PolePairs;
            if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
                set_param(block,'Mechanical',mat2str(Mechanical));
            end
        end

        SM.PortLabel='w';
    end




    varargout={Ts,SM,WantBlockChoice,X,Y};