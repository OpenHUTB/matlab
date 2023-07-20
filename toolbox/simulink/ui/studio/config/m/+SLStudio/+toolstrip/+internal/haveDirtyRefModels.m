function result=haveDirtyRefModels(cbinfo)




    result=false;
    handles=cbinfo.studio.App.getBlockDiagramHandles;
    for i=1:numel(handles)
        h=handles(i);
        if(h~=cbinfo.model.Handle&&SLStudio.toolstrip.internal.isModelDirty(h,true))
            result=true;
            return;
        end
    end
end
