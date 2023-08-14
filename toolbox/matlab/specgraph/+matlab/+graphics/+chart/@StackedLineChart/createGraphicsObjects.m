function createGraphicsObjects(hObj,oldState)





    if nargin<2
        oldState=[];
    end

    clearPlotObjects(hObj);
    numAxes=hObj.getNumAxesCapped();
    if numAxes>0
        createAxes(hObj,numAxes);
        createTitle(hObj);
        createToolbars(hObj);
        enableZoomAndPan(hObj);

        [axesMapping,plotMapping]=hObj.Presenter.mapPlotObjects(oldState);
        hObj.createLineProperties(axesMapping,plotMapping);
        hObj.createAxesProperties(axesMapping,plotMapping);
        configureYLimits(hObj);


        hObj.createPlotObjects();

        createLegends(hObj,numAxes);
        createXLabel(hObj);
        hObj.createDisplayLabels(axesMapping,plotMapping);
        createChartLegend(hObj);
    else

        delete(hObj.Axes_I);
        delete(hObj.LegendHandle);
        resetChartGraphicsObjects(hObj);
    end
end

function clearPlotObjects(hObj)

    for axesIndex=1:length(hObj.Axes_I)
        delete(hObj.Axes_I(axesIndex).Children);
    end
    hObj.Plots={};
end

function createAxes(hObj,numAxes)

    allocateAxes(hObj,numAxes);
    initAxesVisibleCache(hObj,numAxes);
    configureAxes(hObj);
end

function allocateAxes(hObj,numAxes)
    if~hObj.Presenter.ChartDataChanged





        return
    end


    numOldAxes=numel(hObj.Axes_I);
    if numAxes<=numOldAxes
        delete(hObj.Axes_I(numAxes+1:end));
        hObj.Axes_I=hObj.Axes_I(1:numAxes);
        for i=1:numAxes
            cla(hObj.Axes_I(i),"reset");
        end
    else
        hAx=gobjects(1,numAxes);
        hAx(1:numOldAxes)=hObj.Axes_I(:);
        for i=numOldAxes+1:numAxes
            hAx(i)=matlab.graphics.axis.Axes();
            hObj.addNode(hAx(i));
        end
        hObj.Axes_I=hAx;
        for i=1:numAxes
            cla(hObj.Axes_I(i),"reset");
        end
    end
end

function initAxesVisibleCache(hObj,numAxes)

    hObj.AxesVisibleCache=true(1,numAxes);
end

function configureAxes(hObj)

    disableBrushing(hObj);
    set(hObj.Axes_I,...
    'HitTest','on',...
    'TickLabelInterpreter','none',...
    'Internal',true,...
    'XLimSpec','tight',...
    'YLimSpec','tight',...
    'FontName',hObj.FontName,...
    'FontSize',hObj.FontSize,...
    'Units',hObj.Units,...
    'XGrid',hObj.GridVisible,...
    'YGrid',hObj.GridVisible,...
    'XLimMode','manual',...
    'YLimMode','manual'...
    );
    configureRulers(hObj);
    configureXLimits(hObj);
end

function disableBrushing(hObj)
    for i=1:length(hObj.Axes_I)
        br=hggetbehavior(hObj.Axes_I(i),'brush');
        br.Enable=false;
    end
end

function configureRulers(hObj)
    for axesIndex=1:length(hObj.Axes_I)
        hObj.Axes_I(axesIndex).Description="StackedLineChart Axes "+axesIndex;
        xv=hObj.Presenter.getXLimits();
        yv=hObj.Presenter.getAxesYData(axesIndex);
        if isempty(yv)
            yv=[];
        else
            yv=yv{1};
        end
        matlab.graphics.internal.configureAxes(hObj.Axes_I(axesIndex),xv,yv);

        if~isa(hObj.Axes_I(axesIndex).YAxis,'matlab.graphics.axis.decorator.CategoricalRuler')
            hObj.Axes_I(axesIndex).YAxis.HideEndTicksIfOutside='on';
        end
    end
end

function configureXLimits(hObj)

    if hObj.XLimitsMode_I=="manual"
        autoxlim=hObj.Axes_I(1).XAxis.Limits_I;
        manualxlim=hObj.XLimits_I;

        if(isnumeric(autoxlim)&&isnumeric(manualxlim))||isequal(class(autoxlim),class(manualxlim))
            set(hObj.Axes_I,'XLim',manualxlim);
        else


            hObj.XLimitsMode_I='auto';
            autoxlim=hObj.Presenter.getXLimits();
            set(hObj.Axes_I,'XLim',autoxlim);
        end
    else
        autoxlim=hObj.Presenter.getXLimits();
        set(hObj.Axes_I,'XLim',autoxlim);
    end
end

function configureYLimits(hObj)

    for i=1:length(hObj.AxesProperties_I)
        if hObj.AxesProperties_I(i).YLimitsMode=="manual"
            autoylim=hObj.Presenter.getYLimits(i);
            manualylim=hObj.AxesProperties_I(i).YLimits_I;
            if(isnumeric(autoylim)&&isnumeric(manualylim))||isequal(class(autoylim),class(manualylim))
                set(hObj.Axes_I(i),'YLim',manualylim);
            else


                hObj.AxesProperties_I(i).YLimitsMode='auto';
                autoylim=hObj.Presenter.getYLimits(i);
                set(hObj.Axes_I(i),'YLim',autoylim);
            end
        else
            set(hObj.Axes_I(i),'YLim',hObj.Presenter.getYLimits(i));
        end
    end
end

function createTitle(hObj)

    hObj.TitleHandle=hObj.Axes_I(1).Title_I;
    set(hObj.TitleHandle,'StringMode','manual','String_I',hObj.Title_I);
end

function createToolbars(hObj)

    for i=1:length(hObj.Axes_I)
        ax=hObj.Axes_I(i);


        [axestoolbar,reset]=axtoolbar(ax,'restoreview');

        if~isempty(axestoolbar)
            axestoolbar.Serializable='off';
        end

        if~isempty(reset)
            reset.ButtonPushedFcn=@(varargin)resetCallback(hObj);
        end
    end
end

function enableZoomAndPan(hObj)

    f=ancestor(hObj.Axes_I(1),'figure');
    if~isempty(f)
        hObj.ZoomInteraction=hObj.ZoomInteraction([]);
        hObj.PanInteraction=hObj.PanInteraction([]);
        for i=1:length(hObj.Axes_I)
            strategy=matlab.graphics.chart.internal.stackedplot.StackedInteractionStrategy(hObj.Axes_I(i),hObj);
            hObj.ZoomInteraction(i)=matlab.graphics.interaction.uiaxes.ScrollZoom(hObj.Axes_I(i),...
            f,'WindowScrollWheel','WindowMouseMotion');
            hObj.ZoomInteraction(i).strategy=strategy;
            hObj.ZoomInteraction(i).enable();
            hObj.PanInteraction(i)=matlab.graphics.interaction.uiaxes.Pan(hObj.Axes_I(i),f,...
            'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
            hObj.PanInteraction(i).strategy=strategy;
            hObj.PanInteraction(i).enable();
        end
    end
end

function createLegends(hObj,numAxes)

    nplots=hObj.NumPlotsInAxes;
    for i=numAxes:-1:1



        leg(i)=matlab.graphics.illustration.Legend(...
        'Standalone','on','Units','points',...
        'FontName',hObj.FontName,'FontSize',hObj.FontSize,...
        'Interpreter','none','Visible','off',...
        'HitTest','off','PickableParts','none');



        for j=1:nplots(i)
            hObj.Plots{i}(j).DisplayName=...
            hObj.AxesProperties_I(i).LegendLabels{j};
        end
    end
    delete(hObj.LegendHandle);
    hObj.LegendHandle=leg;
end

function createXLabel(hObj)

    hObj.XLabelHandle=hObj.XLabelHandle([]);
    for i=1:length(hObj.Axes_I)
        hObj.XLabelHandle(i)=hObj.Axes_I(i).XAxis.Label;
    end
    set(hObj.XLabelHandle,'Interpreter','none');
    if strcmp(hObj.XLabelMode,'auto')
        hObj.XLabel_I=hObj.Presenter.getXLabel();
    else
        set(hObj.XLabelHandle,'StringMode','manual','String_I',hObj.XLabel_I);
    end
end

function createChartLegend(hObj)

    import matlab.graphics.chart.primitive.Scatter



    legendOptions={'Standalone','on','Units','points',...
    'FontName',hObj.FontName,'FontSize',hObj.FontSize,...
    'Interpreter','none','Visible','off','HitTest','off',...
    'PickableParts','none','Orientation',hObj.LegendOrientation};
    leg=hObj.ChartLegendHandle;
    if isvalid(leg)
        set(leg,legendOptions{:});
        reusingOldLegend=true;
    else
        leg=matlab.graphics.illustration.Legend(legendOptions{:});
        reusingOldLegend=false;
    end



    oldChildren=leg.PlotChildren;
    children=gobjects(1,numel(hObj.LegendLabels_I));
    commonChildOptions={'XData',NaN,'YData',NaN,'Marker','square'};
    for i=1:numel(hObj.LegendLabels_I)
        childOptions={'DisplayName',hObj.LegendLabels_I{i},...
        'MarkerFaceColor',hObj.ColorOrderInternal(rem(i-1,size(hObj.ColorOrderInternal,1))+1,:)};
        if reusingOldLegend&&i<=numel(oldChildren)&&isvalid(oldChildren(i))&&...
            isa(oldChildren(i),'matlab.graphics.chart.primitive.Scatter')
            children(i)=oldChildren(i);
            set(children(i),commonChildOptions{:},childOptions{:});
        else
            children(i)=Scatter(commonChildOptions{:},childOptions{:});
        end
    end
    leg.PlotChildren=children;

    if~reusingOldLegend
        delete(hObj.ChartLegendHandle);
        hObj.ChartLegendHandle=leg;
    end
end

function resetChartGraphicsObjects(hObj)

    hObj.Axes_I=[];
    hObj.ZoomInteraction=hObj.ZoomInteraction([]);
    hObj.PanInteraction=hObj.PanInteraction([]);
    hObj.LineProperties_I=hObj.LineProperties_I([]);
    hObj.AxesProperties_I=hObj.AxesProperties_I([]);
    hObj.DisplayLabels_I=hObj.DisplayLabels_I([]);
    hObj.DisplayLabelsHandle=hObj.DisplayLabelsHandle([]);
    if strcmp(hObj.XLabelMode,'auto')
        hObj.XLabel_I=hObj.XLabel_I([]);
    end
    hObj.TitleHandle=hObj.TitleHandle([]);
    hObj.XLabelHandle=hObj.XLabelHandle([]);
    hObj.LegendHandle=hObj.LegendHandle([]);
end
