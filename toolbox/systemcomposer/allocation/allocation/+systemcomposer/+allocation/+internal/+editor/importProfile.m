function importProfile(setName)



    if systemcomposer.allocation.internal.editor.performImportDialog(setName)
        drawnow;
        systemcomposer.allocation.internal.editor.WindowManager.showStudio;
    end
end

