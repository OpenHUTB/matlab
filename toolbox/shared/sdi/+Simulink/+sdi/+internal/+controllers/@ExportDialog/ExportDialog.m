


classdef ExportDialog<handle



    methods(Static)

        function ret=getController(varargin)

            if nargin>=2
                if strcmpi(varargin{2},'forceNewController')

                    clear ctrlObj;
                end
            end
            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)



                assert(nargin<=2&&isa(varargin{1},'Simulink.sdi.internal.controllers.Dispatcher'));
                dispatcherObj=varargin{1};
                ctrlObj=Simulink.sdi.internal.controllers.ExportDialog(dispatcherObj);
            end

            ret=ctrlObj;
        end


        function cb_HelpButton(arg)

            if(isfield(arg,'data')&&isfield(arg.data,'activeApp')&&strcmp(arg.data.activeApp,'siganalyzer'))
                if isfield(arg.data,'helpType')
                    signal.analyzer.controllers.SignalAnalyzerHelp(arg.data.helpType);
                else
                    signal.analyzer.controllers.SignalAnalyzerHelp('sigAppHelp');
                end
            else
                Simulink.sdi.internal.controllers.SDIHelp('exportSignalRunsHelp');
            end
        end
    end


    methods(Hidden)

        function this=ExportDialog(dispatcherObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            import Simulink.sdi.internal.controllers.ExportDialog;

            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','help'],...
            @(arg)ExportDialog.cb_HelpButton(arg));

            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','browseFolderDialogRequest'],...
            @(arg)cb_BrowseFolderDialogRequest(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','ok'],...
            @(arg)cb_OKButton(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','excel_export_ok'],...
            @(arg)cb_ExcelExport(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','overwriteVariableInBaseWorkspace'],...
            @(arg)cb_OverwriteVariableInBaseWorkspace(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','overwriteExistingFile'],...
            @(arg)cb_OverwriteExistingFile(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','exportPlotToFigure'],...
            @(arg)cb_ExportPlotToFigure(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','preshowdialog'],...
            @(arg)cb_PreShowDialog(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','closeexportdialog'],...
            @(arg)cb_CloseDialog(this,arg));
            this.Dispatcher.subscribe(...
            [ExportDialog.ControllerID,'/','exportToIndividualSignals'],...
            @(arg)cb_ExportToIndividualSignals(this,arg));
        end


        function cb_OKButton(this,arg)



            import Simulink.sdi.internal.controllers.ExportDialog;
            info=arg.data;
            assert(strcmpi(info.exportDestination,'exportDataBaseWorkspace')||...
            strcmpi(info.exportDestination,'exportDataMatFile')||...
            strcmpi(info.exportDestination,'exportDataToFile')||...
            strcmpi(info.exportDestination,'exportDataMatFileForceOverWrite'));
            assert(isfield(info,'activeApp')&&~isempty(info.activeApp));
            if~isfield(info,'runIDs')||~isfield(info,'signalIDs')||isempty([info.runIDs;info.signalIDs])
                this.helperCloseDialogOnOK(arg.clientID);
                return;
            end
            runIDs=info.runIDs;
            signalIDs=info.signalIDs;
            if strcmp(info.activeApp,'siganalyzer')

                varInfo=Simulink.sdi.internal.signalanalyzer.Utilities.getSelectedSignalHierarchyFromViewIndices(this.Engine,info.idArray,info.clientID,info.activeApp);




                [varInfo,validFlag]=Simulink.sdi.internal.signalanalyzer.Utilities.verifyValidHierarchy(this.Engine,varInfo);
                varInfo=Simulink.sdi.internal.signalanalyzer.Utilities.convertSigNamesToVarNames(this.Engine,varInfo);
                baseWorkspace_VarName=varInfo;
                matFile_VarName=varInfo;
                signalIDs=[varInfo.signalID];
                if~validFlag




                    this.BaseWorkspace_VarName=varInfo;
                    this.Data=info;
                    this.SignalIDs=signalIDs;
                    this.Dispatcher.publishToClient(arg.clientID,...
                    ExportDialog.ControllerID,'confirmExportAsIndividualSignals',[]);
                    return;
                end
            else
                baseWorkspace_VarName=info.baseWorkspace_VarName;
                matFile_VarName='data';
            end
            switch info.exportDestination
            case 'exportDataBaseWorkspace'
                this.exportSelectedDataToBaseWorkspace(...
                runIDs,signalIDs,info.activeApp,baseWorkspace_VarName,arg.clientID);
            case 'exportDataMatFile'
                matFile_FileName=info.matFile_FileName;
                this.exportSelectedDataToMatFile(...
                runIDs,signalIDs,info.activeApp,matFile_VarName,matFile_FileName,arg.clientID);
            case 'exportDataToFile'

                if~isfield(info,'exportToFileOptions')
                    info.exportToFileOptions=struct();
                end
                fileName=info.file_FileName;
                this.exportSelectedDataToFile(...
                runIDs,signalIDs,info.activeApp,matFile_VarName,...
                fileName,arg.clientID,info.exportToFileOptions);
            case 'exportDataMatFileForceOverWrite'
                matFile_FileName=info.matFile_FileName;
                this.exportSelectedDataToMatFile(...
                runIDs,signalIDs,info.activeApp,matFile_VarName,matFile_FileName,arg.clientID,true);
            end
        end


        function cb_ExcelExport(this,arg)



            import Simulink.sdi.internal.controllers.ExportDialog;
            ImportDialogCtrlObj=Simulink.sdi.internal.controllers.ImportDialog(this.Dispatcher);
            info=arg.data;
            assert(strcmpi(info.exportDestination,'exportDataBaseWorkspace')||...
            strcmpi(info.exportDestination,'exportDataToRun')||...
            strcmpi(info.exportDestination,'exportDataToMatFile')||...
            strcmpi(info.exportDestination,'exportDataMatFileForceOverWrite'));
            assert(isfield(info,'activeApp')&&~isempty(info.activeApp));
            matFile_VarName='data';
            switch info.exportDestination
            case 'exportDataBaseWorkspace'


                [runID,~,signalIDs]=Simulink.sdi.createRun('temp','file',info.file_Location);
                this.exportSelectedDataToBaseWorkspace(...
                runID,signalIDs,info.activeApp,info.baseWorkspace_VarName,arg.clientID);
                Simulink.sdi.deleteRun(runID);
            case 'exportDataToRun'
                importer=Simulink.sdi.internal.import.FileImporter.getDefault();
                runID=importer.verifyFileAndImport(...
                sdi.Repository(1),...
                info.file_Location,...
                'Run <run_index>: Imported_Data',...
                false,...
                int32(0),...
                ImportDialogCtrlObj.VarParser);%#ok
            case 'exportDataToMatFile'
                if~isfield(info,'exportToFileOptions')
                    info.exportToFileOptions=struct();
                end


                [runID,~,signalIDs]=Simulink.sdi.createRun('temp','file',info.file_Location);
                this.exportSelectedDataToFile(...
                runID,signalIDs,info.activeApp,matFile_VarName,...
                info.file_FileName,arg.clientID,info.exportToFileOptions);
                Simulink.sdi.deleteRun(runID);
            case 'exportDataMatFileForceOverWrite'


                [runID,~,signalIDs]=Simulink.sdi.createRun('temp','file',info.file_Location);
                this.exportSelectedDataToMatFile(...
                runID,signalIDs,info.activeApp,matFile_VarName,info.file_FileName,arg.clientID,true);
                Simulink.sdi.deleteRun(runID);
            end
        end


        function cb_PreShowDialog(this,arg)
            info=arg.data;
            runIDs=[];
            signalIDs=[];

            if isfield(info,'idArray')&&~isempty(info.idArray)

                [runIDs,signalIDs]=...
                Simulink.sdi.getIDsFromViewIndices(...
                this.Engine.sigRepository,int32(info.idArray),info.clientID);
            end
            if isfield(info,'runIDs')&&~isempty(info.runIDs)
                runIDs=info.runIDs;
            end
            if isfield(info,'signalIDs')&&~isempty(info.signalIDs)
                signalIDs=info.signalIDs;
            end

            data.signalIDs=signalIDs;
            data.runIDs=runIDs;
            data=this.updateSupportedFileTypes(data);










            this.Dispatcher.publishToClient(arg.clientID,...
            this.ControllerID,'setSelectedSignalAndRunIDs',data);
        end


        function cb_ExportPlotToFigure(this,arg)
            try
                copyType='';
                argList={};
                if isfield(arg.data,'copyType')
                    copyType=arg.data.copyType;
                end
                if isfield(arg.data,'unplottedSignalID')&&arg.data.unplottedSignalID
                    argList{end+1}='unplottedSignalID';
                    argList{end+1}=arg.data.unplottedSignalID;
                end
                if isfield(arg.data,'displayList')&&~isempty(arg.data.displayList)
                    argList{end+1}='displayList';
                    argList{end+1}=arg.data.displayList;
                end
                if isfield(arg.data,'compareRunName')&&~isempty(arg.data.compareRunName)
                    argList{end+1}='compareRunName';
                    argList{end+1}=arg.data.compareRunName;
                end
                if isfield(arg.data,'signalName')&&~isempty(arg.data.signalName)
                    argList{end+1}='signalName';
                    argList{end+1}=arg.data.signalName;
                end
                if isfield(arg.data,'comparisonStatus')&&~isempty(arg.data.comparisonStatus)
                    argList{end+1}='comparisonStatus';
                    argList{end+1}=arg.data.comparisonStatus;
                end
                this.Engine.exportPlotToFigure(arg.data.clientID,arg.data.axesID,copyType,argList{:});
            catch me
                msgStr=me.message;
                okStr=getString(message('SDI:sdi:OKShortcut'));
                if strcmp(me.identifier,'SDI:sdi:SendToFigWhileStreaming')
                    appName='sdi';
                    titleStr=getString(message('SDI:sdi:SendToFigError'));
                elseif strcmp(me.identifier,'SDI:sdi:ExportWhileStreaming')
                    titleStr=getString(message('SDI:sdi:ExportError'));

                    info=arg.data;
                    appName=info.appName;
                end
                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                appName,titleStr,msgStr,{okStr},0,-1,[]);
            end
        end


        function cb_OverwriteVariableInBaseWorkspace(this,arg)



            import Simulink.sdi.internal.controllers.ExportDialog;
            try
                if strcmp(this.ActiveApp,'siganalyzer')
                    this.Engine.exportToBaseWorkspace(...
                    [],this.SignalIDs,this.ActiveApp,...
                    this.BaseWorkspace_VarName,false);
                else


                    assignin('base',this.BaseWorkspace_VarName,this.Data);
                end
            catch me
                this.Dispatcher.publishToClient(arg.clientID,...
                ExportDialog.ControllerID,'baseWorkspace_VarNameError',...
                me.message);

                if strcmp(this.ActiveApp,'siganalyzer')

                    this.Dispatcher.publishToClient(arg.clientID,ExportDialog.ControllerID,'resetExportDialogSpinner',[]);
                end

                return;
            end

            this.BaseWorkspace_VarName='';
            this.Data='';
            this.ActiveApp='';
            this.SignalIDs=[];
            this.helperCloseDialogOnOK(arg.clientID);
        end


        function cb_CloseDialog(this,arg)
            this.BaseWorkspace_VarName='';
            this.Data='';
            this.ActiveApp='';
            this.SignalIDs=[];
            this.helperCloseDialogOnOK(arg.clientID);
        end


        function cb_OverwriteExistingFile(this,arg)
            if strcmp(arg.data.activeApp,'SDI')
                this.helperCloseDialogOnOK(arg.clientID);
                bCmdLine=false;
                this.Engine.FileExporter.exportToFile(...
                arg.data.runIDs,arg.data.signalIDs,...
                arg.data.activeApp,this.Engine,...
                arg.data.file_FileName,true,...
                arg.data.exportToFileOptions,bCmdLine);
            else
                this.Engine.exportToMatFile(...
                arg.data.runIDs,arg.data.signalIDs,arg.data.activeApp,...
                arg.data.matFile_VarName,arg.data.matFile_FileName);
                this.helperCloseDialogOnOK(arg.clientID);
            end
        end


        function cb_ExportToIndividualSignals(this,arg)



            import Simulink.sdi.internal.controllers.ExportDialog;
            try
                info=this.Data;
                signalIDs=this.SignalIDs;
                baseWorkspace_VarName=this.BaseWorkspace_VarName;
                matFile_VarName=this.BaseWorkspace_VarName;





                varInfo=baseWorkspace_VarName;
                individualSignalNameExists=length(unique({varInfo.varName}))~=length(varInfo);

                if individualSignalNameExists
                    titleStr=getString(message('SDI:sdi:ExportError'));
                    msgStr=getString(message('SDI:sigAnalyzer:mgExportAsIndividualSignalsNamingError'));
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    arg.data.appName,...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    0,...
                    -1,...
                    []);
                    return;
                end




                this.BaseWorkspace_VarName='';
                this.Data='';
                this.SignalIDs=[];
                if strcmp(info.activeApp,'siganalyzer')
                    switch info.exportDestination
                    case 'exportDataBaseWorkspace'
                        this.exportSelectedDataToBaseWorkspace(...
                        [],signalIDs,info.activeApp,baseWorkspace_VarName,arg.clientID);
                    case 'exportDataMatFile'
                        matFile_FileName=info.matFile_FileName;
                        this.exportSelectedDataToMatFile(...
                        [],signalIDs,info.activeApp,matFile_VarName,matFile_FileName,arg.clientID);
                    case 'exportDataMatFileForceOverWrite'
                        matFile_FileName=info.matFile_FileName;
                        this.exportSelectedDataToMatFile(...
                        runIDs,signalIDs,info.activeApp,matFile_VarName,matFile_FileName,arg.clientID,true);
                    end
                end
            catch me
                this.Dispatcher.publishToClient(arg.clientID,...
                ExportDialog.ControllerID,'baseWorkspace_VarNameError',...
                me.message);

                if strcmp(info.activeApp,'siganalyzer')

                    this.Dispatcher.publishToClient(arg.clientID,ExportDialog.ControllerID,'resetExportDialogSpinner',[]);
                end
                return;
            end
        end
    end

    methods(Hidden)


        function exportSelectedDataToBaseWorkspace...
            (this,runIDs,signalIDs,activeApp,baseWorkspace_VarName,clientID)
            import Simulink.sdi.internal.controllers.ExportDialog;


            message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName','sdi'));
            tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName','sdi')));


            Simulink.SimulationData.utValidSignalOrCompositeData([],true);
            tmp2=onCleanup(@()Simulink.SimulationData.utValidSignalOrCompositeData([],false));

            try
                [variableExist,data]=...
                this.Engine.exportToBaseWorkspace(...
                runIDs,signalIDs,activeApp,baseWorkspace_VarName);
                delete(tmp);


                if variableExist

                    this.BaseWorkspace_VarName=baseWorkspace_VarName;
                    this.Data=data;
                    this.ActiveApp=activeApp;
                    this.SignalIDs=signalIDs;
                    this.Dispatcher.publishToClient(clientID,...
                    ExportDialog.ControllerID,'confirmOverwriteVariable',struct('varName',baseWorkspace_VarName));
                    return;
                elseif strcmp(activeApp,'labeler')



                    this.Dispatcher.publishToClient(clientID,...
                    ExportDialog.ControllerID,'confirmOverwriteVariableOk',struct('varName',baseWorkspace_VarName));
                    return;
                end
            catch me
                switch(me.identifier)
                case 'SDI:sdi:ExportWhileStreaming'
                    msgStr=me.message;
                    titleStr=getString(message('SDI:sdi:ExportError'));
                    okStr=getString(message('SDI:sdi:OKShortcut'));
                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    0,...
                    -1,...
                    []);
                case 'MATLAB:assigninInvalidVariable'

                    msgStr=getString(message('SDI:sdi:InvalidVarNameForExportErr',...
                    baseWorkspace_VarName));
                    this.Dispatcher.publishToClient(clientID,...
                    ExportDialog.ControllerID,'baseWorkspace_VarNameError',...
                    msgStr);
                    return;
                otherwise
                    this.Dispatcher.publishToClient(clientID,...
                    ExportDialog.ControllerID,'baseWorkspace_VarNameError',...
                    me.message);

                    if strcmp(activeApp,'siganalyzer')

                        this.Dispatcher.publishToClient(arg.clientID,ExportDialog.ControllerID,'resetExportDialogSpinner',[]);
                    end
                    return;
                end
            end


            this.helperCloseDialogOnOK(clientID);
        end


        function exportSelectedDataToMatFile...
            (this,runIDs,signalIDs,activeApp,matFile_VarName,matFile_FileName,clientID,forceOverWrite)
            import Simulink.sdi.internal.controllers.ExportDialog;
            if nargin<8
                forceOverWrite=false;
            end

            try

                [~,~,fext]=fileparts(matFile_FileName);
                if~strcmpi(fext,'.mat')
                    matFile_FileName=[matFile_FileName,'.mat'];
                end


                if exist(matFile_FileName,'file')>0&&~forceOverWrite
                    exportInfo={};
                    exportInfo.runIDs=runIDs;
                    exportInfo.signalIDs=signalIDs;
                    exportInfo.activeApp=activeApp;
                    exportInfo.matFile_VarName=matFile_VarName;
                    exportInfo.matFile_FileName=matFile_FileName;
                    exportInfo.clientID=clientID;

                    this.Dispatcher.publishToClient(clientID,...
                    ExportDialog.ControllerID,'confirmOverwriteExistingFile',...
                    exportInfo);
                    return;
                elseif strcmp(activeApp,'labeler')


                    exportInfo={};
                    exportInfo.runIDs=runIDs;
                    exportInfo.signalIDs=signalIDs;
                    exportInfo.activeApp=activeApp;
                    exportInfo.matFile_VarName=matFile_VarName;
                    exportInfo.matFile_FileName=matFile_FileName;
                    exportInfo.clientID=clientID;

                    this.Dispatcher.publishToClient(clientID,...
                    ExportDialog.ControllerID,'confirmOverWriteExistingFileOk',...
                    struct('data',exportInfo));
                    return;
                end
                this.Engine.exportToMatFile(...
                runIDs,signalIDs,activeApp,matFile_VarName,matFile_FileName);
            catch me


                this.Dispatcher.publishToClient(clientID,...
                ExportDialog.ControllerID,'matFile_FileNameError',...
                me.message);

                if strcmp(activeApp,'siganalyzer')

                    this.Dispatcher.publishToClient(clientID,ExportDialog.ControllerID,'resetExportDialogSpinner',[]);
                end
                return;












            end


            this.helperCloseDialogOnOK(clientID);
        end


        function exportSelectedDataToFile...
            (this,runIDs,signalIDs,activeApp,matFile_VarName,...
            file_FileName,clientID,exportToFileOptions)
            import Simulink.sdi.internal.controllers.ExportDialog;
            overwriteFile=false;
            try

                if exist(file_FileName,'file')
                    overwriteFile=true;
                    exportInfo={};
                    exportInfo.runIDs=runIDs;
                    exportInfo.signalIDs=signalIDs;
                    exportInfo.activeApp=activeApp;
                    exportInfo.file_VarName=matFile_VarName;
                    exportInfo.file_FileName=file_FileName;
                    exportInfo.clientID=clientID;
                    exportInfo.exportToFileOptions=exportToFileOptions;
                    [~,~,ext]=fileparts(file_FileName);

                    if strcmpi(ext,'.xlsx')
                        if strcmpi(exportInfo.exportToFileOptions.overwrite,'file')


                            this.Dispatcher.publishToClient(clientID,...
                            ExportDialog.ControllerID,...
                            'confirmOverwriteExistingFile',exportInfo);
                            return;
                        end
                    else


                        this.Dispatcher.publishToClient(clientID,...
                        ExportDialog.ControllerID,...
                        'confirmOverwriteExistingFile',exportInfo);
                        return;
                    end
                end
                this.helperCloseDialogOnOK(clientID);
                bCmdLine=false;
                this.Engine.FileExporter.exportToFile(...
                runIDs,signalIDs,activeApp,this.Engine,...
                file_FileName,overwriteFile,exportToFileOptions,...
                bCmdLine);
            catch me
                this.Dispatcher.publishToClient(clientID,...
                ExportDialog.ControllerID,'file_FileNameError',...
                me.message);
                return;
            end
        end


        function cb_BrowseFolderDialogRequest(this,arg)



            fileName='';
            activeApp='';
            isMP4Active=false;

            if isfield(arg,'data')
                if~isfield(arg.data,'appName')
                    fileName=arg.data;
                end
                if isfield(arg.data,'activeApp')
                    activeApp=arg.data.activeApp;
                end
                if isfield(arg.data,'isMP4Active')
                    isMP4Active=arg.data.isMP4Active;
                end
            end
            if isempty(fileName)
                fileFilter={'*.mat'};
                if strcmp(activeApp,'SDI')
                    fileFilter={'*.mat';'*.xlsx'};
                    if(Simulink.sdi.enableSDIVideo()>1)
                        fileFilter{end+1}='*.webm';
                    end
                    if isMP4Active
                        fileFilter{end+1}='*.mp4';
                    end
                end
                try
                    [filename,pathname]=uiputfile(fileFilter,...
                    Simulink.sdi.internal.StringDict.mgExportMatFolderUIBrowseTitle);
                catch me
                    okStr=getString(message('SDI:sdi:OKShortcut'));

                    info=arg.data;
                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    info.appName,...
                    Simulink.sdi.internal.StringDict.mgError,...
                    me.message,...
                    {okStr},...
                    0,...
                    -1,...
                    []);

                    if strcmp(activeApp,'siganalyzer')

                        this.Dispatcher.publishToClient(arg.clientID,ExportDialog.ControllerID,'resetExportDialogSpinner',[]);
                    end
                end

                if ischar(filename)&&ischar(pathname)
                    fileName=fullfile(pathname,filename);
                else
                    fileName=[];
                end
            end

            import Simulink.sdi.internal.controllers.ExportDialog;
            this.Dispatcher.publishToClient(arg.clientID,...
            ExportDialog.ControllerID,'matFile_FileName',...
            fileName);
        end


        function helperCloseDialogOnOK(this,clientID)
            import Simulink.sdi.internal.controllers.ExportDialog;
            this.Dispatcher.publishToClient(clientID,ExportDialog.ControllerID,'closeDialog',[]);
        end


        function data=updateSupportedFileTypes(this,data)
            repo=this.Engine.sigRepository;
            data.isMP4Supported=false;

            if numel(data.signalIDs)==1&&isempty(data.runIDs)
                sig=Simulink.sdi.getSignal(data.signalIDs);
                supportedTypes={'single','double','uint8'};
                if repo.isUnexpandedMatrix(sig.ID)&&...
                    ismember(class(sig.Values.Data),supportedTypes)&&...
                    (numel(sig.Dimensions)==2||numel(sig.Dimensions)==3)&&...
                    strcmp(sig.Complexity,'real')

                    data.isMP4Supported=true;
                end
            end

        end
    end


    properties(Access=private)
        Engine;
        Dispatcher;
        ActiveApp;
        SignalIDs;
    end

    properties
        BaseWorkspace_VarName;
        Data;
    end


    properties(Constant)
        ControllerID='exportDataDialog';
    end
end

