function varargout=SinglePhaseAsynchronousMachineInit(block,varargin)








    [TsPowergui,TsBlock,MechanicalLoad,UNITS,MachineType,NominalParameters,MainWindingStator,MainWindingRotor,MutualInductance,AuxiliaryWinding,Mechanical,CapacitorStart,CapacitorRun,DisconnectionSpeed,InitialSpeed,MeasurementBus]=varargin{1:end};


    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    [WantBlockChoice,Ts]=SetInternalModels('get',block,'Single Phase Asynchronous Machine',PowerguiInfo,TsPowergui,TsBlock,MechanicalLoad,MeasurementBus);


    X.p1=-55;
    Y.p1=-30;
    X.p2=55;
    Y.p2=90;
    X.p3=[0,10.8,21.6,28.8,34.8,36,34.8,28.8,21.6,10.8,0,-10.8,-21.6,-28.8,-34.8,-36,-34.8,-28.8,-21.6,-10.8,0];
    Y.p3=[56.1,54.78,48.18,40.26,28.38,16.5,4.62,-7.26,-15.18,-21.78,-23.1,-21.78,-15.18,-7.26,4.62,16.5,28.38,40.26,48.18,54.78,56.1]-8;
    X.p4=[-20,-43]-15;
    Y.p4=[50,50]-20;
    X.p5=[-18,-43]*.90-19;
    Y.p5=[-18,-18]+9;

    switch MachineType
    case 'Main & auxiliary windings'
        Y.p3=Y.p3+10;
        X.p6=[-35,-0,-0];
        Y.p6=[78,78,60];
    otherwise
        X.p6=[-35,-0,-0];
        Y.p6=[65,65,50];
    end

    X.p7=[55,35];
    Y.p7=[22,22];


    psbloadfunction(block,'gotofrom','Initialize');


    SinglePhaseAsynchronousMachineCback(block,'Machine type','UpdateBlock');
    SinglePhaseAsynchronousMachineCback(block,'Units','UpdateBlock');

    DownOrLeft=strcmp('down',get_param(block,'Orientation'))|strcmp('left',get_param(block,'Orientation'));
    switch MachineType
    case 'Split Phase'
        SM.EnableCrun=0;
        SM.EnableCstart=0;
        SM.TextIcon='\n\nsplit\nphase';
        if DownOrLeft
            SM.TextIcon='split\nphase\n\n';
        end
    case 'Capacitor-Start'
        SM.EnableCrun=0;
        SM.EnableCstart=1;
        SM.TextIcon='\n\ncapacitor\n-start';
        if DownOrLeft
            SM.TextIcon='capacitor\n-start\n\n';
        end
    case 'Capacitor-Start-Run'
        SM.EnableCrun=1;
        SM.EnableCstart=0;
        SM.TextIcon='\n\ncapacitor\n-start-run';
        if DownOrLeft
            SM.TextIcon='capacitor\n-start-run\n\n';
        end
    case 'Main & auxiliary windings'
        SM.EnableCrun=0;
        SM.EnableCstart=0;
        DisconnectionSpeed=inf;
        SM.TextIcon='\nMain &\nAuxiliary\nwindings';
        if DownOrLeft
            SM.TextIcon='Main &\nAuxiliary\nwindings\n\n';
        end
    end



    switch MechanicalLoad
    case 'Torque Tm'
        SM.PortLabel='Tm';
    otherwise
        SM.PortLabel=' ';
    end

    if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
        varargout={Ts,SM,WantBlockChoice,X,Y};
        return
    end





    Pn=NominalParameters(1);
    SM.Pn=Pn;
    Vn=NominalParameters(2);
    freq=NominalParameters(3);
    SM.p=Mechanical(3);


    BaseVoltage=sqrt(2)*Vn;
    BaseCurrent=sqrt(2)*Pn/Vn;
    FreqRads=2*pi*freq;
    BaseSpeed=FreqRads/SM.p;
    BaseTorque=Pn/BaseSpeed;
    BaseFlux=BaseVoltage/FreqRads;
    Zb=Vn^2/Pn;
    Lb=Zb/FreqRads;
    Cb=1/(Zb*FreqRads);


    if strcmp(UNITS,'SI')


        MainWindingStator=[MainWindingStator(1)/Zb,MainWindingStator(2)/Lb];
        MainWindingRotor=[MainWindingRotor(1)/Zb,MainWindingRotor(2)/Lb];
        MutualInductance=MutualInductance/Lb;
        AuxiliaryWinding=[AuxiliaryWinding(1)/Zb,AuxiliaryWinding(2)/Lb];

        J=Mechanical(1);
        F=Mechanical(2);
        SM.p=Mechanical(3);
        N=Mechanical(4);
        H=J*BaseSpeed^2/(2*Pn);
        F=F/(Pn/BaseSpeed^2);

        Mechanical=[H,F,SM.p,N];
        CapacitorStart=[CapacitorStart(1)/Zb,CapacitorStart(2)/Cb];
        CapacitorRun=[CapacitorRun(1)/Zb,CapacitorRun(2)/Cb];


        SM.ConvertMeasurements_1=[BaseCurrent*ones(4,1);BaseFlux;BaseFlux;BaseCurrent;BaseCurrent;BaseFlux;BaseFlux;BaseVoltage];
        SM.ConvertMeasurements_2=[BaseSpeed;BaseTorque;1];
        SM.ConvertTorque=1/BaseTorque;

    else

        SM.ConvertMeasurements_1=1;
        SM.ConvertMeasurements_2=1;
        SM.ConvertTorque=1;
    end



    SM.BaseVoltage=BaseVoltage;
    SM.BaseCurrent=BaseCurrent;
    SM.FreqRads=FreqRads;

    SM.Rs=MainWindingStator(1);
    SM.Ls=MainWindingStator(2);
    SM.Rr=MainWindingRotor(1);
    SM.Lr=MainWindingRotor(2);
    SM.Lm=MutualInductance;
    SM.Raux=AuxiliaryWinding(1);
    SM.Laux=AuxiliaryWinding(2);
    SM.H=Mechanical(1);
    SM.F=Mechanical(2);
    SM.N=Mechanical(4);
    SM.Rstart=CapacitorStart(1);
    SM.Cstart=CapacitorStart(2);
    SM.Rrun=CapacitorRun(1);
    SM.Crun=CapacitorRun(2);
    SM.wc=DisconnectionSpeed/100;
    SM.w0=InitialSpeed/100;


    [WantBlockChoice,SM]=SPSrl('userblock','SinglePhaseasynchronousMachine',bdroot(block),WantBlockChoice,SM);
    power_initmask();


    varargout={Ts,SM,WantBlockChoice,X,Y};
