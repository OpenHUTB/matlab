function resultArray=doUnCachedPartitionSelectionOf(cbinfo,inType,inReturnHandles)




    resultArray=[];
    selection=cbinfo.selection;
    if selection.size>0
        if strcmp(inType,'blocks')
            for i=1:selection.size
                item=selection.at(i);
                if SLStudio.Utils.objectIsValidBlock(item)
                    if~inReturnHandles
                        resultArray=[resultArray,item];%#ok<AGROW>
                    else
                        resultArray=[resultArray,item.handle];%#ok<AGROW>
                    end
                end
            end
        elseif strcmp(inType,'notes')
            for i=1:selection.size
                item=selection.at(i);
                if SLStudio.Utils.objectIsValidAnnotation(item)
                    if~inReturnHandles
                        resultArray=[resultArray,item];%#ok<AGROW>
                    else
                        resultArray=[resultArray,item.handle];%#ok<AGROW>
                    end
                end
            end
        elseif strcmp(inType,'segments')
            for i=1:selection.size
                item=selection.at(i);
                if SLStudio.Utils.objectIsValidSegment(item)
                    if~inReturnHandles
                        resultArray=[resultArray,item];%#ok<AGROW>
                    else
                        resultArray=[resultArray,item.handle];%#ok<AGROW>
                    end
                end
            end
        elseif strcmp(inType,'other')
            for i=1:selection.size
                item=selection.at(i);
                if~SLStudio.Utils.objectIsValidBlock(item)&&~SLStudio.Utils.objectIsValidAnnotation(item)&&...
                    ~SLStudio.Utils.objectIsValidSegment(item)&&~SLStudio.Utils.objectIsValidMarkupItem(item)&&...
                    ~SLStudio.Utils.objectIsValidMarkupConnector(item)

                    resultArray=[resultArray,item];%#ok<AGROW>
                end
            end
        elseif strcmp(inType,'markupItems')
            for i=1:selection.size
                item=selection.at(i);
                if SLStudio.Utils.objectIsValidMarkupItem(item)

                    resultArray=[resultArray,item];%#ok<AGROW>
                end
            end
        elseif strcmp(inType,'markupConnectors')
            for i=1:selection.size
                item=selection.at(i);
                if SLStudio.Utils.objectIsValidMarkupConnector(item)

                    resultArray=[resultArray,item];%#ok<AGROW>
                end
            end
        end
    end
end
