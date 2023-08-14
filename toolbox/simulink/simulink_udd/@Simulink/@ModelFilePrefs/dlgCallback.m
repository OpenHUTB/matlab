function[success,msg]=dlgCallback(obj,dlg)









    success=true;
    msg='';

    updating=dlg.getWidgetValue('NotifyUpdating');
    slprivate('mdl_file_change_settings','CheckWhenUpdating',i_onoff(updating));

    editing=dlg.getWidgetValue('NotifyEditing');
    slprivate('mdl_file_change_settings','CheckWhenEditing',i_onoff(editing));

    saving=dlg.getWidgetValue('NotifySaving');
    slprivate('mdl_file_change_settings','CheckWhenSaving',i_onoff(saving));

    action_ind=dlg.getWidgetValue('NotifyAction');
    actions=slprivate('mdl_file_change_settings','Handling');
    action=actions(action_ind+1);
    slprivate('mdl_file_change_settings','Handling',action);

    val=get_param(0,'AutoSaveOptions');
    val.SaveOnModelUpdate=dlg.getWidgetValue('AutoSaveOnUpdate');
    val.SaveBackupOnVersionUpgrade=dlg.getWidgetValue('SaveBackupOnVersionUpgrade');
    set_param(0,'AutoSaveOptions',val);

    oldmodel=dlg.getWidgetValue('NotifyIfLoadOldModel');
    set_param(0,'NotifyIfLoadOldModel',i_onoff(oldmodel));

    newmodel=dlg.getWidgetValue('ErrorIfLoadNewModel');
    set_param(0,'ErrorIfLoadNewModel',i_onoff(newmodel));

    shadowedmodel=dlg.getWidgetValue('ErrorIfLoadShadowedModel');
    set_param(0,'ErrorIfLoadShadowedModel',i_onoff(shadowedmodel));

    savethumbnail=dlg.getWidgetValue('SaveSLXThumbnail');
    set_param(0,'SaveSLXThumbnail',i_onoff(savethumbnail));

    validate=dlg.getWidgetValue('ProtectedModelValidateCertificate');
    set_param(0,'ProtectedModelValidateCertificate',i_onoff(validate));

    validate=dlg.getWidgetValue('PromptToOpenProjectContainingModel');
    obj.promptToOpenProject(validate);



    format=dlg.getWidgetValue('ModelFileFormat');
    if format==1
        format='slx';
    else
        assert(format==0);
        format='mdl';
    end
    set_param(0,'ModelFileFormat',format);

    p=Simulink.Preferences.getInstance;
    p.Save;

end


function s=i_onoff(b)

    if b
        s='on';
    else
        s='off';
    end

end


