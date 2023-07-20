function[]=spsDrivesDcBusCbak(block,cbakMode)




    busType=get_param(block,'busType');
    internalBlock=[block,'/DC bus and braking chopper'];
    ports=get_param(block,'Ports');
    nbInPorts=ports(1);
    nbRConns=ports(7);
    haveGenericBus=(nbInPorts==0);
    haveDividedDCBus=(nbRConns==3);
    initVoltageEnable=get_param(block,'Setx0');

    switch busType

    case 'Capacitive (generic)'

        variant='Capacitive';

        if~isequal(get_param(internalBlock,'LabelModeActiveChoice'),variant)
            set_param(internalBlock,'LabelModeActiveChoice',variant);
        end

        if(strcmp(cbakMode,'init')&&~haveGenericBus)
            replace_block(block,'FollowLinks','on','Name','P_chop','Parent',block,'Ground','noprompt');
            replace_block(block,'FollowLinks','on','Name','Brak_ctrl','Parent',block,'Ground','noprompt');
        elseif(strcmp(cbakMode,'init')&&haveDividedDCBus)
            PortHandles1=get_param([block,'/DC bus and braking chopper'],'PortHandles');
            PortHandles2=get_param([block,'/com'],'PortHandles');
            delete_line(block,PortHandles1.RConn(2),PortHandles2.RConn);
            delete_block([block,'/com']);
        end

        maskEnables={...
        'on',...
        'on',...
        'on',...
        'off',...
        'on',...
        initVoltageEnable,...
        'on',...
        'on',...
        'on',...
        'on',...
        };

    case 'LC (for six-step drive)'

        variant='LC_six_step_drive';

        if~isequal(get_param(internalBlock,'LabelModeActiveChoice'),variant)
            set_param(internalBlock,'LabelModeActiveChoice',variant);
        end

        if(strcmp(cbakMode,'init')&&haveGenericBus)
            blk=replace_block(block,'FollowLinks','on','Name','P_chop','Parent',block,'Inport','noprompt');
            set_param(blk{1},'ForegroundColor','blue');
            blk=replace_block(block,'FollowLinks','on','Name','Brak_ctrl','Parent',block,'Inport','noprompt');
            set_param(blk{1},'ForegroundColor','blue');
        elseif(strcmp(cbakMode,'init')&&haveDividedDCBus)
            PortHandles1=get_param([block,'/DC bus and braking chopper'],'PortHandles');
            PortHandles2=get_param([block,'/com'],'PortHandles');
            delete_line(block,PortHandles1.RConn(2),PortHandles2.RConn);
            delete_block([block,'/com']);
        end

        maskEnables={...
        'on',...
        'on',...
        'on',...
        'on',...
        'on',...
        initVoltageEnable,...
        'on',...
        'on',...
        'off',...
        'off',...
        };

    case 'DividedCapacitor (for single phase motor)'

        variant='DividedCapacitor';

        if~isequal(get_param(internalBlock,'LabelModeActiveChoice'),variant)
            set_param(internalBlock,'LabelModeActiveChoice',variant);
        end

        if(strcmp(cbakMode,'init')&&~haveGenericBus)
            replace_block(block,'FollowLinks','on','Name','P_chop','Parent',block,'Ground','noprompt');
            replace_block(block,'FollowLinks','on','Name','Brak_ctrl','Parent',block,'Ground','noprompt');
        elseif(strcmp(cbakMode,'init')&&~haveDividedDCBus)
            add_block('built-in/PMIOPort',[block,'/com'],'Port','5');
            set_param([block,'/com'],'Position',[280,168,310,182],'Orientation','Left','Side','Right');
            PortHandles1=get_param([block,'/DC bus and braking chopper'],'PortHandles');
            PortHandles2=get_param([block,'/com'],'PortHandles');
            add_line(block,PortHandles1.RConn(2),PortHandles2.RConn,'AUTOROUTING','ON');
        end

        maskEnables={...
        'on',...
        'on',...
        'on',...
        'off',...
        'on',...
        initVoltageEnable,...
        'on',...
        'on',...
        'on',...
        'on',...
        };

    otherwise
        error(message('physmod:powersys:common:InvalidParameter',block,busType,'Bus type'));
    end

    if~bdIsLibrary(bdroot(block))&&~strcmp(get_param(bdroot(block),'EditingMode'),'Restricted')
        set_param(block,'MaskEnables',maskEnables);
    end