function handleActiveEditorChanged(obj,cbinfo)





    if isempty(obj.prevActiveEditor)
        obj.prevActiveEditor=obj.studio.App.getActiveEditor;
    end

    if obj.ready
        sfprivate('eml_man','update_data',obj.objectId);
    end

    newEditor=obj.studio.App.getActiveEditor;
    newEditorDiagram=newEditor.getDiagram;
    prevEditorDiagram=obj.prevActiveEditor.getDiagram;

    if isa(prevEditorDiagram,'SA_M3I.StudioAdapterDiagram')&&...
        (isa(sf('IdToHandle',obj.chartId),'Stateflow.EMChart')||...
        isa(sf('IdToHandle',obj.objectId),'Stateflow.EMFunction'))&&...
        prevEditorDiagram.blockHandle==obj.blkH
        obj.unregisterFocusListener();
    end



    if isa(newEditorDiagram,'SA_M3I.StudioAdapterDiagram')&&...
        (isa(sf('IdToHandle',obj.chartId),'Stateflow.EMChart')||...
        isa(sf('IdToHandle',obj.objectId),'Stateflow.EMFunction'))&&...
        newEditorDiagram.blockHandle==obj.blkH
        obj.registerFocusListener();
    end


    obj.prevActiveEditor=newEditor;
end
