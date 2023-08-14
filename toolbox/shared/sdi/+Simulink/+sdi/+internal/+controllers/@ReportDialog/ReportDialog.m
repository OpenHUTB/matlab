classdef ReportDialog<handle





    properties(Access=private)
        Engine;
        Dispatcher;
    end

    properties(Constant)
        ControllerID='generateReportDialog';
    end


    methods(Hidden)

        function this=ReportDialog(dispatcherObj)
            this.Engine=Simulink.sdi.Instance.engine;

            import Simulink.sdi.internal.controllers.ReportDialog;
            this.Dispatcher=dispatcherObj;


            this.Dispatcher.subscribe(...
            [ReportDialog.ControllerID,'/','get_initSetup'],...
            @(arg)cb_GetInitSetup(this,arg));
            this.Dispatcher.subscribe(...
            [ReportDialog.ControllerID,'/','get_openDialog'],...
            @(arg)cb_GetOpenDialog(this,arg));
            this.Dispatcher.subscribe(...
            [ReportDialog.ControllerID,'/','generateReport'],...
            @(arg)cb_GenerateReport(this,arg));
            this.Dispatcher.subscribe(...
            [ReportDialog.ControllerID,'/','browseFolderPath'],...
            @(arg)cb_BrowseFolderDialogRequest(this,arg));


            this.Dispatcher.subscribe(...
            [ReportDialog.ControllerID,'/','help'],...
            @(arg)ReportDialog.cb_HelpButton(arg));
        end


        function cb_GetInitSetup(this,arg)
            import Simulink.sdi.internal.controllers.ReportDialog;


            reportFolder=fullfile(pwd,'sdireports');

            this.Dispatcher.publishToClient(arg.clientID,...
            ReportDialog.ControllerID,'set_initSetup',reportFolder);
        end


        function cb_GetOpenDialog(this,arg)
            import Simulink.sdi.internal.controllers.ReportDialog;


            compareRunID=Simulink.sdi.getRecentValidComparisonRunID();
            drr=Simulink.sdi.DiffRunResult(compareRunID);


            try
                baseSigRunName=Simulink.sdi.getRun(drr.RunID1).name;
            catch
                baseSigRunName='';
            end
            try
                cmprSigRunName=Simulink.sdi.getRun(drr.RunID2).name;
            catch
                cmprSigRunName='';
            end


            baseSigRun=Simulink.sdi.internal.controllers.ReportDialog.jsUpdateStr(baseSigRunName);
            cmprSigRun=Simulink.sdi.internal.controllers.ReportDialog.jsUpdateStr(cmprSigRunName);
            username=getenv('username');
            reportType=getString(message('SDI:dialogs:Compare'));
            if isempty(baseSigRun)||isempty(cmprSigRun)
                reportHeaderTitle=sprintf('%s: ',reportType);
            else
                reportHeaderTitle=sprintf('%s: %s vs. %s',reportType,baseSigRun,cmprSigRun);
            end
            reportHeaderAuthor=sprintf('%s',username);
            jsonInit=sprintf('{"Title":"%s", "Author":"%s"}',...
            reportHeaderTitle,reportHeaderAuthor);

            this.Dispatcher.publishToClient(arg.clientID,...
            ReportDialog.ControllerID,'set_openDialog',jsonInit);
        end


        function cb_GenerateReport(this,arg)
            import Simulink.sdi.internal.controllers.ReportDialog;
            import Simulink.sdi.internal.ReportManager;

            info=arg.data;
            try
                switch info.reportType
                case 'inspectSignals'
                    reportType='Inspect Signals';
                    reportStyle='Printable';
                case 'compareRuns'
                    bIsRunCompare=~isempty(this.Engine.DiffRunResult);
                    if~bIsRunCompare
                        reportType='Compare Signals';
                        reportStyle='Interactive';
                    else
                        reportType='Compare Runs';
                        reportStyle='Interactive';
                        if strcmpi(info.signalsToReport,'reportMismatchedSignals')
                            signalsToReport='ReportOnlyMismatchedSignals';
                        else
                            signalsToReport='ReportAllSignals';
                        end
                    end
                otherwise
                    this.Dispatcher.publishToClient(arg.clientID,...
                    ReportDialog.ControllerID,'closeDialog',[]);
                end

                if isempty(info.reportHeaderTitle)
                    reportHeaderTitle='';
                else
                    reportHeaderTitle=info.reportHeaderTitle;
                end

                if isempty(info.reportHeaderAuthor)
                    reportHeaderAuthor='';
                else
                    reportHeaderAuthor=info.reportHeaderAuthor;
                end

                rm=this.Engine.ReportManager;
                rm.AppName=info.appName;
                if strcmp(reportType,'Compare Runs')
                    rm.SignalsToReport=signalsToReport;
                end
                columnsToReport=ReportDialog.populateColumns(reportType);
                rm.ColumnsToReport=...
                ReportManager.convertColumnNamesToSignalMetaDataElements(...
                info.reportType,columnsToReport);

                opts={...
                'ReportType',reportType,...
                'ReportStyle',reportStyle,...
                'ReportOutputFolder',info.reportFolder,...
                'ReportOutputFile',info.reportFileName,...
                'PreventOverwritingFile',info.preventOverwrite,...
                'ColumnsToReport',rm.ColumnsToReport,...
                'ShortenBlockPath',info.shortenBlockPath,...
                'LaunchReport',true,...
                'SignalsToReport',rm.SignalsToReport,...
                'ReportTitle',reportHeaderTitle,...
                'ReportAuthor',reportHeaderAuthor,...
                };

                this.Engine.report(opts{:});
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:ReportError'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                info.appName,titleStr,msgStr,{okStr},0,-1,[]);
            end

            this.Dispatcher.publishToClient(arg.clientID,...
            ReportDialog.ControllerID,'closeDialog',[]);
        end


        function cb_BrowseFolderDialogRequest(this,arg)
            requestedDir=arg.data.path;
            try
                directoryName=uigetdir(requestedDir,...
                Simulink.sdi.internal.StringDict.rgReportOutputUIBrowseTitle);
            catch me
                msgStr=me.message;
                titleStr=getString(message('SDI:sdi:ReportError'));
                okStr=getString(message('SDI:sdi:OKShortcut'));

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                arg.data.appName,titleStr,msgStr,{okStr},0,-1,[]);
            end

            if ischar(directoryName)
                reportFolder=directoryName;
            else
                reportFolder=[];
            end

            import Simulink.sdi.internal.controllers.ReportDialog;
            this.Dispatcher.publishToClient(arg.clientID,...
            ReportDialog.ControllerID,'reportFolder',...
            reportFolder);


            bWasRunning=Simulink.sdi.Instance.isSDIRunning();
            if bWasRunning
                gui=Simulink.sdi.Instance.getMainGUI();
                gui.bringToFront();
            end
        end
    end

    methods(Hidden,Static,Access=public)

        function newStr=jsUpdateStr(currStr)
            try
                newStr=regexprep(currStr,'<','&lt');
                newStr=regexprep(newStr,'>','&gt');
                newStr=regexprep(newStr,'\\','\\\\');
                newStr=regexprep(newStr,'''','\\''');
            catch
                newStr='';
            end
        end
    end


    methods(Static)

        function ret=getController(varargin)
            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)



                assert(nargin==1&&isa(varargin{1},'Simulink.sdi.internal.controllers.Dispatcher'));
                dispatcherObj=varargin{1};
                ctrlObj=Simulink.sdi.internal.controllers.ReportDialog(dispatcherObj);
            end
            ret=ctrlObj;
        end


        function cb_HelpButton(~)
            Simulink.sdi.internal.controllers.SDIHelp('reportHelp');
        end


        function visibleColumns=populateColumns(reportType)
            switch reportType
            case 'Inspect Signals'
                prefStruct=Simulink.sdi.getViewPreferences();
                if isfield(prefStruct,'sdiColumns')&&...
                    ~isempty(prefStruct.sdiColumns)
                    sdiColumns=prefStruct.sdiColumns;
                    [~,ind]=sort([sdiColumns.orderID]);
                    sdiColumns=sdiColumns(ind);
                    numColumns=length(sdiColumns);
                    visibleColumns=cell(numColumns,1);
                    for i=1:numColumns
                        if sdiColumns(i).orderID>-1...
                            &&~strcmpi(...
                            sdiColumns(i).colField,...
                            'checked')...
                            &&~strcmpi(...
                            sdiColumns(i).colField,...
                            'linestyle')


                            visibleColumns{i}=...
                            sdiColumns(i).colField;
                        end
                    end
                    visibleColumns=visibleColumns(...
                    ~cellfun('isempty',visibleColumns));
                else
                    visibleColumns={'name','color'};
                end
            otherwise
                prefStruct=Simulink.sdi.getViewPreferences();
                if isfield(prefStruct,'comparisonColumns')&&...
                    ~isempty(prefStruct.comparisonColumns)
                    comparisonColumns=prefStruct.comparisonColumns;
                    [~,ind]=sort([comparisonColumns.orderID]);
                    comparisonColumns=comparisonColumns(ind);
                    numColumns=length(comparisonColumns);
                    visibleColumns=cell(numColumns,1);
                    for i=1:numColumns
                        if comparisonColumns(i).orderID>-1...
                            &&~strcmpi(...
                            comparisonColumns(i).colField,...
                            'plotted')...
                            &&~strcmpi(...
                            comparisonColumns(i).colField,...
                            'Baseline_linestyle')...
                            &&~strcmpi(...
                            comparisonColumns(i).colField,...
                            'Compared_linestyle')


                            visibleColumns{i}=...
                            comparisonColumns(i).colField;
                        end
                    end
                    visibleColumns=visibleColumns(...
                    ~cellfun('isempty',visibleColumns));
                else
                    visibleColumns={'status','name',...
                    'abs','rel'};
                end
            end
        end
    end
end

