function SvcCback(block,PO)





    if~exist('PO','var')
        PO=0;
    end

    BlockName=getfullname(block);
    Param_OpMode=get_param(BlockName,'mode');
    Param_External=get_param(BlockName,'ExternalVref');
    Param_Vref=get_param([BlockName,'/Vref '],'BlockType');

    External_On=strcmp('on',Param_External);
    Inport_On=strcmp('Inport',Param_Vref);

    MV=get_param(block,'MaskVisibilities');
    ME=get_param(block,'MaskEnables');

    if strcmp('Voltage regulation',Param_OpMode)
        MV{7}='on';
        MV{8}='on';
        MV{9}='on';
        MV{10}='on';
        MV{11}='off';
    else
        MV{7}='off';
        MV{8}='off';
        MV{9}='off';
        MV{10}='off';
        MV{11}='on';
    end

    if(External_On)
        ME{7}='off';
    else
        ME{7}='on';
    end

    if(External_On&&~Inport_On)&&PO
        replace_block(BlockName,'FollowLinks','on','Name','Vref ','Inport','noprompt');
        set_param([BlockName,'/Vref '],'Port','1');
    else
        if(~External_On&&Inport_On)&&PO
            replace_block(BlockName,'FollowLinks','on','Name','Vref ','Constant','noprompt');
            set_param([BlockName,'/Vref '],'Value','Vref');
        end
    end

    set_param(block,'MaskEnables',ME);
    set_param(BlockName,'MaskVisibilities',MV);
    set_param(BlockName,'mode',Param_OpMode);
    set_param(BlockName,'ExternalVref',Param_External);