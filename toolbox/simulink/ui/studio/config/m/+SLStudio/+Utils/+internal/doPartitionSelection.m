function parts=doPartitionSelection(cbinfo,inReturnHandles)




    parts=struct;
    parts.blocks=[];
    parts.notes=[];
    parts.segments=[];
    parts.others=[];
    parts.connectors=[];
    parts.markupItems=[];
    parts.markupConnectors=[];
    selection=cbinfo.selection;
    if selection.size>0
        model=selection.at(1).modelM3I;
        if~inReturnHandles
            parts.blocks=SLM3I.Util.getSelectedBlocksFromEditor(cbinfo.studio.App.getActiveEditor,model);
            parts.notes=SLM3I.Util.getSelectedAnnotationsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            parts.segments=SLM3I.Util.getSelectedSegmentsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            parts.others=cbinfo.studio.App.getActiveEditor.getSelectedObjectsExcludingTypes(model,...
            [SLM3I.Block.MetaClass.qualifiedName,',',SLM3I.Annotation.MetaClass.qualifiedName,',',...
            SLM3I.Segment.MetaClass.qualifiedName,',',markupM3I.MarkupItem.MetaClass.qualifiedName,',',...
            markupM3I.MarkupConnector.MetaClass.qualifiedName]);
            parts.connectors=SLM3I.Util.getSelectedConnectorsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            parts.markupItems=SLM3I.Util.getSelectedMarkupItemsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            parts.markupConnectors=SLM3I.Util.getSelectedMarkupConnectorsFromEditor(cbinfo.studio.App.getActiveEditor,model);
        else
            parts.blocks=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesOfType(model,SLM3I.Block.MetaClass);
            parts.notes=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesOfType(model,SLM3I.Annotation.MetaClass);
            parts.segments=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesOfType(model,SLM3I.Segment.MetaClass);
            parts.others=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesExcludingTypes(model,...
            [SLM3I.Block.MetaClass.qualifiedName,',',SLM3I.Annotation.MetaClass.qualifiedName,',',...
            SLM3I.Segment.MetaClass.qualifiedName,',',markupM3I.MarkupItem.MetaClass.qualifiedName,',',...
            markupM3I.MarkupConnector.MetaClass.qualifiedName]);



        end
    end
end
