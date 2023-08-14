



function ttClearAllBreakPointRF(cbinfo,action)
    import Stateflow.TruthTable.TruthTableManager

    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        return;
    end
    ttMan=TruthTableManager.getInstance(ttObjectId);
    shouldEnable=checkClearAllBreakPointsEnabled(ttMan);
    action.enabled=shouldEnable;

    if any(strcmp(cbinfo.Context.TypeChain,'TruthTableEditorAutoChartContext'))
        action.enabled=false;
        return;
    end
end

function shouldEnable=checkClearAllBreakPointsEnabled(ttMan)
    shouldEnable=false;
    for status=ttMan.TruthTableBreakPointInfo.ConditionBreakPointStatus
        if status.regValue
            shouldEnable=true;
            return;
        end
    end
    for status=ttMan.TruthTableBreakPointInfo.ActionBreakPointStatus
        if status.regValue
            shouldEnable=true;
            return;
        end
    end
    for status=ttMan.TruthTableBreakPointInfo.DecisionTestedBreakPointStatus
        if status.regValue
            shouldEnable=true;
            return;
        end
    end
    for status=ttMan.TruthTableBreakPointInfo.DecisionValidBreakPointStatus
        if status.regValue
            shouldEnable=true;
            return;
        end
    end
end
