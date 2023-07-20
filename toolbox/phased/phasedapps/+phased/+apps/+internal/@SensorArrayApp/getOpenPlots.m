function[isArrayGeoFig,is3DPatternFig,isAzPatternFig,...
    isElPatternFig,isUPatternFig,isGLDiagFig]=getOpenPlots(obj)






    import matlab.ui.container.internal.appcontainer.*;
    if strcmp(obj.Container,'ToolGroup')

        figClients=getFiguresDropTargetHandler(obj.ToolGroup);
        plotTag=cell(1,numel(figClients.CloseListeners));
        for i=1:numel(figClients.CloseListeners)

            plotTag{i}=figClients.CloseListeners(i).Source{1}.Tag;
        end

        isArrayGeoFig=any(strcmp('arrayGeoFig',plotTag));
        is3DPatternFig=any(strcmp('pattern3DFig',plotTag));
        isAzPatternFig=any(strcmp('azPatternFig',plotTag));
        isElPatternFig=any(strcmp('elPatternFig',plotTag));
        isUPatternFig=any(strcmp('uPatternFig',plotTag));
        isGLDiagFig=any(strcmp('gratingLobeFig',plotTag));
    else
        isArrayGeoFig=has(obj.ToolGroup,"DOCUMENT","arraytab_group","arraytab");
        is3DPatternFig=has(obj.ToolGroup,"DOCUMENT","3dpattab_group","3dpattab");
        isAzPatternFig=has(obj.ToolGroup,"DOCUMENT","2DAzpattab_group","2DAzpattab");
        isElPatternFig=has(obj.ToolGroup,"DOCUMENT","2DElpattab_group","2DElpattab");
        isUPatternFig=has(obj.ToolGroup,"DOCUMENT","2DUcuttab_group","2DUcuttab");
        isGLDiagFig=has(obj.ToolGroup,"DOCUMENT","LobeDiagTab_group","LobeDiagTab");
    end