


function setFileType(dlg,obj)
    value=dlg.getComboBoxText('FileTypeComboBox');
    blockHandle=get(obj.blockObj,'handle');
    toFileValue=get_param(blockHandle,'Filename');
    [fileLocation,name,currExt]=fileparts(toFileValue);
    selectedExt=value(3:end);

    if(strcmp(selectedExt,currExt))
        return;
    end

    if(strcmp(currExt,'.mldatx')||strcmp(currExt,'.mat')||...
        strcmp(currExt,'.xlsx'))
        toFileValue=fullfile(fileLocation,strcat(name,['.',selectedExt]));
    else
        toFileValue=fullfile(fileLocation,strcat(name,[currExt,'.',selectedExt]));
    end

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'Filename',toFileValue});
    utils.recordDialogUtils.updateFileHistory(blockHandle,toFileValue);

    dlg.clearWidgetDirtyFlag('FileTypeComboBox');
end
