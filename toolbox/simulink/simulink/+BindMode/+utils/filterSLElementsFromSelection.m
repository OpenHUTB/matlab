

function filteredElements=filterSLElementsFromSelection(selectionTypes,selectionHandles)

    assert(numel(selectionTypes)==numel(selectionHandles));
    for idx=1:numel(selectionHandles)
        type=get_param(selectionHandles(idx),'Type');

        if(strcmp(type,'block')&&utils.isWebBlock(selectionHandles(idx)))
            selectionHandles(idx)=0;
        end
    end
    indicesToRemove=selectionHandles==0;
    selectionTypes(indicesToRemove)=[];
    selectionHandles(indicesToRemove)=[];
    filteredElements.selectionTypes=selectionTypes;
    filteredElements.selectionHandles=selectionHandles;
end