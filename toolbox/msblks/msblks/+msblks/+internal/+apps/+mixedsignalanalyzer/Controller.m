classdef Controller<handle




    properties(Hidden)
Model
View
MixedSignal
AutoUpdateString
Listeners
    end

    methods

        function obj=Controller(model,view)
            obj.Model=model;
            obj.View=view;
            obj.AutoUpdateString='Update';

            obj.listenFileButtons();
            obj.listenFilterButton();
            obj.listenPlotButton();
            obj.listenAnalysisButtons();
            obj.listenMetricsButtons();
            obj.listenDefaultLayoutButtons();
            obj.listenExportButton();
            addlistener(obj.View,'UpdateCustomGalleryListeners',...
            @(h,e)obj.runAnalysisCustomFunction(e,[]));
        end
    end

    methods(Access=private)
        function listenFileButtons(obj)
            toolstrip=obj.View.Toolstrip;


            addlistener(toolstrip.FileBtn_New,'ButtonPushed',@(h,e)newAction(obj.Model));


            addlistener(toolstrip.FileBtn_Open,'ButtonPushed',@(h,e)openAction(obj.Model,'Open session .mat file'));


            addlistener(toolstrip.FileBtn_Save,'ButtonPushed',@(h,e)obj.Model.saveAction());
            items=toolstrip.FileBtn_Save.Popup.getChildByIndex();
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',@(h,e)savePopupActions(obj.Model,items(i).Tag));
            end


            addlistener(toolstrip.FileBtn_Import,'ButtonPushed',@(h,e)openAction(obj.Model,items(1).Tag));
            items=toolstrip.FileBtn_Import.Popup.getChildByIndex();
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',@(h,e)openPopupActions(obj.Model,items(i).Tag));
            end


            addlistener(toolstrip.FileBtn_Update,'ButtonPushed',@(h,e)updateAction(obj.Model,items(1).Tag));
            items=toolstrip.FileBtn_Update.Popup.getChildByIndex();
            for i=1:numel(items)
                addlistener(items(i),'ItemPushed',@(h,e)updatePopupActions(obj.Model,items(i).Tag));
            end
        end

        function listenFilterButton(obj)
            addlistener(obj.View.Toolstrip.FilterBtn,'ButtonPushed',@(h,e)filterAction(obj.View,'Filter'));
        end

        function listenPlotButton(obj)
            toolstrip=obj.View.Toolstrip;
            toolstrip.PlotBtn.ButtonPushedFcn=@(h,e)obj.View.addNewPlot();
            items=toolstrip.PlotBtn.Popup.getChildByIndex();
            for i=1:numel(items)
                switch items(i).Tag
                case 'PlotListItem_AddPlot'
                    items(i).ItemPushedFcn=@(h,e)obj.View.addNewPlot();
                case 'PlotListItem_RenamePlot'
                    items(i).ItemPushedFcn=@(h,e)obj.View.renamePlot();
                case 'PlotListItem_SetPlotScales'
                    items(i).ItemPushedFcn=@(h,e)obj.View.setPlotScales();
                case 'PlotListItem_TogglePlotGrid'
                    items(i).ItemPushedFcn=@(h,e)obj.View.togglePlotGrid();
                end
            end
        end

        function listenAnalysisButtons(obj)
            toolstrip=obj.View.Toolstrip;
            analysisButtons=toolstrip.AnalysisButtons;
            for i=1:length(analysisButtons)
                if analysisButtons{i}==toolstrip.AnalysisBtn_DisplayWaveform

                    analysisButtons{i}.ItemPushedFcn=@(h,e)obj.showSelectedWaveformsAndLegendVisibilityTable();
                elseif analysisButtons{i}==toolstrip.AnalysisBtn_Custom

                    analysisButtons{i}.ItemPushedFcn=@(h,e)obj.runSampleAnalysis();
                else

                    analysisButtons{i}.ItemPushedFcn=@(h,e)obj.runAnalysisFunction(analysisButtons{i}.Text,[]);
                end
            end
        end

        function listenMetricsButtons(obj)
            toolstrip=obj.View.Toolstrip;
            metricsButtons=toolstrip.MetricsButtons;
            for i=1:length(metricsButtons)
                if metricsButtons{i}==toolstrip.MetricsBtn_TrendChart

                    metricsButtons{i}.ItemPushedFcn=@(h,e)obj.setupTrendChart();
                elseif metricsButtons{i}==toolstrip.MetricsBtn_Histogram

                elseif metricsButtons{i}==toolstrip.MetricsBtn_PieChart

                elseif metricsButtons{i}==toolstrip.MetricsBtn_Table

                end
            end
        end

        function listenDefaultLayoutButtons(obj)
            addlistener(obj.View.Toolstrip.DefaultLayoutBtn,'ButtonPushed',@(h,e)defaultLayoutAction(obj.View));
        end

        function listenExportButton(obj)
            toolstrip=obj.View.Toolstrip;
            items=toolstrip.ExportBtn.Popup.getChildByIndex();
            toolstrip.ExportBtn.ButtonPushedFcn=@(h,e)obj.Model.exportPopupActions(items(1).Tag);
            for i=1:numel(items)
                items(i).ItemPushedFcn=@(h,e)obj.Model.exportPopupActions(items(i).Tag);
                switch items(i).Tag
                case 'ExportListItem_ToScript'
                    items(i).ItemPushedFcn=@(h,e)obj.Model.exportScript();
                case 'ExportListItem_ToReport'
                    items(i).ItemPushedFcn=@(h,e)obj.Model.exportReport();
                case 'ExportListItem_ToWorkspace'
                    items(i).ItemPushedFcn=@(h,e)obj.Model.exportWorkSpace();
                case 'Generic database .csv file'
                    items(i).ItemPushedFcn=@(h,e)saveAction(obj.Model,'Save generic database file');
                end
            end
        end
    end

    methods(Hidden)
        function[wfNames,wfValues,wfTables,wfDbIndices]=getSelectedWaveforms(obj)
            wfNames=[];
            wfValues=[];
            wfTables=[];
            wfDbIndices=[];
            if~isempty(obj.View)
                [wfNames,wfValues,wfTables,wfDbIndices]=obj.View.getSelectedWaveforms();
            end
        end

        function showSelectedWaveforms(obj)
            [wfNames,wfValues,wfTables,wfDbIndices]=obj.getSelectedWaveforms();
            if~isempty(wfNames)
                mixedsignalplot(obj.Model.MixedSignalAnalysis,{...
                obj.View.Toolstrip.AnalysisBtn_DisplayWaveform.Tag,obj.View,wfNames,wfValues,wfTables,wfDbIndices});
                obj.View.addPlotMargins();
            end
        end
        function showSelectedWaveformsAndLegendVisibilityTable(obj)
            [wfNames,wfValues,wfTables,wfDbIndices]=obj.getSelectedWaveforms();
            if~isempty(wfNames)
                mixedsignalplot(obj.Model.MixedSignalAnalysis,{...
                obj.View.Toolstrip.AnalysisBtn_DisplayWaveform.Tag,obj.View,wfNames,wfValues,wfTables,wfDbIndices});
                obj.View.addPlotMargins();
                obj.View.updateWaveformPlotTableAndControls([]);
            end
        end


        function[nodesOut,nameValuePairs]=runAnalysisFunction(obj,functionName,dialogAnswers)
            functionPath=['msblks.internal.mixedsignalanalysis.',functionName,'WaveWrapper'];
            clear(functionPath);
            [wfNames,wfValues,wfTables,wfDbIndices]=obj.getSelectedWaveforms();
            if isempty(dialogAnswers)

                [nodesOut,nameValuePairs]=...
                feval(functionPath,wfValues,'wfNames',wfNames,'wfTables',wfTables,'wfDbIndices',wfDbIndices);
            else

                [nodesOut,nameValuePairs]=...
                feval(functionPath,wfValues,'wfNames',wfNames,'wfTables',wfTables,'wfDbIndices',wfDbIndices,'AnalysisDialogAnswers',dialogAnswers);
            end
            if obj.isSameWaveforms(wfValues,nodesOut)

                for i=1:length(nodesOut)
                    nodesOut{i}.type='Metrics Only';
                end
            end
            if~isempty(nodesOut)&&strcmpi(nodesOut{1}(1),'cancel')
                return;
            elseif isempty(nodesOut)
                obj.View.addWaveformsAndOrMetricsToDataTree(wfValues,nameValuePairs);
            else
                obj.View.addWaveformsAndOrMetricsToDataTree(nodesOut,nameValuePairs);
            end
        end


        function[nodesOut,nameValuePairs]=runAnalysisCustomFunction(obj,functionName,dialogAnswers)


            if(isempty(dialogAnswers))
                if(isobject(functionName))
                    functionName=functionName.data.path;
                end
            end
            functionPath=['msaCustom.',functionName,'Wrapper'];
            clear(functionPath);
            [wfNames,wfValues,wfTables,wfDbIndices]=obj.getSelectedWaveforms();
            if isempty(dialogAnswers)

                [nodesOut,nameValuePairs]=...
                feval(functionPath,wfValues,'wfNames',wfNames,'wfTables',wfTables,'wfDbIndices',wfDbIndices);
            else

                [nodesOut,nameValuePairs]=...
                feval(functionPath,wfValues,'wfNames',wfNames,'wfTables',wfTables,'wfDbIndices',wfDbIndices,'AnalysisDialogAnswers',dialogAnswers);
            end
            if obj.isSameWaveforms(wfValues,nodesOut)

                for i=1:length(nodesOut)
                    nodesOut{i}.type='Metrics Only';
                end
            end
            if~isempty(nodesOut)&&strcmpi(nodesOut{1}(1),'cancel')
                return;
            elseif isempty(nodesOut)
                obj.View.addWaveformsAndOrMetricsToDataTree(wfValues,nameValuePairs);
            else
                obj.View.addWaveformsAndOrMetricsToDataTree(nodesOut,nameValuePairs);
            end
        end


        function isSame=isSameWaveforms(obj,waveforms1,waveforms2)
            if length(waveforms1)~=length(waveforms2)
                isSame=false;
                return;
            else
                for i=1:length(waveforms1)
                    if~isequal(waveforms1{i}.x,waveforms2{i}.x)||...
                        ~isequal(waveforms1{i}.y,waveforms2{i}.y)||...
                        ~isequal(waveforms1{i}.xunit,waveforms2{i}.xunit)||...
                        ~isequal(waveforms1{i}.yunit,waveforms2{i}.yunit)||...
                        ~isequal(waveforms1{i}.xlabel,waveforms2{i}.xlabel)||...
                        ~isequal(waveforms1{i}.ylabel,waveforms2{i}.ylabel)||...
                        ~isequal(waveforms1{i}.xscale,waveforms2{i}.xscale)||...
                        ~isequal(waveforms1{i}.yscale,waveforms2{i}.yscale)
                        isSame=false;
                        return;
                    end
                end
            end
            isSame=true;
        end

        function[nodesOut,nameValuePairs]=runSampleAnalysis(obj)
            [wfNames,wfValues,wfTables,wfDbIndices]=obj.getSelectedWaveforms();
            [nodesOut,nameValuePairs]=...
            msblks.internal.mixedsignalanalysis.sampleAnalysisFunction(wfValues,'wfNames',wfNames,'wfTables',wfTables,'wfDbIndices',wfDbIndices);
            obj.View.addWaveformsAndOrMetricsToDataTree(nodesOut,nameValuePairs);
        end

        function setupTrendChart(obj)
            try
                obj.View.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyUpdatingTrendChartPlotOptions')));
                obj.View.Toolstrip.PlotListItem_SetPlotScales.Enabled=false;
                [~,~,wfTables,~]=obj.View.getSelectedMetrics();
                obj.View.updateTrendPlotTableAndControls(wfTables,[]);
                drawnow;
                pause(2.0);
                obj.showTrendChart();
                obj.View.Toolstrip.PlotListItem_SetPlotScales.Enabled=false;
            catch ex
                obj.View.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.View.MixedSignalAnalyzerTool.setStatus('');
        end
        function showTrendChart(obj)
            try
                obj.View.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyPlotting')));
                mergedTable=obj.View.PlotOptionsPanels{1}.Children.Children(2);
                metricsPanel=obj.View.PlotOptionsPanels{2};
                tree=[];
                for i=1:length(metricsPanel.Children(1).Children(2).Children(1).Children)
                    if strcmpi(metricsPanel.Children(1).Children(2).Children(1).Children(i).Type,'uicheckboxtree')
                        tree=metricsPanel.Children(1).Children(2).Children(1).Children(i);
                        break;
                    end
                end
                if isempty(tree)
                    return;
                end
                cornerParams=tree.UserData{2};
                metricParams=tree.UserData{3};
                [figHandle,docHandle]=obj.View.getSelectedPlot();
                if isempty(figHandle)||~isempty(figHandle.UserData)&&obj.View.isWaveformPlot(figHandle)

                    obj.View.addNewPlot();
                    drawnow;
                    pause(1.0);
                    [figHandle,docHandle]=obj.View.getSelectedPlot();
                end
                docHandle.Selected=true;
                symRunNames=obj.getItemsInListBox(metricsPanel,'leftPanel');
                yAxisParams=obj.getItemsInListBox(metricsPanel,'topRightPanel');
                xAxisParams=obj.getItemsInListBox(metricsPanel,'midRightPanel');
                legendParams=obj.getItemsInListBox(metricsPanel,'botRightPanel');
                SortXCellArray=fliplr(xAxisParams);
                T=metricsPanel.UserData{4};
                if isempty(figHandle.CurrentAxes)
                    figHandle.CurrentAxes=axes('Parent',figHandle);
                end

                figAxes=figHandle.CurrentAxes;
                hold(figAxes,'off');
                try
                    if isempty(xAxisParams)||isempty(yAxisParams)||isempty(xAxisParams{1})||isempty(yAxisParams{1})
                        plot(figAxes,0,0);
                        plotHandle='Blank';
                    elseif isempty(legendParams)||isempty(legendParams{1})
                        [~,~,plotHandle]=msblks.internal.apps.mixedsignalanalyzer.multiline(T,SortXCellArray,yAxisParams,figAxes);
                    else
                        [~,~,plotHandle]=msblks.internal.apps.mixedsignalanalyzer.multiline(T,SortXCellArray,yAxisParams,figAxes,legendParams);
                    end
                catch ex
                    uialert(figHandle,ex.message,'Unable to plot Trend Chart');
                    plot(figAxes,0,0);
                    plotHandle='Blank';
                end
                metricsPanel.UserData{5}=plotHandle;
                metricsPanel.UserData{6}=yAxisParams;
                metricsPanel.UserData{7}=yAxisParams;



                figHandle.UserData={metricsPanel...
                ,T...
                ,mergedTable.Data...
                ,mergedTable.ColumnName...
                ,symRunNames...
                ,cornerParams...
                ,metricParams...
                ,xAxisParams...
                ,yAxisParams...
                ,legendParams...
                ,obj.View.DataTreeMetricCheckedNodes};
                drawnow limitrate;
                obj.View.showTrendChartPlotOptions();
                drawnow limitrate;
            catch ex
                obj.View.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.View.MixedSignalAnalyzerTool.setStatus('');
        end
        function restoreTrendChart(obj,figHandle,docHandle,cornerParams,metricParams)
            try
                obj.View.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyPlotting')));
                mergedTable=obj.View.PlotOptionsPanels{1}.Children.Children(2);
                metricsPanel=obj.View.PlotOptionsPanels{2};
                docHandle.Selected=true;
                symRunNames=obj.getItemsInListBox(metricsPanel,'leftPanel');
                yAxisParams=obj.getItemsInListBox(metricsPanel,'topRightPanel');
                xAxisParams=obj.getItemsInListBox(metricsPanel,'midRightPanel');
                legendParams=obj.getItemsInListBox(metricsPanel,'botRightPanel');
                SortXCellArray=fliplr(xAxisParams);
                T=metricsPanel.UserData{4};
                if isempty(figHandle.CurrentAxes)
                    figHandle.CurrentAxes=axes('Parent',figHandle);
                end
                plotHandle=obj.plotTrend(figHandle,xAxisParams,yAxisParams,legendParams,T,SortXCellArray);
                metricsPanel.UserData{5}=plotHandle;
                metricsPanel.UserData{6}=yAxisParams;
                metricsPanel.UserData{7}=yAxisParams;



                figHandle.UserData={metricsPanel...
                ,T...
                ,mergedTable.Data...
                ,mergedTable.ColumnName...
                ,symRunNames...
                ,cornerParams...
                ,metricParams...
                ,xAxisParams...
                ,yAxisParams...
                ,legendParams...
                ,obj.View.DataTreeMetricCheckedNodes};
                drawnow limitrate;
                obj.View.showTrendChartPlotOptions();
                drawnow limitrate;
            catch ex
                obj.View.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.View.MixedSignalAnalyzerTool.setStatus('');
        end
        function plotHandle=plotTrend(obj,figHandle,xAxisParams,yAxisParams,legendParams,T,SortXCellArray)
            figAxes=figHandle.CurrentAxes;
            hold(figAxes,'off');
            try
                if isempty(xAxisParams)||isempty(yAxisParams)||isempty(xAxisParams{1})||isempty(yAxisParams{1})
                    plot(figAxes,0,0);
                    plotHandle='Blank';
                elseif isempty(legendParams)||isempty(legendParams{1})
                    [~,~,plotHandle]=msblks.internal.apps.mixedsignalanalyzer.multiline(T,SortXCellArray,yAxisParams,figAxes);
                else
                    [~,~,plotHandle]=msblks.internal.apps.mixedsignalanalyzer.multiline(T,SortXCellArray,yAxisParams,figAxes,legendParams);
                end
            catch ex
                uialert(figHandle,ex.message,'Unable to plot Trend Chart');
                plot(figAxes,0,0);
                plotHandle='Blank';
            end
        end
        function items=getItemsInListBox(obj,metricPanel,listBoxPanelTag)
            if isa(metricPanel,'matlab.ui.container.Panel')&&isa(metricPanel.Children,'matlab.ui.container.GridLayout')
                for i=1:length(metricPanel.Children.Children)
                    if isa(metricPanel.Children.Children(i),'matlab.ui.container.Panel')&&strcmp(metricPanel.Children.Children(i).Tag,listBoxPanelTag)&&...
                        isa(metricPanel.Children.Children(i).Children,'matlab.ui.container.GridLayout')
                        for j=1:length(metricPanel.Children.Children(i).Children.Children)
                            if isa(metricPanel.Children.Children(i).Children.Children(j),'matlab.ui.control.ListBox')
                                items=metricPanel.Children.Children(i).Children.Children(j).Items;
                                return;
                            end
                        end
                    end
                end
            end
            items=[];
        end
    end

    methods(Static)
        function destinationWf=copyWfProperties(sourceWf,destinationWf)
            if~isempty(sourceWf)&&~isempty(destinationWf)

                destinationWf.xunit=sourceWf.xunit;
                destinationWf.yunit=sourceWf.yunit;
                destinationWf.xlabel=sourceWf.xlabel;
                destinationWf.ylabel=sourceWf.ylabel;
                destinationWf.xscale=sourceWf.xscale;
                destinationWf.yscale=sourceWf.yscale;
            end
        end

        function[destinationWf,nameValuePairs]=moveWfProperties(destinationWf,nameValuePairs)
            if~isempty(destinationWf)&&~isempty(nameValuePairs)
                try
                    for j=length(nameValuePairs):-1:1
                        if j<length(nameValuePairs)
                            found=true;
                            switch lower(nameValuePairs{j})
                            case 'xunit'
                                destinationWf.xunit=nameValuePairs{j+1};
                            case 'yunit'
                                destinationWf.yunit=nameValuePairs{j+1};
                            case 'xlabel'
                                destinationWf.xlabel=nameValuePairs{j+1};
                            case 'ylabel'
                                destinationWf.ylabel=nameValuePairs{j+1};
                            case 'xscale'
                                destinationWf.xscale=nameValuePairs{j+1};
                            case 'yscale'
                                destinationWf.yscale=nameValuePairs{j+1};
                            otherwise
                                found=false;
                            end
                            if found

                                nameValuePairs=...
                                msblks.internal.apps.mixedsignalanalyzer.Controller.removeNameValuePair(nameValuePairs,j);
                            end
                        end
                    end
                catch

                end
            end
        end

        function[wfNames,wfTables,wfDBIndices,nameValuePairs]=getWfNamesTablesDBIndices(nameValuePairs)
            wfNames=[];
            wfTables=[];
            wfDBIndices=[];
            if~isempty(nameValuePairs)
                try
                    for j=length(nameValuePairs):-1:1
                        if j<length(nameValuePairs)
                            found=true;
                            switch lower(nameValuePairs{j})
                            case 'wfnames'
                                wfNames=nameValuePairs{j+1};
                            case 'wftables'
                                wfTables=nameValuePairs{j+1};
                            case 'wfdbindices'
                                wfDBIndices=nameValuePairs{j+1};
                            otherwise
                                found=false;
                            end
                            if found

                                nameValuePairs=...
                                msblks.internal.apps.mixedsignalanalyzer.Controller.removeNameValuePair(nameValuePairs,j);
                            end
                        end
                    end
                catch

                end
            end
        end

        function nameValuePairs=removeNameValuePair(nameValuePairs,index)
            if index>0&&index<length(nameValuePairs)

                if length(nameValuePairs)==2
                    nameValuePairs={};
                else
                    temp=[];
                    temp{length(nameValuePairs)-2}=[];
                    for k=1:index-1
                        temp{k}=nameValuePairs{k};
                    end
                    for k=index+2:length(nameValuePairs)
                        temp{k-2}=nameValuePairs{k};
                    end
                    nameValuePairs=temp;
                end
            end
        end
    end
end

