function[filePath,file]=browseAllocSet()




    dialogTitle='Select Allocation Set';
    fileTypes={'*.mldatx'};
    [file,path]=uigetfile(fileTypes,dialogTitle);
    if file==0
        filePath='';
        drawnow;
        systemcomposer.allocation.internal.editor.WindowManager.showStudio;
        return
    end
    filePath=fullfile(path,file);

    drawnow;
    systemcomposer.allocation.internal.editor.WindowManager.showStudio;

end

