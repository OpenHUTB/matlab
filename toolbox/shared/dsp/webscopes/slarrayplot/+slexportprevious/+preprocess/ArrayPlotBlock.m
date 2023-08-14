function ArrayPlotBlock(obj)





    if isR2021bOrEarlier(obj.ver)


        obj.appendRule('<Block<BlockType|ArrayPlot><ScopeFrameLocation:remove>>');

        obj.appendRule('<Block<BlockType|ArrayPlot><WasSavedAsWebScope:remove>>');
    end

    if isR2020bOrEarlier(obj.ver)


        obj.appendRule('<Block<BlockType|ArrayPlot><XDataMode:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><SampleIncrement:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><XOffset:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><CustomXData:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><XScale:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><YScale:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><PlotType:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><AxesScaling:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><AxesScalingNumUpdates:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><MaximizeAxes:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><PlotAsMagnitudePhase:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><YLimits:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><XLabel:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><YLabel:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><Title:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><ShowGrid:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><ShowLegend:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><ChannelNames:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><ExpandToolstrip:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><MeasurementChannel:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><GraphicalSettings:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><WindowPosition:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><OpenAtSimulationStart:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><FrameBasedProcessing:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><Visible:remove>>');
        obj.appendRule('<Block<BlockType|ArrayPlot><IsFloating:remove>>');


        apBlks=find_scopes(obj);
        for idx=1:numel(apBlks)

            mapScopeParameters(obj,apBlks{idx},obj.modelName);
        end
    end
end

function apBlks=find_scopes(obj)

    apBlks=obj.findBlocksOfType('ArrayPlot');
    apBlks_viewers=obj.findBlocksOfType('ArrayPlot','IOType','viewer');
    apBlks=[apBlks;apBlks_viewers];
end

function mapScopeParameters(~,apBlk,~)

    set_param(apBlk,'ScopeSpecificationString',Simulink.scopes.ArrayPlotUtils.toScopeSpecificationString(apBlk));

    set_param(apBlk,'DefaultConfigurationName','dsp.scopes.ArrayPlotBlockSpecification');
end
