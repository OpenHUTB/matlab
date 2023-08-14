function schema=menuFluids(fcnName,cbInfo)




    schema=feval(['l',fcnName],cbInfo);

end

function schema=lFluids(cbInfo)
    schema=sl_container_schema;
    schema.label='&Fluids';
    schema.tag='fluids:Fluids';
    schema.state='Hidden';
    schema.autoDisableWhen='Busy';
    selection=cbInfo.getSelection;
    if(numel(selection)==1)&&...
        strcmpi(selection.Type,'block')&&...
        strcmpi(selection.BlockType,'SimscapeBlock')
        componentPath=selection.ComponentPath;
        if fluids.internal.mask.isComponentPlotILPropertiesSupported(componentPath)||...
            fluids.internal.mask.isComponentPlotTLPropertiesSupported(componentPath)||...
            fluids.internal.mask.isComponentPlot2PPropertiesSupported(componentPath)||...
            fluids.internal.mask.isComponentValveCharacteristicsSupported(componentPath)||...
            fluids.internal.mask.isComponentValveCharacteristicsMWayNPosSupported(componentPath)||...
            fluids.internal.mask.isComponentCompressorMapSupported(componentPath)||...
            fluids.internal.mask.isComponentTurbineMapSupported(componentPath)||...
            fluids.internal.mask.isComponentPlotFanCharacteristicsSupported(componentPath)||...
            fluids.internal.mask.isComponentPlotCentrifugalPumpCharacteristicsSupported(componentPath)||...
            fluids.internal.mask.isComponentPosDispCompressorCharacteristicsSupported(componentPath)||...
            fluids.internal.mask.isComponentPlotTXVQuadrantDiagramSupported(componentPath)
            schema.state='Enabled';
        end
        im=DAStudio.InterfaceManagerHelper(cbInfo.studio,'Simulink');
        children={
        im.getAction('fluids:PlotILProperties1D')
        im.getAction('fluids:PlotTLProperties')
        im.getAction('fluids:Plot2PProperties3D')
        im.getAction('fluids:Plot2PPropertiesContours')
        im.getAction('fluids:PlotValveCharacteristics')
        im.getAction('fluids:PlotValveCharacteristicsMWayNPos')
        im.getAction('fluids:PlotCompressorMap')
        im.getAction('fluids:PlotTurbineMap')
        im.getAction('fluids:PlotFanCharacteristics')
        im.getAction('fluids:PlotCentrifugalPumpCharacteristics')
        im.getAction('fluids:PlotPosDispCompressorCharacteristics')
        im.getAction('fluids:PlotTXVQuadrantDiagram')};
        schema.childrenFcns=children;
    end
end

function schema=lPlotILProperties1D(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotILProperties1D(cbInfo);
end

function schema=lPlotTLProperties(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotTLProperties(cbInfo);
end

function schema=lPlot2PProperties3D(cbInfo)
    schema=fluids.internal.contextmenu.menuPlot2PProperties3D(cbInfo);
end

function schema=lPlot2PPropertiesContours(cbInfo)
    schema=fluids.internal.contextmenu.menuPlot2PPropertiesContours(cbInfo);
end

function schema=lPlotValveCharacteristics(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotValveCharacteristics(cbInfo);
end

function schema=lPlotValveCharacteristicsMWayNPos(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotValveCharacteristicsMWayNPos(cbInfo);
end


function schema=lPlotCompressorMap(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotCompressorMap(cbInfo);
end

function schema=lPlotTurbineMap(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotTurbineMap(cbInfo);
end

function schema=lPlotFanCharacteristics(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotFanCharacteristics(cbInfo);
end

function schema=lPlotCentrifugalPumpCharacteristics(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotCentrifugalPumpCharacteristics(cbInfo);
end

function schema=lPlotPosDispCompressorCharacteristics(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotPosDispCompressorCharacteristics(cbInfo);
end

function schema=lPlotTXVQuadrantDiagram(cbInfo)
    schema=fluids.internal.contextmenu.menuPlotTXVQuadrantDiagram(cbInfo);
end