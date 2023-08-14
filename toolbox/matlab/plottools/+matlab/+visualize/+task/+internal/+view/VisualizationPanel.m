classdef(Hidden)VisualizationPanel<matlab.visualize.task.internal.view.VisualizeDataBaseView







    properties(Access={?matlab.internal.visualizelivetask.utils.hVisualizeLiveTask,?hVisualizeTaskBase})
        VizGrid matlab.ui.container.GridLayout
        ChartIconGrid matlab.ui.container.GridLayout
        VizCategoryDropDown matlab.ui.control.DropDown
        SearchEditField matlab.ui.control.EditField
FilteredData

PreviousKeyword

        IsVisualizationPreSelected logical
        MarkedCleanListener event.listener
SearchKeywordTimer
    end

    properties(Access={?matlab.internal.visualizelivetask.utils.hVisualizeLiveTask,?hVisualizeTaskBase},Constant)
        MIN_HEIGHT=130
        ROW_HEIGHT=8

        FIXED_SPACING=5
        CHART_HEIGHT=675
        LINE_HEIGHT=2
        WAIT_TIME=0.5
    end

    events

VisualizationSelectionChanged


ViewUpdated

SearchCompleted
    end

    methods(Hidden)

        function obj=VisualizationPanel(parentContainer,model)
            obj@matlab.visualize.task.internal.view.VisualizeDataBaseView(parentContainer,model);
        end

        function hasCharts=hasChartShowing(obj)
            hasCharts=isempty(findobj(obj.ChartIconGrid,'Tag','NoVizButton'));
        end

        function updateEnabledCharts(obj,model,allMatchingCharts)
            obj.Model=model.ChartModel;
            obj.Model.EnabledCharts=allMatchingCharts;
        end

        function scrollToSelectedChart(obj)
            currentChart=findobj(obj.ChartIconGrid,'Value',1);
            if~isempty(currentChart)
                scroll(obj.ChartIconGrid.Parent,[10,-currentChart.Position(2)]);
            end
        end


        function updateState(obj,model,allMatchingCharts)
            obj.updateEnabledCharts(model,allMatchingCharts);
            chartsData=obj.Model.ChartMetaData;
            idx=cellfun(@(x)ismember(x.Name,obj.Model.EnabledCharts),chartsData);
            enableInd=cellfun(@(x)x.Index,chartsData(idx));
            obj.enableDisableCharts(enableInd);
            notify(obj,'ViewUpdated');
        end



        function preSelectVisualization(obj,userKeyword)
            allCharts=cellfun(@(x)x.Name,obj.Model.ChartMetaData,'UniformOutput',false);
            try
                chartToPreselect=validatestring(userKeyword,allCharts);
            catch
                return;
            end
            obj.SearchEditField.Value=userKeyword;
            obj.Model.InitialSearchTerm=userKeyword;
            obj.searchChart(chartToPreselect);
            obj.selectVisualization(chartToPreselect);
            notify(obj,'VisualizationSelectionChanged');
        end

        function selectVisualization(obj,chartToSelect)
            chartButton=findobj(obj.ChartIconGrid,'Text',chartToSelect);
            set(chartButton,'Value',1);
            obj.Model.SelectionIdx=str2double(chartButton.Tag);

            obj.IsVisualizationPreSelected=true;
        end


        function updateView(obj,model)
            obj.Model=model.ChartModel;
            filterByCategoryMap=obj.Model.FilterByCategoryMap;

            doFilter=false;
            doSearch=false;

            if~strcmpi(obj.SearchEditField.Value,obj.Model.CurrentSearchTerm)
                doSearch=true;
                obj.SearchEditField.Value=obj.Model.CurrentSearchTerm;
            end
            if~isempty(filterByCategoryMap)
                categoryData=keys(filterByCategoryMap);

                if~isempty(categoryData)
                    obj.VizCategoryDropDown.Enable='on';

                    if~strcmpi(obj.VizCategoryDropDown.Value,obj.Model.CurrentCategory)
                        doFilter=true;
                        obj.VizCategoryDropDown.Items=categoryData;
                        obj.VizCategoryDropDown.Value=obj.Model.CurrentCategory;
                        obj.filterByCategory(struct('Value',obj.VizCategoryDropDown.Value));
                    end
                end


                if~doFilter
                    if doSearch
                        obj.searchChart(obj.SearchEditField.Value);
                    elseif~isempty(obj.SearchEditField.Value)
                        obj.updateCharts();
                    else
                        chartsData=obj.Model.ChartMetaData;
                        if isempty(obj.Model.EnabledCharts)
                            enableInd=0;
                        else
                            idx=cellfun(@(x)ismember(x.Name,obj.Model.EnabledCharts),chartsData);
                            enableInd=cellfun(@(x)x.Index,chartsData(idx));
                        end

                        obj.enableDisableCharts(enableInd);
                        notify(obj,'ViewUpdated');
                    end
                end
                currentChart=findobj(obj.ChartIconGrid,'Tag',num2str(obj.Model.SelectionIdx));
                if~isempty(currentChart)
                    set(obj.ChartIconGrid.Children,'Value',0);
                    set(currentChart,'Value',1);
                elseif obj.hasChartShowing()
                    set(obj.ChartIconGrid.Children,'Value',0);
                end
            end
        end
    end

    methods(Access=protected)

        function updateCharts(obj)
            chartsData=obj.FilteredData;
            if~isempty(chartsData)
                searchData=obj.searchQueryFilter(obj.FilteredData,obj.Model.CurrentSearchTerm);
                obj.createAllVisualizationOptions(searchData);
            end
        end

        function createComponents(obj)

            selectVizGrid=uigridlayout(obj.ParentContainer);
            selectVizGrid.Padding=[0,obj.FIXED_SPACING,0,0];
            selectVizGrid.ColumnSpacing=0;
            selectVizGrid.RowSpacing=obj.FIXED_SPACING;
            selectVizGrid.ColumnWidth={'fit'};
            selectVizGrid.RowHeight={'fit','fit'};


            searchFilterVizGrid=uigridlayout(selectVizGrid);
            searchFilterVizGrid.Padding=[0,0,0,0];
            searchFilterVizGrid.ColumnSpacing=obj.FIXED_SPACING;
            searchFilterVizGrid.RowSpacing=0;
            searchFilterVizGrid.ColumnWidth={'1x','fit','fit'};
            searchFilterVizGrid.RowHeight={'fit'};


            obj.SearchEditField=uieditfield(searchFilterVizGrid,'text',...
            'Placeholder',getString(message('MATLAB:graphics:visualizedatatask:SearchPlaceholderText')));
            obj.SearchEditField.Value='';
            obj.SearchEditField.Layout.Row=1;
            obj.SearchEditField.Layout.Column=1;
            obj.SearchEditField.ValueChangingFcn=@(e,d)obj.searchCallback(d);


            filterByLabel=uilabel(searchFilterVizGrid,...
            'Text',getString(message('MATLAB:graphics:visualizedatatask:FilterCategoryLabel')));
            filterByLabel.Layout.Row=1;
            filterByLabel.Layout.Column=2;

            obj.VizCategoryDropDown=uidropdown('Parent',searchFilterVizGrid,'Enable','off');
            obj.VizCategoryDropDown.Layout.Row=1;
            obj.VizCategoryDropDown.Layout.Column=3;
            obj.VizCategoryDropDown.ValueChangedFcn=@(e,d)obj.filterByCategory(d);



            vizMainGrid=uigridlayout(selectVizGrid);
            vizMainGrid.Padding=[0,0,0,0];
            vizMainGrid.ColumnSpacing=0;
            vizMainGrid.RowSpacing=0;
            vizMainGrid.ColumnWidth={'1x'};
            vizMainGrid.RowHeight={'fit',obj.LINE_HEIGHT-1};

            obj.VizGrid=uigridlayout(vizMainGrid);
            obj.VizGrid.Padding=[0,0,0,0];
            obj.VizGrid.ColumnSpacing=0;
            obj.VizGrid.RowSpacing=0;
            obj.VizGrid.ColumnWidth={'1x'};
            obj.VizGrid.RowHeight={obj.MIN_HEIGHT};

            vizPanel=uipanel(obj.VizGrid);
            ax=uiaxes(vizMainGrid,'YLimMode','manual',...
            'XLimMode','manual','Toolbar',[],'XTick',[],...
            'YTick',[],'Color',[0.94,0.94,0.94]);
            disableDefaultInteractivity(ax);


            yline(ax,0,'LineWidth',obj.LINE_HEIGHT,'Color',[0.7,0.7,0.7]);


            obj.MarkedCleanListener=event.listener(ax,'MarkedClean',@(e,d)obj.valueChanged(e,d));
            chartGrid=uigridlayout(vizPanel,'Scrollable','on');
            chartGrid.Padding=[0,0,0,0];
            chartGrid.ColumnSpacing=0;
            chartGrid.RowSpacing=0;
            chartGrid.ColumnWidth={'1x'};
            chartGrid.RowHeight={'fit'};
            obj.ChartIconGrid=uigridlayout(chartGrid,'ColumnSpacing',obj.ROW_HEIGHT,'RowSpacing',obj.ROW_HEIGHT,'Tag','ChartIcons');
            obj.createEmptyChartGrid();
        end

        function valueChanged(obj,~,~)

            if obj.IsVisualizationPreSelected







                notify(obj,'ValueChangedEvent');
                obj.IsVisualizationPreSelected=false;
                delete(obj.MarkedCleanListener);
            end
        end
    end

    methods(Access=?hVisualizeTaskBase)

        function model=getModel(obj)
            model=obj.Model;
        end


        function visualizationSelectionChanged(obj,d)



            prevIdx=obj.Model.SelectionIdx;





            if strcmpi(d.Source.Enable,'off')
                d.Source.Value=~d.Source.Value;
                return;
            end
            if prevIdx~=-1
                allCharts=findobj(obj.ChartIconGrid,'Value',1,'Tag',num2str(prevIdx));
                set(allCharts,'Value',0);

                prevChart=obj.Model.ChartMetaData(prevIdx);
                channels=prevChart{1}.Channels;
                for j=1:numel(channels)
                    channels(j).DataMapped='select variable';
                end
            end

            if d.Value
                obj.Model.SelectionIdx=str2double(d.Source.Tag);
            else
                obj.Model.SelectionIdx=-1;
            end

            notify(obj,'VisualizationSelectionChanged');
        end

        function enableDisableCharts(obj,enabledIndices)
            chartIcons=obj.ChartIconGrid.Children;
            enabledIcons=matlab.ui.control.Button.empty;
            disabledIcons=matlab.ui.control.Button.empty;
            obj.ChartIconGrid.ColumnWidth=repmat({60},obj.ROW_HEIGHT,1);

            for i=1:numel(chartIcons)
                chartButton=chartIcons(i);
                if ismember(str2double(chartButton.Tag),enabledIndices)
                    chartButton.Enable='on';
                    enabledIcons(end+1)=chartButton;%#ok<AGROW>
                else
                    chartButton.Enable='off';
                    disabledIcons(end+1)=chartButton;
                end
            end
            colNum=1;
            rowNum=1;
            reorderIcons=[enabledIcons,disabledIcons];
            for i=1:numel(reorderIcons)
                if colNum>obj.ROW_HEIGHT
                    rowNum=ceil(i/obj.ROW_HEIGHT);
                    colNum=1;
                end
                chartButton=reorderIcons(i);
                if numel(chartButton.Text)>9
                    obj.ChartIconGrid.ColumnWidth{colNum}='fit';
                end
                chartButton.Layout.Row=rowNum;
                chartButton.Layout.Column=colNum;
                colNum=colNum+1;
            end
        end


        function createCharts(obj,enabledChartData,disabledChartData)
            delete(obj.ChartIconGrid.Children());
            selectedChartData=[];


            if obj.Model.SelectionIdx>0
                selectedChartData=obj.Model.ChartMetaData{obj.Model.SelectionIdx};
            end
            chartDataValues=[enabledChartData,disabledChartData];
            numOfEnableCharts=length(enabledChartData);
            numOfDisableCharts=length(disabledChartData);

            obj.ChartIconGrid.ColumnWidth=repmat({60},obj.ROW_HEIGHT,1);
            obj.ChartIconGrid.RowHeight=num2cell(repmat(50,1,ceil((numOfEnableCharts+numOfDisableCharts)/obj.ROW_HEIGHT)));
            obj.ChartIconGrid.Padding=[obj.FIXED_SPACING,obj.FIXED_SPACING,obj.FIXED_SPACING,obj.FIXED_SPACING];
            doEnable='on';
            colNum=1;
            rowNum=1;

            for i=1:(numOfEnableCharts+numOfDisableCharts)

                if i>numOfEnableCharts
                    doEnable='off';
                end
                if colNum>obj.ROW_HEIGHT
                    rowNum=ceil(i/obj.ROW_HEIGHT);
                    colNum=1;
                end

                chartData=chartDataValues{i};

                chartName=chartData.Name;
                chartIcon=chartData.Icon;
                chartTooltip=getString(message(chartData.Description));
                if numel(chartName)>9
                    obj.ChartIconGrid.ColumnWidth{colNum}='fit';
                end
                chartButton=uibutton(obj.ChartIconGrid,'state',...
                'IconAlignment','top',...
                'Text',chartName,...
                'FontSize',10,...
                'Enable',doEnable,...
                'Tooltip',chartTooltip,...
                'Icon',fullfile(matlabroot,chartIcon),...
                'ValueChangedFcn',@(e,d)obj.visualizationSelectionChanged(d),...
                'Tag',num2str(chartData.Index));
                if~isempty(selectedChartData)&&strcmp(selectedChartData.Name,chartName)
                    chartButton.Value=1;
                end
                chartButton.Layout.Row=rowNum;
                chartButton.Layout.Column=colNum;
                colNum=colNum+1;
            end
        end






        function searchChart(obj,searchKeyword)
            if nargin>1
                obj.Model.CurrentSearchTerm=searchKeyword;
            end

            if isempty(obj.PreviousKeyword)||~strcmpi(obj.Model.CurrentSearchTerm,obj.PreviousKeyword)
                obj.updateCharts();
                obj.PreviousKeyword=obj.Model.CurrentSearchTerm;
            end


            notify(obj,'SearchCompleted');

            obj.stopTimer();
        end

        function searchCallback(obj,eventData)
            searchKeyword=eventData.Value;
            obj.Model.CurrentSearchTerm=searchKeyword;
            obj.startTimer();
        end

        function startTimer(obj)
            t=obj.SearchKeywordTimer;

            if~(isscalar(t)&&isvalid(t))


                t=timer(...
                'Name','VLT_SearchKeywordTimer',...
                'ObjectVisibility','off',...
                'StartDelay',obj.WAIT_TIME,...
                'BusyMode','drop');
                obj.SearchKeywordTimer=t;


                cb=@(e,d)obj.searchChart();
                t.TimerFcn=matlab.graphics.controls.internal.timercb(cb);
                t.start();
            end
        end

        function stopTimer(obj)



            if~isempty(obj)&&isvalid(obj)
                t=obj.SearchKeywordTimer;
                if isscalar(t)&&isvalid(t)
                    stop(t);
                    delete(t);
                end
            end
        end

        function filterByCategory(obj,eventData)
            selectedCategory=eventData.Value;
            obj.Model.CurrentCategory=selectedCategory;

            obj.categoryFilter(selectedCategory);
            chartsData=obj.searchQueryFilter(obj.FilteredData,obj.SearchEditField.Value);
            obj.createAllVisualizationOptions(chartsData);
        end

        function categoryFilter(obj,selectedCategory)
            chartList=obj.Model.FilterByCategoryMap(selectedCategory).Charts;
            chartData=obj.Model.ChartMetaData;

            subListInd=cellfun(@(x)any(strcmpi(chartList,x.Name)),chartData);
            obj.FilteredData=chartData(subListInd);
        end

        function chartsData=searchQueryFilter(~,chartsData,searchTerm)
            if~isempty(searchTerm)

                searchTerm=lower(searchTerm);
                numOfCharts=length(chartsData);
                for i=1:numOfCharts
                    chartsData{i}.Relevance=0;
                    chartName=chartsData{i}.Name;
                    chartKeywords=chartsData{i}.Keywords;
                    chartDescription=getString(message(chartsData{i}.Description));

                    strInd=strfind(lower(chartName),searchTerm);
                    if~isempty(strInd)
                        strInd=strInd(1);


                        if strcmpi(chartName,searchTerm)

                            strInd=0.5;
                        end
                        chartsData{i}.Relevance=chartsData{i}.Relevance+max(10-strInd,1)*100;
                    end

                    if contains(lower(chartKeywords),searchTerm)
                        chartsData{i}.Relevance=chartsData{i}.Relevance+10;
                    end

                    if contains(lower(chartDescription),searchTerm)
                        chartsData{i}.Relevance=chartsData{i}.Relevance+1;
                    end
                end
                subListInd=cellfun(@(x)x.Relevance>0,chartsData);
                chartsData=chartsData(subListInd);
                [~,subListInd]=sort(cellfun(@(x)x.Relevance,chartsData),'descend');
                chartsData=chartsData(subListInd);
            end
        end



        function createEmptyChartGrid(obj)
            delete(obj.ChartIconGrid.Children());
            obj.ChartIconGrid.ColumnWidth={obj.CHART_HEIGHT};
            obj.ChartIconGrid.RowHeight={25};
            obj.ChartIconGrid.Padding=[obj.FIXED_SPACING,0,obj.FIXED_SPACING,40];
            catButtons=uibutton(obj.ChartIconGrid,'state','Text',{getString(message('MATLAB:graphics:visualizedatatask:NoVizFound'))},...
            'Value',1,...
            'Enable','off',...
            'BackgroundColor',[0.98,0.98,0.98],...
            'FontSize',12,...
            'FontColor',[0,0,0],...
            'Tag','NoVizButton');
            catButtons.Layout.Row=1;
            catButtons.Layout.Column=1;
        end

        function createAllVisualizationOptions(obj,chartsData)
            chartValues=chartsData;
            if isempty(chartValues)
                obj.createEmptyChartGrid();

                notify(obj,'ViewUpdated');
                return
            end
            if isempty(obj.Model.EnabledCharts)
                enableInd=1:numel(chartsData);
                obj.createCharts([],chartsData(enableInd));
            else
                enableInd=cellfun(@(x)any(strcmpi(obj.Model.EnabledCharts,x.Name)),chartsData);
                obj.createCharts(chartsData(enableInd),chartsData(~enableInd));
            end

            notify(obj,'ViewUpdated');
        end
    end
end