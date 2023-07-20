function closeSession()



    import stm.internal.SlicerDebuggingStatus
    stmDebugger=stm.internal.StmDebugger.getInstance;

    if~isempty(stmDebugger)&&isvalid(stmDebugger)
        stmDebugger.delete;
        stm.internal.setSlicerDebugStatus(int32(SlicerDebuggingStatus.DebugInactive));
    end

end
