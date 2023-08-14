function resetBlockBpHitCount(model)




    modelHandle=get_param(model,'Handle');
    editor=GLUE2.Util.findAllEditors(get_param(modelHandle,'Name'));
    studio=editor.getStudio();
    comp=studio.getComponent('GLUE2:SpreadSheet',SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.name_);
    if~isempty(comp)
        src=comp.getSource();
        src.resetHitCount();
        src.refreshBpUI()
    end
end
