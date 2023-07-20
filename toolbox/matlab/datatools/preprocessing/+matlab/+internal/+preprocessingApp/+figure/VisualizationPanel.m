classdef VisualizationPanel<matlab.ui.componentcontainer.ComponentContainer





    properties(Constant)
        ORIGINAL_PLOT(1,1)string=string(getString(message('MATLAB:datatools:preprocessing:visualizations:variablesummaryview:ORIGINAL_PLOT')))
        CLEANED_PLOT(1,1)string=string(getString(message('MATLAB:datatools:preprocessing:visualizations:variablesummaryview:CLEANED_PLOT')))
        DEFAULT_BLANK_CANVAS_ROW=2;
    end

    properties
PlotName

        VariableSummary containers.Map
        VAR_SUMMARY=getString(message('MATLAB:datatools:preprocessing:visualizations:vizpanel:VAR_SUMMARY'));
Annotations
    end

    properties
        VariableSummaryViewComponent matlab.internal.preprocessingApp.visualizations.VariableSummaryView
        Grid matlab.ui.container.GridLayout
        StatsGridLayout matlab.ui.container.GridLayout
        TableStatsLabels matlab.ui.control.Label
        TableStatsValues matlab.ui.control.Label
        TableSummaryLabel matlab.ui.control.Label
AxesOuterSubpanel
AxesInnerSubpanel
TiledLayout
SummaryPanel
AxesMap
ShowSummary
ShowLegend
StatsLabel
TimeStatsLabel
StatsValue
TableVariables
    end

    methods(Access='protected')
        function setup(obj)
        end

        function update(obj)
        end
    end

    methods
        function this=VisualizationPanel(varargin)
            this@matlab.ui.componentcontainer.ComponentContainer(varargin{:});
            this.createTileLayout();
            this.ShowSummary=true;
            this.ShowLegend=true;
        end

        function setData(this,data,variable,tableVariables)
            this.updatePlotView(variable,tableVariables,data,[],[],false);
        end

        function createTileLayout(obj)
            obj.Parent.AutoResizeChildren='on';
            obj.TiledLayout=uigridlayout(obj.Parent,...
            'BackgroundColor','#FAFAFA','Scrollable',true,...
            'Padding',[10,10,10,10]);
            obj.TiledLayout.ColumnWidth={'3x','1x'};
            obj.TiledLayout.RowHeight={'1x'};
        end

        function updatePlots(this,visScript,workspace,variable,tableVariables)
            tableVars=tableVariables;
            tableVars=cellfun(@(x)regexprep(x,'^\.',''),tableVars,'UniformOutput',false);
            this.updatePlotView(variable,tableVars,[],workspace,visScript,true);
        end

        function updatePlotView(this,variable,tableVariables,data,workspace,script,execScript)
            if isempty(variable)
                return;
            end

            if execScript&&isempty(script)
                return;
            end

            if execScript
                tableVariables=string(script.keys);
            end

            f=this.getParent();
            f.Internal=false;
            f.HandleVisibility='on';
            figure(f);

            if isempty(this.AxesMap)||this.isDataSizeChanged(data.currentData)
                this.initializeGridContents(data.currentData);
            elseif~isSelectionSourceClient()||execScript

                this.hideAllPlots();
            end

            if isempty(tableVariables)
                this.showBlankCanvas();
                drawnow nocallbacks;
                return;
            end



            wasPreviousViewBlank=this.isBlankView();
            this.TableVariables=tableVariables;
            stats=this.getStatsInfo(data,workspace,variable,tableVariables);


            plotCount=length(tableVariables);
            tileCount=plotCount*2;

            height=getpixelposition(this.TiledLayout);
            if plotCount>1
                rowHeight=max((height(4))/min(2,plotCount),250);
            else
                rowHeight='1x';
            end
            allTableVariables=[data.currentData.Properties.VariableNames];
            if istimetable(data.currentData)
                allTableVariables=...
                [data.currentData.Properties.DimensionNames{1},...
                allTableVariables];
            end

            for i=1:2:tileCount
                plotNum=((i-1)/2)+1;
                colIndex=find(strcmp(allTableVariables,tableVariables{plotNum}),1);

                if isempty(colIndex)
                    continue;
                end

                if~wasPreviousViewBlank&&...
                    ~isequal(this.TiledLayout.RowHeight{colIndex},0)&&...
                    contains(this.AxesMap{colIndex}.YLabel.String,tableVariables{plotNum})
                    if~isequal(this.TiledLayout.RowHeight{colIndex},rowHeight)
                        this.TiledLayout.RowHeight{colIndex}=rowHeight;
                    end
                    continue;
                end

                this.TiledLayout.RowHeight{colIndex}=rowHeight;


                if isempty(this.AxesMap{colIndex})
                    this.AxesMap{colIndex}=this.createNewAxes();
                end
                ax=this.AxesMap{colIndex};
                ax.Parent.Layout.Row=colIndex;


                if execScript
                    this.addPlotUsingScript(ax,plotNum,workspace,script);
                else
                    this.addPlot(ax,variable,tableVariables{plotNum},data);
                end


                if this.ShowSummary&&~isempty(stats)
                    this.addSummaryInfo(stats,plotNum,rowHeight,colIndex,tableVariables{plotNum});
                    ax.Parent.Layout.Column=1;
                else
                    ax.Parent.Layout.Column=[1,2];
                end

                ax.Legend.Visible=this.ShowLegend;

                if mod(plotNum,10)==0
                    drawnow nocallbacks;
                end
            end



            unselectedTableVariableIndices=find(~contains(allTableVariables,tableVariables));
            for i=1:length(unselectedTableVariableIndices)
                this.TiledLayout.RowHeight{unselectedTableVariableIndices(i)}=0;
            end

            f.HandleVisibility='off';
            f.Internal=true;
        end

        function showBlankCanvas(this)
            this.hideAllPlots();
            this.TiledLayout.RowHeight{this.DEFAULT_BLANK_CANVAS_ROW}='1x';
            delete(this.AxesMap{this.DEFAULT_BLANK_CANVAS_ROW});
            this.AxesMap{this.DEFAULT_BLANK_CANVAS_ROW}=this.createNewAxes();
            this.AxesMap{this.DEFAULT_BLANK_CANVAS_ROW}.Parent.Layout.Row=this.DEFAULT_BLANK_CANVAS_ROW;
            this.AxesMap{this.DEFAULT_BLANK_CANVAS_ROW}.Parent.Layout.Column=[1,2];
            this.AxesMap{this.DEFAULT_BLANK_CANVAS_ROW}.Legend.Visible=false;
        end

        function result=isBlankView(this)
            result=false;

            if isequal(this.TiledLayout.RowHeight{this.DEFAULT_BLANK_CANVAS_ROW},'1x')&&...
                ~isempty(this.AxesMap)&&isempty(this.AxesMap{this.DEFAULT_BLANK_CANVAS_ROW}.Children)
                result=true;
            end
        end

        function showLegends(this)
            this.ShowLegend=true;
            for i=1:length(this.AxesMap)
                if~isempty(this.AxesMap{i})
                    this.AxesMap{i}.Legend.Visible=true;
                end
            end
        end

        function hideLegends(this)
            this.ShowLegend=false;
            for i=1:length(this.AxesMap)
                if~isempty(this.AxesMap{i})
                    this.AxesMap{i}.Legend.Visible=false;
                end
            end
        end

        function showAxToolbar(this)
            for i=1:length(this.AxesMap)
                if~isempty(this.AxesMap{i})
                    this.AxesMap{i}.Toolbar.Visible=true;
                end
            end
        end

        function hideAxToolbar(this)
            for i=1:length(this.AxesMap)
                if~isempty(this.AxesMap{i})
                    this.AxesMap{i}.Toolbar.Visible=false;
                end
            end
        end

        function hideAnnotations(this)
            this.ShowSummary=false;
            f=this.getParent();
            f.Internal=false;
            f.HandleVisibility='on';
            figure(f);
            annotations=findall(this.TiledLayout,'type','uilabel');
            for i=1:length(annotations)
                annotations(i).Visible='off';
            end

            children=findall(this.TiledLayout,'type','axes');
            for i=1:length(children)
                children(i).Parent.Layout.Column=[1,2];
            end
            f.HandleVisibility='off';
            f.Internal=true;
        end

        function showAnnotations(this)
            this.ShowSummary=true;
            f=this.getParent();
            f.Internal=false;
            f.HandleVisibility='on';
            figure(f);
            annotations=findall(this.TiledLayout,'type','uilabel');
            for i=1:length(annotations)
                annotations(i).Visible='on';
            end

            children=findall(this.TiledLayout,'type','axes');
            for i=1:length(children)
                children(i).Parent.Layout.Column=1;
            end
            f.HandleVisibility='off';
            f.Internal=true;
        end

        function enableUpdateInteractions()
        end

        function disableUpdateInteractions()
        end


        function testInitializeGridContents(this,data)
            this.initializeGridContents(data);
        end

        function testAddPlotUsingScript(this,axesObj,plotNum,workspace,script)
            this.addPlotUsingScript(axesObj,plotNum,workspace,script);
        end

        function testConstructPlotData(this,axesObj,data,variable,tableVariable)
            this.constructPlotData(axesObj,data,variable,tableVariable);
        end
    end

    methods(Access='private')
        function initializeGridContents(this,data)
            colCount=size(data,2);
            if istimetable(data)
                colCount=colCount+1;
            end

            this.AxesMap=cell(1,colCount);
            this.TiledLayout.RowHeight=zeros(1,colCount);
        end

        function stats=getStatsInfo(this,data,workspace,variable,tableVariables)
            if~isempty(data)
                stats=this.updateStats(data.currentData,variable,tableVariables);
            elseif~isempty(workspace)

                if isfield(workspace.getVariables,'newTable')
                    data=workspace.('newTable');
                else
                    data=workspace.(variable);
                end
                stats=this.updateStats(data,variable,tableVariables);
            end
        end

        function addPlot(this,axesObj,variable,tableVariable,data)
            this.constructPlotData(axesObj,data,variable,string(tableVariable));
        end

        function axesObj=createNewAxes(this)
            axesObj=uiaxes(uipanel(this.TiledLayout,...
            'autoresizechildren','off',...
            'bordertype','none',...
            'backgroundColor','white'),...
            'units','normalized',...
            'OuterPosition',[0,0,1,1]);
            legend(axesObj);
            axtoolbar(axesObj,{'pan','restoreview','zoomin','zoomout'});
            l=axesObj.Legend;
            try
                l.ItemHitFcn=@matlab.internal.dataui.legendHitFcn;
            catch e
                disp(e);
            end
            grid(axesObj,'on');
            disableDefaultInteractivity(axesObj);
        end

        function addSummaryInfo(this,stats,plotNum,rowHeight,colIndex,tableVariableName)
            height=rowHeight-60;
            htmlStart=['<header style="width:100%;height:100%;display:block;overflow:none">'...
            ,'<table style="width:100%;height:100%;display:block;">'];
            str='';
            str=[str,'<tr>'];
            str=[str,'<td style="height: 20px;font-weight:bold;">',tableVariableName,'</td>'];
            for i=1:length(this.StatsLabel)
                str=[str,'<tr>'];
                str=[str,'<td style="height: 18px;">',this.StatsLabel{i},'</td>'];
                str=[str,'<td style="height: 18px;">',char(this.StatsValue{i,plotNum}),'</td>'];
                str=[str,'</tr>'];
            end
            htmlEnd='</table>';
            html=[htmlStart,str,htmlEnd];
            lb=uilabel(this.TiledLayout,'Interpreter','html');
            lb.BackgroundColor='#FAFAFA';

            lb.Text=html;
            lb.VerticalAlignment='top';
            lb.Layout.Row=colIndex;
            lb.Layout.Column=2;
        end

        function constructPlotData(obj,axesObj,data,variable,tableVariable)
            xData=1:height(data.currentData);
            yData=data.currentData.(tableVariable);
            xOrigData=1:height(data.origData);
            try
                yOrigData=data.origData.(tableVariable);
            catch
                yOrigData=[];
            end
            dataVars=internal.matlab.datatoolsservices.VariableUtils.generateDotSubscripting(variable,...
            tableVariable,data.currentData);
            isTimetableTimeVar=false;
            if istimetable(data.currentData)
                if strcmp(tableVariable,data.currentData.Properties.DimensionNames{1})

                    yData=[0;diff(data.currentData.Properties.RowTimes)];
                    try
                        yOrigData=[0;diff(data.origData.Properties.RowTimes)];
                    catch
                        yOrigData=[];
                    end
                    dataVars=...
                    string(getString(message('MATLAB:datatools:preprocessing:visualizations:variablesummaryview:TimeAxesLabel')));
                    isTimetableTimeVar=true;
                else
                    xData=data.currentData.Properties.RowTimes;
                    try
                        xOrigData=data.origData.Properties.RowTimes;
                    catch
                        xOrigData=[];
                    end
                    dataVars(2)=internal.matlab.datatoolsservices.VariableUtils.generateDotSubscripting(variable,...
                    data.currentData.Properties.DimensionNames{1},...
                    []);
                end
            end
            [plotType,unpreprocessedPlot,preprocessedPlot]=matlab.internal.preprocessingApp.visualizations.PlotUtils.plotData(...
            axesObj,...
            xData,...
            yData,...
            xOrigData,...
            yOrigData,...
            dataVars,...
            isTimetableTimeVar,...
            "",...
            "",...
            [1,1]);
            preprocessedPlot.DisplayName="☑"+" "+obj.CLEANED_PLOT;
            unpreprocessedPlot.DisplayName="☑"+" "+obj.ORIGINAL_PLOT;
        end

        function addPlotUsingScript(this,axesObj,plotNum,workspace,script)
            var=keys(script);
            f=this.getParent();
            f.CurrentAxes=axesObj;
            try
                cla(axesObj);


                axesObj.YLimMode='auto';
                axesObj.XLimMode='auto';
                s=script(var{plotNum});
                evalin(workspace,s);
            catch e
                disp(e)
            end
        end

        function sizeChanged=isDataSizeChanged(this,data)
            newColumnCount=length([data.Properties.DimensionNames{1}...
            ,data.Properties.VariableNames]);
            oldColumnCount=size(this.AxesMap,2);
            sizeChanged=~isequal(newColumnCount,oldColumnCount);
        end

        function hideAllPlots(this)
            this.TiledLayout.RowHeight=zeros(1,length(this.TiledLayout.RowHeight));
        end

        function hideExtraGrids(this,plotCount)
            if plotCount<length(this.TiledLayout.RowHeight)
                for i=plotCount+1:length(this.TiledLayout.RowHeight)
                    this.TiledLayout.RowHeight{i}=0;
                end
            end
        end

        function numPrevPlots=getPrevPlotCount(this)
            rowHeightsArr=this.TiledLayout.RowHeight;
            numPrevPlots=nnz(cellfun(@(x)~isequal(x,0),rowHeightsArr));
        end

        function parent=getParent(this)
            parent=this.Parent;
            while~isa(parent,'matlab.ui.Figure')
                parent=parent.Parent;
            end
        end

        function clearSummaryInfo(this)
            summaries=findall(this.TiledLayout,'type','uilabel');
            for i=1:length(summaries)
                delete(summaries(i));
            end
        end

        function stats=updateStats(this,data,~,tableVariable)
            [summaryTable,~,timeStats,tooltips,~,timeStatsTooltips]=matlab.internal.preprocessingApp.tabular.createSummaryTable(data);

            fn=summaryTable.Properties.VariableNames;
            this.StatsLabel=fn;
            numProps=length(fn);
            stats=cell(1,length(tableVariable));
            for i=1:length(tableVariable)
                varRow=find(strcmp(summaryTable.Properties.RowNames,tableVariable(i)));
                if isempty(varRow)




                    index=find(strcmp(data.Properties.VariableNames,tableVariable(i)));
                    if~isempty(index)&&index>0
                        varRow=...
                        char(internal.matlab.datatoolsservices.VariableUtils.generateUniqueName(tableVariable(i),...
                        data.Properties.VariableNames,[]));
                    else
                        return;
                    end
                end
                str="";
                for j=1:numProps
                    statsLabel=fn{j};
                    statsValue=string(summaryTable.(fn{j})(varRow));
                    str=str+newline+statsLabel+":"+" "+statsValue;
                    this.StatsValue{j,i}=statsValue;
                end
                stats{i}=str;













            end
        end
    end
end

function isSourceClient=isSelectionSourceClient()
    selectionInstance=matlab.internal.preprocessingApp.selection.Selection.getInstance();
    isSourceClient=false;
    if~isempty(selectionInstance.LastChangedSrc)&&...
        ~isempty(selectionInstance.LastChangedSrc.Tag)&&...
        strcmp(selectionInstance.LastChangedSrc.Tag,"variable_browser_panel")
        isSourceClient=true;
    end
end
