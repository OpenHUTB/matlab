



function setFilePath(dlg,obj)

    blockHandle=get(obj.blockObj,'handle');

    fullFileName=get_param(blockHandle,'Filename');
    [~,~,ext]=fileparts(fullFileName);
    ext=insertBefore(ext,".","*");
    fileFilter={ext};
    [filename,pathname]=uiputfile(fileFilter,'Select the output folder for the record file');
    path_FileName=fullfile(pathname,filename);

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'Filename',path_FileName});
    utils.recordDialogUtils.updateFileHistory(blockHandle,path_FileName);

    dlg.clearWidgetWithError('ToFileLocationButton');
    dlg.clearWidgetDirtyFlag('ToFileLocationButton');
end