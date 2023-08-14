function resultArray=doPartitionSelectionOf(cbinfo,inType,inReturnHandles)




    resultArray=[];
    selection=cbinfo.selection;
    if selection.size>0

        model=selection.at(1).modelM3I;
        if~inReturnHandles
            if strcmp(inType,'blocks')
                resultArray=SLM3I.Util.getSelectedBlocksFromEditor(cbinfo.studio.App.getActiveEditor,model);
            elseif strcmp(inType,'notes')
                resultArray=SLM3I.Util.getSelectedAnnotationsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            elseif strcmp(inType,'segments')
                resultArray=SLM3I.Util.getSelectedSegmentsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            elseif strcmp(inType,'connectors')
                resultArray=SLM3I.Util.getSelectedConnectorsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            elseif strcmp(inType,'markupItems')
                resultArray=SLM3I.Util.getSelectedMarkupItemsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            elseif strcmp(inType,'markupConnectors')
                resultArray=SLM3I.Util.getSelectedMarkupConnectorsFromEditor(cbinfo.studio.App.getActiveEditor,model);
            elseif strcmp(inType,'other')
                resultArray=cbinfo.studio.App.getActiveEditor.getSelectedObjectsExcludingTypes(model,...
                [SLM3I.Block.MetaClass.qualifiedName,',',SLM3I.Annotation.MetaClass.qualifiedName,',',...
                SLM3I.Segment.MetaClass.qualifiedName,',',markupM3I.MarkupItem.MetaClass.qualifiedName,',',...
                markupM3I.MarkupConnector.MetaClass.qualifiedName]);
            end
        else
            if strcmp(inType,'blocks')
                resultArray=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesOfType(model,SLM3I.Block.MetaClass);
            elseif strcmp(inType,'notes')
                resultArray=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesOfType(model,SLM3I.Annotation.MetaClass);
            elseif strcmp(inType,'segments')
                resultArray=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesOfType(model,SLM3I.Segment.MetaClass);
            elseif strcmp(inType,'other')
                resultArray=cbinfo.studio.App.getActiveEditor.getSelectedObjectHandlesExcludingTypes(model,...
                [SLM3I.Block.MetaClass.qualifiedName,',',SLM3I.Annotation.MetaClass.qualifiedName,',',...
                SLM3I.Segment.MetaClass.qualifiedName,',',markupM3I.MarkupItem.MetaClass.qualifiedName,',',...
                markupM3I.MarkupConnector.MetaClass.qualifiedName]);
            end



        end
    end
end
