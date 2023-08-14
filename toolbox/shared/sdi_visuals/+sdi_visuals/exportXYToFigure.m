

function exportXYToFigure(hFig,clientID,rowIdx,colIdx,appInfo)
    sdiEngine=Simulink.sdi.Instance.engine;

    subplotID=8*(colIdx-1)+rowIdx;
    appInstanceID=0;
    if~isempty(appInfo)&&~isempty(appInfo.recordBlk)
        appInstanceID=get_param(appInfo.recordBlk,'AppInstanceID');
    end
    boundSignals=sdi_visuals.getBoundSignalIDs(appInstanceID,subplotID);


    plotFunctionHandle=@(boundData)plotOnSubplot(sdiEngine,hFig,subplotID,boundData,appInfo);

    cellfun(plotFunctionHandle,boundSignals);


    if~isempty(boundSignals)
        hLegend=legend(hFig.CurrentAxes,'show');
        hLegend.Interpreter='none';
        hLegend.Visible='on';
        hLegend.Location='northoutside';
    end
end


function plotOnSubplot(sdiEngine,hFig,subplotID,boundSignals,appInfo)
    if(numel(boundSignals)==4)
        paramName=boundSignals{1,1};


        if strcmpi(paramName,'X-Axis')
            xAxisSigID=boundSignals{2,1};
            yAxisSigID=boundSignals{2,2};
        else
            xAxisSigID=boundSignals{2,2};
            yAxisSigID=boundSignals{2,1};
        end
        if sdiEngine.sigRepository.getSignalIsActivelyStreaming(xAxisSigID)||...
            sdiEngine.sigRepository.getSignalIsActivelyStreaming(yAxisSigID)
            error(message('SDI:sdi:SendToFigWhileStreaming'));
        end
        tsX=exportSignalToTimeSeries(sdiEngine,xAxisSigID,true,'AddEndTime',true);
        tsY=exportSignalToTimeSeries(sdiEngine,yAxisSigID,true,'AddEndTime',true);


        minLen=min(length(tsX.Data),length(tsY.Data));
        xData=tsX.Data(1:minLen);
        yData=tsY.Data(1:minLen);
        xclr=getSignalLineColor(sdiEngine,xAxisSigID);
        yclr=getSignalLineColor(sdiEngine,yAxisSigID);
        xName=tsX.Name;
        yName=tsY.Name;

        appInstanceID=0;
        if~isempty(appInfo)&&~isempty(appInfo.recordBlk)
            appInstanceID=get_param(appInfo.recordBlk,'AppInstanceID');
        end
        settings=sdi_visuals.getVisualizationPreferences(appInstanceID,subplotID);
        axesLimits=settings.transform;
        if~isempty(appInfo)&&~isempty(appInfo.recordBlk)
            settings=getRecordBlkXYPref(appInfo.recordBlk);
        end
        exportSubPlotToFigure(xName,yName,xData,yData,xclr,yclr,settings,axesLimits,hFig);
    end
end

function settings=getRecordBlkXYPref(recordBlk)
    pref=get_param(recordBlk,'PlotPreferences');
    gridlines.style=lower(pref.XY.GridLines);
    settings.gridlines=gridlines;

    line.visible=0;
    if strcmp(pref.XY.Line,'Show')
        line.visible=1;
    end
    line.colorType='x';
    if strcmp(pref.XY.LineColor,'YColor')
        line.colorType='y';
    end
    settings.line=line;

    markers.visible=0;
    if strcmp(pref.XY.Markers,'Show')
        markers.visible=1;
    end
    markers.borderColorType='y';
    if strcmp(pref.XY.MarkerBorder,'XColor')
        markers.borderColorType='x';
    end
    markers.fillColorType='y';
    if strcmp(pref.XY.MarkerFill,'XColor')
        markers.fillColorType='y';
    end
    settings.markers=markers;

    trendline.visible=0;
    if strcmp(pref.XY.TrendLine,'Show')
        trendline.visible=1;
    end
    trendline.type=lower(pref.XY.TrendLineType);
    trendline.polynomialOrder=pref.XY.PolynomialOrder;
    trendline.thickness=pref.XY.TrendLineWeight;
    trendline.color=pref.XY.TrendLineColor;
    settings.trendline=trendline;
end


function exportSubPlotToFigure(xName,yName,xData,yData,xclr,yclr,settings,axesLimits,hFig)
    try
        type='';
        opts={};
        clr='r';
        if settings.line.visible==1
            type=strcat(type,'-');
            if settings.line.colorType=='y'
                clr=yclr;
            elseif settings.line.colorType=='x'
                clr=xclr;
            else
                clr=settings.line.color;

                if strcmp(clr,'steelblue')
                    clr='#4682B4';
                end
            end
            opts={type,'Color',clr};
        end
        if settings.markers.visible==1
            type=strcat(type,'o');
            if settings.markers.fillColorType=='y'
                mFaceColor=yclr;
            elseif settings.markers.fillColorType=='x'
                mFaceColor=xclr;
            else
                mFaceColor=settings.markers.fillColor;

                if strcmp(mFaceColor,'pink')
                    mFaceColor='#FFC0CB';
                end
            end
            if settings.markers.borderColorType=='y'
                mEdgeColor=yclr;
            elseif settings.markers.borderColorType=='x'
                mEdgeColor=xclr;
            else
                mEdgeColor=settings.markers.borderColor;
            end
            opts={type,'Color',clr};
            opts=[opts,{'MarkerEdgeColor',mEdgeColor,...
            'MarkerFaceColor',mFaceColor}];
        end
        if~isempty(type)

            opts=[opts,{'DisplayName',['(',xName,', ',yName,')']}];
            plot(xData,yData,opts{:});
        end
        if settings.trendline.visible&&~isempty(xData)&&~isempty(yData)
            hold on;
            p=[];
            isTrendLineValid=true;
            switch(settings.trendline.type)
            case 'polynomial'





                ws=warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
                cleanupWarning=onCleanup(@()warning(ws));
                p=polyfit(xData,yData,settings.trendline.polynomialOrder);
                [~,warnID]=lastwarn;
                if strcmpi(warnID,'MATLAB:polyfit:RepeatedPointsOrRescale')
                    isTrendLineValid=false;
                end
            otherwise





                p=polyfit(xData,yData,1);
            end
            if isTrendLineValid
                trendlineY=polyval(p,xData);
                [xSorted,i]=sort(xData);
                tYSorted=trendlineY(i);
                plot(xSorted,tYSorted,'-',...
                'Color',settings.trendline.color,...
                'LineWidth',settings.trendline.thickness);
            end
            hold off;
        end
    catch me
        delete(hFig);
        rethrow(me);
    end

    switch(settings.gridlines.style)
    case 'on'
        hFig.CurrentAxes.XGrid='on';
        hFig.CurrentAxes.YGrid='on';
    case 'horizontal'
        hFig.CurrentAxes.YGrid='on';
    case 'vertical'
        hFig.CurrentAxes.XGrid='on';
    otherwise
        hFig.CurrentAxes.XGrid='off';
        hFig.CurrentAxes.YGrid='off';
    end

    if~isempty(fieldnames(axesLimits))
        hFig.CurrentAxes.YLim=[axesLimits.yMin,axesLimits.yMax];
        hFig.CurrentAxes.XLim=[axesLimits.xMin,axesLimits.xMax];
    end
    hFig.CurrentAxes.Box='on';
    hFig.CurrentAxes.Title.String='';
    hFig.CurrentAxes.XTickLabelMode='auto';
    hFig.CurrentAxes.YTickLabelMode='auto';
    hFig.CurrentAxes.NextPlot='add';
end