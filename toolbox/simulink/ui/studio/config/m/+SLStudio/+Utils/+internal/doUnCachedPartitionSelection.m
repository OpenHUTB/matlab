function parts=doUnCachedPartitionSelection(cbinfo,inReturnHandles)




    parts=struct;
    parts.blocks=[];
    parts.notes=[];
    parts.segments=[];
    parts.others=[];
    parts.markupItems=[];
    parts.markupConnectors=[];
    selection=cbinfo.selection;
    if~inReturnHandles
        for i=1:selection.size
            item=selection.at(i);
            if SLStudio.Utils.objectIsValidBlock(item)
                parts.blocks=[parts.blocks,item];
            elseif SLStudio.Utils.objectIsValidAnnotation(item)
                parts.notes=[parts.notes,item];
            elseif SLStudio.Utils.objectIsValidSegment(item)
                parts.segments=[parts.segments,item];
            elseif SLStudio.Utils.objectIsValidMarkupItem(item)
                parts.markupItems=[parts.markupItems,item];
            elseif SLStudio.Utils.objectIsValidMarkupConnector(item)
                parts.markupConnectors=[parts.markupConnectors,item];
            else
                parts.others=[parts.others,item];
            end
            if~isempty(parts.markupItems)
                parts.markupItems=SLStudio.Utils.internal.sortMarkupItemsByClientName(parts.markupItems);
            end
            if~isempty(parts.markupConnectors)
                parts.markupConnectors=SLStudio.Utils.internal.sortMarkupItemsByClientName(parts.markupConnectors);
            end
        end
    else

        for i=1:selection.size
            item=selection.at(i);
            if SLStudio.Utils.objectIsValidBlock(item)
                parts.blocks=[parts.blocks,item.handle];
            elseif SLStudio.Utils.objectIsValidAnnotation(item)
                parts.notes=[parts.notes,item.handle];
            elseif SLStudio.Utils.objectIsValidSegment(item)
                parts.segments=[parts.segments,item.handle];
            elseif SLStudio.Utils.objectIsValidMarkupItem(item)
                ;
            elseif SLStudio.Utils.objectIsValidMarkupConnector(item)
                ;
            else
                parts.others=[parts.others,item.handle];
            end
        end
    end
end
