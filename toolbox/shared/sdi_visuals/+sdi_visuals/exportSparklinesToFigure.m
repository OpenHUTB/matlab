
function exportSparklinesToFigure(hFig,clientId,rowIdx,colIdx,appInfo)
    sdiEngine=Simulink.sdi.Instance.engine;

    pluginMedatData=sdi_visuals.getPluginMetadata(clientId,rowIdx,colIdx);
    if~isempty(pluginMedatData)
        axesIDs=arrayfun(@(tyData)tyData.axesID,pluginMedatData.timePlotData);
        totalTYs=length(axesIDs);

        yMins=arrayfun(@(tyData)tyData.yMin,pluginMedatData.timePlotData);
        yMaxs=arrayfun(@(tyData)tyData.yMax,pluginMedatData.timePlotData);

        xMins=arrayfun(@(tyData)tyData.xMin,pluginMedatData.timePlotData);
        xMaxs=arrayfun(@(tyData)tyData.xMax,pluginMedatData.timePlotData);

        if~isempty(appInfo)&&~isempty(appInfo.recordBlk)
            prefStruct=getRecordBlkSparklinesPref(appInfo.recordBlk);
        else
            subplotID=8*(colIdx-1)+rowIdx;
            appID=sdi_visuals.getAppInstID(clientId);
            settings=sdi_visuals.getVisualizationPreferences(appID,subplotID);

            prefStruct=struct();
            prefStruct.Markers=settings.style.markers;

            prefStruct.legendPref.legendPositionRunsView='insideTop';
            prefStruct.ticksPosition=settings.style.ticks;
            prefStruct.tickLabelsDisplayed=settings.style.tickLabel;
            prefStruct.GridDisplay=settings.style.grid;
        end


        left=hFig.CurrentAxes.Position(1);
        bottom=hFig.CurrentAxes.Position(2);
        width=hFig.CurrentAxes.Position(3);
        height=hFig.CurrentAxes.Position(4)/(totalTYs);

        for tyIndex=1:totalTYs
            tyAxes=axes(hFig,'position',[left,bottom,width,height]);
            hFig.CurrentAxes=tyAxes;
            currentTYAxesID=axesIDs(totalTYs-tyIndex+1);
            currentYMin=yMins(totalTYs-tyIndex+1);
            currentYMax=yMaxs(totalTYs-tyIndex+1);

            currentXMin=xMins(totalTYs-tyIndex+1);
            currentXMax=xMaxs(totalTYs-tyIndex+1);


            sdiEngine.exportTimePlotToFigure(clientId,currentTYAxesID,hFig,prefStruct);
            if tyIndex==1
                hFig.CurrentAxes.XLim=[currentXMin,currentXMax];
                tyAxes.NextPlot='add';
            end

            hFig.Children(2).Position(4)=height;
            hFig.Children(2).YLim=[currentYMin,currentYMax];

            bottom=hFig.Children(2).Position(2)+hFig.Children(2).Position(4);


            tyAxes.YAxis.Exponent=0;

            if tyIndex~=1
                hFig.CurrentAxes.XTickLabel={};
                hFig.CurrentAxes.XLabel.String='';
            end
        end
    end
end


function prefStruct=getRecordBlkSparklinesPref(recordBlk)
    recordPref=get_param(recordBlk,'PlotPreferences');
    showMarkers=false;
    if strcmp(recordPref.Sparklines.Markers,'Show')
        showMarkers=true;
    end
    prefStruct.Markers=showMarkers;

    legendPref.legendPositionRunsView='None';
    if strcmp(recordPref.Sparklines.LegendPosition,'TopLeft')
        legendPref.legendPositionRunsView='top';
    elseif strcmp(recordPref.Sparklines.LegendPosition,'OutsideRight')
        legendPref.legendPositionRunsView='right';
    elseif strcmp(recordPref.Sparklines.LegendPosition,'InsideLeft')
        legendPref.legendPositionRunsView='insideTop';
    elseif strcmp(recordPref.Sparklines.LegendPosition,'InsideRight')
        legendPref.legendPositionRunsView='insideRight';
    end

    prefStruct.legendPref=legendPref;

    prefStruct.ticksPosition=recordPref.Sparklines.TicksPosition;
    prefStruct.tickLabelsDisplayed='All';
    if strcmp(recordPref.Sparklines.TickLabels,'Timeaxis')
        prefStruct.tickLabelsDisplayed='t-Axis';
    elseif strcmp(recordPref.Sparklines.TickLabels,'YAxis')
        prefStruct.tickLabelsDisplayed='y-Axis';
    elseif strcmp(recordPref.Sparklines.TickLabels,'None')
        prefStruct.tickLabelsDisplayed='None';
    end

    prefStruct.GridDisplay=recordPref.Sparklines.GridLines;
end