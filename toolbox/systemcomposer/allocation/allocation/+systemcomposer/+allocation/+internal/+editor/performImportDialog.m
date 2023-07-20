function didIt=performImportDialog(setName)



    didIt=false;
    dialogTitle='Import Profile';
    fileTypes={'*.xml'};
    [file,path]=uigetfile(fileTypes,dialogTitle);
    if file==0
        drawnow;
        systemcomposer.allocation.internal.editor.WindowManager.showStudio;
        return
    end
    filePath=fullfile(path,file);

    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    theSets=appCatalog.getAllocationSets();
    theSet=[];
    for si=1:numel(theSets)
        if strcmp(theSets(si).getName(),setName)
            theSet=theSets(si);
            break;
        end
    end

    theSet.addProfile(filePath);
    didIt=true;
end

