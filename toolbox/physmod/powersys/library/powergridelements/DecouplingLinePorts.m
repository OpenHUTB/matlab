function DecouplingLinePorts(block)






    ports=get_param(block,'ports');
    HavePorts=(ports(1)==1&&ports(2)==1);
    WantPorts=strcmp('on',get_param(block,'ShowPorts'));
    ME=get_param(block,'MaskEnables');

    if WantPorts&&~HavePorts
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','send','Outport','noprompt');
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','receive','Inport','noprompt');
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Unit Delay','Gain','noprompt');
        ME{11}='off';
        set_param(block,'MaskEnables',ME);
    elseif~WantPorts&&HavePorts
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','send','Goto','noprompt');
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','receive','From','noprompt');
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','Unit Delay','UnitDelay','noprompt');
        ME{11}='on';
        set_param(block,'MaskEnables',ME);
    end