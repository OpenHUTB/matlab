function highlightBlock(model,block)




    blockPath=[model,'/',block];
    if getSimulinkBlockHandle(blockPath)~=-1
        appMgr=multicoredesigner.internal.UIManager.getInstance();
        ui=appMgr.getMulticoreUI(get_param(model,'Handle'));
        removeAllHighlighting(ui);
        set_param(model,'HiliteAncestors','off');
        bp=Simulink.BlockPath(blockPath);
        hilite_system(bp);
        set_param(blockPath,'Selected','on');
    end
end
