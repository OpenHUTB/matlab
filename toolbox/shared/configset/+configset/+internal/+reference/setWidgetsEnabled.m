function setWidgetsEnabled(dlg,enabled)




    tag=strcat('Tag_ConfigSetRef_',{
'SourceName'
'SourceName2'
'SplitButton'
    });

    cellfun(@(t)dlg.setEnabled(t,enabled),tag);
