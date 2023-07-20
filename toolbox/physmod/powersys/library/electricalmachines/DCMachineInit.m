function varargout=DCMachineInit(block,varargin)






    DCMachineCback(block,'Continuous','UpdateBlock')


    [TsPowergui,TsBlock,MechanicalLoad,FieldType,RLa,RLf,Laf,~,Ke,Kt,J,Bm,tTf,w0,MeasurementBus]=varargin{1:end};
    WantWound=strcmp(get_param(block,'FieldType'),'Wound');
    WantTorqueConstant=strcmp(get_param(block,'MachineConstant'),'Torque constant (N.m/A)');
    P=get_param(block,'ports');
    if sum(P)~=6&&sum(P)~=4

        varargout={};
        return
    end
    HavePorts=P(7)==2;

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);

    [WantBlockChoice,Ts]=SetInternalModels('get',block,'DC Machine',PowerguiInfo,TsPowergui,TsBlock,MechanicalLoad,FieldType,MeasurementBus);

    if~WantWound&&HavePorts

        FpPortHandles=get_param([block,'/F+'],'PortHandles');
        FmPortHandles=get_param([block,'/F-'],'PortHandles');
        iFPortHandles=get_param([block,'/iF'],'PortHandles');
        ligne1=get_param(FpPortHandles.RConn,'line');

        ligne3=get_param(FmPortHandles.RConn,'line');

        delete_line(ligne1);

        delete_line(ligne3);

        delete_block([block,'/F+']);
        delete_block([block,'/F-']);






    end

    if WantWound&&~HavePorts

        add_block('built-in/PMIOPort',[block,'/F+']);
        set_param([block,'/F+'],'Position',[20,230,50,250],'side','Left','orientation','Right');
        add_block('built-in/PMIOPort',[block,'/F-']);
        set_param([block,'/F-'],'Position',[480,235,510,255],'side','Right','orientation','left');




        FpPortHandles=get_param([block,'/F+'],'PortHandles');
        FmPortHandles=get_param([block,'/F-'],'PortHandles');
        iFPortHandles=get_param([block,'/iF'],'PortHandles');
        RfPortHandles=get_param([block,'/Rf Lf'],'PortHandles');
        add_line(block,iFPortHandles.LConn,FpPortHandles.RConn);

        add_line(block,RfPortHandles.RConn,FmPortHandles.RConn);





    end

    X.p1=-80;
    Y.p1=-80;
    X.p2=80;
    Y.p2=80;
    X.p3=[0,9,18,24,29,30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0];
    Y.p3=[30,29,24,18,9,0,-9,-18,-24,-29,-30,-29,-24,-18,-9,0,9,18,24,29,30];
    X.p4=[-29,-35,-35,-29];
    Y.p4=[-8,-8,8,8];
    X.p5=[29,35,35,29];
    Y.p5=[-8,-8,8,8];

    if WantWound
        X.p6=[-35,-55];
        Y.p6=[0,0];
        X.p7=[35,55];
        Y.p7=[0,0];
        X.p8=[-78,-50,-50,-49,-45,-39,-33,-26,-21,-18,-17,-19,-22,-22,-26,-27,-25,-22,-16,-9,-3,2,6,6,4,1,1,-3,-4,-2,2,7,14,20,26,29,30,28,24,24,21,20,21,25,31,37,44,49,50,50,50,78]*.7;
        Y.p8=[58,58,57.2,49.2,42.8,38.8,38,39.6,44.4,51.6,59.6,67.6,72.4,72.4,65.2,57.2,49.2,42.8,38.8,38,39.6,44.4,51.6,59.6,67.6,72.4,72.4,65.2,57.2,49.2,42.8,38.8,38,39.6,44.4,51.6,59.6,67.6,72.4,72.4,65.2,57.2,49.2,42.8,38.8,38,39.6,44.4,51.6,58,58,58]*.6-85;
        X.p11=[0,0];
        Y.p11=[0,0];
        X.p12=[0,0];
        Y.p12=[0,0];
        X.p13=[0,0];
        Y.p13=[0,0];
    else
        X.p6=[-35,-50,-50,-55];
        Y.p6=[0,0,-43,-43];
        X.p7=[-35,-50,-50,-55]*-1;
        Y.p7=[0,0,-43,-43];
        X.p8=[-54.6,-15.4-10,-18.2-10,-18.9-10,-18.2-10,-15.4-10,-54.6,-54.6]+10;
        Y.p8=[-41.56,-41.56,-45.88,-50.68,-55.48,-62.2,-62.2,-41.56];
        X.p11=[-54.6,-15.4-10,-18.2-10,-18.9-10,-18.2-10,-15.4-10,-54.6,-54.6]*-1-10;
        Y.p11=[-41.56,-41.56,-45.88,-50.68,-55.48,-62.2,-62.2,-41.56];
        X.p12=[-45,-45,-35,-35]+10;
        Y.p12=[-56.5,-47,-56.5,-47];
        X.p13=[50,37.5+4,35+2,37.5+2,47.5,50,47.5,35+2]-2-10;
        Y.p13=[-46.5,-46.5,-48.5,-51,-51,-52.5,-56.5,-56.5];
    end

    X.p9=[-50,-10,-10];
    Y.p9=[50,50,30];
    X.p10=[50,10,10];
    Y.p10=[50,50,30];


    if isequal(size(RLa),[1,2])
        SM.Ra=RLa(1);
        SM.La=RLa(2);
    else
        SM.Ra=1;
        SM.La=1;
    end
    if isequal(size(RLf),[1,2])
        SM.Rf=RLf(1);
        SM.Lf=RLf(2);
    else
        SM.Rf=1;
        SM.Lf=1;
    end
    SM.Laf=Laf;
    SM.J=J;
    SM.Bm=Bm;
    SM.Tf=tTf;
    SM.w0=w0;

    if WantTorqueConstant
        SM.Ke=Kt;
    else
        SM.Ke=Ke*60/(2*pi);
    end


    [WantBlockChoice,SM]=SPSrl('userblock','DCMachine',bdroot(block),WantBlockChoice,SM);
    power_initmask();


    switch MechanicalLoad
    case 'Torque TL'
        SM.PortLabel='TL';
    case 'Mechanical rotational port'
        SM.PortLabel=' ';
    otherwise
        SM.PortLabel='w';
    end


    varargout={Ts,SM,WantBlockChoice,X,Y};
