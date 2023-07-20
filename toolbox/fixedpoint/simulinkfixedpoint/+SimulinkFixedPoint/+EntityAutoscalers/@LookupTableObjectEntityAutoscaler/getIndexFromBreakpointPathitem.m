function index=getIndexFromBreakpointPathitem(breakpointPathItem)



    index=str2double(regexprep(breakpointPathItem,'Breakpoint',''));
end