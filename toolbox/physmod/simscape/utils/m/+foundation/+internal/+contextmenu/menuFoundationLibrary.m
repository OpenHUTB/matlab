function schema=menuFoundationLibrary(fcnName,cbInfo)




    schema=feval(['l',fcnName],cbInfo);
end

function schema=lFoundationLibrary(cbInfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.label='&Foundation Library';
    schema.tag='simscape:FoundationLibrary';
    schema.state='Hidden';
    schema.autoDisableWhen='Busy';
    selection=cbInfo.getSelection;
    if(numel(selection)==1)&&...
        strcmpi(selection.Type,'block')&&...
        strcmpi(selection.BlockType,'SimscapeBlock')
        componentPath=cbInfo.getSelection.ComponentPath;
        if foundation.internal.mask.isComponentPlotLookupTable1DSupported(componentPath)||...
            foundation.internal.mask.isComponentPlotLookupTable2DSupported(componentPath)||...
            foundation.internal.mask.isComponentPlotTLPropertiesSupported(componentPath)||...
            foundation.internal.mask.isComponentPlotGasPropertiesSupported(componentPath)||...
            foundation.internal.mask.isComponentPlot2PPropertiesSupported(componentPath)||...
            foundation.internal.mask.isComponentPlotILPropertiesSupported(componentPath)
            schema.state='Enabled';
        end
        im=DAStudio.InterfaceManagerHelper(cbInfo.studio,'Simulink');
        children={
        im.getAction('simscape:PlotLookupTable1D')
        im.getAction('simscape:PlotLookupTable2D')
        im.getAction('simscape:PlotTLProperties')
        im.getAction('simscape:PlotGasProperties')
        im.getAction('simscape:Plot2PProperties3D')
        im.getAction('simscape:Plot2PPropertiesContours')
        im.getAction('simscape:PlotILProperties')};
        schema.childrenFcns=children;
    end
end

function schema=lPlotLookupTable1D(cbInfo)%#ok<DEFNU>
    schema=foundation.internal.contextmenu.menuPlotLookupTable1D(cbInfo);
end

function schema=lPlotLookupTable2D(cbInfo)%#ok<DEFNU>
    schema=foundation.internal.contextmenu.menuPlotLookupTable2D(cbInfo);
end

function schema=lPlotTLProperties(cbInfo)%#ok<DEFNU>
    schema=foundation.internal.contextmenu.menuPlotTLProperties(cbInfo);
end

function schema=lPlotGasProperties(cbInfo)%#ok<DEFNU>
    schema=foundation.internal.contextmenu.menuPlotGasProperties(cbInfo);
end

function schema=lPlot2PProperties3D(cbInfo)%#ok<DEFNU>
    schema=foundation.internal.contextmenu.menuPlot2PProperties3D(cbInfo);
end

function schema=lPlot2PPropertiesContours(cbInfo)%#ok<DEFNU>
    schema=foundation.internal.contextmenu.menuPlot2PPropertiesContours(cbInfo);
end

function schema=lPlotILProperties(cbInfo)%#ok<DEFNU>
    schema=foundation.internal.contextmenu.menuPlotILProperties(cbInfo);
end


