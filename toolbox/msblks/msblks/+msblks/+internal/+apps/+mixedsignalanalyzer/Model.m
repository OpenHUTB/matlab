classdef Model<handle




    properties(Hidden)
Name
        IsChanged=false;
MixedSignalAnalyzerTool
MixedSignalAnalysis

Database
Database_Type

figUpdateSession
figWorkspaceVariable

        isAppInitializing=true;
    end

    properties(Constant,Access=private)
        DefaultName=getString(message('msblks:mixedsignalanalyzer:DefaultMixedSignalAnalysisName'));
    end

    properties(Access=private)
        sessionMatFilePath=''
        genericCsvFilePath=''
        inputFilePath=''
    end

    properties
View
    end

    methods

        function obj=Model(varargin)
            if nargin==1&&isa(varargin{1},'msblks.internal.apps.mixedsignalanalyzer.MixedSignalAnalyzerTool')
                obj.MixedSignalAnalyzerTool=varargin{1};
            end
            defaultModel(obj)
            obj.MixedSignalAnalysis=mixedSignalAnalysis([]);
        end

        function readCadenceData(obj,cadenceMatfile,pathname,updateRequests)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingCadenceData')));
                if isstruct(pathname)

                    database=msblks.internal.apps.mixedsignalanalyzer.dataCadence(pathname,cadenceMatfile);
                    pathname='structs_from_readAdeInfoDialog';
                else

                    database=msblks.internal.apps.mixedsignalanalyzer.dataCadence([pathname,cadenceMatfile],cadenceMatfile);
                end
                isBadCadenceAdeInfoFile=islogical(database.db);
                if~isempty(database)&&~isBadCadenceAdeInfoFile
                    database=database.getGenericDB();
                    if~isempty(database)

                        if isempty(obj.Database)
                            obj.Database=database;
                            obj.Database_Type='Cadence';
                        else
                            obj.Database=[obj.Database,database];
                            obj.Database_Type=[obj.Database_Type,{'Cadence'}];
                        end
                    end
                end
                if isempty(database)||isBadCadenceAdeInfoFile
                    obj.MixedSignalAnalyzerTool.setStatus('');
                    return;
                end
                if isempty(updateRequests)

                    obj.View.addDatabaseToDataTree(pathname,cadenceMatfile,database,[]);
                    obj.View.addPlotOptionsTable(pathname,cadenceMatfile,database,[]);
                else

                    obj.performRequestedUpdates(1,pathname,cadenceMatfile,database,updateRequests);
                    obj.View.updateTrendCharts();
                end
                obj.IsChanged=true;
                obj.setMainTitle(obj.Name);
                drawnow limitrate;
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
    end

    methods(Hidden)
        function setMainTitle(obj,designName)
            if~isempty(obj.View)
                mainTitle=strcat({getString(message('msblks:mixedsignalanalyzer:MixedSignalAnalyzerText'))},{' - '},{designName});
                if obj.IsChanged
                    mainTitle=strcat(mainTitle,{getString(message('msblks:mixedsignalanalyzer:DirtyMixedSignalAnalysisFlag'))});
                end
                obj.View.Toolstrip.appContainer.Title=mainTitle{1};
            end
        end

        function setDefaultMixedSignalAnalysis(obj)
            obj.MixedSignalAnalysis=mixedSignalAnalysis([]);
            obj.MixedSignalAnalysis.View=obj.View;
            if~isempty(obj.View)
                obj.View.defaultLayoutAction();
            end
        end

        function defaultModel(obj)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyInitializingApp')));
                if~isempty(obj.View)
                    obj.View.PlotsCount=0;
                end
                obj.MixedSignalAnalyzerTool.clearMixedSignalAnalyzer(false);
                obj.Name=obj.DefaultName;
                obj.setDefaultMixedSignalAnalysis();
                obj.IsChanged=false;
                obj.setMainTitle(obj.Name);
                obj.sessionMatFilePath='';
                obj.enableNewSaveUpdateToolstripButtons();
                if~isempty(obj.View)&&isvalid(obj.View)
                    obj.View.enableFilterActions(false);
                    obj.View.enableAnalysisActions(false);
                    obj.View.enableMetricsActions(false);
                    obj.View.clearPlotOptions();
                end
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end

        function success=initialModel(obj,matFiles)
            success=false;
            if isempty(matFiles)
                return;
            end

            fileCount=length(matFiles);
            names{fileCount}=[];
            paths{fileCount}=[];
            for i=1:fileCount
                arg=matFiles{i};
                if ischar(arg)

                    [~,~,ext]=fileparts(arg);
                    if isempty(ext)
                        filename=[arg,'.mat'];
                    else
                        filename=arg;
                    end

                    [path,name,ext]=fileparts(filename);
                    names{i}=[name,ext];
                    if isempty(path)
                        paths{i}=path;
                    else
                        paths{i}=filename(1:end-length(name)-length(ext));
                    end
                elseif isa(matFiles{i},'table')
                    names{i}=matFiles{i};
                    paths{i}=[];
                else
                    names{i}=[];
                    paths{i}=[];
                end
            end







            for i=1:fileCount
                try
                    if isa(names{i},'table')||endsWith(names{i},'.csv')||endsWith(names{i},'.xlsx')
                        continue;
                    end

                    matfilepath=[paths{i},names{i}];
                    temp=load(matfilepath,'-mat');
                    if obj.isValidMixedSignalAnalysisSessionFile(temp)&&i>1

                        msg=message('msblks:mixedsignalanalyzer:WrongOrderMixedSignalAnalyzerFile',matfilepath);
                        error(msg);
                    end
                    if~obj.isValidMixedSignalAnalysisSessionFile(temp)&&~obj.isValidCadenceMatFile(temp)

                        msg=message('msblks:mixedsignalanalyzer:BadMixedSignalAnalyzerFile',matfilepath);
                        error(msg);
                    end
                catch err
                    ttl=message('msblks:mixedsignalanalyzer:LoadFailed');
                    h=errordlg(err.message,getString(ttl),'modal');
                    uiwait(h)
                    return;
                end
            end

            obj.Name=obj.DefaultName;
            obj.setMainTitle(obj.Name);
            success=obj.readSessionData(names,paths);
            obj.enableNewSaveUpdateToolstripButtons();
        end
    end

    methods(Hidden)
        function workspaceObject=getNamedWorkspaceObject(obj,name)
            workspaceObject=[];
            if isempty(name)||~ischar(name)
                return;
            end
            workspaceVariables=evalin('base','who');
            if~isempty(workspaceVariables)
                for i=1:length(workspaceVariables)
                    if strcmp(workspaceVariables{i},name)
                        workspaceObject=evalin('base',workspaceVariables{i});
                        return;
                    end
                end
            end
        end
        function workspaceObjectName=getWorkspaceObjectName(obj,workspaceObject)
            workspaceObjectName='';
            if isempty(workspaceObject)
                return;
            end
            workspaceStruct=table2struct(workspaceObject);
            workspaceVariables=evalin('base','who');
            if~isempty(workspaceVariables)
                for i=1:length(workspaceVariables)
                    workspaceObject2=evalin('base',workspaceVariables{i});
                    if isa(workspaceObject2,'table')
                        workspaceStruct2=table2struct(workspaceObject2);
                        if isequaln(workspaceStruct2,workspaceStruct)
                            workspaceObjectName=workspaceVariables{i};
                            return;
                        end
                    end
                end
            end
        end
        function getWorkspaceObject(obj,forImportOrUpdate)
            workspaceVariables=evalin('base','who');
            if~isempty(workspaceVariables)
                for i=length(workspaceVariables):-1:1
                    if~isa(evalin('base',workspaceVariables{i}),'table')
                        workspaceVariables(i)=[];
                    end
                end
            end
            title=['Select Base Workspace Variable For ',forImportOrUpdate];
            if isempty(workspaceVariables)

                appFig=obj.View.Toolstrip.appContainer;
                if~isempty(appFig)&&isvalid(appFig)
                    uiconfirm(appFig,'No base workspace variables found matching MATLAB type "table"',title,...
                    'Options',{'OK'});
                end
                obj.deleteDialogWorkspaceVariable();
                return;
            end


            obj.figWorkspaceVariable=uifigure('Name',title,'Tag','BaseWorkspaceDialog');
            figLayout=uigridlayout(obj.figWorkspaceVariable,...
            'RowHeight',{'1x',30,'1x',20},...
            'ColumnWidth',{60,'1x',60,60},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            dropdown=uidropdown(figLayout,...
            'Items',workspaceVariables,'Value',workspaceVariables{1},...
            'Tag','workspace variable dropdown');
            okButton=uibutton('Parent',figLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:OkText')),...
            'Tag','workspace variable okButton');
            cancelButton=uibutton('Parent',figLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:CancelText')),...
            'Tag','workspace variable cancelButton');
            dropdown.Layout.Row=2;
            okButton.Layout.Row=4;
            cancelButton.Layout.Row=4;
            dropdown.Layout.Column=2;
            okButton.Layout.Column=3;
            cancelButton.Layout.Column=4;



            okButton.ButtonPushedFcn=@(h,e)obj.applyAndDeleteWorkspaceVariableDialog(dropdown.Value,forImportOrUpdate);
            cancelButton.ButtonPushedFcn=@obj.deleteDialogWorkspaceVariable;
        end
        function deleteDialogWorkspaceVariable(obj,src,event)
            close(obj.figWorkspaceVariable);
            obj.figWorkspaceVariable=[];
        end
        function applyAndDeleteWorkspaceVariableDialog(obj,workspaceObjectName,forImportOrUpdate)
            workspaceObject=evalin('base',workspaceObjectName);
            if isa(workspaceObject,'table')
                if strcmpi(forImportOrUpdate,'Import')
                    obj.readCsvData(workspaceObject,workspaceObjectName,[]);
                elseif strcmpi(forImportOrUpdate,'Update')
                    obj.updateCsvData(workspaceObject,workspaceObjectName);
                end
            end
            obj.deleteDialogWorkspaceVariable;
        end

        function isContinue=isContinueWithSessionFile(obj,matfilepath)

            isContinue=false;

            yes=getString(message('msblks:mixedsignalanalyzer:IsSessionFilePromptYes'));
            cancel=getString(message('msblks:mixedsignalanalyzer:IsSessionFilePromptCancel'));

            if~isempty(obj.MixedSignalAnalysis)&&~isempty(obj.View)&&~isempty(obj.View.Toolstrip)
                appFig=obj.View.Toolstrip.appContainer;
                msg=getString(message('msblks:mixedsignalanalyzer:IsSessionFilePromptQuestion',matfilepath));
                title=getString(message('msblks:mixedsignalanalyzer:IsSessionFilePromptTitle'));
                if~isempty(appFig)&&isvalid(appFig)
                    selection=uiconfirm(appFig,msg,title,...
                    'Options',{yes,cancel},...
                    'DefaultOption',1,'CancelOption',2);
                end
            else
                selection=cancel;
            end

            switch selection
            case yes
                isContinue=true;
            case cancel
                isContinue=false;
            end
        end

        function isCanceled=processMixedSignalAnalysisSaving(obj)

            isCanceled=false;

            yes=getString(message('msblks:mixedsignalanalyzer:UnsavedPromptYes'));
            no=getString(message('msblks:mixedsignalanalyzer:UnsavedPromptNo'));
            cancel=getString(message('msblks:mixedsignalanalyzer:UnsavedPromptCancel'));

            if~isempty(obj.MixedSignalAnalysis)&&~isempty(obj.MixedSignalAnalysis.View.DataDB)&&obj.IsChanged
                appFig=obj.View.Toolstrip.appContainer;
                msg=getString(message('msblks:mixedsignalanalyzer:UnsavedPromptQuestion'));
                title=getString(message('msblks:mixedsignalanalyzer:UnsavedPromptTitle'));
                if~isempty(appFig)&&isvalid(appFig)
                    selection=uiconfirm(appFig,msg,title,...
                    'Options',{yes,no,cancel},...
                    'DefaultOption',1,'CancelOption',3);
                end
            else
                selection=no;
            end

            switch selection
            case yes
                isCanceled=saveAction(obj,'Save session .mat file');
            case no

            case cancel
                isCanceled=true;
            end
        end

        function enableNewSaveUpdateToolstripButtons(obj)
            if~isempty(obj.View)&&~isempty(obj.View.Toolstrip)
                if isempty(obj.View.DataDB)
                    obj.View.Toolstrip.FileBtn_New.Enabled=true;
                    obj.View.Toolstrip.FileBtn_Save.Enabled=true;
                    obj.View.Toolstrip.FileBtn_Update.Enabled=true;
                else


                    obj.View.Toolstrip.FileBtn_New.Enabled=true;
                    obj.View.Toolstrip.FileBtn_Save.Enabled=true;
                    obj.View.Toolstrip.FileBtn_Update.Enabled=true;
                end
            end
        end

        function newAction(obj)

            isCanceled=obj.processMixedSignalAnalysisSaving();
            if isCanceled
                return;
            end
            obj.defaultModel();
        end


        function openPopupActions(obj,tag)
            switch tag
            case 'Open session .mat file'
                openAction(obj,tag);
            case 'Import file'
                openAction(obj,tag);
            case 'Import workspace'
                openAction(obj,tag);
            case 'Import AdeInfo database'

                msblks.internal.cadence2matlab.readAdeInfoDialog(obj,obj.View.DataFig,[]);
            end
            obj.enableNewSaveUpdateToolstripButtons();
        end
        function canceled=openAction(obj,tag)

            allFiles='All Files';
            switch tag
            case 'Open session .mat file'
                [inputFile,pathname]=uigetfile(...
                {'*.mat','MSA session File (*.mat)';...
                '*.*',[allFiles,' (*.*)']},...
                'Select MSA session File',obj.sessionMatFilePath);
            case 'Import file'
                [inputFile,pathname]=uigetfile(...
                {'*.csv;*.mat;*.xlsx','Import Files (*.csv,*.mat,*.xlsx)';...
                '*.*',[allFiles,' (*.*)']},...
                'Select Import File',obj.inputFilePath);
            case 'Import workspace'
                obj.getWorkspaceObject('Import');
                inputFile=0;
            otherwise
                canceled=true;
                return;
            end
            canceled=isequal(inputFile,0)||isequal(pathname,0);
            if canceled
                return;
            end


            switch tag
            case 'Open session .mat file'
                obj.readSessionData(inputFile,pathname);
            case 'Import file'
                matfilepath=[pathname,inputFile];
                if endsWith(matfilepath,'.mat')
                    temp=load(matfilepath,'-mat');
                    if obj.isValidMixedSignalAnalysisSessionFile(temp)

                        if obj.isContinueWithSessionFile(matfilepath)

                            obj.readSessionData(inputFile,pathname);
                        end
                    elseif obj.isValidCadenceMatFile(temp)

                        obj.readCadenceData(inputFile,pathname,[]);
                    end
                elseif endsWith(matfilepath,'.csv')

                    databases=obj.readGenericData(inputFile,pathname,[]);
                    if isempty(databases.simulationsDB)

                        obj.readCsvData(inputFile,pathname,[]);
                    end
                elseif endsWith(matfilepath,'.xlsx')

                    obj.readXlsxData(inputFile,pathname,[]);
                end
            otherwise
                return;
            end
            obj.enableNewSaveUpdateToolstripButtons();
        end
        function success=readSessionData(obj,fileName,pathname)







            if iscell(fileName)


                multiFilesFromCommandLine=true;
            else


                multiFilesFromCommandLine=false;
                fileName={fileName};
                pathname={pathname};
            end
            try
                for i=1:length(fileName)
                    success=false;
                    matfilepath=[pathname{i},fileName{i}];

                    if isa(fileName{i},'table')

                        obj.readCsvData(fileName{i},obj.getWorkspaceObjectName(fileName{i}),[]);
                        success=true;
                        continue;
                    elseif endsWith(matfilepath,'.xlsx')

                        obj.readXlsxData(fileName{i},pathname{i},[]);
                        success=true;
                        continue;
                    elseif endsWith(matfilepath,'.csv')

                        databases=obj.readGenericData(fileName{i},pathname{i},[]);
                        if isempty(databases.simulationsDB)

                            obj.readCsvData(fileName{i},pathname{i},[]);
                        end
                        success=true;
                        continue;
                    end

                    temp=load(matfilepath,'-mat');
                    if multiFilesFromCommandLine&&obj.isValidCadenceMatFile(temp)

                        obj.readCadenceData(fileName{i},temp,[]);
                        success=true;
                    elseif obj.isValidMixedSignalAnalysisSessionFile(temp)

                        obj.MixedSignalAnalyzerTool.clearMixedSignalAnalyzer(false);
                        [~,obj.Name,~]=fileparts(matfilepath);
                        obj.setMainTitle(obj.Name);


                        dataDB=temp.mixedSignalAnalysis.DataDB;
                        for j=1:length(dataDB)
                            if iscell(dataDB)
                                database=dataDB{j};
                            else
                                database=dataDB(j);
                            end
                            if~isempty(database)
                                if isempty(obj.Database)
                                    obj.Database=database;
                                    obj.Database_Type='Session';
                                else
                                    obj.Database=[obj.Database,database];
                                    obj.Database_Type=[obj.Database_Type,{'Session'}];
                                end
                            end
                            pathNameOriginal=database.fullPathMatFileName;
                            csvfileOriginal=database.matFileName;
                            obj.View.addDatabaseToDataTree(pathNameOriginal,csvfileOriginal,database,[]);
                            obj.View.addPlotOptionsTable(pathNameOriginal,csvfileOriginal,database,[]);
                            obj.View.restoreWaveformsAndOrMetricsToDataTree(database);
                        end


                        plots=temp.mixedSignalAnalysis.Plots;
                        for j=1:length(plots)
                            if j>1||isempty(plots)
                                obj.View.addNewPlot(plots{j}.Title);
                            else
                                obj.View.PlotDocs{1}.Title=plots{j}.Title;
                            end
                            for k=1:length(obj.View.PlotDocs)

                                obj.View.PlotDocs{k}.Selected=(k==length(obj.View.PlotDocs));
                            end
                            drawAndPause(0.5);
                            fields=fieldnames(plots{j});
                            if any(contains(fields,'Tables'))

                                [wfNames,wfValues,wfTables,wfDbIndices]=obj.View.getPlottedWaveforms(plots{j});
                                if~isempty(wfNames)
                                    mixedsignalplot(obj.MixedSignalAnalysis,{...
                                    obj.View.Toolstrip.AnalysisBtn_DisplayWaveform.Tag,obj.View,wfNames,wfValues,wfTables,wfDbIndices});
                                    obj.View.addPlotMargins();
                                    obj.View.updateWaveformPlotTableAndControls([]);
                                end
                            elseif isfield(plots{j},'T')

                                obj.View.loadTrendChartWidgets(...
                                plots{j}.T,...
                                plots{j}.tableData,...
                                plots{j}.tableColumnName,...
                                plots{j}.symRunNames,...
                                plots{j}.cornerParams,...
                                plots{j}.metricParams,...
                                plots{j}.xAxisParams,...
                                plots{j}.yAxisParams,...
                                plots{j}.legendParams,...
                                plots{j}.checkedNodes)
                                obj.MixedSignalAnalyzerTool.Controller.showTrendChart();
                            end
                            drawnow limitrate;
                        end


                        obj.sessionMatFilePath=matfilepath;
                        obj.IsChanged=false;
                        success=true;
                    else
                        msg=message('msblks:mixedsignalanalyzer:BadMixedSignalAnalyzerFile',matfilepath);
                        error(msg)
                    end
                end
            catch err
                ttl=message('msblks:mixedsignalanalyzer:LoadFailed');
                h=errordlg(err.message,getString(ttl),'modal');
                uiwait(h)
                if exist('temp','var')&&...
                    (obj.isValidMixedSignalAnalysisSessionFile(temp)||obj.isValidCadenceMatFile(temp))
                    defaultModel(obj);
                end
            end
        end
        function databases=readGenericData(obj,csvfile,pathname,updateRequests)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingGenericData')));
                databases=msblks.internal.apps.mixedsignalanalyzer.dataGeneric([pathname,csvfile],csvfile,false);
                for i=1:length(databases.simulationsDB)
                    database=databases.simulationsDB{i};
                    if~isempty(database)

                        if isempty(obj.Database)
                            obj.Database=database;
                            obj.Database_Type='Generic';
                        else
                            obj.Database=[obj.Database,database];
                            obj.Database_Type=[obj.Database_Type,{'Generic'}];
                        end
                    else
                        obj.MixedSignalAnalyzerTool.setStatus('');
                        return;
                    end
                    pathNameOriginal=database.fullPathMatFileName;
                    csvfileOriginal=database.matFileName;
                    if isempty(updateRequests)

                        obj.View.addDatabaseToDataTree(pathNameOriginal,csvfileOriginal,database,[]);
                        obj.View.addPlotOptionsTable(pathNameOriginal,csvfileOriginal,database,[]);
                    else

                        obj.performRequestedUpdates(i,pathNameOriginal,csvfileOriginal,database,updateRequests);
                    end
                end
                if~isempty(updateRequests)
                    obj.View.updateTrendCharts();
                end
                obj.IsChanged=true;
                obj.setMainTitle(obj.Name);
                drawnow limitrate;
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function readCsvData(obj,csvfile,pathname,updateRequests)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingCsvData')));
                if isa(csvfile,'table')

                    database=msblks.internal.apps.mixedsignalanalyzer.dataTable(csvfile,pathname);
                    type='table';
                else

                    database=msblks.internal.apps.mixedsignalanalyzer.dataTable([pathname,csvfile],csvfile);
                    type='.csv';
                end
                if~isempty(database)
                    database=database.db;
                    if isa(csvfile,'table')

                        csvfile=database.matFileName;
                    end
                end
                if~isempty(database)

                    if isempty(obj.Database)
                        obj.Database=database;
                        obj.Database_Type=type;
                    else
                        obj.Database=[obj.Database,database];
                        obj.Database_Type=[obj.Database_Type,{type}];
                    end
                else
                    obj.MixedSignalAnalyzerTool.setStatus('');
                    return;
                end
                if isempty(updateRequests)

                    obj.View.addDatabaseToDataTree(pathname,csvfile,database,[]);
                    obj.View.addPlotOptionsTable(pathname,csvfile,database,[]);
                else

                    obj.performRequestedUpdates(1,pathname,csvfile,database,updateRequests);
                    obj.View.updateTrendCharts();
                end
                obj.IsChanged=true;
                obj.setMainTitle(obj.Name);
                drawnow limitrate;
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function readXlsxData(obj,xlsxfile,pathname,updateRequests)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingXlsxData')));
                database=msblks.internal.apps.mixedsignalanalyzer.dataTable([pathname,xlsxfile],xlsxfile);
                if~isempty(database)
                    database=database.db;
                end
                if~isempty(database)

                    if isempty(obj.Database)
                        obj.Database=database;
                        obj.Database_Type='.xlsx';
                    else
                        obj.Database=[obj.Database,database];
                        obj.Database_Type=[obj.Database_Type,{'.xlsx'}];
                    end
                else
                    obj.MixedSignalAnalyzerTool.setStatus('');
                    return;
                end


                if isempty(updateRequests)

                    obj.View.addDatabaseToDataTree(pathname,xlsxfile,database,[]);
                    obj.View.addPlotOptionsTable(pathname,xlsxfile,database,[]);
                else

                    obj.performRequestedUpdates(1,pathname,xlsxfile,database,updateRequests);
                    obj.View.updateTrendCharts();
                end
                obj.IsChanged=true;
                obj.setMainTitle(obj.Name);
                drawnow limitrate;
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end

        function performRequestedUpdates(obj,dbIndex,pathName,fileName,database,updateRequests)
            if dbIndex<1||isempty(database)||isempty(updateRequests)
                return;
            end


            obj.View.oldDataDB{length(obj.View.DataDB)}=[];
            for i=1:length(obj.View.DataDB)
                obj.View.oldDataDB{i}=obj.View.DataDB(i);
            end

            lastIndexTreeDB=0;
            isUpdated{length(updateRequests)}=false;
            for j=1:length(updateRequests)

                indexTreeDB=updateRequests{j}{1};
                indexTreeSim=updateRequests{j}{2};
                indexUpdateDB=updateRequests{j}{3};
                indexUpdateSim=updateRequests{j}{4};

                if indexUpdateDB==dbIndex
                    if~obj.View.checkCompatibilityOfRequest(database,updateRequests{j})
                        isUpdated{j}=false;
                        continue;
                    end
                    isUpdated{j}=true;
                    if indexTreeDB~=lastIndexTreeDB

                        obj.Database(indexTreeDB)=obj.Database(end).clone;
                        obj.Database_Type(indexTreeDB)=obj.Database_Type(end);
                        lastIndexTreeDB=indexTreeDB;
                    end
                    if indexTreeSim~=indexUpdateSim

                        obj.Database(indexTreeDB).SimulationResultsNames{indexTreeSim}=obj.Database(end).SimulationResultsNames{indexUpdateSim};
                        obj.Database(indexTreeDB).SimulationResultsObjects{indexTreeSim}=obj.Database(end).SimulationResultsObjects{indexUpdateSim};
                    end





                    obj.View.addDatabaseToDataTree(pathName,fileName,database,updateRequests{j});
                    obj.View.addPlotOptionsTable(pathName,fileName,database,updateRequests{j});
                    obj.View.updateAnalysisWaveformsAndMetrics();
                    obj.View.updateWaveformPlots();
                end
            end

            newSimCount=length(obj.Database(end).SimulationResultsNames);
            if newSimCount>1&&isa(obj.Database(end),'msblks.internal.mixedsignalanalysis.SimulationsDB')

                databaseClone=obj.Database(end).clone;
                for j=1:length(updateRequests)

                    indexTreeSim=updateRequests{j}{2};
                    indexUpdateDB=updateRequests{j}{3};
                    indexUpdateSim=updateRequests{j}{4};

                    if indexUpdateDB==dbIndex
                        if isUpdated{j}
                            obj.Database(end).SimulationResultsNames(indexTreeSim)=databaseClone.SimulationResultsNames(indexUpdateSim);
                            obj.Database(end).SimulationResultsObjects(indexTreeSim)=databaseClone.SimulationResultsObjects(indexUpdateSim);
                        end
                    end
                end

                for j=1:length(updateRequests)


                    indexUpdateDB=updateRequests{j}{3};


                    if indexUpdateDB==dbIndex
                        oldSimCount=length(obj.View.oldDataDB{dbIndex}.SimulationResultsNames);
                        if oldSimCount<newSimCount
                            for k=newSimCount:-1:1
                                if k>length(isUpdated)||~isUpdated{k}
                                    obj.Database(end).SimulationResultsNames(k)=[];
                                    obj.Database(end).SimulationResultsObjects(k)=[];
                                end
                            end
                        end
                        obj.Database(dbIndex)=obj.Database(end);
                        break;
                    end
                end
            end

            obj.Database(end)=[];
            obj.Database_Type(end)=[];


            obj.View.clearOldDataUsedForUpdates();
            obj.View.oldDataDB=[];
        end

        function matfilepath=getMatFilePath(obj)


            allFiles='All Files';
            selectFileTitle='Save Output File';
            if isempty(obj.sessionMatFilePath)
                [outputFile,pathname]=uiputfile(...
                {'*.mat','Session MAT File (*.mat)';...
                '*.*',[allFiles,' (*.*)']},...
                selectFileTitle,obj.DefaultName);
            else
                [outputFile,pathname]=...
                uiputfile('*.mat','Save Mixed-Signal Analyzer Session As',obj.sessionMatFilePath);
            end
            isCanceled=isequal(outputFile,0)||isequal(pathname,0);
            if isCanceled
                matfilepath=0;
            else
                matfilepath=[pathname,outputFile];
            end
        end


        function savePopupActions(obj,str)
            switch str
            case 'Save'
                saveAction(obj)
            case 'SaveAs'
                matfilepath=getMatFilePath(obj);
                if isequal(matfilepath,0)
                    return;
                end
                saveAction(obj,matfilepath);
            end
        end


        function saveAction(obj,matfilepath)
            if nargin<2

                if isempty(obj.sessionMatFilePath)
                    matfilepath=getMatFilePath(obj);
                    if isequal(matfilepath,0)
                        return;
                    end
                else
                    matfilepath=obj.sessionMatFilePath;
                end
            end
            obj.saveSession(matfilepath);
        end
        function saveSession(obj,fullPathMatFileName)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusySave')));
                try
                    mixedSignalAnalysis=clone(obj.MixedSignalAnalysis);
                    mixedSignalAnalysis.VersionWhenSaved=version('-release');

                    save(fullPathMatFileName,'mixedSignalAnalysis')


                    obj.sessionMatFilePath=fullPathMatFileName;


                    obj.IsChanged=false;
                    [~,obj.Name]=fileparts(obj.sessionMatFilePath);
                    obj.setMainTitle(obj.Name);
                catch err
                    ttl=message('msblks:mixedsignalanalyzer:SaveFailed');
                    h=errordlg(err.message,getString(ttl),'modal');
                    uiwait(h)
                    obj.MixedSignalAnalyzerTool.setStatus('');
                    return;
                end
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function writeGenericData(obj,outputFile,pathname)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusySaveGeneric')));
                genericDB=msblks.internal.apps.mixedsignalanalyzer.dataGeneric(obj.View.DataDB,outputFile,false);
                genericDB.fullPathCsvFileName=[pathname,outputFile];
                genericDB.writeDataGeneric();


                obj.genericCsvFilePath=genericDB.fullPathCsvFileName;
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end

        function exportScript(obj)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExportToMATLABscript')));
                obj.MixedSignalAnalysis.exportScript();
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function exportReport(obj)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExportToReport')));
                obj.MixedSignalAnalysis.exportReport(obj.View.PlotDocs,obj.View.PlotFigs);
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function exportWorkSpace(obj)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExportToMATLABworkspace')));
                obj.MixedSignalAnalysis.exportWorkSpace();
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end
        function exportPopupActions(obj,tag)
            try
                switch tag
                case 'ExportListItem_ToScript'
                    obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExportToMATLABscript')));
                    obj.MixedSignalAnalysis.exportScript();
                case 'ExportListItem_ToReport'
                    obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExportToReport')));
                    obj.MixedSignalAnalysis.exportReport(obj.View.PlotDocs,obj.View.PlotFigs);
                case 'ExportListItem_ToWorkspace'
                    obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyExportToMATLABworkspace')));
                    obj.MixedSignalAnalysis.exportWorkSpace();
                case 'Save generic database file'
                    allFiles='All Files';
                    selectFileTitle='Save Output File';
                    [outputFile,pathname]=uiputfile(...
                    {'*.csv','Generic Database File (*.csv)';...
                    '*.*',[allFiles,' (*.*)']},...
                    selectFileTitle,obj.genericCsvFilePath);
                end

                canceled=isequal(outputFile,0)||isequal(pathname,0);
                if canceled
                    return;
                end


                switch tag
                case 'Save session .mat file'
                    obj.saveSession(outputFile,pathname);
                case 'Save generic database file'
                    obj.writeGenericData(outputFile,pathname);
                otherwise
                    return;
                end

            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
        end


        function updatePopupActions(obj,tag)
            switch tag
            case 'Update file'
                updateAction(obj,tag);
            case 'Update workspace'
                updateAction(obj,tag);
            case 'Update AdeInfo database'

                msblks.internal.cadence2matlab.readAdeInfoDialog(obj,obj.View.DataFig,obj.Database);
            end
        end
        function canceled=updateAction(obj,tag)

            allFiles='All Files';
            switch tag
            case 'Update file'
                [inputFile,pathname]=uigetfile(...
                {'*.csv;*.mat;*.xlsx','Update Files (*.csv,*.mat,*.xlsx)';...
                '*.*',[allFiles,' (*.*)']},...
                'Select Update File',obj.inputFilePath);
            case 'Update workspace'
                obj.getWorkspaceObject('Update');
                inputFile=0;
            otherwise
                canceled=true;
                return;
            end
            canceled=isequal(inputFile,0)||isequal(pathname,0);
            if canceled
                return;
            end


            switch tag
            case 'Update file'
                matfilepath=[pathname,inputFile];
                if endsWith(matfilepath,'.mat')
                    temp=load(matfilepath,'-mat');
                    if obj.isValidMixedSignalAnalysisSessionFile(temp)

                        if obj.isContinueWithSessionFile(matfilepath)

                            obj.readSessionData(inputFile,pathname);
                        end
                    elseif obj.isValidCadenceMatFile(temp)

                        obj.updateCadenceData(inputFile,pathname);
                    end
                elseif endsWith(matfilepath,'.csv')

                    databases=obj.updateGenericData(inputFile,pathname);
                    if isempty(databases.simulationsDB)

                        obj.updateCsvData(inputFile,pathname);
                    end
                elseif endsWith(matfilepath,'.xlsx')

                    obj.updateXlsxData(inputFile,pathname);
                end


            otherwise
                return;
            end
        end
        function databases=updateGenericData(obj,csvfile,pathname)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingGenericData')));
                databases=msblks.internal.apps.mixedsignalanalyzer.dataGeneric([pathname,csvfile],csvfile,true);
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
            if~isempty(databases)&&~isempty(databases.simulationsDB)
                obj.updateSession(databases);
            end
        end
        function updateCsvData(obj,csvfile,pathname)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingCsvData')));
                if isa(csvfile,'table')
                    database=msblks.internal.apps.mixedsignalanalyzer.dataTable(csvfile,pathname);
                else
                    database=msblks.internal.apps.mixedsignalanalyzer.dataTable([pathname,csvfile],csvfile);
                end
                if~isempty(database)
                    database=database.db;
                end
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
            if~isempty(database)
                obj.updateSession(database);
            end
        end
        function updateXlsxData(obj,xlsxfile,pathname)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingXlsxData')));
                databases=msblks.internal.apps.mixedsignalanalyzer.dataTable([pathname,xlsxfile],xlsxfile);
                if~isempty(databases)
                    databases=databases.db;
                end
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
            if~isempty(databases)
                obj.updateSession(databases);
            end
        end
        function updateCadenceData(obj,cadenceMatfile,pathname)
            try
                obj.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyParsingCadenceData')));
                if isstruct(pathname)

                    databases=msblks.internal.apps.mixedsignalanalyzer.dataCadence(pathname,cadenceMatfile);
                else

                    databases=msblks.internal.apps.mixedsignalanalyzer.dataCadence([pathname,cadenceMatfile],cadenceMatfile);
                end
                if~isempty(databases)
                    databases=databases.getGenericDB();
                end
            catch ex
                obj.MixedSignalAnalyzerTool.setStatus('');
                rethrow(ex);
            end
            obj.MixedSignalAnalyzerTool.setStatus('');
            if~isempty(databases)
                obj.updateSession(databases);
            end
        end
        function updateSession(obj,databases)
            if isempty(obj.Database)||isempty(databases)
                return;
            end

            obj.figUpdateSession=uifigure('Name',getString(message('msblks:mixedsignalanalyzer:FileBtn_Update')),'Tag','UpdateDialog');
            figLayout=uigridlayout(obj.figUpdateSession,...
            'RowHeight',{'1x',20},...
            'ColumnWidth',{'1x',60,60},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on');
            mainPanel=uipanel('Parent',figLayout,'Scrollable','on');
            okButton=uibutton('Parent',figLayout,...
            'Text',getString(message('msblks:mixedsignalanalyzer:RefreshText')),...
            'Tag','okButton');
            cancelButton=uibutton('Parent',figLayout,...
            'Tag','cancelButton',...
            'Text',getString(message('msblks:mixedsignalanalyzer:CancelText')),...
            'ButtonPushedFcn',@obj.deleteDialogUpdateSession);
            mainPanel.Layout.Row=1;
            okButton.Layout.Row=2;
            cancelButton.Layout.Row=2;
            mainPanel.Layout.Column=[1,3];
            okButton.Layout.Column=2;
            cancelButton.Layout.Column=3;


            count=0;
            count=count+1;
            count=count+1;
            for i=1:length(obj.Database)
                treeDatabaseName=removeTrailingMarkerGDB(obj.Database(i).matFileName);
                count=count+1;
                for j=1:length(obj.Database(i).SimulationResultsNames)
                    treeSimulationName=obj.Database(i).SimulationResultsNames{j};
                    count=count+1;
                    if isa(databases,'msblks.internal.apps.mixedsignalanalyzer.dataGeneric')

                        if~isempty(databases)
                            simulationsDB=databases.simulationsDB;
                            for k=1:length(simulationsDB)
                                updateDatabaseName=removeTrailingMarkerGDB(simulationsDB{k}.matFileName);
                                count=count+1;
                                for m=1:length(simulationsDB{k}.SimulationResultsNames)
                                    updateSimulationName=simulationsDB{k}.SimulationResultsNames{m};
                                    if~strcmp(treeDatabaseName,updateDatabaseName)||~strcmp(treeSimulationName,updateSimulationName)
                                        count=count+1;
                                    end
                                end
                            end
                        end
                    else

                        if isprop(databases,'matFileName')
                            updateDatabaseName=removeTrailingMarkerGDB(databases.matFileName);
                        else
                            updateDatabaseName='';
                        end
                        count=count+1;
                        for m=1:length(databases.SimulationResultsNames)
                            updateSimulationName=databases.SimulationResultsNames{m};
                            if~strcmp(treeDatabaseName,updateDatabaseName)||~strcmp(treeSimulationName,updateSimulationName)
                                count=count+1;
                            end
                        end
                    end
                end
            end
            count=max(count,18);


            buttonGroups=[];

            folderIcon_16=[fullfile('+msblks','+internal','+apps','+mixedsignalanalyzer'),filesep,'folder_16.png'];
            indent0=25;
            indent1=30;
            indent2=55;
            indent3=75;
            height=20;
            width=450;
            allButtonGroups={};
            uilabel('Parent',mainPanel,'Position',[5,count*height,width,height],'Text',getString(message('msblks:mixedsignalanalyzer:ReplaceWithText')));
            count=count-1;
            uilabel('Parent',mainPanel,'Position',[5,count*height,width,height],'Text','');
            count=count-1;
            for i=1:length(obj.Database)
                uiimage('Parent',mainPanel,'Position',[5,count*height,16,16],'imagesource',folderIcon_16);
                treeDatabaseName=obj.Database(i).matFileName;
                uilabel('Parent',mainPanel,'Position',[indent0,count*height,width,height],'Text',treeDatabaseName);
                treeDatabaseName=removeTrailingMarkerGDB(treeDatabaseName);
                count=count-1;
                for j=1:length(obj.Database(i).SimulationResultsNames)
                    treeSimulationName=obj.Database(i).SimulationResultsNames{j};
                    checkbox=uicheckbox('Parent',mainPanel,'Position',[indent1,count*height,width,height],'Text',treeSimulationName,'Value',0);
                    existingCornerTablePanelIndex=obj.View.getExistingCornerTablePanelIndex(i,treeSimulationName);
                    count=count-1;
                    if isa(databases,'msblks.internal.apps.mixedsignalanalyzer.dataGeneric')

                        buttonGroups=[];
                        buttonGroups{length(databases)}=[];%#ok<AGROW>
                        if~isempty(databases)
                            simulationsDB=databases.simulationsDB;
                            for k=1:length(simulationsDB)
                                uiimage('Parent',mainPanel,'Position',[indent2,count*height,16,16],'imagesource',folderIcon_16);
                                updateDatabaseName=simulationsDB{k}.matFileName;
                                uilabel('Parent',mainPanel,'Position',[indent2+20,height*count,width,height],'Text',updateDatabaseName);
                                updateDatabaseName=removeTrailingMarkerGDB(updateDatabaseName);
                                resultsTotal=length(simulationsDB{k}.SimulationResultsNames);
                                buttonGroup=uibuttongroup('Parent',mainPanel,'Position',[indent3,height*(count-resultsTotal),width,height*resultsTotal],'BorderType','none');
                                buttonGroups{k}=buttonGroup;
                                count=count-1;
                                uiradiobutton('Parent',buttonGroup,'Text','N/A','Visible','off');
                                offset=resultsTotal;
                                for m=1:resultsTotal

                                    updateSimulationName=simulationsDB{k}.SimulationResultsNames{m};
                                    if~strcmp(treeDatabaseName,updateDatabaseName)||~strcmp(treeSimulationName,updateSimulationName)
                                        radioButton=uiradiobutton('Parent',buttonGroup,'Position',[5,height*(offset-m),width,height],'Text',updateSimulationName);
                                        count=count-1;
                                        radioButton.UserData={i,j,k,m,existingCornerTablePanelIndex};
                                    else
                                        offset=offset+1;
                                    end
                                end
                            end
                        end
                        for k=1:length(buttonGroups)
                            buttonGroup=buttonGroups{k};
                            buttonGroup.SelectionChangedFcn=@(h,e)selectButton(buttonGroup,buttonGroups);
                        end
                    else

                        uiimage('Parent',mainPanel,'Position',[indent2,count*height,16,16],'imagesource',folderIcon_16);
                        updateDatabaseName=databases.matFileName;
                        uilabel('Parent',mainPanel,'Position',[indent2+20,height*count,width,height],'Text',updateDatabaseName);
                        updateDatabaseName=removeTrailingMarkerGDB(updateDatabaseName);
                        resultsTotal=length(databases.SimulationResultsNames);
                        buttonGroup=uibuttongroup('Parent',mainPanel,'Position',[indent3,height*(count-resultsTotal),width,height*resultsTotal],'BorderType','none');
                        buttonGroups{1}=buttonGroup;
                        count=count-1;
                        uiradiobutton('Parent',buttonGroup,'Text','N/A','Visible','off');
                        offset=resultsTotal;
                        for m=1:resultsTotal

                            updateSimulationName=databases.SimulationResultsNames{m};
                            if~strcmp(treeDatabaseName,updateDatabaseName)||~strcmp(treeSimulationName,updateSimulationName)
                                radioButton=uiradiobutton('Parent',buttonGroup,'Position',[5,height*(offset-m),width,height],'Text',updateSimulationName);
                                count=count-1;
                                radioButton.UserData={i,j,1,m,existingCornerTablePanelIndex};
                            else
                                offset=offset+1;
                            end
                        end
                    end
                    checkbox.ValueChangedFcn=@(h,e)enableButtons(buttonGroups,checkbox);
                    initButtonsAndCheckbox(buttonGroups,checkbox);
                    allButtonGroups{end+1}=buttonGroups;%#ok<AGROW>
                end
            end
            okButton.ButtonPushedFcn=@(h,e)obj.applyAndDeleteUpdateSessionDialog(databases,allButtonGroups);
        end
        function deleteDialogUpdateSession(obj,src,event)
            close(obj.figUpdateSession);
            obj.figUpdateSession=[];
        end
        function applyAndDeleteUpdateSessionDialog(obj,databases,allButtonGroups)
            try
                obj.View.MixedSignalAnalyzerTool.setStatus(getString(message('msblks:mixedsignalanalyzer:BusyUpdatingSource')));
                requests={};
                for i=1:length(allButtonGroups)
                    buttonGroups=allButtonGroups{i};
                    for j=1:length(buttonGroups)
                        buttonGroup=buttonGroups{j};
                        for k=1:length(buttonGroup.Buttons)
                            button=buttonGroup.Buttons(k);
                            if button.Enable&&...
                                button.Visible&&...
                                button.Value&&...
                                ~isempty(button.UserData)
                                requests{end+1}=button.UserData;%#ok<AGROW>
                            end
                        end
                    end
                end
                obj.deleteDialogUpdateSession;
                if~isempty(requests)

                    if isa(databases,'msblks.internal.apps.mixedsignalanalyzer.dataGeneric')

                        [path,name,ext]=fileparts(databases.fullPathCsvFileName);
                        obj.readGenericData([name,ext],[path,'/'],requests);
                    elseif strcmpi(databases.sourceType,'Cadence')

                        [path,name,ext]=fileparts(databases.fullPathMatFileName);
                        obj.readCadenceData([name,ext],[path,'/'],requests);
                    elseif strcmpi(databases.sourceType,'.csv')

                        [path,name,ext]=fileparts(databases.fullPathMatFileName);
                        obj.readCsvData([name,ext],[path,'/'],requests);
                    elseif strcmpi(databases.sourceType,'.xlsx')

                        [path,name,ext]=fileparts(databases.fullPathMatFileName);
                        obj.readXlsxData([name,ext],[path,'/'],requests);
                    elseif strcmpi(databases.sourceType,'table')

                        workspaceObjectName=databases.matFileName;
                        workspaceObject=obj.getNamedWorkspaceObject(workspaceObjectName);
                        obj.readCsvData(workspaceObject,workspaceObjectName,requests);
                    end
                end
            catch ex
                obj.View.MixedSignalAnalyzerTool.setStatus('');
                if strcmpi(ex.identifier,'MATLAB:undefinedVarOrClass')
                    uialert(obj.View.DataFig,'Cadence API utilities/tools not available.',ex.identifier);
                else
                    uialert(obj.View.DataFig,ex.message,ex.identifier);
                end
            end
            obj.View.MixedSignalAnalyzerTool.setStatus('');
            if~isempty(obj.figUpdateSession)
                obj.deleteDialogUpdateSession;
            end
        end
    end

    methods(Static)
        function isValid=isValidMixedSignalAnalysisSessionFile(msaStruct)

            isValid=isfield(msaStruct,'mixedSignalAnalysis')&&...
            isa(msaStruct.mixedSignalAnalysis,'msblks.internal.mixedsignalanalysis.MIXEDSIGNALAnalysis')&&...
            isprop(msaStruct.mixedSignalAnalysis,'DataDB')&&...
            ~isempty(msaStruct.mixedSignalAnalysis.DataDB)&&...
            isa(msaStruct.mixedSignalAnalysis.DataDB(1),'msblks.internal.mixedsignalanalysis.SimulationsDB')&&...
            isprop(msaStruct.mixedSignalAnalysis.DataDB(1),'SimulationResultsObjects')&&...
            ~isempty(msaStruct.mixedSignalAnalysis.DataDB(1).SimulationResultsObjects)&&...
            isa(msaStruct.mixedSignalAnalysis.DataDB(1).SimulationResultsObjects{1},'msblks.internal.mixedsignalanalysis.SimulationResults');
        end
        function isValid=isValidCadenceMatFile(cadenceStruct)

            isValid=...
            isfield(cadenceStruct,'dbTables')&&~isempty(cadenceStruct.dbTables)||...
            isfield(cadenceStruct,'signalTables')&&~isempty(cadenceStruct.signalTables)||...
            isfield(cadenceStruct,'exprTables')&&~isempty(cadenceStruct.exprTables);
        end
    end
end


function initButtonsAndCheckbox(buttonGroups,checkbox)
    if length(buttonGroups{1}.Buttons)>1
        buttonGroups{1}.Buttons(2).Value=1;
    end
    for i=1:length(buttonGroups)
        for j=1:length(buttonGroups{i}.Buttons)

            buttonGroups{i}.Buttons(j).Enable=0;
        end
    end
    checkbox.Value=0;
end
function enableButtons(buttonGroups,checkbox)
    for i=1:length(buttonGroups)
        for j=1:length(buttonGroups{i}.Buttons)

            buttonGroups{i}.Buttons(j).Enable=checkbox.Value;
        end
    end
end
function selectButton(selectedbuttonGroup,buttonGroups)
    for i=1:length(buttonGroups)
        if buttonGroups{i}~=selectedbuttonGroup
            for j=1:length(buttonGroups{i}.Buttons)
                if~buttonGroups{i}.Buttons(j).Visible

                    buttonGroups{i}.Buttons(j).Value=1;
                    break;
                end
            end
        end
    end
end
function databaseName=removeTrailingMarkerGDB(databaseName)
    index=strfind(databaseName,' (GDB)');
    if~isempty(index)
        databaseName=extractBefore(databaseName,index(1));
        databaseName=strtrim(databaseName);
    end
end
function drawAndPause(timeInSeconds)
    drawnow limitrate;

end
