function autoblks_update_torconv(blkHndl,callID)



    blkTyp=get_param(gcb,'TCType');

    maskSet=get_param(blkHndl,'MaskVisibilities');
    maskObj=Simulink.Mask.get(blkHndl);
    ClutchLockUpgroupObj=maskObj.getDialogControl('ClutchLockUp');
    ClutchgroupObj=maskObj.getDialogControl('ClutchParams');
    switch blkTyp
    case 'No lock-up'
        set_param([blkHndl,'/Lock-up Type'],'LabelModeActiveChoice','0');
        if strcmp(get_param([blkHndl,'/Clutch Force'],'BlockType'),'Inport')&&callID==1
            replace_block(blkHndl,'SearchDepth',1,'FollowLinks','on','BlockType','Inport','Name','Clutch Force','built-in/Constant','noprompt')
            set_param([blkHndl,'/Clutch Force'],'Value','eps');
        end
        maskSet(15:end)=cellstr('off');
        set_param(blkHndl,'MaskVisibilities',maskSet);
        ClutchLockUpgroupObj.Visible='off';
        ClutchgroupObj.Visible='off';
    case 'Lock-up'
        set_param([blkHndl,'/Lock-up Type'],'LabelModeActiveChoice','1');
        if strcmp(get_param([blkHndl,'/Clutch Force'],'BlockType'),'Inport')&&callID==1
            replace_block(blkHndl,'SearchDepth',1,'FollowLinks','on','BlockType','Inport','Name','Clutch Force','built-in/Constant','noprompt')
            set_param([blkHndl,'/Clutch Force'],'Value','eps');
        end
        maskSet(15:end)=cellstr('on');
        set_param(blkHndl,'MaskVisibilities',maskSet);
        ClutchLockUpgroupObj.Visible='on';
        ClutchgroupObj.Visible='on';
    case 'External lock-up input'
        set_param([blkHndl,'/Lock-up Type'],'LabelModeActiveChoice','0');
        if strcmp(get_param([blkHndl,'/Clutch Force'],'BlockType'),'Constant')&&callID==1
            replace_block(blkHndl,'SearchDepth',1,'FollowLinks','on','BlockType','Constant','Name','Clutch Force','built-in/Inport','noprompt')
        end
        maskSet(19:end)=cellstr('off');
        set_param(blkHndl,'MaskVisibilities',maskSet);
        ClutchLockUpgroupObj.Visible='off';
        ClutchgroupObj.Visible='on';
    otherwise
        set_param([blkHndl,'/Lock-up Type'],'LabelModeActiveChoice','0');
        if strcmp(get_param([blkHndl,'/Clutch Force'],'BlockType'),'Inport')&&callID==1
            replace_block(blkHndl,'SearchDepth',1,'FollowLinks','on','BlockType','Inport','Name','Clutch Force','built-in/Constant','noprompt')
            set_param([blkHndl,'/Clutch Force'],'Value','eps');
        end
        maskSet(15:end)=cellstr('off');
        set_param(blkHndl,'MaskVisibilities',maskSet);
        ClutchLockUpgroupObj.Visible='off';
        ClutchgroupObj.Visible='off';

    end

    TCResp=str2double((get_param(blkHndl,'TCTau')));
    if TCResp<=0
        set_param([blkHndl,'/Unlocked/Torque Converter/Torque Response'],'LabelModeActiveChoice','0');
    else
        set_param([blkHndl,'/Unlocked/Torque Converter/Torque Response'],'LabelModeActiveChoice','1');
    end

end