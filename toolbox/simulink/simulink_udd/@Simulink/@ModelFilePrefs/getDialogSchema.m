function dlgstruct=getDialogSchema(obj,~)







    row=1;

    format=i_format;
    format.RowSpan=[row,row];
    format.ColSpan=[1,2];
    row=row+1;

    changeNotification=i_change_notification;
    changeNotification.RowSpan=[row,row];
    changeNotification.ColSpan=[1,2];
    row=row+1;

    autoSave=i_autosave;
    autoSave.RowSpan=[row,row];
    autoSave.ColSpan=[1,2];
    row=row+1;

    notifyOldModel.Type='checkbox';
    notifyOldModel.Name=DAStudio.message('Simulink:prefs:NotifyIfLoadOldModel');
    notifyOldModel.ToolTip=...
    DAStudio.message('Simulink:prefs:NotifyIfLoadOldModelToolTip');
    notifyOldModel.Tag='NotifyIfLoadOldModel';
    notifyOldModel.Value=i_ison(get_param(0,'NotifyIfLoadOldModel'));
    notifyOldModel.RowSpan=[row,row];
    notifyOldModel.ColSpan=[1,2];
    row=row+1;

    errorNewModel.Type='checkbox';
    errorNewModel.Name=DAStudio.message('Simulink:prefs:ErrorIfLoadNewModel');
    errorNewModel.ToolTip=...
    DAStudio.message('Simulink:prefs:ErrorIfLoadNewModelToolTip');
    errorNewModel.Tag='ErrorIfLoadNewModel';
    errorNewModel.Value=i_ison(get_param(0,'ErrorIfLoadNewModel'));
    errorNewModel.RowSpan=[row,row];
    errorNewModel.ColSpan=[1,2];
    row=row+1;

    errorShadowedModel.Type='checkbox';
    errorShadowedModel.Name=DAStudio.message('Simulink:prefs:ErrorIfLoadShadowedModel');
    errorShadowedModel.ToolTip=...
    DAStudio.message('Simulink:prefs:ErrorIfLoadShadowedModelToolTip');
    errorShadowedModel.Tag='ErrorIfLoadShadowedModel';
    errorShadowedModel.Value=i_ison(get_param(0,'ErrorIfLoadShadowedModel'));
    errorShadowedModel.RowSpan=[row,row];
    errorShadowedModel.ColSpan=[1,2];
    row=row+1;

    if slfeature('ProtectedModelValidateCertificatePreferences')>0
        protectedModelValidation=i_protected_model_validation;
        protectedModelValidation.RowSpan=[row,row];
        protectedModelValidation.ColSpan=[1,2];
        row=row+1;
    end

    openProjectPrompt.Type='checkbox';
    openProjectPrompt.Name=DAStudio.message('Simulink:prefs:PromptToOpenProjectContainingModel');
    openProjectPrompt.ToolTip=DAStudio.message('Simulink:prefs:PromptToOpenProjectContainingModelTooltip');
    openProjectPrompt.Tag='PromptToOpenProjectContainingModel';
    openProjectPrompt.Value=obj.promptToOpenProject;
    openProjectPrompt.RowSpan=[row,row];
    openProjectPrompt.ColSpan=[1,2];
    row=row+1;

    blankSpace.Type='text';
    blankSpace.Name=' ';
    blankSpace.RowSpan=[row,row];
    blankSpace.ColSpan=[1,2];


    dlgstruct.DialogTitle=DAStudio.message('Simulink:prefs:ModelFilePreferencesTitle');
    dlgstruct.LayoutGrid=[row,2];
    dlgstruct.RowStretch=zeros(1,row);
    dlgstruct.RowStretch(row-1)=1;
    dlgstruct.Items={...
    format,changeNotification,autoSave,...
    notifyOldModel,errorNewModel,errorShadowedModel,openProjectPrompt,...
    blankSpace};

    if slfeature('ProtectedModelValidateCertificatePreferences')>0
        dlgstruct.Items{end+1}=protectedModelValidation;
    end


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={'mapkey:Simulink.ModelFilePrefs','help_button','CSHelpWindow'};

    dlgstruct.PostApplyMethod='dlgCallback';
    dlgstruct.PostApplyArgs={'%dialog'};
    dlgstruct.PostApplyArgsDT={'handle'};

end


function format=i_format

    modelFileFormat.Type='combobox';
    modelFileFormat.Entries={'mdl','slx'};
    modelFileFormat.Name=DAStudio.message('Simulink:prefs:ModelFileFormatPrompt');
    modelFileFormat.ToolTip=DAStudio.message('Simulink:prefs:ModelFileFormatTooltip');
    modelFileFormat.Tag='ModelFileFormat';
    modelFileFormat.Value=get_param(0,'ModelFileFormat');

    saveThumbnail.Type='checkbox';
    saveThumbnail.Name=DAStudio.message('Simulink:prefs:SaveSLXThumbnail');
    saveThumbnail.ToolTip=...
    DAStudio.message('Simulink:prefs:SaveSLXThumbnailToolTip');
    saveThumbnail.Tag='SaveSLXThumbnail';
    saveThumbnail.Value=i_ison(get_param(0,'SaveSLXThumbnail'));

    format.Type='group';
    format.Name=DAStudio.message('Simulink:prefs:FileFormatOptions');
    format.Items={modelFileFormat,saveThumbnail};

end


function changeNotification=i_change_notification

    label.Type='text';
    label.Name=DAStudio.message('Simulink:prefs:ChangedOnDiskLabel');
    label.RowSpan=[1,1];
    label.ColSpan=[1,1];

    updating.Type='checkbox';
    updating.Name=DAStudio.message('Simulink:prefs:ChangedOnDiskUpdating');
    updating.ToolTip=...
    DAStudio.message('Simulink:prefs:ChangedOnDiskUpdatingToolTip');
    updating.ObjectMethod='controlCallback';
    updating.MethodArgs={'%dialog'};
    updating.ArgDataTypes={'handle'};
    updating.Tag='NotifyUpdating';
    updating.Value=...
    i_ison(slprivate('mdl_file_change_settings','CheckWhenUpdating'));
    updating.RowSpan=[2,2];
    updating.ColSpan=[1,1];

    actions=slprivate('mdl_file_change_settings','Handling');
    entries=actions(1:end-1);
    current=actions(end);
    ind=find(strcmp(entries,current))-1;

    action.Type='combobox';
    action.Name=['     ',DAStudio.message('Simulink:prefs:Action'),'   '];
    action.Tag='NotifyAction';
    action.ToolTip=...
    DAStudio.message('Simulink:prefs:ChangedOnDiskHandlingToolTip');
    action.Entries=entries;
    action.Value=ind;
    action.Enabled=updating.Value;
    action.RowSpan=[3,3];
    action.ColSpan=[1,1];

    editing.Type='checkbox';
    editing.Name=DAStudio.message('Simulink:prefs:ChangedOnDiskEditing');
    editing.ToolTip=...
    DAStudio.message('Simulink:prefs:ChangedOnDiskEditingToolTip');
    editing.Tag='NotifyEditing';
    editing.Value=...
    i_ison(slprivate('mdl_file_change_settings','CheckWhenEditing'));
    editing.RowSpan=[4,4];
    editing.ColSpan=[1,1];

    saving.Type='checkbox';
    saving.Name=DAStudio.message('Simulink:prefs:ChangedOnDiskSaving');
    saving.ToolTip=...
    DAStudio.message('Simulink:prefs:ChangedOnDiskSavingToolTip');
    saving.Tag='NotifySaving';
    saving.Value=...
    i_ison(slprivate('mdl_file_change_settings','CheckWhenSaving'));
    saving.RowSpan=[5,5];
    saving.ColSpan=[1,1];

    changeNotification.Type='group';
    changeNotification.Name=DAStudio.message('Simulink:prefs:ChangeNotification');
    changeNotification.Items={label,updating,action,...
    editing,saving};

end


function autoSave=i_autosave

    updating.Type='checkbox';
    updating.Name=DAStudio.message('Simulink:prefs:AutoSaveOnUpdate');
    updating.ToolTip=DAStudio.message('Simulink:prefs:AutoSaveOnUpdateToolTip');
    updating.Tag='AutoSaveOnUpdate';
    val=get_param(0,'AutoSaveOptions');
    updating.Value=val.SaveOnModelUpdate;

    upgrading.Type='checkbox';
    upgrading.Name=DAStudio.message('Simulink:prefs:SaveBackupOnVersionUpgrade');
    upgrading.ToolTip=DAStudio.message('Simulink:prefs:SaveBackupOnVersionUpgradeToolTip');
    upgrading.Tag='SaveBackupOnVersionUpgrade';
    val=get_param(0,'AutoSaveOptions');
    upgrading.Value=val.SaveBackupOnVersionUpgrade;

    autoSave.Type='group';
    autoSave.Name=DAStudio.message('Simulink:prefs:AutoSaveOptions');
    autoSave.Items={updating,upgrading};

end


function protectedModelValidation=i_protected_model_validation

    validate.Type='checkbox';
    validate.Name=DAStudio.message('Simulink:prefs:ProtectedModelValidateCertificate');
    validate.ToolTip=DAStudio.message('Simulink:prefs:ProtectedModelValidateCertificateTooltip');
    validate.Tag='ProtectedModelValidateCertificate';
    validate.Value=i_ison(get_param(0,'ProtectedModelValidateCertificate'));

    protectedModelValidation=validate;
end


function b=i_ison(s)

    b=strcmp(s,'on');
    assert(b||strcmp(s,'off'));

end


