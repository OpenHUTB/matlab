function CAN_SAVE_AS=canSaveAs(edditorAppID,fileToSave)



    CAN_SAVE_AS=true;

    hash1=Simulink.sta.InstanceMap.getInstance();
    openTags=hash1.getOpenTags;


    if isStringScalar(fileToSave)
        fileToSave=char(fileToSave);
    end

    for k=1:length(openTags)

        openEditorInstance=hash1.getUIInstance(openTags{k});

        if~strcmp(openEditorInstance.editorAppID,edditorAppID)&&...
            ischar(openEditorInstance.DataSource)&&...
            strcmp(fileToSave,openEditorInstance.DataSource)


            CAN_SAVE_AS=false;

        end

    end
