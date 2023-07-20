function conditionalPauseListCB(cbinfo)




    model=cbinfo.editorModel;
    if isempty(model),return;end

    if~strcmp(get_param(cbinfo.model.handle,'BlockDiagramType'),'model'),return;end

    if slfeature('slBreakpointList')>0
        editor=SLM3I.SLDomain.findLastActiveEditor();
        studio=editor.getStudio();

        instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
        ssComp=SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.createSpreadSheetComponent(studio,instance);
        SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.moveComponentToDock(ssComp,studio);
    else
        SLStudio.ShowBlockDiagramConditionalPauseList(model.handle,0);
    end
end
