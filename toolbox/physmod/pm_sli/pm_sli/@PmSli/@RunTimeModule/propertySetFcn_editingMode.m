function allowedMode=propertySetFcn_editingMode(sourceObject,requestedMode)












    this=PmSli.RunTimeModule.getInstance;

    hModel=sourceObject.getBlockDiagram;

    if isempty(this)||isempty(hModel)||~this.isModelRegistered(hModel)


        allowedMode=requestedMode;
        return;

    end


    currentMode=this.getConfigSetEditingMode(sourceObject);

    if this.isDiagramLocked(hModel)&&(~strcmp(currentMode,requestedMode))

        configData=RunTimeModule_config;
        pm_error(configData.Error.CannotChangeLockedMode_templ_msgid,...
        pm_message(configData.EditingMode.Label_msgid),...
        sanitizeName(hModel.Name));

    end

    if~sourceObject.isActive

        allowedMode=requestedMode;
        return;
    end






















    acs=hModel.getActiveConfigSet;
    checkOnly=(acs~=sourceObject.up);

    success=this.switchEditingMode(hModel,currentMode,requestedMode,checkOnly);



    if success
        allowedMode=requestedMode;
    else

    end



