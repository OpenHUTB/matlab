function dirtyRefs=getDirtyRefModels(cbinfo)




    dirtyRefs={};
    handles=cbinfo.studio.App.getBlockDiagramHandles;
    for i=1:numel(handles)
        h=handles(i);
        if(h~=cbinfo.model.Handle&&SLStudio.toolstrip.internal.isModelDirty(h,false))
            dirtyRefs=[dirtyRefs;get_param(h,'name')];%#ok<AGROW>
        end
    end
end
