



function ttAddClearBreakpointRF(cbinfo,action)
    import Stateflow.TruthTable.TruthTableManager
    action.enabled=false;
    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        return;
    end

    ttMan=TruthTableManager.getInstance(ttObjectId);
    typeChain=ttMan.TruthTableSelectionInfo.TypeChain;

    if any(strcmp(cbinfo.Context.TypeChain,'TruthTableEditorAutoChartContext'))
        action.enabled=false;
        return;
    end

    if size(typeChain,2)<2
        return;
    end
    rowIndex=convertUIRowIndexToMLRowIndex(ttMan.TruthTableSelectionInfo.RowIndex(1));
    colIndex=ttMan.TruthTableSelectionInfo.ColumnIndex(1)-ttMan.CONDITION_OR_ACTION_COLUMN_INDEX;
    breakpointEnabled=false;
    if strcmp(typeChain{1},'ConditionTable')
        if strcmp(typeChain{2},'RowContext')&&rowIndex>0&&rowIndex<=length(ttMan.TruthTableBreakPointInfo.ConditionBreakPointStatus)
            action.enabled=true;
            breakpointEnabled=ttMan.TruthTableBreakPointInfo.ConditionBreakPointStatus(rowIndex).regValue;
        elseif strcmp(typeChain{2},'ColumnContext')&&colIndex>0&&colIndex<=length(ttMan.TruthTableBreakPointInfo.DecisionTestedBreakPointStatus)
            cellInfo.type=2;
            cellInfo.index=colIndex;
            isDefaultDecision=TruthTableManager.checkDefaultDecisionMATLABCodeTT(ttMan.TruthTableObjectId,cellInfo);
            if~isDefaultDecision
                action.enabled=true;
                breakpointEnabled=ttMan.TruthTableBreakPointInfo.DecisionTestedBreakPointStatus(colIndex).regValue;
            else
                return;
            end
        elseif strcmp(typeChain{2},'CellContext')
            if ttMan.TruthTableSelectionInfo.ColumnIndex(1)==2&&rowIndex>0&&rowIndex<=length(ttMan.TruthTableBreakPointInfo.ConditionBreakPointStatus)
                action.enabled=true;
                breakpointEnabled=ttMan.TruthTableBreakPointInfo.ConditionBreakPointStatus(rowIndex).regValue;
            elseif rowIndex==size(ttMan.ConditionTable,1)&&colIndex>0&&colIndex<=length(ttMan.TruthTableBreakPointInfo.DecisionValidBreakPointStatus)
                action.enabled=true;
                breakpointEnabled=ttMan.TruthTableBreakPointInfo.DecisionValidBreakPointStatus(colIndex).regValue;
            end
        else
            return;
        end
    elseif strcmp(typeChain{1},'ActionTable')
        if(strcmp(typeChain{2},'RowContext')||(strcmp(typeChain{2},'CellContext')&&...
            ttMan.TruthTableSelectionInfo.ColumnIndex(1)==2))&&rowIndex>0&&...
            rowIndex<=length(ttMan.TruthTableBreakPointInfo.ActionBreakPointStatus)
            action.enabled=true;
            breakpointEnabled=ttMan.TruthTableBreakPointInfo.ActionBreakPointStatus(rowIndex).regValue;
        else
            return;
        end
    end
    if breakpointEnabled
        action.text=message('stateflow_ui:studio:resources:clearBreakpoint').getString();
        action.icon='clearBreakpoint';
    end
end

function mlRowIndex=convertUIRowIndexToMLRowIndex(uiRowIndex)
    mlRowIndex=uiRowIndex+1;
end
