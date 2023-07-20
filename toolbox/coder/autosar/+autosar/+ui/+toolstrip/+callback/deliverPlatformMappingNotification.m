function deliverPlatformMappingNotification(modelName,interfaceDictFileName)





    editor=GLUE2.Util.findAllEditors(modelName);
    if~isempty(editor)
        notificationID='autosarstandard:editor:DictionaryPlatformMappingNotification';
        notificationMsg=DAStudio.message(notificationID,interfaceDictFileName);
        editor.deliverInfoNotification(notificationID,notificationMsg);
    end


