
function uiController(obj,event,action,varargin)%#ok<INUSL>














    switch(action)
    case 'run'
        run(varargin{:});
    case 'automaticRun'
        automaticRun(obj,varargin{:});
    case 'plotSelectorBox'
        plotSelectorBox(obj,varargin{:});
    case 'plotSelectionChanged'
        plotSelectionChanged(varargin{:});
    case 'zoomin'
        zoomin(obj,varargin{:});
    case 'zoomout'
        zoomout(obj,varargin{:});
    case 'datacursor'
        datacursor(obj,varargin{:});
    case 'overlay'
        overlay(obj,varargin{:});
    case 'showAsTab'
        showAsTab(obj,varargin{:});
    case 'showAsGrid'
        showAsGrid(obj,varargin{:});
    case 'showAsColumn'
        showAsColumn(obj,varargin{:});
    case 'showAsRow'
        showAsRow(obj,varargin{:});
    case 'exportData'
        exportData(varargin{:});
    case 'exportFigures'
        exportFigures(varargin{:});
    case 'configureAxesProperties'
        configureAxesProperties(varargin{:});
    case 'resizeFigure'
        resizeFigure(varargin{:});
    case 'viewModel'
        viewModel(varargin{:});
    case 'plotExternalData'
        plotExternalData(varargin{:})
    case 'updateLegend'
        updateLegend(varargin{:});
    case 'relayoutAfterLabelChange'
        relayoutAfterLabelChange(varargin{:});
    case 'openFile'
        openFile(varargin{:});
    end


    function automaticRun(obj,appUI)

        if strcmp(obj.State,'on')
            appUI.AutomaticRun=true;
        else
            appUI.AutomaticRun=false;
        end


        function run(appUI)

            msg=appUI.okToRun;
            if~isempty(msg)
                errordlg(msg,'Run Error');
                return;
            end

            model=appUI.Model;

            set(appUI.Handles.Figure,'Pointer','watch');
            set(appUI.Handles.RunButton,'Enable','off');
            drawnow;




            try
                params=appUI.Sliders;
                values=ones(1,length(params));
                for i=1:length(params)
                    p=params(i);
                    values(i)=str2double(p.ValueField.String);
                end


                set(appUI.Handles.ZoomIn,'State','off');
                set(appUI.Handles.ZoomOut,'State','off');
                set(appUI.Handles.DataCursor,'State','off');


                if appUI.UseStopTime
                    set(model.SimulationOptions,'StopTime',appUI.StopTime);

                    if(appUI.SupportOutputTimes)
                        set(model.SimulationOptions,'OutputTimes',[]);
                    end
                else
                    set(model.SimulationOptions,'StopTime',appUI.StopTime);

                    if(appUI.SupportOutputTimes)
                        set(model.SimulationOptions,'OutputTimes',appUI.OutputTimes);
                    end
                end


                tobj=privatesimulate(model,values,model.getdose);


                appUI.LastDataRun=tobj;


                plots=appUI.Plots;
                for i=1:length(plots)
                    ax=appUI.axesHandles(i);
                    tag=ax.Tag;


                    dataToPlot={};
                    time=tobj.Time;
                    for j=1:length(plots(i).PlotLines)
                        switch(plots(i).PlotLines(j).Type)
                        case SimBiology.simviewer.LineTypes.STATE
                            lineName=plots(i).PlotLines(j).Name;
                            [~,x,name]=selectbyname(tobj,lineName);
                            if isempty(x)
                                errordlg(['There is no data for state: ',lineName,'. Verify StatesToLog includes this state.'],'Run Error');
                            else

                                dataToPlot{end+1}=time;
                                dataToPlot{end+1}=x;


                                if~isNameBeingUsedByExternalData(plots(i),name{1})
                                    plots(i).PlotLines(j).Name=name{1};
                                end
                            end

                        case SimBiology.simviewer.LineTypes.MATH

                            mathExpr=plots(i).PlotLines(j).MathExpression;


                            mathExprData=evaluateExpression(tobj,mathExpr,plots(i).PlotLines(j).MathTokenPQN);

                            dataToPlot{end+1}=time;
                            dataToPlot{end+1}=mathExprData;
                        case SimBiology.simviewer.LineTypes.EXTERNAL_DATA

                            dataToPlot{end+1}=plots(i).PlotLines(j).Time;
                            dataToPlot{end+1}=plots(i).PlotLines(j).YData;
                        end
                    end


                    if~isempty(dataToPlot)
                        hLines=plot(ax,dataToPlot{:});
                        ax.Tag=tag;
                        configureLineProperties(hLines,plots(i).PlotLines);
                    end


                    extData=plots(i).ExternalData;
                    for j=1:length(extData)
                        plotExternalData(ax,extData(j))
                    end
                end


                for i=1:length(plots)
                    ax=appUI.axesHandles(i);
                    configureAxesProperties(ax,plots(i));
                end

                updateTickLabels(appUI);



                [~,uiplot]=getAxes(appUI);
                options=getLegendNames(uiplot);
                options{end+1}='Add new line from data...';
                appUI.Handles.PlotSetup.LineComboBox.String=options;


                stats=appUI.Statistics;
                for i=1:length(stats)
                    value=evaluateExpression(tobj,stats(i).Expression,stats(i).ExpressionTokens);
                    stats(i).Value=value;
                    set(appUI.Statistics(i).ValueField,'String',num2str(value));
                end
            catch ex
                errordlg(['An error occurred while simulating:',sprintf('\n'),ex.message],'Run Error');
            end


            if~isempty(appUI.LastDataRun)
                set(appUI.Handles.ExportData,'Enable','on');
                set(appUI.Handles.ExportFigures,'Enable','on');
            end

            set(appUI.Handles.Figure,'Pointer','arrow');
            set(appUI.Handles.RunButton,'Enable','on');


            function out=isNameBeingUsedByExternalData(plotObj,name)

                out=false;
                allLines=plotObj.ExternalData;
                for i=1:length(allLines)
                    if strcmp(allLines(i).Name,name)
                        out=true;
                        return;
                    end
                end


                function result=evaluateExpression(data,expression,tokens)

                    assignVariable=@(name,value)assignin('caller',name,value);
                    for j=1:length(tokens)
                        nextToken=tokens{j};
                        if strcmp(nextToken,'time')
                            nextData=data.Time;
                            time=nextData;%#ok<NASGU> time is needed for expression
                        else
                            next=['x',num2str(j)];
                            nextData=selectbyname(data,nextToken);
                            nextData=nextData.Data;
                            assignVariable(next,nextData);
                        end
                    end

                    try
                        result=eval(expression);
                    catch
                        result=-1;
                    end


                    function plotSelectionChanged(appUI)

                        tab=appUI.Handles.PlotTabPanelGroup.SelectedTab;
                        names=appUI.Handles.PlotSetup.PlotComboBox.String;
                        value=find(strcmp(tab.Title,names));

                        appUI.Handles.PlotSetup.PlotComboBox.Value=value;
                        plotSelectorBox(appUI.Handles.PlotSetup.PlotComboBox,appUI);


                        function plotSelectorBox(obj,appUI)

                            [~,uiplot]=getAxes(appUI);
                            handles=appUI.Handles.PlotSetup;


                            handles.GridCheckBox.Value=strcmp(uiplot.Grid,'on');
                            handles.XScaleCheckBox.Value=strcmp(uiplot.XScale,'log');
                            handles.YScaleCheckBox.Value=strcmp(uiplot.YScale,'log');

                            handles.XLimCheckBox.Value=strcmp(uiplot.XLimMode,'manual');
                            handles.XLimMinField.String=num2str(uiplot.XMin);
                            handles.XLimMaxField.String=num2str(uiplot.XMax);

                            enableState='off';
                            if strcmp(uiplot.XLimMode,'manual');
                                enableState='on';
                            end

                            set(handles.XLimMinLabel,'Enable',enableState);
                            set(handles.XLimMinField,'Enable',enableState);
                            set(handles.XLimMaxLabel,'Enable',enableState);
                            set(handles.XLimMaxField,'Enable',enableState);



                            handles.YLimCheckBox.Value=strcmp(uiplot.YLimMode,'manual');
                            handles.YLimMinField.String=num2str(uiplot.YMin);
                            handles.YLimMaxField.String=num2str(uiplot.YMax);

                            enableState='off';
                            if strcmp(uiplot.YLimMode,'manual');
                                enableState='on';
                            end
                            set(handles.YLimMinLabel,'Enable',enableState);
                            set(handles.YLimMinField,'Enable',enableState);
                            set(handles.YLimMaxLabel,'Enable',enableState);
                            set(handles.YLimMaxField,'Enable',enableState);


                            handles.TabNameField.String=uiplot.Name;
                            handles.TitleField.String=uiplot.Title;
                            handles.XLabelField.String=uiplot.XLabel;
                            handles.YLabelField.String=uiplot.YLabel;


                            handles.LineComboBox.Value=1;
                            options=getLegendNames(uiplot);
                            options{end+1}='Add new line from data...';
                            handles.LineComboBox.String=options;



                            fcn=appUI.Handles.PlotSetup.PositionLineProps;
                            fcn(appUI);


                            fcn=appUI.Handles.LM.ConfigureComponents;
                            fcn(appUI);

                            index=obj.Value;
                            tabToSelect=appUI.plotTabHandle(index);
                            appUI.Handles.PlotTabPanelGroup.SelectedTab=tabToSelect;


                            function zoomin(obj,appUI)

                                state=obj.State;
                                fig=appUI.Handles.Figure;

                                datacursormode(fig,'off');
                                rotate3d(fig,'off');

                                if strcmp(state,'on')
                                    appUI.Handles.ZoomMode.Enable='on';
                                    appUI.Handles.ZoomMode.Direction='in';
                                    appUI.Handles.ZoomMode.Motion='both';
                                    appUI.Handles.ZoomMode.ActionPostCallback={@zoomDone,appUI};

                                    appUI.Handles.ZoomOut.State='off';
                                    appUI.Handles.DataCursor.State='off';
                                else
                                    appUI.Handles.ZoomMode.Enable='off';
                                end


                                function zoomout(obj,appUI)

                                    state=obj.State;
                                    fig=appUI.Handles.Figure;

                                    datacursormode(fig,'off');
                                    rotate3d(fig,'off');

                                    if strcmp(state,'on')
                                        appUI.Handles.ZoomMode.Enable='on';
                                        appUI.Handles.ZoomMode.Direction='out';
                                        appUI.Handles.ZoomMode.ActionPostCallback={@zoomDone,appUI};
                                        appUI.Handles.ZoomIn.State='off';
                                        appUI.Handles.DataCursor.State='off';
                                    else
                                        appUI.Handles.ZoomMode.Enable='off';
                                    end


                                    function zoomDone(obj,eventdata,appUI)


                                        function datacursor(obj,appUI)

                                            state=obj.State;
                                            fig=appUI.Handles.Figure;

                                            rotate3d(fig,'off');
                                            zoom(fig,'off');

                                            if strcmp(state,'on')
                                                datacursormode(fig,'on');
                                                set(appUI.Handles.ZoomIn,'State','off');
                                                set(appUI.Handles.ZoomOut,'State','off');
                                            else
                                                datacursormode(fig,'off');
                                            end


                                            function overlay(obj,appUI)

                                                state=obj.State;
                                                ax=appUI.axesHandles;

                                                if strcmp(state,'on')
                                                    value='add';
                                                else
                                                    value='replace';
                                                end

                                                set(ax,'NextPlot',value);

                                                if strcmp(state,'off')
                                                    for i=1:length(ax)



                                                        numLines=length(appUI.Plots(i).PlotLines);
                                                        children=findobj(ax(i).Children,'Type','line');
                                                        lastLineColor=children(end).Color;
                                                        delete(children(numLines+1:end));



                                                        if numLines==1
                                                            ax(i).Children.Color=lastLineColor;
                                                        end
                                                    end
                                                end


                                                function showAsTab(obj,appUI)

                                                    set(obj,'State','on');
                                                    set(appUI.Handles.ShowAsGrid,'State','off');
                                                    set(appUI.Handles.ShowAsColumn,'State','off');
                                                    set(appUI.Handles.ShowAsRow,'State','off');

                                                    layoutPlots(obj,appUI,1,1);


                                                    function showAsColumn(obj,appUI)

                                                        set(obj,'State','on');
                                                        set(appUI.Handles.ShowAsTab,'State','off');
                                                        set(appUI.Handles.ShowAsGrid,'State','off');
                                                        set(appUI.Handles.ShowAsRow,'State','off');

                                                        ax=appUI.axesHandles;
                                                        numRows=length(ax);
                                                        numCols=1;

                                                        layoutPlots(obj,appUI,numRows,numCols);
                                                        updateTickLabels(appUI);


                                                        function showAsRow(obj,appUI)

                                                            set(obj,'State','on');
                                                            set(appUI.Handles.ShowAsTab,'State','off');
                                                            set(appUI.Handles.ShowAsColumn,'State','off');
                                                            set(appUI.Handles.ShowAsGrid,'State','off');

                                                            ax=appUI.axesHandles;
                                                            numRows=1;
                                                            numCols=length(ax);

                                                            layoutPlots(obj,appUI,numRows,numCols);
                                                            updateTickLabels(appUI);


                                                            function showAsGrid(obj,appUI)

                                                                set(obj,'State','on');
                                                                set(appUI.Handles.ShowAsTab,'State','off');
                                                                set(appUI.Handles.ShowAsColumn,'State','off');
                                                                set(appUI.Handles.ShowAsRow,'State','off');

                                                                ax=appUI.axesHandles;
                                                                numAxes=length(ax);
                                                                numRows=ceil(sqrt(numAxes));
                                                                numCols=ceil(numAxes/numRows);

                                                                layoutPlots(obj,appUI,numRows,numCols);
                                                                updateTickLabels(appUI);


                                                                function updateTickLabels(appUI)

                                                                    ax=appUI.axesHandles;

                                                                    if strcmp(appUI.Handles.ShowAsGrid.State,'on')
                                                                        numAxes=length(ax);
                                                                        numRows=ceil(sqrt(numAxes));







                                                                        axesToHaveLabels=ax(numRows:numRows:numAxes);
                                                                        axesToHaveLabels=[axesToHaveLabels,ax(end)];


                                                                        axesToNotHaveLabels=setdiff(ax,axesToHaveLabels);


                                                                        set(ax,'XTickLabelMode','auto');


                                                                        set(axesToNotHaveLabels,'XTickLabel',[]);
                                                                    elseif strcmp(appUI.Handles.ShowAsColumn.State,'on')

                                                                        set(ax(1:end-1),'XTickLabel',[]);
                                                                        set(ax(end),'XTickLabelMode','auto');
                                                                    elseif strcmp(appUI.Handles.ShowAsRow.State,'on')

                                                                        set(ax(2:2:end),'XTickLabel',[]);
                                                                        set(ax(1:2:end),'XTickLabelMode','auto');
                                                                    end


                                                                    function layoutPlots(obj,appUI,numRows,numCols)

                                                                        ax=appUI.axesHandles;
                                                                        plots=appUI.Plots;
                                                                        showAsTabs=(obj==appUI.Handles.ShowAsTab);

                                                                        if~showAsTabs
                                                                            oldState=appUI.Handles.SubPlotPanel.Visible;
                                                                            appUI.Handles.SubPlotPanel.Visible='on';
                                                                            appUI.Handles.PlotTabPanelGroup.Visible='off';

                                                                            axesGrid=appUI.Handles.AxesGrid;
                                                                            axesGrid.fill(appUI.Handles.SubPlotPanel);
                                                                            axesGrid.gridDimensions=[numRows,numCols];

                                                                            if strcmp(oldState,'off')





                                                                                updatePlotsForGridMode(plots);

                                                                                oldNextPlot=appUI.axesHandles(1).NextPlot;


                                                                                children=axesGrid.children;
                                                                                for i=1:length(children)

                                                                                    delete(children{i}.Children);


                                                                                    copyobj(get(ax(i),'Children'),children{i});
                                                                                    set(children{i},'NextPlot',oldNextPlot);
                                                                                    configureAxesProperties(children{i},plots(i));
                                                                                end


                                                                                appUI.axesHandles=[axesGrid.children{:}];


                                                                                relayoutAfterLabelChange(appUI);



                                                                                plotSelectorBox(appUI.Handles.PlotSetup.PlotComboBox,appUI);
                                                                            end

                                                                            axesGrid.fill(appUI.Handles.SubPlotPanel);


                                                                            linkaxes([appUI.Handles.AxesGrid.children{:}],'x');
                                                                        else
                                                                            oldNextPlot=appUI.axesHandles(1).NextPlot;


                                                                            appUI.Handles.SubPlotPanel.Visible='off';
                                                                            appUI.Handles.PlotTabPanelGroup.Visible='on';

                                                                            tabs=appUI.plotTabHandle;
                                                                            axesGrid=appUI.Handles.AxesGrid;
                                                                            oldChildren=axesGrid.children;

                                                                            for i=1:length(tabs)

                                                                                originalAxes=findall(tabs(i).Children,'Type','axes');
                                                                                tag=originalAxes.Tag;


                                                                                delete(tabs(i).Children);


                                                                                oldAxes=oldChildren{i};
                                                                                next=subplot(1,1,1,'Parent',tabs(i),'Tag',tag);
                                                                                copyobj(get(oldAxes,'Children'),next);
                                                                                set(next,'NextPlot',oldNextPlot);


                                                                                configureAxesProperties(next,plots(i));


                                                                                appUI.axesHandles(i)=next;
                                                                            end


                                                                            axesGrid.fill(appUI.Handles.SubPlotPanel);


                                                                            linkaxes([appUI.Handles.AxesGrid.children{:}],'off');
                                                                        end


                                                                        function relayoutAfterLabelChange(appUI)

                                                                            axesGrid=appUI.Handles.AxesGrid;


                                                                            [leftGap,bottomGap,topGap]=calculateGaps(axesGrid.children);
                                                                            axesGrid.gap=[leftGap,bottomGap+topGap];
                                                                            axesGrid.insets=[leftGap+15,bottomGap,25,25];

                                                                            axesGrid.fill(appUI.Handles.SubPlotPanel);


                                                                            function[left,bottom,top]=calculateGaps(children)

                                                                                if iscell(children)
                                                                                    children=[children{:}];
                                                                                end

                                                                                h=get(children,{'TightInset'});
                                                                                h=vertcat(h{:});
                                                                                left=max(h(:,1));
                                                                                bottom=max(h(:,2));
                                                                                top=max(h(:,4));



                                                                                if ismac
                                                                                    left=left+8;
                                                                                end


                                                                                function configureAxesProperties(ax,uiPlot)


                                                                                    updateLegend(ax,uiPlot);


                                                                                    set(ax,'XScale',uiPlot.XScale);
                                                                                    set(ax,'YScale',uiPlot.YScale);
                                                                                    grid(ax,uiPlot.Grid);
                                                                                    set(ax,'Color',uiPlot.AxesColor);

                                                                                    set(ax,'XLimMode',uiPlot.XLimMode);
                                                                                    if strcmp(uiPlot.XLimMode,'manual')
                                                                                        set(ax,'XLim',[uiPlot.XMin,uiPlot.XMax]);
                                                                                    end
                                                                                    set(ax,'XDir',uiPlot.XDir);

                                                                                    set(ax,'YLimMode',uiPlot.YLimMode);
                                                                                    if strcmp(uiPlot.YLimMode,'manual')
                                                                                        set(ax,'YLim',[uiPlot.YMin,uiPlot.YMax]);
                                                                                    end
                                                                                    set(ax,'YDir',uiPlot.YDir);

                                                                                    h=title(ax,uiPlot.Title);
                                                                                    SimBiology.simviewer.internal.layouthandler('configureTitle',h);

                                                                                    h=xlabel(ax,uiPlot.XLabel);
                                                                                    SimBiology.simviewer.internal.layouthandler('configureXLabel',h);

                                                                                    h=ylabel(ax,uiPlot.YLabel);
                                                                                    SimBiology.simviewer.internal.layouthandler('configureYLabel',h);


                                                                                    function updateLegend(ax,uiPlot)

                                                                                        if length(ax.Children)==length(uiPlot.getLegendNames)
                                                                                            h=legend(ax,uiPlot.getLegendNames,'AutoUpdate','off');
                                                                                            set(h,'Interpreter','none');
                                                                                            set(h,'Location',uiPlot.LegendLocation);
                                                                                            refreshLegend(h);
                                                                                        else



                                                                                            lines=findobj(ax.Children,'Type','line','Visible','on');
                                                                                            names=get(lines,{'DisplayName'});
                                                                                            tnames=names;
                                                                                            tnames(cellfun('isempty',tnames))=[];
                                                                                            tnames=unique(tnames);
                                                                                            legendNames=getVisibleLegendNames(uiPlot);
                                                                                            if length(tnames)==length(legendNames)



                                                                                                h=legend(ax,legendNames,'AutoUpdate','off');
                                                                                                set(h,'Interpreter','none');
                                                                                                set(h,'Location',uiPlot.LegendLocation);
                                                                                            else
                                                                                                if~isempty(names)&&~any(cellfun('isempty',names))
                                                                                                    h=legend(ax,names,'AutoUpdate','off');
                                                                                                    set(h,'Interpreter','none');
                                                                                                    set(h,'Location',uiPlot.LegendLocation);
                                                                                                    refreshLegend(h);
                                                                                                else
                                                                                                    refreshAllLegends;
                                                                                                end
                                                                                            end
                                                                                        end


                                                                                        function out=getVisibleLegendNames(obj)

                                                                                            out={};

                                                                                            for i=1:length(obj.PlotLines)
                                                                                                next=obj.PlotLines(i);
                                                                                                if strcmp(next.Visible,'on')
                                                                                                    out{end+1}=obj.PlotLines(i).Name;%#ok<*AGROW>
                                                                                                end
                                                                                            end

                                                                                            for i=1:length(obj.ExternalData)
                                                                                                next=obj.ExternalData(i);
                                                                                                if strcmp(next.Visible,'on')
                                                                                                    out{end+1}=obj.ExternalData(i).Name;
                                                                                                end
                                                                                            end


                                                                                            function refreshAllLegends

                                                                                                hLeg=findall(0,'Type','legend');
                                                                                                for i=1:length(hLeg)
                                                                                                    h=hLeg(i);
                                                                                                    refreshLegend(h);
                                                                                                    if isempty(h.String)
                                                                                                        delete(h);
                                                                                                    end
                                                                                                end


                                                                                                function refreshLegend(hLeg)

                                                                                                    uic=get(hLeg,'UIContextMenu');
                                                                                                    r=findall(uic,'Label','Refresh');
                                                                                                    if~isempty(r)
                                                                                                        hgfeval(r.Callback,[],[]);
                                                                                                    end


                                                                                                    function configureLineProperties(hLines,lineDefs)

                                                                                                        for i=1:length(hLines)
                                                                                                            hLine=hLines(i);
                                                                                                            lineDef=lineDefs(i);
                                                                                                            hLine.Tag=lineDef.Name;
                                                                                                            hLine.DisplayName=lineDef.Name;

                                                                                                            if~isempty(lineDef.Color)
                                                                                                                set(hLine,'Color',lineDef.Color);
                                                                                                            end

                                                                                                            if~isempty(lineDef.LineWidth)
                                                                                                                set(hLine,'LineWidth',lineDef.LineWidth);
                                                                                                            end

                                                                                                            if~isempty(lineDef.LineStyle)
                                                                                                                set(hLine,'LineStyle',lineDef.LineStyle);
                                                                                                            end

                                                                                                            if~isempty(lineDef.Marker)
                                                                                                                set(hLine,'Marker',lineDef.Marker);
                                                                                                            end
                                                                                                            if~isempty(lineDef.MarkerSize)
                                                                                                                set(hLine,'MarkerSize',lineDef.MarkerSize);
                                                                                                            end

                                                                                                            if~isempty(lineDef.MarkerEdgeColor)
                                                                                                                set(hLine,'MarkerEdgeColor',lineDef.MarkerEdgeColor);
                                                                                                            end

                                                                                                            if~isempty(lineDef.MarkerFaceColor)
                                                                                                                set(hLine,'MarkerFaceColor',lineDef.MarkerFaceColor);
                                                                                                            end

                                                                                                            set(hLine,'Visible',lineDef.Visible);
                                                                                                        end


                                                                                                        function[ax,uiplot]=getAxes(appUI)

                                                                                                            [uiplot,ax]=SimBiology.simviewer.internal.layouthandler('getUIPlot',appUI);


                                                                                                            function plotExternalData(ax,extData)


                                                                                                                nextPlot=get(ax,'NextPlot');
                                                                                                                set(ax,'NextPlot','add');


                                                                                                                data=extData.Data;
                                                                                                                time=extData.Time;
                                                                                                                y=extData.Y;


                                                                                                                time=data.(time);
                                                                                                                y=data.(y);


                                                                                                                hLine=plot(ax,time,y);
                                                                                                                set(hLine,'DisplayName',extData.Name);
                                                                                                                set(hLine,'Tag',extData.Name);
                                                                                                                configureLineProperties(hLine,extData);


                                                                                                                set(ax,'NextPlot',nextPlot);


                                                                                                                function exportData(appUI)

                                                                                                                    SimBiology.simviewer.internal.exportResultsToExcel(appUI);


                                                                                                                    function viewModel(appUI)

                                                                                                                        filePath=appUI.ModelDocument;
                                                                                                                        if isdeployed
                                                                                                                            if ispc

                                                                                                                                filePath=regexprep(filePath,'^.:\','');
                                                                                                                            end

                                                                                                                            filePath=fullfile(ctfroot,filePath);
                                                                                                                        end

                                                                                                                        openFile(filePath);


                                                                                                                        function openFile(filePath)


                                                                                                                            try
                                                                                                                                if ispc
                                                                                                                                    system(filePath);
                                                                                                                                elseif ismac
                                                                                                                                    cmd=sprintf('open ''%s''',filePath);
                                                                                                                                    system(cmd);
                                                                                                                                else
                                                                                                                                    open(filePath);
                                                                                                                                end
                                                                                                                            catch
                                                                                                                                errorMsg=sprintf('Cannot open file %s.',filePath);
                                                                                                                                errordlg(errorMsg,'File Open Error');
                                                                                                                            end


                                                                                                                            function exportFigures(appUI)

                                                                                                                                SimBiology.simviewer.internal.exportPlots(appUI);


                                                                                                                                function resizeFigure(appUI)

                                                                                                                                    hFigure=appUI.Handles.Figure;
                                                                                                                                    hPlotPanel=appUI.Handles.SubPlotPanel;
                                                                                                                                    hPlotTabPanel=appUI.Handles.PlotTabUIPanel;
                                                                                                                                    hWestComponent=appUI.Handles.TabPanelGroup;


                                                                                                                                    fullWidth=hFigure.Position(3);
                                                                                                                                    fullHeight=hFigure.Position(4);



                                                                                                                                    units=hWestComponent.Units;
                                                                                                                                    hWestComponent.Units='pixels';
                                                                                                                                    westX=hWestComponent.Position(1);
                                                                                                                                    westWidth=westX+hWestComponent.Position(3);



                                                                                                                                    if hWestComponent.Position(3)>400
                                                                                                                                        westPos=hWestComponent.Position;
                                                                                                                                        westPos(3)=400;
                                                                                                                                        hWestComponent.Position=westPos;
                                                                                                                                        westWidth=westX+hWestComponent.Position(3);
                                                                                                                                    end


                                                                                                                                    hWestComponent.Units=units;




                                                                                                                                    pos=hPlotPanel.Position;
                                                                                                                                    pos(1)=westWidth+westX;
                                                                                                                                    pos(3)=fullWidth-westWidth-westX;


                                                                                                                                    pos(4)=fullHeight-6;


                                                                                                                                    hPlotPanel.Position=pos;
                                                                                                                                    hPlotTabPanel.Position=pos;


                                                                                                                                    function updatePlotsForGridMode(plots)






                                                                                                                                        isMixed=false;
                                                                                                                                        xlimMode=plots(1).XLimMode;
                                                                                                                                        xmin=plots(1).XMin;
                                                                                                                                        xmax=plots(1).XMax;
                                                                                                                                        for i=2:length(plots)
                                                                                                                                            if~strcmp(xlimMode,plots(i).XLimMode)


                                                                                                                                                isMixed=true;
                                                                                                                                                break;
                                                                                                                                            end

                                                                                                                                            if strcmp(xlimMode,'manual')
                                                                                                                                                if(plots(i).XMin~=xmin)||(plots(i).XMax~=xmax)


                                                                                                                                                    isMixed=true;
                                                                                                                                                    break;
                                                                                                                                                end
                                                                                                                                            end
                                                                                                                                        end

                                                                                                                                        if isMixed
                                                                                                                                            for i=1:length(plots)
                                                                                                                                                plots(i).XLimMode='auto';
                                                                                                                                            end
                                                                                                                                        end

                                                                                                                                        isMixed=false;
                                                                                                                                        xscale=plots(1).XScale;
                                                                                                                                        for i=2:length(plots)
                                                                                                                                            if~strcmp(xscale,plots(i).XScale)


                                                                                                                                                isMixed=true;
                                                                                                                                                break;
                                                                                                                                            end
                                                                                                                                        end

                                                                                                                                        if isMixed
                                                                                                                                            for i=1:length(plots)
                                                                                                                                                plots(i).XScale='linear';
                                                                                                                                            end
                                                                                                                                        end
