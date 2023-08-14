function[children,breakpointIdx]=getModelBreakpointRows(globalBreakpoints,studio,children,breakpointIdx)









    mdl=get_param(studio.App.blockDiagramHandle,'Name');

    modelBreakpointsMap=globalBreakpoints.modelBreakpoints;
    for key=modelBreakpointsMap.keys
        bp=modelBreakpointsMap{key{1}};
        if~bdIsLoaded(bp.modelName)||~strcmp(mdl,bp.modelName)


            continue;
        end

        modelbp=SimulinkDebugger.breakpoints.ModelBreakpoint(...
        breakpointIdx,bp);
        childObj=SimulinkDebugger.breakpoints.BreakpointListSpreadsheetModelRow(modelbp);
        children=[children,childObj];%#ok<AGROW>
        breakpointIdx=breakpointIdx+1;
    end
end
