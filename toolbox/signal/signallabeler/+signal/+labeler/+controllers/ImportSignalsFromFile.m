classdef ImportSignalsFromFile<handle




%#ok<*AGROW>

    properties(Hidden)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='ImportSignalsFromFile';
    end

    properties(Access=protected)
        Engine;
        Model;
        ImportToJetstreamCtrl;
        ImportToLabelerAppCtrl;
        TimeMetadataCtrl;
        LazyLoadDataHandler;
    end

    events
ImportSignalsFromFileComplete
ReadyToShowDialog
BrowseFolderDialogRequestComplete
LazyLoadFileDataUpdate
LazyLoadFileDataFailed
LazyLoadFileDataComplete
DirtyStateChanged
    end



    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)

                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                sdiEngine=Simulink.sdi.Instance.engine();
                importToJetstreamCtrl=signal.sigappsshared.models.ImportFromDrop();
                importToLabelerAppCtrl=signal.labeler.controllers.Import.getController();
                timeMetadataCtrl=signal.sigappsshared.controllers.TimeMetadataDialog.getController();

                ctrlObj=signal.labeler.controllers.ImportSignalsFromFile(...
                dispatcherObj,modelObj,sdiEngine,importToJetstreamCtrl,importToLabelerAppCtrl,timeMetadataCtrl);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)
        function this=ImportSignalsFromFile(dispatcherObj,modelObj,sdiEngine,importToJetstreamCtrl,importToLabelerAppCtrl,timeMetadataCtrl)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            this.ImportToJetstreamCtrl=importToJetstreamCtrl;
            this.ImportToLabelerAppCtrl=importToLabelerAppCtrl;
            this.TimeMetadataCtrl=timeMetadataCtrl;
            this.Engine=sdiEngine;

            import signal.labeler.controllers.ImportSignalsFromFile;

            this.Dispatcher.subscribe(...
            [ImportSignalsFromFile.ControllerID,'/','preshowimportsignalsfromfile'],...
            @(arg)cb_preshowDialog(this,arg));


            this.Dispatcher.subscribe(...
            [ImportSignalsFromFile.ControllerID,'/','importsignalsfromfile'],...
            @(arg)cb_import(this,arg));

            this.Dispatcher.subscribe(...
            [ImportSignalsFromFile.ControllerID,'/','lazyloaddata'],...
            @(arg)cb_lazyLoadData(this,arg));

            this.Dispatcher.subscribe(...
            [ImportSignalsFromFile.ControllerID,'/','browsefolderdialog'],...
            @(arg)cb_BrowseFolderDialogRequest(this,arg));

            this.Dispatcher.subscribe(...
            [ImportSignalsFromFile.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end



    methods(Hidden)



        function info=lazyLoadFileData(this,clientID,memberIDsForLazyLoad,srcAction)
            info.success=false;
            info.errors=[];
            hImportToJetStream=this.ImportToJetstreamCtrl;
            totalMemberIDs=numel(memberIDsForLazyLoad);
            for idx=1:totalMemberIDs
                if mod(idx-1,5)==0||idx==totalMemberIDs
                    eventData=struct('clientID',clientID,...
                    'loadedFiles',idx-1,...
                    'totalFiles',totalMemberIDs);
                    this.notify('LazyLoadFileDataUpdate',signal.internal.SAEventData(eventData));
                end
                currentMemberID=memberIDsForLazyLoad(idx);
                dataInfo=this.Model.getDataFromDataStoreForMemberID(currentMemberID);
                if dataInfo.success
                    hLazyLoadDataHandler=getLazyLoadDataHandler(this,this.Model.getAppDataMode());
                    createdSignalInfo=addDataToDBSignal(hLazyLoadDataHandler,hImportToJetStream,dataInfo,currentMemberID,clientID);

                    if~isempty(createdSignalInfo.newImportedSignalIDs)

                        this.reparentSignals(createdSignalInfo.newImportedSignalIDs,int32(currentMemberID));
                        hImportToApp=this.ImportToLabelerAppCtrl;
                        successFlag=importChildrenSignal(hImportToApp,clientID,currentMemberID,createdSignalInfo.newImportedSignalIDs,true,srcAction);
                        if~successFlag
                            error(message('SDI:dialogsLabeler:ImportToAppError'));
                        end
                    end
                else
                    errorData=struct('clientID',clientID,...
                    'FileID',dataInfo.fileID,...
                    'FileName',dataInfo.fileName,...
                    'VarName',dataInfo.varName,...
                    'ErrorID',dataInfo.errorID,...
                    'ErrorMsg',dataInfo.errorMsg);
                    this.notify('LazyLoadFileDataFailed',signal.internal.SAEventData(errorData));
                    break;
                end
            end
            info.success=dataInfo.success;
        end

        function info=reparentSignals(this,childrenIDs,parentID)
            info=[];
            for idx=1:numel(childrenIDs)
                this.Engine.sigRepository.setParent(childrenIDs(idx),parentID);
            end
        end



        function cb_HelpButton(~,args)
            data=args.data;

            if strcmp(data.messageID,'importFromFile')
                signal.labeler.controllers.SignalLabelerHelp('importFromFileHelp');
            end
            if strcmp(data.messageID,'importFromFilesInFolder')
                signal.labeler.controllers.SignalLabelerHelp('importFromFilesInFolderHelp');
            end
        end

        function cb_preshowDialog(this,args)
            infoStruct.fileModeSettings=this.Model.getFileModeSettings();
            infoStruct.mode=args.data.mode;

            this.notify('ReadyToShowDialog',...
            signal.internal.SAEventData(struct('clientID',args.clientID,'data',infoStruct)));
        end

        function cb_BrowseFolderDialogRequest(this,args)
            try
                if args.data.mode=="file"
                    fileFilter={'*'};
                    if isfield(args.data,'fileExtensions')
                        fileFilter=args.data.fileExtensions;
                        for idx=1:numel(args.data.fileExtensions)
                            fileFilter{idx}="*"+fileFilter{idx};
                        end
                    end
                    multiSelect='on';
                    [fileOrFolderNameDlg,pathNameDlg]=uigetfile(fileFilter,...
                    getString(message('SDI:dialogsLabeler:ImportSignalsFromFileDialogTitle')),...
                    'MultiSelect',multiSelect);
                elseif args.data.mode=="folder"
                    pathNameDlg=[];
                    fileOrFolderNameDlg=uigetdir('',...
                    getString(message('SDI:dialogsLabeler:ImportSignalsFromFolderDialogTitle')));
                end
            catch

            end
            fileOrFolderName={};
            if ischar(fileOrFolderNameDlg)&&isempty(pathNameDlg)
                fileOrFolderName=fileOrFolderNameDlg;
            elseif ischar(fileOrFolderNameDlg)&&ischar(pathNameDlg)
                fileOrFolderName=fullfile(pathNameDlg,fileOrFolderNameDlg);
            elseif iscell(fileOrFolderNameDlg)&&ischar(pathNameDlg)
                for idx=1:numel(fileOrFolderNameDlg)
                    fileOrFolderName{end+1}=fullfile(pathNameDlg,fileOrFolderNameDlg{idx});
                end
            end

            outData.clientID=args.clientID;
            outData.messageID='selectionFromBrowseFolderDialog';
            outData.data.fileOrFolderName=fileOrFolderName;
            this.notify('BrowseFolderDialogRequestComplete',signal.internal.SAEventData(outData));
        end

        function cb_import(this,args)
            clientID=args.clientID;
            if(isfield(args.data,"signalColoringType"))
                signalColoringType=args.data.signalColoringType;
            else
                signalColoringType="differentColors";
            end



            importedFilesInfo=this.Model.addImportedFilesToDataStore(args.data);
            if~importedFilesInfo.success
                evtDataStruct.isNewDataImported=false;
                evtDataStruct.hasExceptions=true;
                evtDataStruct.exceptions=struct('ErrorType',importedFilesInfo.errorType,...
                'ErrorID',importedFilesInfo.errorID,...
                'ErrorMsg',importedFilesInfo.errorMsg);
                notifyImportFromFileComplete(this,clientID,evtDataStruct);
                return;
            end
            hImportToJetStream=this.ImportToJetstreamCtrl;

            varsToImport=importedFilesInfo.newFileNames;
            metaStruct=this.getMetaStruct('file','','','','',clientID);

            dataToImport=[0,0];
            importToRepositoryInfo=updateRepository(hImportToJetStream,...
            varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);

            hImportToApp=this.ImportToLabelerAppCtrl;

            successFlag=importSignal(hImportToApp,clientID,importToRepositoryInfo.newImportedSignalIDs,[],signalColoringType);
            if~successFlag
                error(message('SDI:dialogsLabeler:ImportToAppError'));
            end

            importedMemberSignals=importToRepositoryInfo.newImportedSignalIDs;




            for idx=1:length(importedMemberSignals)
                this.Model.addToMemberIDcolorRuleMap(importedMemberSignals(idx),signalColoringType);
            end


            evtDataStruct.isNewDataImported=true;
            evtDataStruct.hasExceptions=false;
            evtDataStruct.totalFiles=numel(importToRepositoryInfo.newImportedSignalIDs);
            evtDataStruct.timeMode=args.data.timeMode;
            if isempty(this.Model.getAppDataMode())
                this.Model.setAppDataMode(args.data.appDataMode);
                evtDataStruct.newAppDataMode=args.data.appDataMode;
            end
            notifyImportFromFileComplete(this,clientID,evtDataStruct);


            dirtyStateChanged=this.Model.setDirty(true);
            if dirtyStateChanged
                this.changeAppTitle(this.Model.isDirty());
                this.notify('DirtyStateChanged',...
                signal.internal.SAEventData(struct('clientID',str2double(args.clientID))));
            end
        end

        function cb_lazyLoadData(this,args)
            clientID=args.clientID;
            info=this.Model.getMemberIDsRequiringLazyLoad(this.Model.getMemberIDs());
            lazyloadInfo.success=true;
            if~isempty(info.memberIDsForLazyLoad)
                lazyloadInfo=lazyLoadFileData(this,args.clientID,info.memberIDsForLazyLoad,args.data.srcAction);
            end

            if lazyloadInfo.success
                this.notify('LazyLoadFileDataComplete',...
                signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID','lazyLoadComplete','data',args.data)));
            else
            end
        end

        function setLazyLoadDataHandler(this,lazyLoadDataHandler)
            this.LazyLoadDataHandler=lazyLoadDataHandler;
        end

        function y=getLazyLoadDataHandler(this,appDataMode)
            if appDataMode=="signalFile"
                y=signal.labeler.controllers.LazyLoadDataHandlerActionBase();
            else


                y=this.LazyLoadDataHandler;
            end
        end
    end



    methods(Access=protected)
        function args=getMetaStruct(~,mode,Fs,Ts,St,Tv,clientID)
            args=signal.sigappsshared.Utilities.getMetaStruct(mode,Fs,Ts,St,Tv,clientID);
        end

        function notifyImportFromFileComplete(this,clientID,evtData)
            this.notify('ImportSignalsFromFileComplete',...
            signal.internal.SAEventData(struct('clientID',clientID,'data',evtData)));
        end
    end

    methods
        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end
    end
end
