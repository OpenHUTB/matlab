function highlightBlock(blkHandle,blkPath)




    if~isempty(blkPath)
        bp=Simulink.BlockPath(blkPath);
        bp.open('OpenType','NEW_TAB');
    else
        open_system(get_param(blkHandle,'Parent'),'force');
    end

    styler=SimulinkDebugger.getSlDebugBlockStyler();
    styler.applyClass(blkHandle,'slDebugGreenGlow');
end
