function varargout=AsynchronousMachineInit(block,varargin)








    [TsPowergui,TsBlock,MechanicalLoad,RotorType,ReferenceFrame,NominalParameters,VoltageRatio,Stator,Rotor,Cage1,Cage2,Lm,Mechanical,PolePairs,InitialConditions,Units,SimulateSaturation,Saturation,IterativeModel,MeasurementBus]=varargin{1:end};



    PowerguiInfo=getPowerguiInfo(bdroot(block),block);


    Ts=PowerguiInfo.Ts;


    if TsPowergui~=0



        Ts=TsPowergui;
    end
    if TsBlock~=-1

        Ts=TsBlock;
    end



    DoubleCage=strcmp(RotorType,'Double squirrel-cage');
    TmInput=strcmp(MechanicalLoad,'Torque Tm');
    LocallyWantDSS=0;

    if PowerguiInfo.Continuous
        if DoubleCage
            WantBlockChoice{1}='Continuous double-cage';
        else
            WantBlockChoice{1}='Continuous';
        end
        switch MechanicalLoad
        case 'Mechanical rotational port'
            WantBlockChoice{2}='Shaft input';
        otherwise
            if TmInput
                WantBlockChoice{2}='Continuous Tm input';
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
            if DoubleCage
                WantBlockChoice{1}=[WantBlockChoice{1},' double-cage'];
            end
            Ts=PowerguiInfo.Ts;

        else
            if DoubleCage
                WantBlockChoice{1}='Discrete double-cage';
            else
                switch IM
                case 'Forward Euler'
                    WantBlockChoice{1}='Discrete';
                otherwise
                    WantBlockChoice{1}='Discrete trapezoidal';
                end
            end
        end

        switch MechanicalLoad
        case 'Mechanical rotational port'
            WantBlockChoice{2}='Shaft input';
        otherwise
            if TmInput
                switch IM
                case 'Forward Euler'
                    WantBlockChoice{2}='Discrete Tm input';
                otherwise
                    WantBlockChoice{2}='Discrete Tm input trapezoidal';
                end
            else
                WantBlockChoice{2}='Discrete w input';
            end
        end

    end

    if PowerguiInfo.Phasor
        if DoubleCage
            WantBlockChoice{1}='Phasor double-cage';
        else
            WantBlockChoice{1}='Phasor';
        end
        switch MechanicalLoad
        case 'Mechanical rotational port'
            WantBlockChoice{2}='Phasor shaft input';
        otherwise
            if TmInput
                WantBlockChoice{2}='Phasor Tm input';
            else
                WantBlockChoice{2}='Phasor w input';
            end
        end
    end

    if PowerguiInfo.DiscretePhasor
        if DoubleCage
            WantBlockChoice{1}='Discrete phasor double-cage';
        else
            WantBlockChoice{1}='Discrete phasor';
        end
        switch MechanicalLoad
        case 'Mechanical rotational port'
            WantBlockChoice{2}='Discrete phasor shaft input';
        otherwise
            if TmInput
                WantBlockChoice{2}='Discrete phasor Tm input';
            else
                WantBlockChoice{2}='Discrete phasor w input';
            end
        end
    end

    if DoubleCage
        WantBlockChoice{3}='Double-cage';
    else
        WantBlockChoice{3}='Single-cage';
    end

    if MeasurementBus
        WantBlockChoice{3}=[WantBlockChoice{3},' uniform'];
    else

        WantBlockChoice{3}=[WantBlockChoice{3},' ',Units];
    end




    X.p1=-55;
    Y.p1=-30;
    X.p2=55;
    Y.p2=90;
    X.p3=[0,10.8,21.6,28.8,34.8,36,34.8,28.8,21.6,10.8,0,-10.8,-21.6,-28.8,-34.8,-36,-34.8,-28.8,-21.6,-10.8,0];
    Y.p3=[56.1,54.78,48.18,40.26,28.38,16.5,4.62,-7.26,-15.18,-21.78,-23.1,-21.78,-15.18,-7.26,4.62,16.5,28.38,40.26,48.18,54.78,56.1];
    X.p4=[-20,-43];
    Y.p4=[50,50];
    X.p5=[-36,-43];
    Y.p5=[15,15];
    X.p6=[-18,-43];
    Y.p6=[-18,-18];

    iconString=' ';
    switch RotorType

    case 'Wound'

        X.p7=[15,30,43];
        Y.p7=[40,50,50];
        X.p8=[45,27];
        Y.p8=[15,15];
        X.p9=[15,30,43];
        Y.p9=[-9,-18,-18];

        X.p11=[-30,-10,-10];
        Y.p11=[70,70,55];
        X.p12=[35,10,10];
        Y.p12=[70,70,55];

    case{'Squirrel-cage','Double squirrel-cage'}

        X.p7=15;
        Y.p7=40;
        X.p8=45;
        Y.p8=15;
        X.p9=15;
        Y.p9=-9;

        X.p11=[-30,-10,-10];
        Y.p11=[70,70,55];
        X.p12=X.p11;
        Y.p12=Y.p11;
        if strcmp(RotorType,'Squirrel-cage')
            iconString='';
        else
            iconString=['double',newline,'cage'];
        end

    end

    X.p10=X.p3*0.75;
    Y.p10=Y.p3*0.75+4;



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



    AsynchronousMachineCback(block,Units,'UpdateBlock');

    switch MechanicalLoad
    case 'Torque Tm'
        SM.PortLabel='Tm';
    case 'Mechanical rotational port'
        SM.PortLabel=' ';
    otherwise
        SM.PortLabel='w';
    end

    if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
        varargout={Ts,SM,WantBlockChoice,X,Y,iconString};
        return
    end



    if SimulateSaturation

        if size(Saturation,1)~=2
            error(message('physmod:powersys:common:InvalidVectorParameter','[i(Arms);v(VLL rms)]',block,'2','N'))
        end

        if Saturation(1,1)==0&&Saturation(2,1)==0
            Saturation=Saturation(:,2:end);
        end

    end



    switch Units
    case 'SI'
        [NominalParameters,Stator,Rotor,Cage1,Cage2,Lm,Mechanical,InitialConditions,Saturation]=AsynchronousMachineConvert(MechanicalLoad,NominalParameters,Stator,Rotor,Cage1,Cage2,Lm,Mechanical,PolePairs,InitialConditions,SimulateSaturation,Saturation);
    end


    if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        ReferenceFrame=3;
    elseif PowerguiInfo.Discrete
        if PowerguiInfo.AutomaticDiscreteSolvers
            ReferenceFrame=1;
        else
            if strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust')
                ReferenceFrame=1;
            end
        end
    end

    SM=AsynchronousMachineParam(MechanicalLoad,RotorType,ReferenceFrame,NominalParameters,VoltageRatio,Stator,Rotor,Cage1,Cage2,Lm,Mechanical,PolePairs,InitialConditions,Units,SimulateSaturation,Saturation,IM,PowerguiInfo.LoadFlowFrequency);

    if PowerguiInfo.DiscretePhasor

        SM.VIselector=[];
        SM.Tv_init=[];
        SM.Ti_init=[];
        SM.DSSmethod=[];
        SM.phiqd0_d=[];
    end



    Vr_Vs=SM.VoltageRatio;

    switch RotorType
    case 'Wound'
        SM.Gain_Vr_Vs=[1/Vr_Vs,1/Vr_Vs,1,1];
        SM.TvGainMatrix_Vr_Vs=diag([1,1,1/Vr_Vs,1/Vr_Vs]);
        SM.TiGainMatrix_Vr_Vs=diag([1,1,1/Vr_Vs,1/Vr_Vs]);

    case 'Squirrel-cage'
        SM.Gain_Vr_Vs=[1,1];
        SM.TvGainMatrix_Vr_Vs=diag([1,1]);
        SM.TiGainMatrix_Vr_Vs=diag([1,1,1,1]);
    end


    switch Units
    case 'SI'
        SM.kVr=Vr_Vs;
        SM.kIr=1/Vr_Vs;
    case 'pu'
        SM.kVr=1;
        SM.kIr=1;
    end



    if PowerguiInfo.Discrete||PowerguiInfo.DiscretePhasor

        if PowerguiInfo.WantDSS||LocallyWantDSS||PowerguiInfo.DiscretePhasor

            switch RotorType
            case 'Wound'
                SM.VIselector=[3,4,1,2];
                SM.Tv_init=[0,0,0,0;0,0,0,0;0,0,2/3,1/3;0,0,0,-sqrt(3)/3]/SM.Vb;
                SM.Ti_init=[0,0,0,0;0,0,0,0;0,0,1,0;0,0,-0.5,-sqrt(3)/2]*SM.ib;
                W=zeros(4,4);


            case 'Squirrel-cage'
                SM.VIselector=[1,2];
                SM.Tv_init=[0,0;0,0;0,0;0,0]/SM.Vb;
                SM.Ti_init=[0,0,0,0;0,0,0,0]*SM.ib;
                W=zeros(4,4);

            case 'Double squirrel-cage'
                SM.VIselector=[1,2];
                SM.Tv_init=zeros(6,2)/SM.Vb;
                SM.Ti_init=zeros(2,6)*SM.ib;
                W=zeros(6,6);

            end

            if strcmp(IM,'Trapezoidal robust')||PowerguiInfo.WantDSS

                SM.DSSmethod=2;
            else
                SM.DSSmethod=1;
            end

            if PowerguiInfo.DiscretePhasor,SM.DSSmethod=2;end


            s=InitialConditions(1);
            wr=1-s;



            W(1,2)=wr;
            W(2,1)=-wr;

            A=-(W+SM.RLinv)*SM.web;






            nstates=size(A,1);


            Bu=-A*SM.phiqd0;
            switch SM.DSSmethod
            case 1


                SM.phiqd0_d=(eye(nstates,nstates)-Ts*A)*SM.phiqd0/Ts-Bu;

            case 2


                SM.phiqd0_d=(eye(nstates,nstates)-Ts*A)*SM.phiqd0/Ts-Bu/2;

            end


        end
    end


    power_initmask();



    [WantBlockChoice,SM]=SPSrl('userblock','AsynchronousMachine',bdroot(block),WantBlockChoice,SM);


    PolePairsAreDifferent=~isequal(PolePairs,Mechanical(3));

    switch MechanicalLoad
    case 'Torque Tm'

        if PolePairsAreDifferent

            PolePairs=Mechanical(3);
            if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
                set_param(block,'PolePairs',mat2str(PolePairs));
            end
        end

        SM.PortLabel='Tm';

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



    varargout={Ts,SM,WantBlockChoice,X,Y,iconString};
