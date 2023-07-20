function[X1,X1m,X2,X2m,X3,X4,Y1,Y1m,Y2,Y2m,Y3,Y4,color1,color2,INp,...
    OUTp,machineMaskType,baseSampleTime]=spsDrivesMaskInit(driveBlock,driveType,...
    AverageValue)







    [X1,X1m,X2,X2m,X3,X4,Y1,Y1m,Y2,Y2m,Y3,Y4,color1,color2]=spsdrivelogo;


    switch driveType

    case{'AC1','AC2','AC3','AC4'}
        machineMaskType='Induction machine';

    case{'AC5'}
        machineMaskType='Synchronous Machine SI Fundamental';

    case{'AC6','AC7','AC8'}
        machineMaskType='Permanent Magnet Synchronous Machine';

    case{'AC9'}
        machineMaskType='SPIM';

    case{'DC1','DC2','DC3','DC4','DC5','DC6','DC7'}
        machineMaskType='DC Machine';

    end

    deleteMechanicalConnections(driveBlock,machineMaskType)
    [INp,OUTp]=setInternalDriveMechInput(driveType,getfullname(driveBlock));
    SetInternalDriveModel(driveType,AverageValue,driveBlock);
    addMechanicalConnections(driveBlock,machineMaskType)
    baseSampleTime=drivelibInitSampleTime(driveBlock);
    spsDrivesOutputSelectorCbak(driveBlock);


    switch driveType
    case{'AC3','AC4','AC6'}
        spsDrivesSetModulation(driveBlock,driveType,AverageValue);
    end


    switch driveType
    case{'AC3','AC7'}
        spsDrivesSetSensorless(driveBlock,driveType,get_param(driveBlock,'sensorless'));
    end

    switch driveType
    case 'AC9'
        spsDrivesMaskControllerSinglePhaseIm(driveBlock,driveType,AverageValue)
        spsDrivesSetControllerTypeSinglePhaseIm(driveBlock);
    otherwise
        spsDrivesMaskController(driveBlock,driveType,AverageValue)
    end

    power_initmask();

    function deleteMechanicalConnections(driveBlock,machineMaskType)






        machinePorts=get_param([driveBlock,'/',machineMaskType],'ports');

        switch machineMaskType

        case 'Synchronous Machine SI Fundamental'
            HaveSPSMec=machinePorts(6)==0;
            HaveSSCMec=machinePorts(6)==1;

        case 'Permanent Magnet Synchronous Machine'
            HaveSPSMec=machinePorts(6)==3||machinePorts(6)==5;
            HaveSSCMec=machinePorts(6)==4||machinePorts(6)==6;

        case 'Induction machine'
            HaveSPSMec=machinePorts(6)==3||machinePorts(6)==6;
            HaveSSCMec=machinePorts(6)==4||machinePorts(6)==7;

        case 'SPIM'
            HaveSPSMec=machinePorts(6)==4;
            HaveSSCMec=machinePorts(6)==5;

        case 'DC Machine'
            if strcmp(get_param([driveBlock,'/',machineMaskType],'FieldType'),'Permanent magnet')&&machinePorts(6)==1
                HaveSPSMec=1;
                HaveSSCMec=0;
            elseif strcmp(get_param([driveBlock,'/',machineMaskType],'FieldType'),'Wound')&&machinePorts(6)==2
                HaveSPSMec=1;
                HaveSSCMec=0;
            else
                HaveSPSMec=0;
                HaveSSCMec=1;
            end

        end

        Mech_param=get_param(driveBlock,'MechanicalLoad');

        switch machineMaskType

        case{'Induction machine','SPIM','Permanent Magnet Synchronous Machine','DC Machine'}

            switch Mech_param

            case 'Mechanical rotational port'

                if(HaveSPSMec==1)

                    delete_line(driveBlock,'Rate Transition/1',[machineMaskType,'/1']);
                    delete_line(driveBlock,'Tm/1','Rate Transition/1');

                    set_param([driveBlock,'/Rate Transition'],'Position',[800,800,820,820]);
                    add_block('simulink/Commonly Used Blocks/Ground',[driveBlock,'/Ground']);
                    add_block('simulink/Commonly Used Blocks/Terminator',[driveBlock,'/term']);
                    set_param([driveBlock,'/Ground'],'Position',[730,800,750,820]);
                    set_param([driveBlock,'/term'],'Position',[850,800,870,820]);
                    Ground=get_param([driveBlock,'/Ground'],'PortHandles');
                    term=get_param([driveBlock,'/term'],'PortHandles');
                    rate=get_param([driveBlock,'/Rate Transition'],'PortHandles');
                    add_line(driveBlock,rate.Outport,term.Inport);
                    add_line(driveBlock,Ground.Outport,rate.Inport);

                    delete_block([driveBlock,'/Tm']);

                    delete_line(driveBlock,'Output Bus Selector/1','Wm/1');
                    add_block('simulink/Commonly Used Blocks/Terminator',[driveBlock,'/term2']);
                    Wm=get_param([driveBlock,'/Wm'],'Position');
                    delete_block([driveBlock,'/Wm']);
                    set_param([driveBlock,'/term2'],'Position',[Wm(1),Wm(2),Wm(3),Wm(4)],'Orientation','Right');
                    add_line(driveBlock,'Output Bus Selector/1','term2/1');

                end

            case{'Torque Tm','Speed w'}

                if(HaveSSCMec==1)
                    PortHandles=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                    ShaftPortHandle=get_param([driveBlock,'/S'],'PortHandles');

                    delete_line(driveBlock,PortHandles.LConn(1),ShaftPortHandle.RConn);
                    delete_block([driveBlock,'/S']);
                    delete_line(driveBlock,'Output Bus Selector/1','term2/1');
                    delete_block([driveBlock,'/term2']);
                end

            end

        case 'Synchronous Machine SI Fundamental'

            switch Mech_param

            case 'Mechanical rotational port'

                if(HaveSPSMec==1)
                    p_motor=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                    p_inp=get_param([driveBlock,'/Mechanical Input Selector'],'PortHandles');

                    delete_line(driveBlock,p_inp.Outport,p_motor.Inport(1));
                    delete_line(driveBlock,'Rate Transition/1',p_inp.Inport(2));
                    delete_line(driveBlock,'Tm/1','Rate Transition/1');

                    delete_block([driveBlock,'/Tm']);

                    add_block('simulink/Commonly Used Blocks/Ground',[driveBlock,'/gnd']);
                    add_block('simulink/Commonly Used Blocks/Terminator',[driveBlock,'/term']);
                    position=get_param([driveBlock,'/Mechanical Input Selector'],'Position');
                    set_param([driveBlock,'/term'],'Position',[position(1)+165,position(2)+11,position(3)+55,position(4)-11]);
                    set_param([driveBlock,'/Rate Transition'],'Position',[position(1)-70,position(2)+25,position(3)-170,position(4)-5]);
                    set_param([driveBlock,'/gnd'],'Position',[position(1)-125,position(2)+21,position(3)-235,position(4)-1]);
                    gnd=get_param([driveBlock,'/gnd'],'PortHandles');
                    term=get_param([driveBlock,'/term'],'PortHandles');
                    rate=get_param([driveBlock,'/Rate Transition'],'PortHandles');
                    add_line(driveBlock,rate.Outport,p_inp.Inport(2));
                    add_line(driveBlock,gnd.Outport,rate.Inport);
                    add_line(driveBlock,p_inp.Outport(1),term.Inport);

                    delete_line(driveBlock,'Output Bus Selector/1','Wm/1');
                    add_block('simulink/Commonly Used Blocks/Terminator',[driveBlock,'/term2']);
                    Wm=get_param([driveBlock,'/Wm'],'Position');
                    delete_block([driveBlock,'/Wm']);
                    set_param([driveBlock,'/term2'],'Position',[Wm(1),Wm(2),Wm(3),Wm(4)],'Orientation','Right');
                    add_line(driveBlock,'Output Bus Selector/1','term2/1');
                end

            case{'Torque Tm','Speed w'}

                if(HaveSSCMec==1)
                    p_motor=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                    p_inp=get_param([driveBlock,'/Mechanical Input Selector'],'PortHandles');
                    S=get_param([driveBlock,'/S'],'PortHandles');
                    term=get_param([driveBlock,'/term'],'PortHandles');
                    gnd=get_param([driveBlock,'/gnd'],'PortHandles');
                    rate=get_param([driveBlock,'/Rate Transition'],'PortHandles');

                    delete_line(driveBlock,p_motor.LConn(1),S.RConn(1));
                    delete_line(driveBlock,p_inp.Outport(1),term.Inport(1));
                    delete_line(driveBlock,gnd.Outport(1),rate.Inport(1));

                    p=get_param([driveBlock,'/gnd'],'Position');
                    delete_block([driveBlock,'/term']);
                    delete_block([driveBlock,'/gnd']);
                    delete_block([driveBlock,'/S']);

                    add_block('built-in/Inport',[driveBlock,'/Tm'],'Port','2');
                    set_param([driveBlock,'/Tm'],'Position',[p(1),p(2),p(3),p(4)]);
                    Tm=get_param([driveBlock,'/Tm'],'PortHandles');
                    add_line(driveBlock,Tm.Outport,rate.Inport(1));

                    delete_line(driveBlock,'Output Bus Selector/1','term2/1');
                    delete_block([driveBlock,'/term2']);

                end
            end
        end

        function addMechanicalConnections(driveBlock,machineMaskType)

            Mech_param=get_param(driveBlock,'MechanicalLoad');
            outputBusMode=get_param(driveBlock,'outputBusMode');
            position=get_param([driveBlock,'/',machineMaskType],'Position');
            position2=get_param([driveBlock,'/Output Bus Selector'],'Position');

            switch machineMaskType

            case{'Induction machine','Permanent Magnet Synchronous Machine','DC Machine'}

                switch Mech_param

                case 'Mechanical rotational port'

                    port=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                    ligne=get_param(port.LConn(1),'line');
                    if(ligne==-1)
                        add_block('built-in/PMIOPort',[driveBlock,'/S'],'Port','1');
                        set_param([driveBlock,'/S'],'Position',[position(1)-100,position(2),position(3)-150,position(4)-60],'side','right');
                        portS=get_param([driveBlock,'/S'],'PortHandles');
                        add_line(driveBlock,port.LConn(1),portS.RConn);
                    end

                case{'Torque Tm','Speed w'}

                    rate=get_param([driveBlock,'/Rate Transition'],'Position');
                    if(rate==[800,800,820,820])
                        Ground=get_param([driveBlock,'/Ground'],'PortHandles');
                        term=get_param([driveBlock,'/term'],'PortHandles');
                        rate=get_param([driveBlock,'/Rate Transition'],'PortHandles');
                        delete_line(driveBlock,rate.Outport,term.Inport);
                        delete_line(driveBlock,Ground.Outport,rate.Inport);
                        delete_block([driveBlock,'/term']);
                        delete_block([driveBlock,'/Ground']);

                        add_block('built-in/Inport',[driveBlock,'/Tm'],'Port','2');
                        set_param([driveBlock,'/Tm'],'Position',[position(1)-130,position(2),position(3)-190,position(4)-60]);
                        set_param([driveBlock,'/Rate Transition'],'Position',[position(1)-90,position(2),position(3)-150,position(4)-60]);


                        switch outputBusMode
                        case 'Single output bus'
                            outPortNumber='2';
                        case 'Multiple output buses'
                            outPortNumber='4';
                        otherwise
                            error(message('physmod:powersys:common:InvalidParameter',driveBlock,outputBusMode,'Output bus mode'));
                        end

                        add_block('built-in/Outport',[driveBlock,'/Wm'],'Port',outPortNumber);
                        set_param([driveBlock,'/Wm'],'Position',[position2(1)+130,position2(2)+10,position2(3)+155,position2(4)-10]);

                        add_line(driveBlock,'Output Bus Selector/1','Wm/1');
                        add_line(driveBlock,'Tm/1','Rate Transition/1');
                        add_line(driveBlock,'Rate Transition/1',[machineMaskType,'/1']);

                        set_param([driveBlock,'/Tm'],'ShowName','off');
                        set_param([driveBlock,'/Wm'],'ShowName','off');
                    end
                end
            case{'SPIM'}

                switch Mech_param

                case 'Mechanical rotational port'

                    port=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                    ligne=get_param(port.LConn(1),'line');
                    if(ligne==-1)
                        add_block('built-in/PMIOPort',[driveBlock,'/S'],'Port','1');
                        set_param([driveBlock,'/S'],'Position',[715,401,730,419],'side','right');
                        portS=get_param([driveBlock,'/S'],'PortHandles');
                        add_line(driveBlock,port.LConn(1),portS.RConn);
                    end

                case{'Torque Tm','Speed w'}

                    rate=get_param([driveBlock,'/Rate Transition'],'Position');
                    if(rate==[800,800,820,820])
                        Ground=get_param([driveBlock,'/Ground'],'PortHandles');
                        term=get_param([driveBlock,'/term'],'PortHandles');
                        rate=get_param([driveBlock,'/Rate Transition'],'PortHandles');
                        delete_line(driveBlock,rate.Outport,term.Inport);
                        delete_line(driveBlock,Ground.Outport,rate.Inport);
                        delete_block([driveBlock,'/term']);
                        delete_block([driveBlock,'/Ground']);

                        add_block('built-in/Inport',[driveBlock,'/Tm'],'Port','2');
                        set_param([driveBlock,'/Tm'],'Position',[710,401,725,419]);
                        set_param([driveBlock,'/Rate Transition'],'Position',[755,396,775,424]);


                        switch outputBusMode
                        case 'Single output bus'
                            outPortNumber='2';
                        case 'Multiple output buses'
                            outPortNumber='4';
                        otherwise
                            error(message('physmod:powersys:common:InvalidParameter',driveBlock,outputBusMode,'Output bus mode'));
                        end

                        add_block('built-in/Outport',[driveBlock,'/Wm'],'Port',outPortNumber);
                        set_param([driveBlock,'/Wm'],'Position',[1045,441,1075,459]);

                        add_line(driveBlock,'Output Bus Selector/1','Wm/1');
                        add_line(driveBlock,'Tm/1','Rate Transition/1');
                        add_line(driveBlock,'Rate Transition/1',[machineMaskType,'/1']);

                        set_param([driveBlock,'/Tm'],'ShowName','off');
                        set_param([driveBlock,'/Wm'],'ShowName','off');
                    end
                end

            case 'Synchronous Machine SI Fundamental'

                switch Mech_param

                case 'Mechanical rotational port'

                    port=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                    ligne=get_param(port.LConn(1),'line');

                    if(ligne==-1)
                        set_param([driveBlock,'/From2'],'Position',[935,271-65,970,289-65]);
                        add_block('built-in/PMIOPort',[driveBlock,'/S'],'Port','1');
                        set_param([driveBlock,'/S'],'Position',[935,271,970,289],'side','Right','orientation','Left')
                        motor=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                        S=get_param([driveBlock,'/S'],'PortHandles');
                        add_line(driveBlock,motor.LConn(1),S.RConn);

                    end

                case{'Torque Tm','Speed w'}
                    from=get_param([driveBlock,'/From2'],'Position');
                    if(from==[935,271-65,970,289-65])
                        set_param([driveBlock,'/From2'],'Position',[935,271,970,289]);
                        p_motor=get_param([driveBlock,'/',machineMaskType],'PortHandles');
                        p_inp=get_param([driveBlock,'/Mechanical Input Selector'],'PortHandles');

                        add_line(driveBlock,p_inp.Outport(1),p_motor.Inport(1));


                        switch outputBusMode
                        case 'Single output bus'
                            outPortNumber='2';
                        case 'Multiple output buses'
                            outPortNumber='4';
                        otherwise
                            error(message('physmod:powersys:common:InvalidParameter',driveBlock,outputBusMode,'Output bus mode'));
                        end
                        add_block('built-in/Outport',[driveBlock,'/Wm'],'Port',outPortNumber);
                        set_param([driveBlock,'/Wm'],'Position',[position2(1)+130,position2(2)+10,position2(3)+155,position2(4)-10]);
                        add_line(driveBlock,'Output Bus Selector/1','Wm/1');
                        set_param([driveBlock,'/Tm'],'ShowName','off');
                        set_param([driveBlock,'/Wm'],'ShowName','off');
                    end
                end
            end