function openvar(name,~)






    if slfeature('TypeEditorStudio')>0
        typeeditor('Create',name);
    else
        aliasTypeObject=evalin('base',name);
        aliasTypeObject.dialog(name,'DLG_STANDALONE');
    end
