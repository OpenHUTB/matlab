

function hdlSaveFixedPointGuiState(logState)


    assert(isa(logState,'com.mathworks.toolbox.coder.fixedpoint.FixedPointRestorationHelper$FpStateSaveContext'));
    coder.internal.F2FGuiCallbackManager.getInstance.updateCachePathParam();
    coder.internal.F2FGuiCallbackManager.saveWithLogs(logState);
end