function bool=isBdReferencedByModelBlock(BD)











    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    activeStudioApp=[studios.App];
    getEditorArray=@(x)x.getAllEditors;
    allEditors=arrayfun(getEditorArray,activeStudioApp,'UniformOutput',false);

    allEditors=[allEditors{:}];
    targetEditor=allEditors([allEditors.blockDiagramHandle]==BD);

    bool=~isempty(targetEditor);















end

