function breakpoints=getEditorViewBreakpoints(filename)
    breakpoints=[];
    breakpointStore=matlab.internal.debugger.breakpoints.EditorViewBreakpointStore.getInstance();
    if breakpointStore.hasBreakpointData(filename)
        data=breakpointStore.getFileBreakpointData(filename);
        breakpoints=data.breakpoints;
    end
end