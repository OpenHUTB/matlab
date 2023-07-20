function incrementBlockBpHitCount(model,blkHandle)




    modelHandle=get_param(model,'Handle');
    editor=GLUE2.Util.findAllEditors(get_param(modelHandle,'Name'));
    studio=editor.getStudio();
    comp=studio.getComponent('GLUE2:SpreadSheet',SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.name_);
    if~isempty(comp)
        src=comp.getSource();
        mdlParent=get_param(blkHandle,'Parent');
        blockPath=[mdlParent,'/',get_param(blkHandle,'Name')];
        BPID=SimulinkDebugger.breakpoints.GlobalBreakpointsList.createBlockBPID(mdlParent,blockPath);
        src.incrementHitCount(BPID);
        src.refreshBpUI()
    end
end
