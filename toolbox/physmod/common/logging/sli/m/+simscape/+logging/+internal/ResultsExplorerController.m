





classdef ResultsExplorerController<handle

    properties


Model



View


TreeView


        Listeners={};
    end

    properties(Access=private)
Options
NodesToPlot
PathsToPlot
LabelsToPlot
    end

    methods

        function this=ResultsExplorerController(resultsExplorerModel,resultsExplorerView)

            import simscape.logging.internal.ResultsExplorerRegistry
            import simscape.logging.internal.ResultsExplorerLinkManager

            this.Model=resultsExplorerModel;
            this.View=resultsExplorerView;
            this.TreeView=simscape.ui.internal.Tree(Parent=gobjects(0,0));


            this.addListeners();



            this.initializeViewComponent;

            ResultsExplorerRegistry.register(this);
            ResultsExplorerLinkManager.link(this);
        end

        function unregister(this,varargin)
            import simscape.logging.internal.ResultsExplorerRegistry
            import simscape.logging.internal.ResultsExplorerLinkManager


            this.Listeners={};


            ResultsExplorerLinkManager.unlink(this);


            ResultsExplorerRegistry.unregister(this);
        end

        function refresh(this,node,p,varName)


            lSetBusy(this.View,true);
            c=onCleanup(@()lSetBusy(this.View,false));
            function lSetBusy(v,val)
                v.Busy=val;
            end


            this.View.bringToFront();
            rootPath={uint32(1)};


            if isempty(p)
                selectedPaths=this.TreeView.SelectedPaths;
            else
                selectedPaths={[rootPath,p]};
            end


            if isempty(selectedPaths)
                selectedPaths={rootPath};
            end


            isNodeChanging=~builtin('isequal',this.Model.Node,node);
            this.Model.updateMdlNode(node,varName);


            if isNodeChanging
                newOptions=simscape.logging.internal.defaultNodeOptions(...
                this.Model.Node);
                this.View.setTitle(this.Model.Node.id);
                this.Options.time.start=newOptions.time.start;
                this.Options.time.stop=newOptions.time.stop;
                startTime=num2str(this.Options.time.start);
                stopTime=num2str(this.Options.time.stop);
                this.View.setTimeAxesLimits(startTime,stopTime);
                this.loadDataInView();
            end


            this.TreeView.SelectedPaths=selectedPaths;
            if isempty(this.TreeView.SelectedPaths)
                this.TreeView.SelectedPaths={rootPath};
            end
        end

    end

    methods(Access=private)

        function addListeners(this)

            eventCallbacks={{'ImportButtonPushed',@this.importButtonPushedCallback},...
            {'SaveButtonPushed',@this.saveButtonPushedCallback},...
            {'LinkUnlinkButtonPushed',@this.linkUnlinkButtonPushedCallback},...
            {'MarkerSelection',@this.markerSelectionCallback},...
            {'LayoutSelection',@this.layoutSelectionCallback},...
            {'UnitSelection',@this.unitSelectionCallback},...
            {'PlotTypeSelection',@this.plotTypeSelectionCallback},...
            {'LegendSelection',@this.legendSelectionCallback},...
            {'LinkAxesButtonToggled',@this.linkButtonToggledCallback},...
            {'LimitTimeAxesValueChanged',@this.limitTimeValueChangedCallback},...
            {'ExportButtonPushed',@this.exportButtonPushedCallback}...
            ,{'DescriptionLinkClicked',@this.descLinkClickedCallback},...
            {'SourceLinkClicked',@this.sourceLinkClickedCallback},...
            {'ViewClosed',@this.unregister}};

            this.Listeners=cellfun(@(p)event.listener(this.View,p{1:end}),eventCallbacks,...
            'UniformOutput',false);

            this.Listeners{end+1}=...
            event.listener(this.TreeView,"SelectionChanged",...
            @this.treeNodeSelectionCallback);

            import simscape.logging.internal.ResultsExplorerLinkManager;
            this.Listeners{end+1}=...
            ResultsExplorerLinkManager.linkListener(@this.linkChangedCallback);
        end

        function initializeViewComponent(this,~,~)
            this.View.createGUIComponents();


            lSetBusy(this.View,true);
            c=onCleanup(@()lSetBusy(this.View,false));
            function lSetBusy(v,val)
                v.Busy=val;
            end


            this.View.setTitle(this.Model.Node.id);
            this.View.setAppVisible();

            this.loadDataInView();
            this.setDefaultOptions();
        end

        function loadDataInView(this,~,~)


            this.TreeView.NodeProvider=...
            simscape.logging.internal.SimlogNodeProvider(...
            this.Model.Node);
            this.TreeView.expand();
            drawnow;


            this.View.setUITreeParent(this.TreeView);


            nodeStats=this.getAppNodeStatistics;
            nodeStats.UserData=getNodeStatistics(this.Model.Node);
            nodeStatistics=simscape.logging.internal.NodeStatistics(...
            this.Model.Node,{this.Model.Node},nodeStats.UserData);
            nodeStatsValues=nodeStatistics.getNodeStatisticsValues();
            this.View.setRootNodeStatsValue(nodeStatsValues);

        end

        function setDefaultOptions(this,~,~)

            this.Options=simscape.logging.internal.defaultNodeOptions(...
            this.Model.Node);
            startTime=num2str(this.Options.time.start);
            stopTime=num2str(this.Options.time.stop);
            this.View.setTimeAxesLimits(startTime,stopTime);
            this.View.setDefaultOptions(this.Options);
            this.setDefaultNodeSelection;
        end

        function setDefaultNodeSelection(this,~,~)
            if~isempty(this.Model.Path)
                this.TreeView.SelectedPaths={[{uint32(1)},this.Model.Path]};
            end
        end

        function p=selectedPaths(this)
            rootId={this.Model.Node.id()};
            p=cellfun(@(p)[rootId,p(2:end)],...
            this.TreeView.SelectedPaths,'UniformOutput',false);
        end

        function treeNodeSelectionCallback(this,~,~)

            [this.NodesToPlot,this.PathsToPlot,this.LabelsToPlot]=...
            simscape.logging.internal.getExplorerSelectedNodes(this.selectedPaths(),...
            this.Model.Node);


            [~,stopTime]=this.View.getTimeAxesLimits;
            if(~isequal(str2double(stopTime),this.Options.time.stop))
                this.Options=simscape.logging.internal.getNodeOptions(...
                this.View.getAppHandle);
            end


            numNodesToPlot=simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,...
            this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),this.Model.Node);


            this.View.enablePlotOptions;
            this.View.enableAxesControlOptions;


            exportButton=this.View.getExportButton;
            if(numNodesToPlot~=0)
                exportButton.Enabled=true;
            else
                exportButton.Enabled=false;
            end


            this.updateNodeStatistics(this.Model.Node);
        end

        function importButtonPushedCallback(this,~,~)

            if(~isstring(this.Model.VarName))
                defaultName=string(this.Model.VarName);
            else
                defaultName=this.Model.VarName;
            end
            varName=inputdlg({...
            getMessageFromCatalog('SpecifyImportDataName')},...
            getMessageFromCatalog('ImportData',this.Model.Node.id),...
            [1,50],defaultName);

            errorDialogTitle=getMessageFromCatalog('ImportDataError');
            errorString=getMessageFromCatalog('NoImportData');

            if~isempty(varName)
                varName=varName{1};
                if~isvarname(varName)
                    errorCause=getMessageFromCatalog('InvalidName',varName);
                    str=sprintf('%s\n %s',errorString,errorCause);
                    errordlg(str,errorDialogTitle,'modal');
                    return;
                end






                logVar='';
                if isvarname(this.Model.Node(1).getSource())&&bdIsLoaded(...
                    this.Model.Node.id)&&strcmp(get_param(this.Model.Node.id,...
                    'ReturnWorkspaceOutputs'),'on')
                    out=get_param(this.Model.Node.id,'ReturnWorkspaceOutputsName');
                    if evalin('base','exist(''out'') == 1')
                        output=evalin('base',out);
                        logVar=output.get(varName);
                    end
                else
                    if~evalin('base',sprintf('exist(''%s'')',varName))
                        errorCause=getMessageFromCatalog('NoVariable',...
                        varName);
                        str=sprintf('%s\n %s',errorString,errorCause);
                        errordlg(str,errorDialogTitle,'modal');
                        return;
                    end
                    logVar=evalin('base',varName);
                end

                if isempty(logVar)
                    logVar=evalin('base',varName);
                end

                if~isa(logVar,'simscape.logging.Node')
                    errorCause=getMessageFromCatalog('NotSimscapeVariable',...
                    varName);
                    str=sprintf('%s\n %s',errorString,errorCause);
                    errordlg(str,errorDialogTitle,'modal');
                    return;
                else
                    this.refresh(logVar,{},varName);
                end
            end
        end

        function saveButtonPushedCallback(this,~,~)

            if(~isstring(this.Model.VarName))
                defaultName=string(this.Model.VarName);
            else
                defaultName=this.Model.VarName;
            end


            saveDataName=inputdlg({...
            getMessageFromCatalog('SpecifySaveDataName')},...
            getMessageFromCatalog('ExportData',this.Model.Node.id),...
            [1,50],defaultName);

            errorDialogTitle=getMessageFromCatalog('ExportDataError');
            errorString=getMessageFromCatalog('NoExportData');

            if(~isempty(saveDataName))
                if(~isvarname(saveDataName{:}))
                    errorCause=getMessageFromCatalog('InvalidName',...
                    saveDataName{:});
                    str=sprintf('%s\n %s',errorString,errorCause);
                    errordlg(str,errorDialogTitle,'modal');
                    return;
                else
                    assignin('base',saveDataName{:},this.Model.Node);
                end
            end
            this.View.getAppHandle.bringToFront();
        end

        function linkUnlinkButtonPushedCallback(this,~,~)
            import simscape.logging.internal.ResultsExplorerLinkManager
            isLinked=this.View.getLinkedVal;
            if(isLinked)
                ResultsExplorerLinkManager.unlink(this);
            else
                ResultsExplorerLinkManager.link(this);
            end
        end

        function linkChangedCallback(this,varargin)
            import simscape.logging.internal.ResultsExplorerLinkManager;
            isLinked=isequal(ResultsExplorerLinkManager.linkedInstance(),this);
            this.View.setLinkUnlinkButton(isLinked);
        end

        function markerSelectionCallback(this,~,~)

            plotOptions=this.View.getPlotOptions;
            this.Options.marker=plotOptions.marker;


            simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);
        end

        function layoutSelectionCallback(this,~,~)

            plotOptions=this.View.getPlotOptions;
            this.Options.layout=plotOptions.layout;


            simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);
        end

        function unitSelectionCallback(this,~,~)

            plotOptions=this.View.getPlotOptions;
            this.Options.unit=plotOptions.unit;


            simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);
        end

        function plotTypeSelectionCallback(this,~,~)

            plotOptions=this.View.getPlotOptions;
            this.Options.plotType=plotOptions.plotType;


            simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);
        end

        function legendSelectionCallback(this,~,~)

            plotOptions=this.View.getPlotOptions;
            this.Options.legend=plotOptions.legend;


            simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);
        end

        function linkButtonToggledCallback(this,~,~)

            this.View.setLinkTimeAxesValue;


            this.Options.link=this.View.getLinkTimeAxesValue;


            simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);
        end

        function limitTimeValueChangedCallback(this,~,~)

            errorDlgTitle=getMessageFromCatalog('OptionsError');
            [startTime,stopTime]=this.View.getLimitTimeAxesValues;


            if~isnumeric(startTime)||...
                isempty(startTime)||isnan(startTime)
                errordlg(getMessageFromCatalog('InvalidStartTime'),...
                errorDlgTitle);
                return;
            end


            if~isnumeric(stopTime)||...
                isempty(stopTime)||isnan(stopTime)
                errordlg(getMessageFromCatalog('InvalidStopTime'),...
                errorDlgTitle);
                return;
            end


            if stopTime<=startTime
                errordlg(getMessageFromCatalog('IncorrectStopTime'),...
                errorDlgTitle);
                return;
            end


            this.Options.time.start=startTime;
            this.Options.time.stop=stopTime;


            simscape.logging.internal.plotNodeFigure(...
            this.getFigureHandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);
        end

        function exportButtonPushedCallback(this,~,~)

            newFigurehandle=figure;
            this.Options.isExtracted=true;


            simscape.logging.internal.plotNodeFigure(...
            newFigurehandle,this.NodesToPlot,this.PathsToPlot,...
            this.LabelsToPlot,this.Options,this.selectedPaths(),...
            this.Model.Node);

            this.Options.isExtracted=false;
        end

        function descLinkClickedCallback(this,~,~)
            import simscape.logging.internal.*;
            selectedNodes=this.getValidSelectedNodes;
            if(~isempty(selectedNodes)&&selectedNodes.hasSource)
                nodeStatisticsCallback(NodeStatsLink.Description,...
                [],selectedNodes);
            end
        end

        function sourceLinkClickedCallback(this,~,~)
            import simscape.logging.internal.*;



            selectedNodes=this.getValidSelectedNodes;

            key='ZeroCrossingLocation';
            if selectedNodes.hasTag(key)
                nodeStatisticsCallback(NodeStatsLink.ZeroCrossingLocation,...
                [],selectedNodes);
            elseif(~isempty(selectedNodes)&&selectedNodes.hasSource)
                source=selectedNodes.getSource;
                nodeStatisticsCallback(NodeStatsLink.Source,source);
            end
        end

        function figHandle=getFigureHandle(this,~,~)
            apphandle=this.View.getAppHandle;
            figHandle=apphandle.getDocuments{1}.Figure;
        end

        function nodeStats=getAppNodeStatistics(this,~,~)
            apphandle=this.View.getAppHandle;
            nodeStats=apphandle.getPanels{2}.Figure;
        end

        function updateNodeStatistics(this,simlog,~)
            nodeStats=this.getAppNodeStatistics;
            nodeStatistics=simscape.logging.internal.NodeStatistics(...
            simlog,this.NodesToPlot,nodeStats.UserData);
            nodeStatsValues=nodeStatistics.getNodeStatisticsValues();
            selectedPaths=this.selectedPaths();

            if(numel(selectedPaths)>1)
                this.View.setMultiNodeStatsValue(nodeStatsValues);
            elseif isempty(selectedPaths)||isscalar(selectedPaths{1})
                this.View.setRootNodeStatsValue(nodeStatsValues);
            else
                this.View.setNodeStatsValue(nodeStatsValues);
            end
        end

        function[selectedNodes]=getValidSelectedNodes(this,~,~)
            if(isempty(this.NodesToPlot))
                selectedNodes=this.Model.Node;
                return;
            else
                if(numel(this.NodesToPlot)>1)
                    selectedNodes=this.NodesToPlot{:};
                else
                    selectedNodes=this.NodesToPlot{1};
                end
                [this.NodesToPlot,this.PathsToPlot,this.LabelsToPlot]=...
                simscape.logging.internal.getExplorerSelectedNodes(...
                this.selectedPaths(),this.Model.Node);
            end
        end
    end

end


