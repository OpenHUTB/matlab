function ShaftInput(block)






    WantSSCMec=strcmp(get_param(block,'MechanicalLoad'),'Mechanical rotational port');
    WantSPSMec=strcmp(get_param(block,'MechanicalLoad'),'Mechanical power Pm')||strcmp(get_param(block,'MechanicalLoad'),'Speed w')||strcmp(get_param(block,'MechanicalLoad'),'Torque Tm')||strcmp(get_param(block,'MechanicalLoad'),'Torque TL');


    MaskType=get_param(block,'MaskType');
    ports=get_param(block,'ports');

    switch MaskType

    case 'Synchronous Machine'
        HaveSPSMec=ports(6)==0;
        HaveSSCMec=ports(6)==1;

    case 'Simplified Synchronous Machine'
        if strcmp(get_param(block,'ConnectionType'),'4-wire Y')&&ports(6)==1
            HaveSPSMec=1;
            HaveSSCMec=0;
        elseif strcmp(get_param(block,'ConnectionType'),'3-wire Y')&&ports(6)==0
            HaveSPSMec=1;
            HaveSSCMec=0;
        else
            HaveSPSMec=0;
            HaveSSCMec=1;
        end

    case 'Asynchronous Machine'
        HaveSPSMec=ports(6)==3||ports(6)==6;
        HaveSSCMec=ports(6)==4||ports(6)==7;

    case 'Single Phase Asynchronous Machine'
        HaveSPSMec=ports(6)==2||ports(6)==4;
        HaveSSCMec=ports(6)==3||ports(6)==5;

    case 'Permanent Magnet Synchronous Machine'
        HaveSPSMec=ports(6)==3||ports(6)==5;
        HaveSSCMec=ports(6)==4||ports(6)==6;

    case 'DC machine'
        if strcmp(get_param(block,'FieldType'),'Permanent magnet')&&ports(6)==1
            HaveSPSMec=1;
            HaveSSCMec=0;
        elseif strcmp(get_param(block,'FieldType'),'Wound')&&ports(6)==2
            HaveSPSMec=1;
            HaveSSCMec=0;
        else
            HaveSPSMec=0;
            HaveSSCMec=1;
        end

        if HaveSSCMec&&WantSPSMec
            PortHandles=get_param([block,'/Electrical model'],'PortHandles');
            ligne1=get_param(PortHandles.LConn(1),'line');

            if ligne1~=-1
                delete_line(ligne1);
                delete_block([block,'/S']);
            end

            replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','mec','Inport','noprompt');
            set_param([block,'/mec'],'orientation','Right','Port','1','ShowName','off');
        end

        if HaveSPSMec&&WantSSCMec
            replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','mec','Constant','noprompt');
            set_param([block,'/mec'],'orientation','Right','ShowName','off');

            add_block('built-in/PMIOPort',[block,'/S'],'Port','1');
            set_param([block,'/S'],'Position',[265,180,295,200],'side','Left','orientation','Right','Foregroundcolor','Red');
            PortHandles=get_param([block,'/Electrical model'],'PortHandles');
            ShaftPortHandle=get_param([block,'/S'],'PortHandles');
            add_line(block,PortHandles.LConn(1),ShaftPortHandle.RConn);
        end


        return
    end

    if HaveSSCMec&&WantSPSMec

        PortHandles=get_param([block,'/Mechanical model'],'PortHandles');
        ligne1=get_param(PortHandles.LConn(1),'line');

        if ligne1~=-1
            delete_line(ligne1);
            delete_block([block,'/S']);
        end

        replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','mec','Inport','noprompt');
        set_param([block,'/mec'],'orientation','Right','Port','1','ShowName','off');

    end

    if HaveSPSMec&&WantSSCMec

        replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','mec','Constant','noprompt');
        set_param([block,'/mec'],'orientation','Left','ShowName','off');

        add_block('built-in/PMIOPort',[block,'/S'],'Port','1');
        set_param([block,'/S'],'Position',[250,385,280,405],'side','Left','orientation','Left','Foregroundcolor','Red');
        PortHandles=get_param([block,'/Mechanical model'],'PortHandles');
        ShaftPortHandle=get_param([block,'/S'],'PortHandles');
        add_line(block,PortHandles.LConn(1),ShaftPortHandle.RConn);

    end