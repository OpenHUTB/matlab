function varargout=SimplifiedSynchronousMachineInit(block,varargin)







    [TsPowergui,TsBlock,MechanicalLoad,Units,ConnectionType,NominalParameters,Mechanical,InternalRL,InitialConditions,MeasurementBus]=varargin{1:end};


    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    IM=get_param(block,'IterativeDiscreteModel');

    [WantBlockChoice,Ts]=SetInternalModels('get',block,'Simplified Synchronous Machine',PowerguiInfo,TsPowergui,TsBlock,MechanicalLoad,[],MeasurementBus,Units);

    if(PowerguiInfo.Discrete&&strcmp(IM,'Backward Euler robust'))||(PowerguiInfo.Discrete&&strcmp(IM,'Trapezoidal robust'))
        LocallyWantDSS=1;
    else
        LocallyWantDSS=0;
    end

    if PowerguiInfo.WantDSS||LocallyWantDSS||PowerguiInfo.DiscretePhasor
        if ConnectionType==1
            nState=2;
        else
            nState=3;
        end
    end


    X.p1=-60;
    Y.p1=-10;
    X.p2=60;
    Y.p2=80;
    X.p3=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0]*1.2;
    Y.p3=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30]*1.2+15;
    X.p4=[0,-9,-18,-24,-16,-16,-24,-18,-9,0,9,18,24,16,16,24,18,9,0];
    Y.p4=[-30,-29,-24,-18,-18,18,18,24,29,30,29,24,18,18,-18,-18,-24,-29,-30]+15;
    X.p5=[23,48];
    Y.p5=[42,42];
    X.p6=[36,48];
    Y.p6=[15,15];
    X.p7=[23,48];
    Y.p7=[-12,-12];

    X.p8=[0,0,40];
    Y.p8=[50,68,68];
    X.p9=[-35,-25];
    Y.p9=[50,40];
    X.p10=[-45,-35];

    switch ConnectionType
    case 1
        Y.p10=[0,0];
        X.p11=0;
        Y.p11=0;
        Wires='3wire';
    otherwise
        Y.p10=[30,30];
        X.p11=[-45,-32];
        Y.p11=[-5,-5];
        Wires='4wire';
    end

    if PowerguiInfo.WantDSS||LocallyWantDSS
        WantBlockChoice{1}=['Discrete_DSS_',Wires];
        Ts=PowerguiInfo.Ts;
    end

    if PowerguiInfo.DiscretePhasor
        WantBlockChoice{1}=['Discrete phasor_',Wires];
        Ts=PowerguiInfo.Ts;
        LocallyWantDSS=1;
    end



    if PowerguiInfo.WantDSS||LocallyWantDSS
        psbloadfunction(block,'gotofromDSS','Initialize');
    else
        psbloadfunction(block,'gotofromNoDSS','Initialize');
    end


    SimplifiedSynchronousMachineCback(block,1);

    if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))

        switch MechanicalLoad
        case 'Mechanical power Pm'
            SM.PortLabel='Pm';
        case 'Mechanical rotational port'
            SM.PortLabel=' ';
        otherwise
            SM.PortLabel='w';
        end
        varargout={Ts,SM,WantBlockChoice,X,Y};
        return
    end


    switch Units
    case 'SI'

        [NominalParameters,Mechanical,InternalRL,InitialConditions]=SimplifiedSynchronousMachineConvert(NominalParameters,Mechanical,InternalRL,InitialConditions);
    end


    SM=SimplifiedSynchronousMachineParam(NominalParameters,Mechanical,InternalRL,InitialConditions,Units,PowerguiInfo.LoadFlowFrequency);

    if ConnectionType==1
        SM.sel=1:2;
    else
        SM.sel=1:3;
    end

    switch MechanicalLoad
    case 'Mechanical power Pm'
        SM.PortLabel='Pm';
    case 'Mechanical rotational port'
        SM.PortLabel=' ';
    otherwise
        SM.PortLabel='w';
    end


    SM.Id1o=InitialConditions(3)*cos(InitialConditions(6)*pi/180);
    SM.Iq1o=InitialConditions(3)*sin(InitialConditions(6)*pi/180);

    if PowerguiInfo.WantDSS||LocallyWantDSS

        SM.nState=nState;

        if strcmp(IM,'Trapezoidal robust')

            SM.DSSmethod=2;
        else
            SM.DSSmethod=1;
        end







        switch nState
        case 2
            A=[-SM.R,0;0,-SM.R]/SM.L*SM.web;

            SM.x0=InitialConditions(3:4).*sind(InitialConditions(6:7));
            SM.x0=(SM.x0)';




            xder0=InitialConditions(3:4).*cosd(InitialConditions(6:7))*SM.web;
            Bu0=xder0'-A*SM.x0;

            if PowerguiInfo.DiscretePhasor

                B=[-2,-1,3,0;1,-1,0,3]/SM.L/3/SM.Vb*SM.web;
                C=eye(2,2)*SM.ib;
                sI=eye(2,2)*1i*SM.web;
                H=C*inv(sI-A)*B;
                SM.HrHi=[real(H),-imag(H);imag(H),real(H)];
            end


        case 3
            A=[-SM.R,0,0;0,-SM.R,0;0,0,-SM.R]/SM.L*SM.web;

            SM.x0=InitialConditions(3:5).*sind(InitialConditions(6:8));
            SM.x0=(SM.x0)';




            xder0=InitialConditions(3:5).*cosd(InitialConditions(6:8))*SM.web;
            Bu0=xder0'-A*SM.x0;

            if PowerguiInfo.DiscretePhasor

                B=[-1,0,0,1,0,0;0,-1,0,0,1,0;0,0,-1,0,0,1]/SM.L/SM.Vb*SM.web;
                C=eye(3,3)*SM.ib;
                sI=eye(3,3)*1i*SM.web;
                H=C*inv(sI-A)*B;
                SM.HrHi=[real(H),-imag(H);imag(H),real(H)];
            end

        end

        switch SM.DSSmethod
        case 1
            SM.x0_d=(eye(SM.nState,SM.nState)-Ts*A)*SM.x0/Ts-Bu0;

        case 2
            SM.x0_d=(eye(SM.nState,SM.nState)-Ts/2*A)*SM.x0/Ts-Bu0/2;

        end

    end


    [WantBlockChoice,SM]=SPSrl('userblock','SimplifiedSynchronousMachine',bdroot(block),WantBlockChoice,SM);
    power_initmask();


    varargout={Ts,SM,WantBlockChoice,X,Y};
