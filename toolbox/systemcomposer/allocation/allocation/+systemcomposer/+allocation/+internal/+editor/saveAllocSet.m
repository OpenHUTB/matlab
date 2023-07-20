function saveAllocSet(allocSetName,saveAs)



    if saveAs
        dialogTitle=message('SystemArchitecture:AllocationUI:SaveAsAllocSetTS').string;
        fileTypes={'*.mldatx'};
        [file,path]=uiputfile(fileTypes,dialogTitle);
        if file==0
            return;
        else
            filePath=fullfile(path,file);
        end
    else
        filePath='';
    end

    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    appCatalog.saveAllocationSet(allocSetName,filePath);

    if saveAs
        drawnow;
        systemcomposer.allocation.internal.editor.WindowManager.showStudio;
    end

end

