function SwitchedReluctanceMotorCback(block,option)






    MachineType=get_param(block,'MachineType');



    MV=get_param(block,'Maskvisibilities');

    aMaskObj=Simulink.Mask.get(block);
    aTabControl=aMaskObj.getDialogControl('Container3');

    switch MachineType
    case{'6/4  (60 kw preset model)','8/6  (75 kw preset model)','10/8  (10 kw preset model)'}

        aTabControl.Visible='off';

        MV{8}='off';
        MV{9}='off';
        MV{10}='off';
        MV{11}='off';
        MV{12}='off';
        MV{13}='off';
        MV{14}='off';
        MV{15}='off';
        MV{16}='off';
        MV{17}='off';

    otherwise

        aTabControl.Visible='on';

        MV{8}='on';
        switch get_param(block,'MachineModel')
        case 'Generic model'
            MV{9}='on';
            MV{10}='on';
            MV{11}='on';
            MV{12}='on';
            MV{13}='on';
            MV{14}='off';
            MV{15}='off';
            MV{16}='off';
            MV{17}='off';
        case 'Specific model'
            MV{9}='off';
            MV{10}='off';
            MV{11}='off';
            MV{12}='off';
            MV{13}='off';
            MV{14}='on';
            MV{15}='on';
            switch get_param(block,'Source')
            case 'Dialog'
                MV{16}='on';
                MV{17}='on';
            case 'MAT-file'
                MV{16}='off';
                MV{17}='off';
            end
        end
    end

    set_param(block,'Maskvisibilities',MV);

    if option==1
        return
    end



    WantSixFourPorts=strcmp(MachineType,'6/4')||strcmp(MachineType,'6/4  (60 kw preset model)');
    WantEightSixPorts=strcmp(MachineType,'8/6')||strcmp(MachineType,'8/6  (75 kw preset model)');
    WantTenEightPorts=strcmp(MachineType,'10/8')||strcmp(MachineType,'10/8  (10 kw preset model)');


    ports=get_param(block,'ports');
    HaveSixFourPorts=ports(6)==6;
    HaveEightSixPorts=ports(6)==8;
    HaveTenEightPorts=ports(6)==10;

    PlotIconSixFour=['image(imread([SP.SPSroot,''srm64h.jpg''],''jpg''));'...
    ,'port_label(''LConn'',1,''A1'');'...
    ,'port_label(''LConn'',2,''A2'');'...
    ,'port_label(''LConn'',3,''B1'');'...
    ,'port_label(''LConn'',4,''B2'');'...
    ,'port_label(''LConn'',5,''C1'');'...
    ,'port_label(''LConn'',6,''C2'');'...
    ,'color(''blue'');'...
    ,'port_label(''input'',1,''TL'');'...
    ,'port_label(''output'',1,''m'');'];

    PlotIconEightSix=['image(imread([SP.SPSroot,''srm86d.jpg''],''jpg''));'...
    ,'port_label(''LConn'',1,''A1'');'...
    ,'port_label(''LConn'',2,''A2'');'...
    ,'port_label(''LConn'',3,''B1'');'...
    ,'port_label(''LConn'',4,''B2'');'...
    ,'port_label(''LConn'',5,''C1'');'...
    ,'port_label(''LConn'',6,''C2'');'...
    ,'port_label(''LConn'',7,''D1'');'...
    ,'port_label(''LConn'',8,''D2'');'...
    ,'color(''blue'');'...
    ,'port_label(''input'',1,''TL'');'...
    ,'port_label(''output'',1,''m'');'];

    PlotIconTenEight=['image(imread([SP.SPSroot,''srm108d.jpg''],''jpg''));'...
    ,'port_label(''LConn'',1,''A1'');'...
    ,'port_label(''LConn'',2,''A2'');'...
    ,'port_label(''LConn'',3,''B1'');'...
    ,'port_label(''LConn'',4,''B2'');'...
    ,'port_label(''LConn'',5,''C1'');'...
    ,'port_label(''LConn'',6,''C2'');'...
    ,'port_label(''LConn'',7,''D1'');'...
    ,'port_label(''LConn'',8,''D2'');'...
    ,'port_label(''LConn'',9,''E1'');'...
    ,'port_label(''LConn'',10,''E2'');'...
    ,'color(''blue'');'...
    ,'port_label(''input'',1,''TL'');'...
    ,'port_label(''output'',1,''m'');'];




    if HaveSixFourPorts&&WantEightSixPorts

        add_block('built-in/PMIOPort',[block,'/D1']);
        set_param([block,'/D1'],'Position',[240,40,270,60],'side','Left','orientation','left');
        add_block('built-in/PMIOPort',[block,'/D2']);
        set_param([block,'/D2'],'Position',[240,95,270,115],'side','Left','orientation','left');
        SRMPortHandles=get_param([block,'/SwitcheReluctanceMotor'],'PortHandles');
        D1PortHandle=get_param([block,'/D1'],'PortHandles');
        D2PortHandle=get_param([block,'/D2'],'PortHandles');
        add_line(block,SRMPortHandles.RConn(1),D1PortHandle.RConn)
        add_line(block,SRMPortHandles.RConn(2),D2PortHandle.RConn)

        set_param(block,'MaskDisplay',PlotIconEightSix);
    end


    if HaveSixFourPorts&&WantTenEightPorts
        SRMPortHandles=get_param([block,'/SwitcheReluctanceMotor'],'PortHandles');

        add_block('built-in/PMIOPort',[block,'/D1']);
        set_param([block,'/D1'],'Position',[240,40,270,60],'side','Left','orientation','left');
        add_block('built-in/PMIOPort',[block,'/D2']);
        set_param([block,'/D2'],'Position',[240,95,270,115],'side','Left','orientation','left');
        D1PortHandle=get_param([block,'/D1'],'PortHandles');
        D2PortHandle=get_param([block,'/D2'],'PortHandles');
        add_line(block,SRMPortHandles.RConn(1),D1PortHandle.RConn)
        add_line(block,SRMPortHandles.RConn(2),D2PortHandle.RConn)

        add_block('built-in/PMIOPort',[block,'/E1']);
        set_param([block,'/E1'],'Position',[240,150,270,170],'side','Left','orientation','left');
        add_block('built-in/PMIOPort',[block,'/E2']);
        set_param([block,'/E2'],'Position',[240,205,270,225],'side','Left','orientation','left');
        E1PortHandle=get_param([block,'/E1'],'PortHandles');
        E2PortHandle=get_param([block,'/E2'],'PortHandles');
        add_line(block,SRMPortHandles.RConn(3),E1PortHandle.RConn)
        add_line(block,SRMPortHandles.RConn(4),E2PortHandle.RConn)

        set_param(block,'MaskDisplay',PlotIconTenEight);
    end


    if HaveEightSixPorts&&WantSixFourPorts

        PortHandles=get_param([block,'/SwitcheReluctanceMotor'],'PortHandles');
        ligneD1=get_param(PortHandles.RConn(1),'line');
        ligneD2=get_param(PortHandles.RConn(2),'line');
        delete_line(ligneD1);
        delete_line(ligneD2);
        delete_block([block,'/D1']);
        delete_block([block,'/D2']);

        set_param(block,'MaskDisplay',PlotIconSixFour);
    end


    if HaveEightSixPorts&&WantTenEightPorts
        add_block('built-in/PMIOPort',[block,'/E1']);
        set_param([block,'/E1'],'Position',[240,150,270,170],'side','Left','orientation','left');
        add_block('built-in/PMIOPort',[block,'/E2']);
        set_param([block,'/E2'],'Position',[240,205,270,225],'side','Left','orientation','left');
        SRMPortHandles=get_param([block,'/SwitcheReluctanceMotor'],'PortHandles');
        E1PortHandle=get_param([block,'/E1'],'PortHandles');
        E2PortHandle=get_param([block,'/E2'],'PortHandles');
        add_line(block,SRMPortHandles.RConn(3),E1PortHandle.RConn)
        add_line(block,SRMPortHandles.RConn(4),E2PortHandle.RConn)

        set_param(block,'MaskDisplay',PlotIconTenEight);
    end


    if HaveTenEightPorts&&WantSixFourPorts
        PortHandles=get_param([block,'/SwitcheReluctanceMotor'],'PortHandles');

        ligneD1=get_param(PortHandles.RConn(1),'line');
        ligneD2=get_param(PortHandles.RConn(2),'line');
        delete_line(ligneD1);
        delete_line(ligneD2);
        delete_block([block,'/D1']);
        delete_block([block,'/D2']);

        ligneE1=get_param(PortHandles.RConn(3),'line');
        ligneE2=get_param(PortHandles.RConn(4),'line');
        delete_line(ligneE1);
        delete_line(ligneE2);
        delete_block([block,'/E1']);
        delete_block([block,'/E2']);

        set_param(block,'MaskDisplay',PlotIconSixFour);
    end


    if HaveTenEightPorts&&WantEightSixPorts
        PortHandles=get_param([block,'/SwitcheReluctanceMotor'],'PortHandles');

        ligneE1=get_param(PortHandles.RConn(3),'line');
        ligneE2=get_param(PortHandles.RConn(4),'line');
        delete_line(ligneE1);
        delete_line(ligneE2);
        delete_block([block,'/E1']);
        delete_block([block,'/E2']);

        set_param(block,'MaskDisplay',PlotIconEightSix);
    end