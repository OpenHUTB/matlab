function str=toScopeSpecificationString(blk)








    import dsp.webscopes.style.*;
    dispParamsStr=displayParamsToSpecString(blk);
    scopeParamsStr=scopeParamsToSpecString(blk);
    scalingParamsStr=scalingParamsToSpecString(blk);
    measParamsStr=measurementsParamsToSpecString(blk);

    graphicalSettingsStruct=getGraphicalSettingsStruct(blk);
    figureColor=[0.16,0.16,0.16];
    if isfield(graphicalSettingsStruct,'Style')
        styleSettingsStruct=graphicalSettingsStruct.Style;
        if~isempty(styleSettingsStruct)

            if isfield(styleSettingsStruct,'BackgroundColor')
                figureColor=styleSettingsStruct.BackgroundColor.';
            end
        end
    end
    openAtMdlStart='false';
    if utils.onOffToLogical(get_param(blk,'OpenAtSimulationStart'))
        openAtMdlStart='true';
    end

    position=get_param(blk,'WindowPosition');
    if isempty(position)
        position='[]';
    end
    str=...
    ['dsp.scopes.ArrayPlotBlockSpecification(''CurrentConfiguration'', extmgr.ConfigurationSet('...
    ,'extmgr.Configuration(''Core'',''General UI'',true,''FigureColor'',[',num2str(figureColor),']),'...
    ,'extmgr.Configuration(''Visuals'',''Array Plot'',true,'...
    ,'''SerializedDisplays'',',dispParamsStr,','...
...
    ,scopeParamsStr,'),'...
...
    ,scalingParamsStr,','...
...
    ,measParamsStr,'),'...
    ,'''Position'',',position,','...
    ,'''VisibleAtModelOpen'',''',get_param(blk,'Visible'),''','...
    ,'''OpenAtMdlStart'',',openAtMdlStart,')'];
end

function dispParamsStr=displayParamsToSpecString(blk)

    yLim=str2num(get_param(blk,'YLimits'));%#ok<ST2NM> 

    showGrid='false';
    if utils.onOffToLogical(get_param(blk,'ShowGrid'))
        showGrid='true';
    end

    plotMagPhase='false';
    if utils.onOffToLogical(get_param(blk,'PlotAsMagnitudePhase'))
        plotMagPhase='true';
    end
    styleParamsStr=styleParamsToSpecString(blk);
    dispParamsStr=['{struct('...
...
    ,'''XLabel'',''',get_param(blk,'XLabel'),''','...
    ,'''Title'',''',get_param(blk,'Title'),''','...
    ,'''YLabelReal'',''',get_param(blk,'YLabel'),''','...
    ,'''MinYLimReal'',''',num2str(yLim(1)),''','...
    ,'''MaxYLimReal'',''',num2str(yLim(2)),''','...
...
...
    ,'''XGrid'', ',showGrid,','...
    ,'''YGrid'', ',showGrid,','...
    ,'''LegendVisibility'',''',get_param(blk,'ShowLegend'),''','...
    ,'''PlotMagPhase'',',plotMagPhase,','...
...
    ,styleParamsStr...
    ,'''ShowContent'',true,'...
    ,'''Placement'',1)}'];
end

function scopeParamsStr=scopeParamsToSpecString(blk)

    channelNames=strrep(get_param(blk,'ChannelNames'),'''','"');

    channelNames=jsondecode(channelNames).';
    if isempty(channelNames)

        channelNames={''};
    end
    channelNamesStr=[];
    for idx=1:numel(channelNames)
        delim=''',''';
        if(idx==numel(channelNames))
            delim=[];
        end
        channelNamesStr=[channelNamesStr,'',channelNames{idx},'',delim];%#ok<AGROW>
    end
    channelNamesStr=['{''',channelNamesStr,'''}'];

    scopeParamsStr=[
    '''PlotType'',''',get_param(blk,'PlotType'),''','...
    ,'''DefaultMarker'',''none'','...
    ,'''XDataMode'',''',get_param(blk,'XDataMode'),''','...
    ,'''CustomXData'',''',get_param(blk,'CustomXData'),''','...
    ,'''XOffset'',''',get_param(blk,'XOffset'),''','...
    ,'''SampleIncrement'',''',get_param(blk,'SampleIncrement'),''','...
    ,'''XScale'',''',get_param(blk,'XScale'),''','...
    ,'''YScale'',''',get_param(blk,'YScale'),''','...
    ,'''UserDefinedChannelNames'',',channelNamesStr,','...
    ,'''MaximizeAxes'',''',get_param(blk,'MaximizeAxes'),''''
    ];
end

function scalingParamsStr=scalingParamsToSpecString(blk)

    onceAtStop='false';
    axesScaling=get_param(blk,'AxesScaling');
    if strcmpi(axesScaling,'OnceAtStop')
        onceAtStop='true';
    end

    scalingParamsStr=[
'extmgr.Configuration(''Tools'',''Plot Navigation'',true,'...
    ,'''OnceAtStop'',',onceAtStop,','...
    ,'''AutoscaleMode'',''',axesScaling,''','...
    ,'''UpdatesBeforeAutoscale'',''',get_param(blk,'AxesScalingNumUpdates'),''')'
    ];
end

function measParamsStr=measurementsParamsToSpecString(blk)
    graphicalSettingsStruct=getGraphicalSettingsStruct(blk);
    measParamsStr=[
'extmgr.Configuration(''Tools'',''Measurements'',true,'...
    ,'''Measurements'',struct(''traceselector'',struct(''Line'','...
    ,num2str(get_param(blk,'MeasurementChannel')),')'];

    if~isempty(graphicalSettingsStruct)
        delim=',';

        if isfield(graphicalSettingsStruct,'Cursors')
            cursors=graphicalSettingsStruct.Cursors;

            lockSpacing='false';
            if(cursors.LockSpacing)
                lockSpacing='true';
            end

            snapToData='false';
            if(cursors.SnapToData)
                snapToData='true';
            end
            measParamsStr=[measParamsStr,delim,...
            '''tcursors'',struct(''XCoordinates'',[',num2str(cursors.XLocation.'),'],'...
            ,'''LockCursorSpacing'',',lockSpacing,','...
            ,'''SnapToData'',',snapToData,')'];
        end

        if isfield(graphicalSettingsStruct,'Stats')
            measParamsStr=[measParamsStr,delim...
            ,'''signalstats'',[]'];
            delim=',';
        end

        if isfield(graphicalSettingsStruct,'Peaks')
            peaks=graphicalSettingsStruct.Peaks;
            measParamsStr=[measParamsStr,delim...
            ,'''peaks'',struct(''Threshold'',',num2str(peaks.Threshold),','...
            ,'''NumPeaks'',',num2str(peaks.NumPeaks),','...
            ,'''MinPeakDistance'',',num2str(peaks.MinDistance),','...
            ,'''MinPeakHeight'',',num2str(peaks.MinHeight),')'];
        end
    end
    measParamsStr=[measParamsStr,'))'];
end

function styleParamsStr=styleParamsToSpecString(blk)
    graphicalSettingsStruct=getGraphicalSettingsStruct(blk);
    styleParamsStr=[];
    if isfield(graphicalSettingsStruct,'Style')
        styleSettingsStruct=graphicalSettingsStruct.Style;
        if~isempty(styleSettingsStruct)

            numLines=1;
            if isfield(styleSettingsStruct,'LineStyle')
                numLines=numel(styleSettingsStruct.LineStyle);
            end

            axesColor=styleSettingsStruct.AxesColor.';

            axesTickColor=styleSettingsStruct.LabelsColor.';
            styleParamsStr=[styleParamsStr,...
            '''AxesColor'',[',num2str(axesColor),'],'...
            ,'''AxesTickColor'',[',num2str(axesTickColor),'],'...
            ,'''NumLines'',',num2str(numLines),','];

            lineParamsStr=[];
            delim=[];
            colorOrder=utils.getColorOrder([0,0,0]);
            for lIdx=1:numLines

                color=colorOrder(lIdx,:);
                if isfield(styleSettingsStruct,'LineColor')
                    color=styleSettingsStruct.LineColor(lIdx,:);
                end

                style='-';
                if isfield(styleSettingsStruct,'LineStyle')
                    style=styleSettingsStruct.LineStyle{lIdx};
                end

                width=1.5;
                if isfield(styleSettingsStruct,'LineWidth')
                    width=styleSettingsStruct.LineWidth(lIdx);
                end

                marker='o';
                if isfield(styleSettingsStruct,'Marker')
                    marker=styleSettingsStruct.Marker{lIdx};
                end
                lineParamsStr=[lineParamsStr,delim...
                ,'struct(''Color'',[',num2str(color),'],'...
                ,'''LineStyle'',''',style,''','...
                ,'''LineWidth'',',num2str(width),','...
                ,'''Marker'',''',marker,''')'...
                ];%#ok<AGROW>
                delim=',';
            end
            styleParamsStr=[styleParamsStr...
            ,'''LinePropertiesCache'',{{',lineParamsStr,'}},'];
        end
    end
end

function settings=getGraphicalSettingsStruct(blk)


    graphicalSettings=get_param(blk,'GraphicalSettings');

    if isempty(graphicalSettings)
        settings=struct([]);
    else
        graphicalSettings=strrep(graphicalSettings,'''','"');
        settings=jsondecode(graphicalSettings);
    end
end
