function reqRefreshTypeChain(ttMan)




    selectionInfo=ttMan.TruthTableSelectionInfo;

    if length(selectionInfo.TypeChain)<2
        return;
    end
    tableIndex=Stateflow.TruthTable.TruthTableManager.CONDITION_TABLE;
    if strcmp(selectionInfo.TypeChain{1},'ActionTable')
        tableIndex=Stateflow.TruthTable.TruthTableManager.ACTION_TABLE;
    end
    Stateflow.TruthTable.TruthTableManager.notifySelectionChanged(ttMan.TruthTableObjectId,...
    tableIndex,selectionInfo.RowIndex,selectionInfo.ColumnIndex,selectionInfo.CanPaste);
end
