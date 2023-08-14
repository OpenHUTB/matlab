function modelBreakpointCB(cbinfo,breakpointType)




    model=cbinfo.editorModel;
    if isempty(model)||...
        ~isa(breakpointType,'slbreakpoints.datamodel.ModelBreakpointType')
        return;
    end

    editor=SLM3I.SLDomain.findLastActiveEditor();
    studio=editor.getStudio();
    topModel=get_param(studio.App.topLevelDiagram.handle,'Name');

    bpListInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
    isEnabled=true;
    bpListInstance.addModelBreakpoint(topModel,breakpointType,isEnabled);
end

