function ttAddClearBreakpointCB(cbinfo)




    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        return;
    end
    ttMan=Stateflow.TruthTable.TruthTableManager.getInstance(ttObjectId);
    typeChain=ttMan.TruthTableSelectionInfo.TypeChain;
    if strcmp(typeChain{1},'ConditionTable')
        if strcmp(typeChain{2},'RowContext')
            ttMan.dispatchUIRequest('addClearConditionTestedBreakPoint',{},false);
        elseif strcmp(typeChain{2},'ColumnContext')
            ttMan.dispatchUIRequest('addClearDecisionTestedBreakPoint',{},false);
        elseif strcmp(typeChain{2},'CellContext')
            ttMan.dispatchUIRequest('addClearConditionTableCellBreakPoint',{},false);
        else
            return;
        end
    elseif strcmp(typeChain{1},'ActionTable')
        if strcmp(typeChain{2},'RowContext')
            ttMan.dispatchUIRequest('addClearActionExecutedBreakPoint',{},false);
        elseif strcmp(typeChain{2},'CellContext')
            ttMan.dispatchUIRequest('addClearActionTableCellBreakPoint',{},false);
        else
            return;
        end
    end
    Stateflow.TruthTable.Utils.refreshTypeChain(ttMan);
end
