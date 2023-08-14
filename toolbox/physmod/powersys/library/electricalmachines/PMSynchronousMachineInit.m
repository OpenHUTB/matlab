function varargout=PMSynchronousMachineInit(block,TsPowergui,TsBlock,MechanicalLoad,RotorType,FluxDistribution,Resistance,Inductance,dqInductances,La,Flux,VoltageCst,TorqueCst,Flat,Mechanical,PolePairs,InitialConditions,InitialConditions5ph,MeasurementBus)






    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    [WantBlockChoice,Ts]=SetInternalModels('get',block,'Permanent Magnet Synchronous Machine',PowerguiInfo,TsPowergui,TsBlock,MechanicalLoad,MeasurementBus);
    Want5Phases=strcmp(get_param(block,'NbPhases'),'5');
    Want3Phases=strcmp(get_param(block,'NbPhases'),'3');

    SinusoidalMachine=strcmp(get_param(block,'FluxDistribution'),'Sinusoidal');

    IM=get_param(block,'IterativeDiscreteModel');

    if(PowerguiInfo.Discrete&&strcmp(IM,'Backward Euler robust'))||(PowerguiInfo.Discrete&&strcmp(IM,'Trapezoidal robust'))
        LocallyWantDSS=1;
    else
        LocallyWantDSS=0;
    end

    if PowerguiInfo.WantDSS||LocallyWantDSS
        if Want5Phases
            WantBlockChoice{1}='Discrete 5 phases_DSS';
            nStates=4;
        else
            nStates=2;
            if SinusoidalMachine
                WantBlockChoice{1}='Discrete_DSS';
            else
                WantBlockChoice{1}='Discrete Trapezoidal_DSS';
            end
        end
        Ts=PowerguiInfo.Ts;
    end



    if Want3Phases

        X.p1=-70;
        Y.p1=-20;
        X.p2=55;
        Y.p2=80;
        X.p3=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0]*1.2;
        Y.p3=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30]*1.2+15;
        X.p4=-[20,48];
        Y.p4=[45,45];
        X.p5=-[36,48];
        Y.p5=[15,15];
        X.p6=-[20,48];
        Y.p6=[-15,-15];
        X.p7=[-10,10,10,-10,-10];
        Y.p7=[38,38,-8,-8,38];
        X.p8=[-2.5,-2.5,2.5,2.5];
        Y.p8=[0,5,0,5]*1.75+25;
        X.p9=[0,5,10,10,0,0,5,10]*.5-2.5;
        Y.p9=[0,0,2,4,6,8,10,10]*.8;


        X.p10=X.p9;
        Y.p10=Y.p9;
        X.p11=X.p9;
        Y.p11=Y.p9;

        X.p12=[-40,0,0];
        Y.p12=[70,70,52];

    end

    if Want5Phases

        X.p1=-70;
        Y.p1=-20;
        X.p2=55;
        Y.p2=80;
        X.p3=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0]*1.2;
        Y.p3=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30]*1.2+15+6.5;
        X.p4=-[13,48];
        Y.p4=[55,55];
        X.p5=-[32,48];
        Y.p5=[38,38];
        X.p6=-[36,48];
        Y.p6=[21,21];
        X.p7=-[32,48];
        Y.p7=[4.5,4.5];
        X.p8=-[13,48];
        Y.p8=[-12,-12];
        X.p9=[-10,10,10,-10,-10];
        Y.p9=[38,38,-8,-8,38]+6.5;
        X.p10=[-2.5,-2.5,2.5,2.5];
        Y.p10=[0,5,0,5]*1.75+25+6.5;
        X.p11=[0,5,10,10,0,0,5,10]*.5-2.5;
        Y.p11=[0,0,2,4,6,8,10,10]*.8+6.5;
        X.p12=[-40,0,0];
        Y.p12=[70,70,52]+5;
    end


    if PowerguiInfo.WantDSS||LocallyWantDSS
        psbloadfunction(block,'gotofromDSS','Initialize');
    else
        psbloadfunction(block,'gotofromNoDSS','Initialize');
    end


    PMSynchronousMachineCback(block,'UpdatePorts','UpdateBlock');

    switch MechanicalLoad
    case 'Torque Tm'
        SM.PortLabel='Tm';
    case 'Mechanical rotational port'
        SM.PortLabel=' ';
    otherwise
        SM.PortLabel='w';
    end

    try




        switch get_param(block,'MechanicalLoad')
        case{'Torque Tm','Mechanical rotational port'}
            Mechanical=getSPSmaskvalues(block,{'Mechanical'});
            if size(Mechanical,2)==3||size(Mechanical,2)==4
                PolePairs=Mechanical(3);
            else
                PolePairs=getSPSmaskvalues(block,{'PolePairs'});
            end
        otherwise
            PolePairs=getSPSmaskvalues(block,{'PolePairs'});
        end


        FlatArea=getSPSmaskvalues(block,{'Flat'})';

        switch get_param(block,'MachineConstant')

        case 'Flux linkage established by magnets (V.s)'

            FluxCst=Flux;


            blocinit(block,{0,0,1,1,1,Flux,1,1});

            if Want5Phases
                VoltageCst=100*pi*PolePairs*Flux*(sqrt(5-sqrt(5))*sqrt(2)/6);
                TorqueCst=Flux*5*PolePairs/2;
            end
            if Want3Phases
                if SinusoidalMachine==1
                    VoltageCst=100*pi*PolePairs*Flux/sqrt(3);
                    TorqueCst=Flux*3*PolePairs/2;
                else
                    VoltageCst=Flux*PolePairs*sqrt(3)*(1000/30*pi)/(cos(min(FlatArea,60)*pi/360));
                    TorqueCst=Flux*PolePairs*sqrt(3)/(cos(min(FlatArea,60)*pi/360));
                end
            end

            if isequal('stopped',get_param(bdroot(block),'SimulationStatus'))
                if isfinite(VoltageCst)
                    set_param(block,'VoltageCst',num2str(VoltageCst));
                end
                if isfinite(TorqueCst)
                    set_param(block,'TorqueCst',num2str(TorqueCst));
                end
            end

        case 'Voltage Constant (V_peak L-L / krpm)'

            blocinit(block,{0,0,1,1,1,1,VoltageCst,1});

            if Want5Phases
                FluxCst=VoltageCst/(100*pi*PolePairs*(sqrt(5-sqrt(5))*sqrt(2)/6));
                TorqueCst=FluxCst*5*PolePairs/2;
            end
            if Want3Phases
                if SinusoidalMachine==1
                    FluxCst=sqrt(3)*VoltageCst/(100*pi*PolePairs);
                    TorqueCst=FluxCst*3*PolePairs/2;
                else
                    FluxCst=VoltageCst/(PolePairs*sqrt(3)*(1000/30*pi)/(cos(min(FlatArea,60)*pi/360)));
                    TorqueCst=FluxCst*PolePairs*sqrt(3)/(cos(min(FlatArea,60)*pi/360));
                end
            end

            if isequal('stopped',get_param(bdroot(block),'SimulationStatus'))
                if isfinite(FluxCst)
                    set_param(block,'Flux',num2str(FluxCst));
                end
                if isfinite(TorqueCst)
                    set_param(block,'TorqueCst',num2str(TorqueCst));
                end
            end

        case 'Torque Constant (N.m / A_peak)'


            blocinit(block,{0,0,1,1,1,1,1,TorqueCst});

            if Want5Phases
                FluxCst=2*TorqueCst/(5*PolePairs);
                VoltageCst=100*pi*PolePairs*FluxCst*(sqrt(5-sqrt(5))*sqrt(2)/6);
            end
            if Want3Phases
                if SinusoidalMachine==1
                    FluxCst=2*TorqueCst/(3*PolePairs);
                    VoltageCst=100*pi*PolePairs*FluxCst/sqrt(3);
                else
                    FluxCst=TorqueCst/(PolePairs*sqrt(3)/(cos(min(FlatArea,60)*pi/360)));
                    VoltageCst=FluxCst*PolePairs*sqrt(3)*(1000/30*pi)/(cos(min(FlatArea,60)*pi/360));
                end
            end

            if isequal('stopped',get_param(bdroot(block),'SimulationStatus'))
                if isfinite(FluxCst)
                    set_param(block,'Flux',num2str(FluxCst));
                end
                if isfinite(VoltageCst)
                    set_param(block,'VoltageCst',num2str(VoltageCst));
                end
            end

        end

    end

    if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
        varargout={Ts,SM,WantBlockChoice,X,Y};
        return
    end


    SM=PMSynchronousMachineParam(block,FluxCst,VoltageCst,PolePairs,InitialConditions,InitialConditions5ph);

    PolePairsAreDifferent=~isequal(PolePairs,Mechanical(3));

    switch MechanicalLoad

    case 'Torque Tm'

        if PolePairsAreDifferent

            PolePairs=Mechanical(3);
            if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
                set_param(block,'PolePairs',mat2str(PolePairs));
            end
        end
        SM.p=Mechanical(3);
        SM.PortLabel='Tm';

    case 'Mechanical rotational port'

        if PolePairsAreDifferent

            PolePairs=Mechanical(3);
            if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
                set_param(block,'PolePairs',mat2str(PolePairs));
            end
        end
        SM.p=Mechanical(3);
        SM.PortLabel=' ';

    otherwise

        SM.p=PolePairs;
        SM.PortLabel='w';
        if PolePairsAreDifferent

            Mechanical(3)=PolePairs;
            if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))
                set_param(block,'Mechanical',mat2str(Mechanical));
            end
        end

    end

    switch RotorType
    case 'Round'
        SM.Ld=La;
        SM.Lq=La;
        Rot_type=0;
    otherwise
        SM.Ld=dqInductances(1);
        SM.Lq=dqInductances(2);
        Rot_type=1;
    end

    SM.Ls=Inductance;
    SM.J=Mechanical(1);
    SM.F=Mechanical(2);

    if length(Mechanical)==4
        SM.Tf=Mechanical(4);
    else
        SM.Tf=0;
    end

    SM.R=Resistance;
    SM.L=Inductance;
    SM.trap=sin((pi-Flat/180*pi)/2);
    SM.sqrt3=sqrt(3);
    SM.one_third=1/3;


    if isequal('initializing',get_param(bdroot(block),'SimulationStatus'))
        blocinit(block,{FluxDistribution,Rot_type,SM.Ls,SM.Ld,SM.Lq,FluxCst,VoltageCst,TorqueCst});
    end


    if PowerguiInfo.WantDSS||LocallyWantDSS

        SM.nState=nStates;

        if strcmp(IM,'Trapezoidal robust')

            SM.DSSmethod=2;
        else
            SM.DSSmethod=1;
        end







        switch nStates
        case 2
            SM.x=[0;0];
            A=[0,0;0,0];

            Bu=-A*SM.x;
        case 4
            SM.x=[0;0;0;0];
            A=[0,0,0,0;0,0,0,0;0,0,0,0;0,0,0,0];

            Bu=-A*SM.x;

        end

        switch SM.DSSmethod
        case 1
            SM.x0_d=(eye(SM.nState,SM.nState)-Ts*A)*SM.x/Ts-Bu;

        case 2
            SM.x0_d=(eye(SM.nState,SM.nState)-Ts/2*A)*SM.x/Ts-Bu/2;

        end

    end



    [WantBlockChoice,SM]=SPSrl('userblock','PermanentMagnetSynchronousMachine',bdroot(block),WantBlockChoice,SM);
    power_initmask();


    varargout={Ts,SM,WantBlockChoice,X,Y};
