function[WantBlockChoice,Ts,TLB,X,Y,Bras,Ron]=ThreeLevelBridgeInit(block,Device,Arms,ForwardVoltages,Ron)





    [X,Y]=UniversalBridgeIcon(Device+2);
    sys=bdroot(block);
    PowerguiInfo=getPowerguiInfo(sys,block);
    Ts=PowerguiInfo.Ts;
    IsLibrary=strcmp(get_param(sys,'BlockDiagramType'),'library');


    if Ron==0&&PowerguiInfo.SPID==0
        Ron=-999;




    end

    TimeStamped=0;
    if PowerguiInfo.Discrete
        if strcmp(PowerguiInfo.SolverType,'Tustin')&&PowerguiInfo.ExternalGateDelay
            TimeStamped=1;
        end
    end





    Vf=ForwardVoltages(1);
    Vfd=ForwardVoltages(2);
    if PowerguiInfo.SPID&&PowerguiInfo.DisableVf
        Vf=0;
        Vfd=0;
    end



    Bras=eval(Arms);

    TLB.Tf_sps=0;
    TLB.Tt_sps=0;

    TLB.NDevices=4*Bras;
    TLB.NDiodes=2*Bras;
    TLB.NIdSw=3*Bras;
    TLB.Vf_SwitchOn=[];
    TLB.Vf_DiodeOn=[];

    for i=1:Bras

        TLB.Vf_SwitchOn=[TLB.Vf_SwitchOn,Vf,Vf,Vf,Vf,Vfd,Vfd];

        TLB.Vf_DiodeOn=[TLB.Vf_DiodeOn,-Vfd,-Vfd,-Vfd,-Vfd,Vfd,Vfd];
    end

    if TimeStamped
        TLB.SignalLength=TLB.NDevices*3;
    else
        TLB.SignalLength=TLB.NDevices;
    end

    TLB.SignalLengthIdealSwitch=TLB.SignalLength;
    TLB.SignalLength=TLB.SignalLength+1;

    TLB.GatesDelaysLength=(TLB.NDevices+TLB.NDiodes);

    switch Bras

    case 1

        if TimeStamped

            TLB.ReorderGatesDelays=[1,5,9,2,6,10,3,7,11,4,8,12,13,13,13,13,13,13];

            TLB.ReorderGatesDelaysIdealSwitch=[1,4,7,2,5,8,3,6,9];
            TLB.selection3=[5,6,8];
            TLB.selection4=[5,7,8];
            TLB.selection5=[5,6,8]+4;
            TLB.selection6=[5,7,8]+4;

            TLB.LengthIdealSwitches=6;

        else

            TLB.ReorderGatesDelays=[1,2,3,4,5,5];

            TLB.ReorderGatesDelaysIdealSwitch=1:3;
            TLB.selection3=1;
            TLB.selection4=1;
            TLB.selection5=1;
            TLB.selection6=1;

            TLB.LengthIdealSwitches=5;
        end



        TLB.selection1=[1,2,4];
        TLB.selection2=[1,3,4];

    case 2

        if TimeStamped

            TLB.ReorderGatesDelays=...
            [1,9,17,2,10,18,3,11,19,4,12,20,25,25,25,25,25,25...
            ,5,13,21,6,14,22,7,15,23,8,16,24,25,25,25,25,25,25];

            TLB.ReorderGatesDelaysIdealSwitch=[1,7,13,2,8,14,3,9,15,4,10,16,5,11,17,6,12,18];
            TLB.selection3=[9,10,12,13,14,16];
            TLB.selection4=[9,11,12,13,15,16];
            TLB.selection5=[9,10,12,13,14,16]+8;
            TLB.selection6=[9,11,12,13,15,16]+8;

            TLB.LengthIdealSwitches=12;

        else

            TLB.ReorderGatesDelays=[1,2,3,4,9,9,5,6,7,8,9,9];

            TLB.ReorderGatesDelaysIdealSwitch=1:6;
            TLB.selection3=1;
            TLB.selection4=1;
            TLB.selection5=1;
            TLB.selection6=1;

            TLB.LengthIdealSwitches=8;

        end



        TLB.selection1=[1,2,4,5,6,8];
        TLB.selection2=[1,3,4,5,7,8];

    case 3

        if TimeStamped

            TLB.ReorderGatesDelays=...
            [1,13,25,2,14,26,3,15,27,4,16,28,37,37,37,37,37,37...
            ,5,17,29,6,18,30,7,19,31,8,20,32,37,37,37,37,37,37...
            ,9,21,33,10,22,34,11,23,35,12,24,36,37,37,37,37,37,37];


            TLB.ReorderGatesDelaysIdealSwitch=[1,10,19,2,11,20,3,12,21,4,13,22,5,14,23,6,15,24,7,16,25,8,17,26,9,18,27];
            TLB.selection3=[13,14,16,17,18,20,21,22,24];
            TLB.selection4=[13,15,16,17,19,20,21,23,24];
            TLB.selection5=[13,14,16,17,18,20,21,22,24]+12;
            TLB.selection6=[13,15,16,17,19,20,21,23,24]+12;

            TLB.LengthIdealSwitches=18;


        else

            TLB.ReorderGatesDelays=[1,2,3,4,13,13,5,6,7,8,13,13,9,10,11,12,13,13];

            TLB.ReorderGatesDelaysIdealSwitch=1:9;
            TLB.selection3=1;
            TLB.selection4=1;
            TLB.selection5=1;
            TLB.selection6=1;

            TLB.LengthIdealSwitches=11;

        end



        TLB.selection1=[1,2,4,5,6,8,9,10,12];
        TLB.selection2=[1,3,4,5,7,8,9,11,12];

    end



    if PowerguiInfo.Discrete
        WantBlockChoice='discrete ';
    else
        WantBlockChoice='continuous ';
    end

    switch Device
    case 1
        WantBlockChoice=[WantBlockChoice,'GTO-Diodes'];
    case 2
        WantBlockChoice=[WantBlockChoice,'MOSFET-Diodes'];
    case 3
        WantBlockChoice=[WantBlockChoice,'IGBT-Diodes'];
    case 4
        WantBlockChoice=[WantBlockChoice,'Ideal Switch'];
    end

    if PowerguiInfo.SPID&&(Device==1||Device==3)


        WantBlockChoice='SPID';
    end





    SetNewGotoTag([block,'/Status'],IsLibrary);


    SetNewGotoTag([block,'/Goto'],IsLibrary);

    switch get_param(block,'Device')

    case{'GTO / Diodes','IGBT / Diodes'}


        if~isequal(size(ForwardVoltages),[1,2])

            message=['In mask of ''',block,''' block:',char(10),'The forward voltages [Vf Vfd] parameter must be a 1-by-2 vector with positive or null values.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);

        elseif ForwardVoltages(1)<0||ForwardVoltages(2)<0

            message=['In mask of ''',block,''' block:',char(10),'The forward voltages [Vf Vfd] parameter must be a 1-by-2 vector with positive or null values.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);

        end



        Vf=ForwardVoltages(1);
        Vfd=ForwardVoltages(2);

        if(Vf~=0||Vfd~=0)
            TermToGoto(block,'VF',IsLibrary);
        end

        if(Vf==0&&Vfd~=0)
            GotoToTerm(block,'VF');
        end


        TermToGoto(block,'ITAIL',IsLibrary);

    case 'MOSFET / Diodes'


        GotoToTerm(block,'VF');



        TermToGoto(block,'ITAIL',IsLibrary);

    case 'Ideal Switches'

        GotoToTerm(block,'VF');

        GotoToTerm(block,'ITAIL');

    end

    if PowerguiInfo.SPID
        FromToGround(block,'Uswitch');
        GotoToTerm(block,'ITAIL');
    else

        GroundToFrom(block,'Uswitch',IsLibrary)
    end



    ports=get_param(block,'ports');
    PortHandles=get_param([block,'/UniversalBridge'],'PortHandles');
    possibilities=mat2str([ports(6),Bras]);

    switch possibilities

    case '[3 2]'

        ligne=get_param(PortHandles.LConn(3),'line');
        delete_line(ligne);
        delete_block([block,'/C']);

    case '[3 1]'

        ligne=get_param(PortHandles.LConn(3),'line');
        delete_line(ligne);
        delete_block([block,'/C']);
        ligne=get_param(PortHandles.LConn(2),'line');
        delete_line(ligne);
        delete_block([block,'/B']);

    case '[2 1]'

        ligne=get_param(PortHandles.LConn(2),'line');
        delete_line(ligne);
        delete_block([block,'/B']);

    case '[2 3]'

        add_block('built-in/PMIOPort',[block,'/C']);
        set_param([block,'/C'],'Position',[20,95,50,115],'orientation','right','port','3');
        set_param([block,'/C'],'side','Left');
        CPortHandle=get_param([block,'/C'],'PortHandles');
        add_line(block,PortHandles.LConn(3),CPortHandle.RConn);

    case '[1 2]'

        add_block('built-in/PMIOPort',[block,'/B']);
        set_param([block,'/B'],'Position',[20,65,50,85],'orientation','right','port','2');
        set_param([block,'/B'],'side','Left');
        BPortHandle=get_param([block,'/B'],'PortHandles');
        add_line(block,PortHandles.LConn(2),BPortHandle.RConn);

    case '[1 3]'

        add_block('built-in/PMIOPort',[block,'/B']);
        set_param([block,'/B'],'Position',[20,65,50,85],'orientation','right','port','2');
        set_param([block,'/B'],'side','Left');
        BPortHandle=get_param([block,'/B'],'PortHandles');
        add_line(block,PortHandles.LConn(2),BPortHandle.RConn);
        add_block('built-in/PMIOPort',[block,'/C']);
        set_param([block,'/C'],'Position',[20,95,50,115],'orientation','right','port','3');
        set_param([block,'/C'],'side','Left');
        CPortHandle=get_param([block,'/C'],'PortHandles');
        add_line(block,PortHandles.LConn(3),CPortHandle.RConn);

    end


    ThreeLevelBridgeCback(block);


    [WantBlockChoice,dummy]=SPSrl('userblock','ThreeLevelBridge',bdroot(block),WantBlockChoice,[]);%#ok
    power_initmask();