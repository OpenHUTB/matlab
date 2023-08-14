function exportDialog=ExportTemplate(modelName,varargin)




    connector.ensureServiceOn;

    modelName=get_param(modelName,'Name');
    exportDialog=i_getExportDialog(modelName,varargin{:});
    exportDialog.show();
end

function exportDialog=i_getExportDialog(modelName,varargin)
    persistent exportDialogMap;
    mlock;

    if isempty(exportDialogMap)
        exportDialogMap=containers.Map();
    end

    if exportDialogMap.isKey(modelName)

        exportDialog=exportDialogMap(modelName);
        return;
    end



    exportDialog=sltemplate.internal.NewExportDialog(modelName,varargin{:});

    exportDialogMap(modelName)=exportDialog;
    exportDialog.addlistener('DialogClosed',@(src,~)exportDialogMap.remove(src.ModelName));

end
