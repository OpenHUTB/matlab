function launchProfileEditor()




    if systemcomposer.internal.profile.newEditor
        app=systemcomposer.internal.profile.app.ProfileEditorApp.getInstance();
        app.openStudio(0);
    else
        systemcomposer.internal.profile.Designer.launch
    end
end
