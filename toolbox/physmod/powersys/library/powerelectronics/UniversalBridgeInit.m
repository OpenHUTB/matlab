function[WantBlockChoice,Ts,Switches,Tf_sps,Tt_sps,Vf,Vf_SwitchOn,Vf_DiodeOn,IC,SignalLength,REORDERGATESDELAYS,X,Y,Ron]=UniversalBridgeInit(block,Device,Arms,ForwardVoltage,ForwardVoltages,GTOparameters,IGBTparameters,Ron)





    [X,Y]=UniversalBridgeIcon(Device);
    sys=bdroot(block);
    PowerguiInfo=getPowerguiInfo(sys,block);
    Ts=PowerguiInfo.Ts;
    IC=0;
    IsLibrary=strcmp(get_param(sys,'BlockDiagramType'),'library');


    Tf_sps=0;
    Tt_sps=0;
    Vf=0;
    Vf_SwitchOn=0;
    Vf_DiodeOn=0;

    Bras=eval(Arms);
    Switches=2*Bras;
    SignalLength=Switches;


    if isempty(Ron)

        Ron=1e-3;
    end
    if Ron==0&&PowerguiInfo.SPID==0
        Ron=-999;




    end

    switch Device

    case 1

        Vf=ForwardVoltage;

    case 2

        Vf=ForwardVoltage;

    case 3


        if length(ForwardVoltages)~=2
            ForwardVoltages=[0,0];
        end
        Vf_SwitchOn=+ForwardVoltages(1)*ones(Switches,1);
        Vf_DiodeOn=-ForwardVoltages(2)*ones(Switches,1);

        if length(GTOparameters)~=2

            GTOparameters=[0,0];
        end
        Tf_sps=GTOparameters(1);
        Tt_sps=GTOparameters(2);

    case 5


        if length(ForwardVoltages)~=2
            ForwardVoltages=[0,0];
        end
        Vf_SwitchOn=+ForwardVoltages(1)*ones(Switches,1);
        Vf_DiodeOn=-ForwardVoltages(2)*ones(Switches,1);

        if length(IGBTparameters)~=2

            IGBTparameters=[0,0];
        end
        Tf_sps=IGBTparameters(1);
        Tt_sps=IGBTparameters(2);

    end


    REORDERGATESDELAYS=1:Switches;
    if PowerguiInfo.Discrete
        WantBlockChoice='discrete ';
        if strcmp(PowerguiInfo.SolverType,'Tustin')&&PowerguiInfo.ExternalGateDelay


            switch Switches
            case 2
                REORDERGATESDELAYS=[1,3,5,2,4,6];
            case 4
                REORDERGATESDELAYS=[1,5,9,2,6,10,3,7,11,4,8,12];
            case 6
                REORDERGATESDELAYS=[1,7,13,2,8,14,3,9,15,4,10,16,5,11,17,6,12,18];
            end

            SignalLength=3*Switches;
        end
    else
        WantBlockChoice='continuous ';
    end

    switch Device
    case 1
        Device='Diodes';
        Lon=getSPSmaskvalues(block,{'Lon'});
        errorScalar(Lon,'Lon',block);
        if Lon~=0&&PowerguiInfo.Continuous
            WantBlockChoice=[WantBlockChoice,'Diode-RL'];
        else
            WantBlockChoice=[WantBlockChoice,'Diode-Logic'];
        end
    case 2
        Device='Thyristors';
        Lon=getSPSmaskvalues(block,{'Lon'});
        errorScalar(Lon,'Lon',block);
        if Lon~=0&&PowerguiInfo.Continuous
            WantBlockChoice=[WantBlockChoice,'Thyristor-RL'];
        else
            WantBlockChoice=[WantBlockChoice,'Thyristor-Logic'];
        end
    case 3
        Device='GTO / Diodes';
        if PowerguiInfo.SPID

            WantBlockChoice='SPID';
        else
            WantBlockChoice=[WantBlockChoice,'GTO'];
        end
    case 4
        Device='MOSFET / Diodes';
        WantBlockChoice=[WantBlockChoice,'MOSFET'];
    case 5
        Device='IGBT / Diodes';
        if PowerguiInfo.SPID

            WantBlockChoice='SPID';
        else
            WantBlockChoice=[WantBlockChoice,'IGBT'];
        end
    case 6
        Device='Ideal Switches';
        WantBlockChoice=[WantBlockChoice,'Ideal Switch'];
    case 7
        Device='Switching-function based VSC';
        if PowerguiInfo.Interpolate&&strcmp(PowerguiInfo.SolverType,'Tustin')
            WantBlockChoice=['interpolation Switching function ',mat2str(Bras)];
        else
            WantBlockChoice=[WantBlockChoice,'Switching function ',mat2str(Bras)];
        end
    case 8
        Device='Average-model based VSC';
        WantBlockChoice=[WantBlockChoice,'Average model ',mat2str(Bras)];
    end



    try
        HavegateInput=strcmp('g',get_param([block,'/g'],'Name'));

    catch ME %#ok display message is not necessary.

        HavegateInput=0;
    end

    switch Device
    case 'Average-model based VSC'
        if HavegateInput
            set_param([block,'/g'],'Name','Uref')
        end
        GUREF='Uref';
    otherwise
        if~HavegateInput
            set_param([block,'/Uref'],'Name','g')
        end
        GUREF='g';
    end



    [VF,Vfs]=getSPSmaskvalues(block,{'ForwardVoltage','ForwardVoltages'});

    if PowerguiInfo.Discrete||PowerguiInfo.SPID
        Lon=0;
    end

    if PowerguiInfo.SPID&&PowerguiInfo.DisableVf
        VF=0;
        Vfs=[0,0];
    end



    G_BlockType=get_param([block,'/',GUREF],'blocktype');

    switch Device
    case 'Diodes'
        if strcmp(G_BlockType,'Inport')
            if Lon==0
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name',GUREF,'Constant','noprompt');
                set_param([block,'/',GUREF],'Value',['zeros(1,',num2str(SignalLength),')']);
            else
                replace_block(block,'Followlinks','on','SearchDepth',1,'Name',GUREF,'Ground','noprompt');
            end
        end
        if strcmp(G_BlockType,'Constant')
            set_param([block,'/',GUREF],'Value',['zeros(1,',num2str(SignalLength),')']);
        end
    otherwise
        if strcmp(G_BlockType,'Ground')||strcmp(G_BlockType,'Constant')
            replace_block(block,'Followlinks','on','SearchDepth',1,'Name',GUREF,'Inport','noprompt');
        end
    end



    switch Device
    case{'Switching-function based VSC','Average-model based VSC'}

        GotoToTerm(block,'Goto');
    case{'Diodes','Thyristors'}
        if Lon==0

            TermToGoto(block,'Goto',IsLibrary);
        else

            GotoToTerm(block,'Goto');
        end
    otherwise

        TermToGoto(block,'Goto',IsLibrary);
    end



    switch Device
    case{'Diodes','Thyristors'}
        if Lon==0

            GroundToFrom(block,'Status',IsLibrary);
        else

            FromToGround(block,'Status');
        end
    otherwise

        GroundToFrom(block,'Status',IsLibrary);
    end



    switch Device
    case{'Diodes','Thyristors','Ideal Switches','Switching-function based VSC','Average-model based VSC'}

        GotoToTerm(block,'ITAIL');
    otherwise
        if PowerguiInfo.SPID

            GotoToTerm(block,'ITAIL');
        else

            TermToGoto(block,'ITAIL',IsLibrary);
        end
    end



    switch Device
    case{'Diodes','Thyristors'}
        if Lon==0

            GotoToTerm(block,'ISWITCH');
        else

            TermToGoto(block,'ISWITCH',IsLibrary);
        end
    case{'Switching-function based VSC','Average-model based VSC'}

        TermToGoto(block,'ISWITCH',IsLibrary);
    otherwise

        GotoToTerm(block,'ISWITCH');
    end



    switch Device

    case{'Diodes','Thyristors'}

        if VF==0||Lon~=0

            GotoToTerm(block,'VF');
        else

            TermToGoto(block,'VF',IsLibrary);
        end

    case{'GTO / Diodes','IGBT / Diodes'}



        if~isequal(size(Vfs),[1,2])
            message=['In mask of ''',block,''' block:',char(10),...
            'The forward voltages [Vf Vfd] parameter must be a 1-by-2 vector with positive or null values.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        if Vfs(1)<0||Vfs(2)<0
            message=['In mask of ''',block,''' block:',char(10),...
            'The forward voltages [Vf Vfd] parameter must be a 1-by-2 vector with positive or null values.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        if Vfs(1)==0&&Vfs(2)==0

            GotoToTerm(block,'VF');
        else

            TermToGoto(block,'VF',IsLibrary);
        end

    case{'MOSFET / Diodes','Ideal Switches'}


        GotoToTerm(block,'VF');

    case{'Switching-function based VSC','Average-model based VSC'}


        TermToGoto(block,'VF',IsLibrary);
    end



    if PowerguiInfo.SPID&&strcmp(Device,'Switching-function based VSC')==0...
        &&strcmp(Device,'Average-model based VSC')==0

        FromToGround(block,'Uswitch');
    else

        GroundToFrom(block,'Uswitch',IsLibrary);
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


    UniversalBridgeCback(block);


    [WantBlockChoice]=SPSrl('userblock','UniversalBridge',sys,WantBlockChoice,[]);
    power_initmask();