function ttDisableAllBreakPointCB(cbinfo)




    import Stateflow.TruthTable.TruthTableManager

    [isTT,ttObjectId]=is_Truth_Table(cbinfo);
    if~isTT
        return;
    end
    ttMan=TruthTableManager.getInstance(ttObjectId);
    ttMan.configBreakPoints('disableAllBreakPoints');

end
