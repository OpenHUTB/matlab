function StatcomCback(block,PO)





    if~exist('PO','var')
        PO=0;
    end

    BlockName=getfullname(block);

    MV=get_param(block,'MaskVisibilities');
    if strcmp('Voltage regulation',get_param(BlockName,'OpMode_SH'));

        MV{8}='on';
        MV{9}='on';
        MV{10}='on';
        MV{11}='on';
        MV{12}='on';
        MV{13}='off';
        MV{14}='off';

        Inport_Vref_On=strcmp('Inport',get_param([BlockName,'/Vref '],'BlockType'));

        if strcmp('on',get_param(BlockName,'ExternalVref'))
            if(~Inport_Vref_On)&&PO
                replace_block(BlockName,'FollowLinks','on','Name','Vref ','Inport','noprompt');
            end
        else
            if(Inport_Vref_On)&&PO
                replace_block(BlockName,'FollowLinks','on','Name','Vref ','Constant','noprompt');
                set_param([BlockName,'/Vref '],'Value','Vref_SH');
            end
        end

    else
        MV{8}='off';
        MV{9}='off';
        MV{10}='off';
        MV{11}='off';
        MV{12}='off';
        MV{13}='on';
        MV{14}='on';
    end
    set_param(BlockName,'MaskVisibilities',MV);

    ME=get_param(block,'MaskEnables');
    if strcmp('on',get_param(BlockName,'ExternalVref'))
        ME{8}='off';
    else
        ME{8}='on';
    end
    set_param(block,'Maskenables',ME);