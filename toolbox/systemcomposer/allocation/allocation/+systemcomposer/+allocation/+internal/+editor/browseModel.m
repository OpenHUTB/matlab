function filePath=browseModel()




    dialogTitle='Select Architecture Model';
    fileTypes={'*.slx'};
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

