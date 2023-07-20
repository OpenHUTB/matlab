classdef Control<handle





    properties
Model
View
data
ImportDialogView
SimscapeModel
Panner
    end

    properties(Access=private)
        ListenerHandles=event.listener.empty;
OKbuttonListenerHandle
CancelButtonListenerHandle
ProgressDialogHandle
LogPath
BlockPath
    end

    methods
        function obj=Control(model,view)



            obj.Model=model;
            obj.View=view;
            obj.disableOptionsSection();
            obj.disableOutputSection();


            obj.ListenerHandles(1)=listener(obj.Model,'StatusChanged',@obj.modelStatusChanged);


            obj.ListenerHandles(end+1)=listener(obj.View.ImportButton,'ButtonPushed',@obj.importButtonPushed);
            obj.ListenerHandles(end+1)=listener(obj.View.Tree,'SelectionChanged',@obj.nodeChanged);
            obj.ListenerHandles(end+1)=listener(obj.View.NoOfPeriodsSpinner,'ValueChanged',@obj.noOfPeriodsUpdated);
            obj.ListenerHandles(end+1)=listener(obj.View.DCOffsetSpinner,'ValueChanged',@obj.dcOffsetUpdated);
            obj.ListenerHandles(end+1)=listener(obj.View.HarmonicOrderSpinner,'ValueChanged',@obj.harmonicOrderUpdated);
            obj.ListenerHandles(end+1)=listener(obj.View.SimTime,'ValueChanged',@obj.simTimeUpdated);
            obj.ListenerHandles(end+1)=listener(obj.View.ExportAsScript,'ValueChanged',@obj.ExportButtonPushed);
            obj.ListenerHandles(end+1)=listener(obj.View.ExportAsFunction,'ValueChanged',@obj.ExportButtonPushed);


            obj.Model.initializeAppStatus;
        end

        function modelStatusChanged(obj,~,~)


            if isvalid(obj.View)...
                &&isvalid(obj.View.StatusLabel)...
                &&~strcmp(obj.View.StatusLabel.Text,obj.Model.Status)
                obj.View.StatusLabel.Text=obj.Model.Status;
            end
        end

        function importButtonPushed(obj,~,~)


            progressDialogText=getString(message('physmod:ee:harmonicAnalyzer:CloseSimDataImportDialog'));
            obj.createProgressDialog(progressDialogText);


            obj.ImportDialogView=ee.internal.harmonics.UIFigureImportDialogView;
            obj.ListenerHandles(end+1)=listener(obj.ImportDialogView,'ImportDialogDataImported',@obj.importDialogOKButtonPushed);
            obj.ListenerHandles(end+1)=listener(obj.ImportDialogView,'ImportDialogCancelled',@obj.importDialogCancelButtonPushed);
        end

        function createProgressDialog(obj,progressDialogText)
            progressDialogTitle=getString(message('physmod:ee:harmonicAnalyzer:ProgressDialogTitle'));
            obj.ProgressDialogHandle=ee.internal.app.common.ui.AppComponentsView.showProgressDialog(obj.View,progressDialogTitle,progressDialogText);
        end

        function importDialogOKButtonPushed(obj,~,eventData)


            obj.initializeApp;
            simLogVariable=eventData.Payload;
            if~isempty(simLogVariable)
                obj.data.Simlog=evalin('base',simLogVariable);
                if~isempty(obj.data.Simlog)&&...
                    isequal(width(obj.data.Simlog),1)&&...
                    isvalid(obj.data.Simlog)
                    obj.SimscapeModel=ee.internal.harmonics.SimscapeModel(obj.data.Simlog.id);
                    obj.SimscapeModel.SimlogId=simLogVariable;
                    obj.Model.Simlog=obj.data.Simlog;
                    obj.Model.SimulationTime=obj.SimscapeModel.SimTime;
                    obj.populateUITree();
                    if~isempty(obj.Panner)
                        obj.Panner=[];
                    end
                else
                    errordlg(getString(message('physmod:ee:harmonicAnalyzer:SimlogNotLoaded')));
                end
            end
            delete(obj.OKbuttonListenerHandle);
            delete(obj.CancelButtonListenerHandle);
            obj.ProgressDialogHandle.close;
            delete(obj.ProgressDialogHandle);
            if~strcmp(obj.View.StatusLabel.Text,'')
                obj.View.StatusLabel.Text='';
            end
        end

        function importDialogCancelButtonPushed(obj,~,~)


            delete(obj.OKbuttonListenerHandle);
            delete(obj.CancelButtonListenerHandle);
            obj.ImportDialogView=[];
            obj.ProgressDialogHandle.close;
            delete(obj.ProgressDialogHandle);
        end

        function populateUITree(obj)


            obj.data.Simlog=obj.Model.Simlog;
            obj.data.Axes=obj.View.UIHarmonicAxes;
            if~isempty(obj.View.Tree.Children)
                obj.View.Tree.Children.delete;
            end
            set(obj.View.Tree,'UserData',obj.data);
            lPopulateTree(obj.View.Tree,obj.Model.Simlog);
            expand(obj.View.Tree);
        end

        function nodeChanged(obj,~,eventData)


            if obj.View.UIHarmonicAxes.Visible
                obj.clearHarmonicPlot;
            end
            if obj.View.UISignalAxes.Visible
                obj.clearSignalPlot;
            end
            if obj.View.PannedSignalAxes.Visible
                obj.clearPannedSignalPlot;
            end

            if~isempty(obj.Model.TimeInterval)
                obj.Model.TimeInterval=[];
            end

            if~isempty(eventData.SelectedNodes)
                obj.Model.TreeNodeselected=eventData.SelectedNodes;
                [obj.LogPath,phaseOfSignal,obj.BlockPath]=obj.Model.getPathFromTreeNode();
                obj.Model.VariableOption=phaseOfSignal;
                obj.Model.CurrentNode=node(obj.View.Tree.UserData.Simlog,obj.LogPath);

                nodeType=obj.Model.checkNodeType();
                if strcmp(nodeType,'Leaf Node')

                    obj.Model.SimulationTime=obj.Model.SignalTimeEndValue;


                    if~isequal(obj.Model.SignalTimeEndValue,0)

                        if isempty(obj.Model.SimulationTime)
                            obj.Model.SimulationTime=obj.Model.SignalTimeEndValue;
                        end
                        obj.plotSignal;
                        if~obj.View.NoOfPeriodsSpinner.Enabled
                            obj.enableOptionsSection;
                        end
                    end
                end
            end
        end

        function noOfPeriodsUpdated(obj,~,eventData)


            if eventData.EventData.Value>0
                obj.clearSignalPlot;
                obj.Model.SimulationTime=obj.Model.SignalTimeEndValue;
                obj.Model.NumberOfPeriods=eventData.EventData.Value;
                obj.plotSignal;
                obj.Panner.XSelected=obj.Model.TimeInterval;
                verticesToPan=[repmat(obj.Model.TimeInterval(1),2,1);repmat(obj.Model.TimeInterval(2),2,1)];
                obj.Panner.Polyshape.Shape.Vertices(:,1)=verticesToPan;
            else
                errordlg(getString(...
                message('physmod:ee:harmonicAnalyzer:NegativeNoOfPeriods')));
            end
        end

        function dcOffsetUpdated(obj,~,~)


            obj.AnalyzeHarmonics();
        end

        function harmonicOrderUpdated(obj,~,eventData)


            if eventData.EventData.Value>0
                obj.AnalyzeHarmonics();
            else
                errordlg(getString(...
                message('physmod:ee:harmonicAnalyzer:NegativeHarmonicOrder')));
            end
        end

        function simTimeUpdated(obj,~,eventData)


            newSimTimeValue=str2double(eventData.EventData.NewValue);
            if~isnan(newSimTimeValue)
                if newSimTimeValue<=obj.Model.SignalTimeEndValue
                    obj.Model.SimulationTime=newSimTimeValue;
                    obj.AnalyzeHarmonics();
                    obj.Panner.XSelected=obj.Model.TimeInterval;
                    notify(obj.Panner,'ValueChanged');
                else
                    errordlg(getString(message('physmod:ee:harmonicAnalyzer:SimulationTimeExceeded',num2str(obj.Model.SignalTimeEndValue))),...
                    getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');
                    obj.View.SimTime.Value=eventData.EventData.OldValue;
                end
            else
                errordlg(getString(message('physmod:ee:harmonicAnalyzer:UnSupportedFormat')),...
                getString(message('physmod:ee:harmonicAnalyzer:ErrorDialogTitle')),'modal');
                obj.View.SimTime.Value=eventData.EventData.OldValue;
            end
        end

        function AnalyzeHarmonics(obj)


            if isequal(obj.Model.CurrentNode.numChildren,0)


                obj.plotHarmonicSpectrum();
                if~obj.View.ExportButton.Enabled
                    obj.View.ExportButton.Enabled=true;
                end
            end
        end

        function ExportButtonPushed(obj,~,eventData)


            progressDialogText=getString(message('physmod:ee:harmonicAnalyzer:CloseFileNameDialog'));
            obj.createProgressDialog(progressDialogText);



            if eventData.EventData.NewValue
                switch eventData.Source.Text
                case getString(...
                    message('physmod:ee:harmonicAnalyzer:ExportAsScript'))
                    fileName='plotHarmonicSpectrum.m';
                    contentToExport=obj.Model.exportAsScript(obj.SimscapeModel.SimlogId);
                    obj.View.ExportAsScript.Value=false;
                case getString(...
                    message('physmod:ee:harmonicAnalyzer:ExportAsFunction'))
                    fileName='plotHarmonicSpectrumFunction.m';
                    contentToExport=obj.Model.exportAsFunction();
                    obj.View.ExportAsFunction.Value=false;
                end
                fileContents=sprintf("%s\n",contentToExport{:});

                fileNameDialogTitle=...
                getString(message('physmod:ee:harmonicAnalyzer:FileNameDialogTitle'));
                [fileName,filePath]=openSaveDialog(obj,fileNameDialogTitle,fileName);




                if~isscalar(fileName)&&...
                    ~isequal(fileName,0)
                    if~strcmp(filesep,'/')
                        filePath=strrep(filePath,'/',filesep);
                    end
                    completePath=strcat(filePath,fileName);
                    fileId=fopen(completePath,'w');
                    if~isequal(fileId,-1)
                        fwrite(fileId,fileContents);
                        fclose(fileId);
                        obj.Model.setExportCompleteStatus;
                    else
                        errordlg(getString(message('physmod:ee:harmonicAnalyzer:FileNotAccessible')));
                    end
                end
                obj.ProgressDialogHandle.close;
                delete(obj.ProgressDialogHandle);
            end
        end

        function[fileName,filePath]=openSaveDialog(~,fileNameDialogTitle,fileName)

            [fileName,filePath]=uiputfile('*.m',fileNameDialogTitle,fileName);
        end

        function HelpButtonPushed(~)


            web(fullfile(docroot,'physmod','sps','ref','harmonicanalyzer-app.html'));
        end

        function plotSignal(obj)

            [plotTime,plotValue]=obj.Model.computeSignalPlot();
            if~obj.View.UISignalAxes.Visible
                obj.View.UISignalAxes.Visible=1;
            end
            plot(obj.View.UISignalAxes,plotTime,plotValue);
            obj.AnalyzeHarmonics();
            if~isempty(obj.Model.TimeInterval)
                if~obj.View.PannedSignalAxes.Visible
                    obj.View.PannedSignalAxes.Visible=1;
                end
                if~isempty(obj.Panner)&&...
                    ~isequal(obj.Panner.XSelected,obj.Model.TimeInterval)

                    obj.Model.TimeInterval=obj.Panner.XSelected;
                end

                obj.createPanner();
                plot(obj.View.PannedSignalAxes,plotTime,plotValue,'.-');
            end
        end

        function createPanner(obj)


            obj.Panner=ee.internal.harmonics.Panner(obj.View.UISignalAxes,obj.Model.TimeInterval);
            obj.ListenerHandles(end+1)=addlistener(obj.Panner,'ValueChanged',@(src,evnt)obj.PannerIntervalChanged(src,evnt));
            notify(obj.Panner,'ValueChanged');
        end

        function PannerIntervalChanged(obj,~,~)


            obj.Model.SimulationTime=obj.Panner.XSelected(2);
            obj.View.SimTime.Value=num2str(obj.Panner.XSelected(2));
            obj.AnalyzeHarmonics();
            obj.View.PannedSignalAxes.XLim=obj.Model.TimeInterval;
            verticesToPan=[repmat(obj.Model.TimeInterval(1),2,1);repmat(obj.Model.TimeInterval(2),2,1)];
            obj.Panner.Polyshape.Shape.Vertices(:,1)=verticesToPan;
        end

        function plotHarmonicSpectrum(obj)


            obj.Model.NumberOfHarmonics=obj.View.HarmonicOrderSpinner.Value;
            obj.Model.DcOffset=obj.View.DCOffsetSpinner.Value;
            obj.Model.NumberOfPeriods=obj.View.NoOfPeriodsSpinner.Value;
            if~isempty(obj.View.SimTime.Value)&&...
                ~isequal(obj.Model.SimulationTime,obj.View.SimTime.Value)
                obj.Model.SimulationTime=str2double(obj.View.SimTime.Value);
            end
            obj.Model.calculateHarmonicSpectrum(obj.BlockPath);



            if~isempty(obj.Model.HarmonicOrder)&&...
                ~isempty(obj.Model.HarmonicMagnitude)&&...
                ~isempty(obj.Model.FundamentalFrequency)
                if~obj.View.UIHarmonicAxes.Visible
                    obj.View.UIHarmonicAxes.Visible=1;
                end
                obj.Model.plotHarmonicSpectrum(obj.View.UIHarmonicAxes);
                xlim(obj.View.UIHarmonicAxes,[1,obj.Model.NumberOfHarmonics]);
                xlim(obj.View.UIHarmonicAxes,'auto')
                ylim(obj.View.UIHarmonicAxes,'auto');
                axis(obj.View.UIHarmonicAxes,'tight');
            end
        end

        function clearHarmonicPlot(obj)


            obj.View.UIHarmonicAxes.Visible=0;
            if~isempty(obj.View.UIHarmonicAxes.Children)
                if~isempty(obj.View.UIHarmonicAxes.Children)
                    delete(obj.View.UIHarmonicAxes.Children);
                end
            end
        end

        function clearSignalPlot(obj)


            obj.View.UISignalAxes.Visible=0;
            if~isempty(obj.View.UISignalAxes.Children)
                delete(obj.View.UISignalAxes.Children);
            end
        end

        function clearPannedSignalPlot(obj)


            obj.View.PannedSignalAxes.Visible=0;
            if~isempty(obj.View.PannedSignalAxes.Children)
                delete(obj.View.PannedSignalAxes.Children);
            end
        end

        function initializeToolstripControls(obj)


            obj.View.NoOfPeriodsSpinner.Value=10;
            obj.View.DCOffsetSpinner.Value=0;
            obj.View.HarmonicOrderSpinner.Value=20;
        end

        function initializeApp(obj)



            if obj.View.NoOfPeriodsSpinner.Enabled
                obj.disableOptionsSection;
            end
            if obj.View.ExportButton.Enabled
                obj.disableOutputSection;
            end
            if obj.View.UISignalAxes.Visible
                obj.clearSignalPlot;
            end
            if obj.View.UIHarmonicAxes.Visible
                obj.clearHarmonicPlot;
            end
            if obj.View.PannedSignalAxes.Visible
                obj.clearPannedSignalPlot;
            end
            obj.initializeToolstripControls;
        end

        function disableOptionsSection(obj)


            obj.View.NoOfPeriodsSpinner.Enabled=false;
            obj.View.DCOffsetSpinner.Enabled=false;
            obj.View.HarmonicOrderSpinner.Enabled=false;
            obj.View.NoOfPeriodsLabel.Enabled=false;
            obj.View.DCOffsetLabel.Enabled=false;
            obj.View.HarmonicOrderLabel.Enabled=false;
            obj.View.SimTime.Enabled=false;
            obj.View.SimTimeLabel.Enabled=false;
        end

        function disableOutputSection(obj)


            obj.View.ExportButton.Enabled=false;
        end

        function enableOptionsSection(obj)


            obj.View.NoOfPeriodsSpinner.Enabled=true;
            obj.View.DCOffsetSpinner.Enabled=true;
            obj.View.HarmonicOrderSpinner.Enabled=true;
            obj.View.NoOfPeriodsLabel.Enabled=true;
            obj.View.DCOffsetLabel.Enabled=true;
            obj.View.HarmonicOrderLabel.Enabled=true;
            obj.View.SimTime.Enabled=true;
            obj.View.SimTimeLabel.Enabled=true;
        end

    end
end


function lPopulateTree(parent,simlog,varargin)


    if~isempty(varargin)
        nodeId=varargin{:};
        treeNode=uitreenode('Text',nodeId,'Parent',parent,'UserData',nodeId);



    else
        treeNode=uitreenode('Text',simlog.getName,'Parent',parent,'UserData',simlog.id);
    end
    listOfChildIds=simlog.childIds;


    for childIdx=1:numel(listOfChildIds)
        childNode=child(simlog,listOfChildIds{childIdx});
        childNodeDimensionVector=childNode.series.dimension;
        if childNodeDimensionVector(2)

            if~isequal(childNodeDimensionVector(2),1)&&isempty(childNode.childIds)


                for dimensionIdx=1:childNodeDimensionVector(2)
                    nodeId=strcat(...
                    childNode.getName,'(',num2str(dimensionIdx),')');

                    lPopulateTree(treeNode,childNode,nodeId);
                end

            else
                lPopulateTree(treeNode,child(simlog,listOfChildIds{childIdx}));
            end

        else
            lPopulateTree(treeNode,child(simlog,listOfChildIds{childIdx}));
        end
    end
end
