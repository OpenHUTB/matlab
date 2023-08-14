function updateOpenPlots(obj)





    import matlab.ui.container.internal.appcontainer.*;


    [isArrayGeoFig,is3DPatternFig,isAzPatternFig,...
    isElPatternFig,isUPatternFig,isGLDiagFig]=getOpenPlots(obj);


    if~strcmp(obj.Container,'ToolGroup')
        if isfield(obj.ToolGroup.Layout.documentLayout,'lastSelectedDocumentId')
            lastDocumentSelected=struct('tag',obj.ToolGroup.Layout.documentLayout.lastSelectedDocumentId);
        else
            lastDocumentSelected=obj.ToolGroup.LastSelectedDocument;
        end
    end


    if isArrayGeoFig
        if~isempty(obj.ArrayGeometryFig)
            notify(obj.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'arrayGeoFig'));
        end
    end

    if is3DPatternFig
        if~isempty(obj.Pattern3DFig)
            notify(obj.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'pattern3DFig'));
        end
    end

    if isAzPatternFig
        if~isempty(obj.AzPatternFig)
            notify(obj.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'azPatternFig'));
        end
    end

    if isElPatternFig
        if~isempty(obj.ElPatternFig)
            notify(obj.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'elPatternFig'));
        end
    end

    if isUPatternFig
        if~isempty(obj.UPatternFig)
            notify(obj.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'uPatternFig'));
        end
    end

    if isGLDiagFig
        if~isempty(obj.GratingLobeFig)
            notify(obj.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'gratingLobeFig'));
        end
    end

    if~strcmp(obj.Container,'ToolGroup')
        if~isempty(lastDocumentSelected)
            obj.ToolGroup.SelectedChild=lastDocumentSelected;
        end
    end
end


