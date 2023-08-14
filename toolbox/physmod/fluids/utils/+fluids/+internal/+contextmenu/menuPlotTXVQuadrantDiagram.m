function schema=menuPlotTXVQuadrantDiagram(cbInfo)




    schema=sl_action_schema;
    schema.label='Plot 4-Quadrant Diagram';
    schema.tag='fluids:PlotTXVQuadrantDiagram';
    schema.state='Hidden';
    schema.callback=@lPlotTXVQuadrantDiagram;
    schema.autoDisableWhen='Busy';
    componentPath=cbInfo.getSelection.ComponentPath;
    if fluids.internal.mask.isComponentPlotTXVQuadrantDiagramSupported(componentPath)
        if isInLockedLibrary(cbInfo.getSelection.Handle)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end
    end
end

function lPlotTXVQuadrantDiagram(cbInfo)
    fluids.internal.mask.plotTXVQuadrantDiagram(cbInfo.getSelection.Handle)
end