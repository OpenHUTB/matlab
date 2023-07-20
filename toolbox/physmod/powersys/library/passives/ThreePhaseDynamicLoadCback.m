function ThreePhaseDynamicLoadCback(block)






    ports=get_param(block,'ports');
    External=(ports(1)==1);
    PQext=strcmp('on',get_param(block,'ExternalControl'));
    MV=get_param(block,'MaskVisibilities');
    if PQext&&~External
        MV{5}='off';
        MV{6}='off';
        MV{7}='off';
        set_param(block,'MaskVisibilities',MV);
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','PQ','BlockType','Ground','Inport','noprompt');
    elseif~PQext&&External
        MV{5}='on';
        MV{6}='on';
        MV{7}='on';
        set_param(block,'MaskVisibilities',MV);
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name','PQ','BlockType','Inport','Ground','noprompt');
    end