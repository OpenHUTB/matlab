function SsscCback(block,PO)





    if~exist('PO','var')
        PO=0;
    end

    BlockName=getfullname(block);

    Inport_Vqref_On=strcmp('Inport',get_param([BlockName,'/Vqref '],'BlockType'));
    Inport_ByPass_On=strcmp('Inport',get_param([BlockName,'/Bypass '],'BlockType'));

    ME=get_param(block,'MaskEnables');
    if strcmp('on',get_param(BlockName,'ExternalVqref'))
        ME{8}='off';
    else
        ME{8}='on';
    end
    set_param(block,'MaskEnables',ME);

    if~PO

        return
    end

    if strcmp('External control',get_param(BlockName,'ExternalByPass'));
        if(~Inport_ByPass_On)
            replace_block(BlockName,'FollowLinks','on','Name','Bypass ','Inport','noprompt');
            set_param([BlockName,'/Bypass '],'Port','1');
        end
    else
        if(Inport_ByPass_On)
            replace_block(BlockName,'FollowLinks','on','Name','Bypass ','Constant','noprompt');
        end
        if strcmp('Closed',get_param(BlockName,'ExternalByPass'));
            Value_ByPass='1';
        else
            Value_ByPass='0';
        end
        set_param([BlockName,'/Bypass '],'Value',Value_ByPass);
    end

    if strcmp('on',get_param(BlockName,'ExternalVqref'))
        if(~Inport_Vqref_On)
            replace_block(BlockName,'FollowLinks','on','Name','Vqref ','Inport','noprompt');
            if(Inport_ByPass_On)
                set_param([BlockName,'/Vqref '],'Port','2');
            else
                set_param([BlockName,'/Vqref '],'Port','1');
            end
        end
    else
        if(Inport_Vqref_On)
            replace_block(BlockName,'FollowLinks','on','Name','Vqref ','Constant','noprompt');
            set_param([BlockName,'/Vqref '],'Value','Vqref');
        end
    end