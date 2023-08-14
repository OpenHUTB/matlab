classdef ImportController<handle




    properties(Access=private)
Model
WorkspaceBrowser
    end

    events

UpdatePlot
CalculateAxes

OpenImportDialog
SetDialogImportButtonEnable
CloseImportDialog

ClearStatusBar

UpdateTable
UpdateTableSelection

UpdateToolstrip
    end

    methods(Hidden)

        function this=ImportController(model)
            this.Model=model;
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            addlistener(dialog,"ImportSignalsOverwriteConfirmed",@(~,args)this.cb_ImportSignals(false,false,args.Data.figure));
        end


        function cb_OpenImportDialog(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            this.notify("OpenImportDialog");
        end

        function cb_CreateWorkspaceBrowser(this,importFigure)
            import matlab.internal.datatools.uicomponents.uiworkspacebrowser.UIWorkspaceBrowser;
            gridLayout=uigridlayout("Parent",importFigure,"ColumnWidth",{'1x'},"RowHeight",{'1x'});
            gridLayout.Padding(2)=50;
            this.WorkspaceBrowser=UIWorkspaceBrowser("Parent",gridLayout,"VisibleColumns",["Name","Size","Class"],...
            "Workspace",wavelettfanalyzer.internal.filteredworkspace.FilteredWorkspace());
            this.WorkspaceBrowser.SelectionChangedCallbackFcn=@(args)this.cb_WorkspaceSelectionChanged(args);
        end

        function cb_ImportSignals(this,fromCommandLine,confirm,varargin)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();

            if~fromCommandLine
                variables=this.getWorkspaceBrowserSelection();
                figure=varargin{1};

                datas=containers.Map;
                for idx=1:length(variables)
                    data=evalin("base",variables(idx));
                    datas(variables(idx))=data;
                end
            else
                if isempty(varargin{2})
                    name="Signal";
                else
                    name=varargin{2};
                end
                variables=string(name);
                datas=containers.Map;
                datas(variables(1))=varargin{1};
            end

            import=true;

            if~fromCommandLine
                [import,errorMessage]=this.Model.checkTimetables(variables,datas);
                if~import
                    this.alertTimetableInvalid(figure,errorMessage);
                end
            end

            if import
                exists=this.Model.checkSignalsExist(variables,datas);
                if confirm&&exists
                    this.confirmOverwriteData(figure);
                else
                    if~fromCommandLine
                        this.cb_CloseImportDialog();
                    end

                    if this.Model.getUseBackgroundPool()
                        bp=backgroundPool;


                        for idx=1:length(variables)-1
                            [data,info]=this.Model.importSignal(variables(idx),datas(variables(idx)),false);
                            this.Model.storeCWTInfo(info.name,info);
                            this.Model.storeSignal(info.name,data);
                        end

                        bkgpcwt=parfeval(bp,@()this.Model.importSignal(variables(end),datas(variables(end)),true),2);
                        result=afterEach(bkgpcwt,@(varargin)this.calculateScalogramCompleted(varargin{:}),0);
                        afterAll(result,@()this.importSignalsComplete(variables,datas),0);
                    else

                        for idx=1:length(variables)
                            [data,info]=this.Model.importSignal(variables(idx),datas(variables(idx)),false);
                            this.Model.storeCWTInfo(info.name,info);
                            this.Model.storeSignal(info.name,data);
                        end

                        [data,info]=this.Model.importSignal(variables(end),datas(variables(end)),true);
                        this.calculateScalogramCompleted(data,info);
                        this.importSignalsComplete(variables,datas);
                    end
                end
            else
                busyOverlay.hide();
            end
        end

        function cb_CloseImportDialog(this)
            this.deleteWorkspaceBrowser();
            this.notify("CloseImportDialog");
        end

        function cb_WorkspaceSelectionChanged(this,args)
            if~isempty(args.SelectedVariables)
                workspaceSelectionChangedEventData.enabled=true;
                this.notify("SetDialogImportButtonEnable",wavelettfanalyzer.internal.EventData(workspaceSelectionChangedEventData));
            else
                workspaceSelectionChangedEventData.enabled=false;
                this.notify("SetDialogImportButtonEnable",wavelettfanalyzer.internal.EventData(workspaceSelectionChangedEventData));
            end
        end
    end

    methods(Access=protected)

        function deleteWorkspaceBrowser(this)
            this.WorkspaceBrowser.delete();
            this.WorkspaceBrowser=[];
        end

        function variables=getWorkspaceBrowserSelection(this)
            variables=this.WorkspaceBrowser.SelectedVariables;
        end

        function confirmOverwriteData(this,dialogFigure)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            dialogTitle=string(getString(message("wavelet_tfanalyzer:dialog:importDataExistsDialogTitle")));
            dialogMessage=string(getString(message("wavelet_tfanalyzer:dialog:importDataExistsDialogMessage")));
            dialog.showConfirm("importSignalsOverwrite",dialogTitle,dialogMessage,dialogFigure);
        end

        function alertTimetableInvalid(this,dialogFigure,errorMessage)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            dialogTitle=string(getString(message("wavelet_tfanalyzer:dialog:timetableErrorDialogTitle")));
            dialogMessage=errorMessage;
            dialog.showAlert(dialogTitle,dialogMessage,dialogFigure);
        end

        function calculateScalogramCompleted(this,varargin)
            data=varargin{1};
            info=varargin{2};
            name=info.name;
            this.Model.storeCWTInfo(name,info);
            this.Model.storeSignal(name,data);
            this.calculateAxes(info);
        end

        function importSignalsComplete(this,variables,datas)
            for idx=1:length(variables)
                name=variables(idx);
                data=datas(name);
                if istimetable(data)
                    variablenames=data.Properties.VariableNames;
                    name=name+"_"+variablenames{1};
                end
                this.updateTable(name);
            end
            this.Model.setCurrentSignalName(name);
            this.updateTableSelection(name);
            this.updateToolstrip();
            this.updatePlot();
        end

        function updateTable(this,name)
            updateTableEventData.tableData=this.Model.getTableData(name);
            this.notify("UpdateTable",wavelettfanalyzer.internal.EventData(updateTableEventData));
        end

        function calculateAxes(this,info)
            updateAxesEventData=info;
            this.notify("CalculateAxes",wavelettfanalyzer.internal.EventData(updateAxesEventData));
        end

        function updatePlot(this)
            updateAxesEventData=this.Model.getUpdatePlotData();
            this.notify("UpdatePlot",wavelettfanalyzer.internal.EventData(updateAxesEventData));
        end

        function updateToolstrip(this)
            updateToolstripEventData=this.Model.getToolstripData();
            this.notify("UpdateToolstrip",wavelettfanalyzer.internal.EventData(updateToolstripEventData));
        end

        function updateTableSelection(this,name)
            updateTableEventData.name=name;
            this.notify("UpdateTableSelection",wavelettfanalyzer.internal.EventData(updateTableEventData));
        end
    end

end
