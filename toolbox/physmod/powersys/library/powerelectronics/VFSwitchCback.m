function VFSwitchCback(block,~)





    [VF,WSStatus]=getSPSmaskvalues(block,{'Vf'},1);
    if WSStatus==0




        return
    end
    if strcmp(get_param([block,'/VF'],'blocktype'),'Goto')&&VF==0
        replace_block(block,'Followlinks','on','Name','VF','BlockType','Goto','Terminator','noprompt');
    elseif strcmp(get_param([block,'/VF'],'blocktype'),'Terminator')&&VF~=0
        replace_block(block,'Followlinks','on','Name','VF','BlockType','Terminator','Goto','noprompt');


        SetNewGotoTag([block,'/VF'],-1);
    end
