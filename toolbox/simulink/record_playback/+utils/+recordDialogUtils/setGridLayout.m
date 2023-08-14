

function setGridLayout(dlg,obj)

    if isa(obj,'rapdlg.Record')
        blockHandle=get(obj.blockObj,'handle');
        gridLayout=dlg.getWidgetValue('GridValue');
    else
        blockHandle=obj.blockHandle;
        row=dlg.getWidgetValue('RowValue');
        col=dlg.getWidgetValue('ColValue');
        gridLayout=['[',row,' ',col,']'];
    end


    editorPath=get(blockHandle,'Path');
    [editor,editorDomain]=utils.recordDialogUtils.getEditor(editorPath);
    if(~isempty(editorDomain))
        success=utils.recordDialogUtils.setParamWithUndo(editor,editorDomain,...
        @setGridLayoutWithUndo,{blockHandle,gridLayout,editorDomain});
        if~success
            errorMsg=DAStudio.message('record_playback:errors:InvalidRowColumns');
            dlg.setWidgetWithError('GridValue',...
            DAStudio.UI.Util.Error('Transparency','Error',errorMsg,[255,0,0,100]));
        else
            dlg.clearWidgetWithError('GridValue');
            dlg.clearWidgetDirtyFlag('GridValue');
        end
    else
        locSetParam(blockHandle,gridLayout);
    end
end

function[success,noop]=setGridLayoutWithUndo(blockHandle,gridLayout,editorDomain)
    success=true;
    noop=false;
    try
        editorDomain.paramChangesCommandAddObject(blockHandle);
        locSetParam(blockHandle,gridLayout);
    catch
        success=false;
    end
end

function locSetParam(blockHandle,gridLayout)
    set_param(blockHandle,'Layout',gridLayout);
end
