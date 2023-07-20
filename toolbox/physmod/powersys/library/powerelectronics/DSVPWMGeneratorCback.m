function DSVPWMGeneratorCback(block)





    InputType=get_param(block,'InputType');
    PortHandles=get_param(block,'PortHandles');
    HaveNoInports=isempty(PortHandles.Inport);
    HaveInports=~HaveNoInports;

    switch InputType
    case 'Magnitude-Angle (rad)'
        set_param(block,'MaskVisibilities',{'on','on','on','off','on'});
        try
            set_param([block,'/Ualpha'],'Name','Umag');
            set_param([block,'/Ubeta'],'Name','Uangle');
        catch ME %#ok display a message is not necessary.
        end
        if HaveNoInports
            replace_block(block,'Followlinks','on','Name','Umag','BlockType','Constant','Inport','noprompt');
            replace_block(block,'Followlinks','on','Name','Uangle','BlockType','Constant','Inport','noprompt');
        end
    case 'alpha-beta components'
        set_param(block,'MaskVisibilities',{'on','on','on','off','on'});
        try
            set_param([block,'/Umag'],'Name','Ualpha');
            set_param([block,'/Uangle'],'Name','Ubeta');
        catch ME %#ok  display a message is not necessary.
        end
        if HaveNoInports
            replace_block(block,'Followlinks','on','Name','Ualpha','BlockType','Constant','Inport','noprompt');
            replace_block(block,'Followlinks','on','Name','Ubeta','BlockType','Constant','Inport','noprompt');
        end
    case 'Internally generated'
        set_param(gcbh,'MaskVisibilities',{'on','on','on','on','on'});
        try
            replace_block(block,'Followlinks','on','Name','Umag','BlockType','Inport','Constant','noprompt');
            replace_block(block,'Followlinks','on','Name','Uangle','BlockType','Inport','Constant','noprompt');
        catch ME %#ok  display a message is not necessary.
        end
        if HaveInports
            replace_block(block,'Followlinks','on','Name','Ualpha','BlockType','Inport','Constant','noprompt');
            replace_block(block,'Followlinks','on','Name','Ubeta','BlockType','Inport','Constant','noprompt');
        end
    end