function SaveCurrentRefModelCB(cbinfo,~)




    editor=cbinfo.studio.App.getActiveEditor();
    currentHandle=SLM3I.SLCommonDomain.getSLHandleForHID(editor.getHierarchyId);
    activeInstanceNames=slInternal('getActiveSRInstanceNames',currentHandle);

    if(~isempty(activeInstanceNames))
        subsystemRefBD=activeInstanceNames{1};
        if(strcmp(get_param(subsystemRefBD,'Dirty'),'on'))
            SLM3I.saveBlockDiagramAndDirtyRefModels(get_param(subsystemRefBD,'Handle'));
        end
    elseif SLStudio.toolstrip.internal.isModelDirty(cbinfo.editorModel.Handle,true)
        SLM3I.saveBlockDiagramAndDirtyRefModels(cbinfo.editorModel.Handle);
    end
end
