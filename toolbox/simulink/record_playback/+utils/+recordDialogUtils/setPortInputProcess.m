


function setPortInputProcess(dlg,obj)
    value=dlg.getComboBoxText('PortInputProcessComboBox');
    blockHandle=get(obj.blockObj,'handle');
    frameSettings=get_param(blockHandle,'FrameSettings');
    selectedPort=get_param(blockHandle,'SelectedPort');
    if strcmp(value,DAStudio.message('record_playback:dialogs:PortSampleBased'))
        frameSettings(str2double(selectedPort))=0;
    else
        frameSettings(str2double(selectedPort))=1;
    end


    editorPath=get(blockHandle,'Path');
    [editor,editorDomain]=utils.recordDialogUtils.getEditor(editorPath);

    if(~isempty(editorDomain))
        success=utils.recordDialogUtils.setParamWithUndo(editor,editorDomain,...
        @setFrameSettingsWithUndo,{blockHandle,frameSettings,editorDomain});
        if~success
            errorMsg=DAStudio.message('record_playback:errors:InvalidNumPorts');
            dlg.setWidgetWithError('PortNumberValue',...
            DAStudio.UI.Util.Error('Transparency','Error',errorMsg,[255,0,0,100]));
        else
            dlg.clearWidgetWithError('PortNumberValue');
            dlg.clearWidgetDirtyFlag('PortNumberValue');
        end
    else


        locSetParam(blockHandle,frameSettings);
    end

    dlg.clearWidgetDirtyFlag('PortInputProcessComboBox');
end


function[success,noop]=setFrameSettingsWithUndo(blockHandle,frameSettings,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(blockHandle);
        locSetParam(blockHandle,frameSettings);
    catch
        success=false;
    end
end

function locSetParam(blockHandle,frameSettings)
    set_param(blockHandle,'FrameSettings',frameSettings);
end
