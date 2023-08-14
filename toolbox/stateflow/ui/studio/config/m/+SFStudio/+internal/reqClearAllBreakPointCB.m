function reqClearAllBreakPointCB(cbinfo)




    import Stateflow.TruthTable.TruthTableManager

    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        return;
    end
    ttMan=TruthTableManager.getInstance(ttObjectId);
    ttMan.configBreakPoints('clearAllBreakPoints');


    Stateflow.TruthTable.Utils.refreshTypeChain(ttMan);
end

