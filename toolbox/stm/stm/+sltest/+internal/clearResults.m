function clearResults(clearPartialResults)



    import stm.internal.SlicerDebuggingStatus;

    if stm.internal.slicerDebugStatus~=SlicerDebuggingStatus.DebugInactive
        error(message('stm:general:OperationProhibitedWhileDebugging','sltest.testmanager.clearResults'));
    end
    stm.internal.deleteAllResults(clearPartialResults);
end

