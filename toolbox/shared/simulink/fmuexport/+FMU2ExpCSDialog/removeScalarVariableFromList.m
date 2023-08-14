function[pTree,scalarVariableList]=removeScalarVariableFromList(pTree,scalarVariableList,pTreeStartIndex,scalarStartIndex)
    scalarVariableList(scalarStartIndex:end)=[];
    pTree=FMU2ExpCSDialog.removeFromTree(pTree,pTreeStartIndex);
end
