classdef ImportAudioController<handle





    properties(Constant)
        ControllerID='ImportAudioController';
    end

    properties(SetAccess=protected)
Dispatcher
        Engine;
        Model;
        ImportToJetstreamCtrl;
        ImportToLabelerAppCtrl;
ImportFromFileCtrl
    end

    events
DirtyStateChanged
    end

    methods(Static)
        function ctrl=getInstance()

            persistent ctrlObj
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=audio.labeler.internal.AudioDataRepository.getModel();
                sdiEngine=Simulink.sdi.Instance.engine();
                importToJetstreamCtrl=signal.sigappsshared.models.ImportFromDrop();
                importToLabelerAppCtrl=signal.labeler.controllers.Import.getController();
                importFromFileCtrl=signal.labeler.controllers.ImportSignalsFromFile.getController();

                ctrlObj=audio.labeler.internal.ImportAudioController(...
                dispatcherObj,modelObj,sdiEngine,...
                importToJetstreamCtrl,importToLabelerAppCtrl,importFromFileCtrl);
            end
            ctrl=ctrlObj;
        end

        function specStruct=getDialogSpecification(mode)

            specStruct=struct();


            audioExt=audioDatastore.getDefaultExtensions;
            if ismac

                audioExt(ismember(audioExt,{'.wma','.wmv','.avi'}))=[];
            elseif isunix

                audioExt(ismember(audioExt,{'.wma'}))=[];
            end
            specStruct.fileExtensions=audioExt;


            if strcmp(mode,'file')
                specStruct.dialogTitle=getString(message(...
                'shared_audiosiglabeler:labeler:BrowseAudioFilesDialogTitle'));
            else
                specStruct.dialogTitle=getString(message(...
                'shared_audiosiglabeler:labeler:BrowseAudioFolderDialogTitle'));
            end


            audioFilesLabel=getString(message('shared_audiosiglabeler:labeler:AudioFiles'));
            audioFilesDesc=append(audioFilesLabel," (*.wav,*.flac,*.mp3,*.m4a,...)");
            audioFilesSpecMATLAB=string(join(append('*',audioExt),';'));
            specStruct.fileFilterSpecMATLAB={audioFilesSpecMATLAB,audioFilesDesc};


            audioFilesSpecJS=string(join(audioExt,';'));
            specStruct.fileFilterSpecJS={append(audioFilesLabel,' |',audioFilesSpecJS)};
        end
    end

    methods(Access=protected)
        function this=ImportAudioController(dispatcherObj,modelObj,...
            sdiEngine,importToJetstreamCtrl,importToLabelerAppCtrl,...
            importFromFileCtrl)



            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            this.Engine=sdiEngine;
            this.ImportToJetstreamCtrl=importToJetstreamCtrl;
            this.ImportToLabelerAppCtrl=importToLabelerAppCtrl;
            this.ImportFromFileCtrl=importFromFileCtrl;


            lazyLoadDataHandler=audio.labeler.internal.LazyLoadAudioDataHandler();
            setLazyLoadDataHandler(this.ImportFromFileCtrl,lazyLoadDataHandler);


            import audio.labeler.internal.ImportAudioController;
            this.Dispatcher.subscribe(...
            [ImportAudioController.ControllerID,'/','preshowimportaudiofiles'],...
            @(arg)cb_preshowDialog(this,arg));
            this.Dispatcher.subscribe(...
            [ImportAudioController.ControllerID,'/','browseaudiofilesdialog'],...
            @(arg)cb_browseAudioFilesDialog(this,arg));
            this.Dispatcher.subscribe(...
            [ImportAudioController.ControllerID,'/','importaudiofiles'],...
            @(arg)cb_importAudioFiles(this,arg));
        end
    end

    methods
        function delete(~)

            munlock;
        end
    end


    methods(Hidden)
        function cb_preshowDialog(this,args)





            [success,errMsg]=audio.labeler.internal.AudioModeController.checkoutAudioToolboxLicense();
            if success
                data.mode=args.data.mode;
                data.dialogSpecification=this.getDialogSpecification(args.data.mode);

                this.Dispatcher.publishToClient(args.clientID,...
                'importAudioFilesController','readyToShowDialog',data);
            else
                errStruct=struct('ErrorType','AudioToolboxLicenseFailed',...
                'ErrorID','AudioToolboxLicenseFailedAtImport',...
                'ErrorMsg',errMsg);

                this.Dispatcher.publishToClient(args.clientID,...
                'importAudioFilesController','audioToolboxLicenseFailed',errStruct);
            end
        end

        function cb_browseAudioFilesDialog(this,args)


            dialogSpec=this.getDialogSpecification(args.data.mode);
            outData.fileOrFolderName={};
            if strcmp(args.data.mode,'file')

                [fileName,pathName]=uigetfile(dialogSpec.fileFilterSpecMATLAB,...
                dialogSpec.dialogTitle,'MultiSelect','on');
                if~isequal(fileName,0)
                    outData.fileOrFolderName=fullfile(pathName,fileName);
                end
            else

                pathName=uigetdir('',dialogSpec.dialogTitle);
                if pathName
                    outData.fileOrFolderName=pathName;
                end
            end
            this.Dispatcher.publishToClient(args.clientID,...
            'importAudioFilesController',...
            'selectionFromBrowseAudioFilesDialog',outData);
        end

        function cb_importAudioFiles(this,args)



            clientID=args.clientID;
            outDataStruct.isNewDataImported=false;
            outDataStruct.totalFiles=0;
            outDataStruct.hasExceptions=false;



            if isempty(args.data)||isempty(args.data.fileOrFolderName)

                notifyImportAudioSignalsComplete(this,clientID,outDataStruct);
                return;
            end


            importedFilesInfo=this.Model.addImportedAudioFilesToDatastore(args.data);
            if~importedFilesInfo.success
                outDataStruct.hasExceptions=true;
                outDataStruct.exceptions=struct('ErrorType',importedFilesInfo.errorType,...
                'ErrorID',importedFilesInfo.errorID,...
                'ErrorMsg',importedFilesInfo.errorMsg);
                notifyImportAudioSignalsComplete(this,clientID,outDataStruct);
                return;
            end


            hImportToJetStream=this.ImportToJetstreamCtrl;
            varsToImport=importedFilesInfo.newFileNames;
            metaStruct=signal.sigappsshared.Utilities.getMetaStruct('file','','','','',clientID);

            dataToImport=[0,0];
            importToRepositoryInfo=updateRepository(hImportToJetStream,...
            varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);


            hImportToApp=this.ImportToLabelerAppCtrl;
            successFlag=importSignal(hImportToApp,clientID,importToRepositoryInfo.newImportedSignalIDs,[]);
            if~successFlag
                error(message('SDI:dialogsLabeler:ImportToAppError'));
            end

            outDataStruct.isNewDataImported=true;
            outDataStruct.totalFiles=numel(importToRepositoryInfo.newImportedSignalIDs);
            outDataStruct.timeMode=args.data.timeMode;
            if isempty(this.Model.getAppDataMode())
                this.Model.setAppDataMode(args.data.appDataMode);
                outDataStruct.newAppDataMode=args.data.appDataMode;
            end
            notifyImportAudioSignalsComplete(this,clientID,outDataStruct);


            dirtyStateChanged=this.Model.setDirty(true);
            if dirtyStateChanged
                this.updateAppTitle(this.Model.isDirty());
                notify(this,'DirtyStateChanged',...
                signal.internal.SAEventData(struct('clientID',str2double(args.clientID))));
            end
        end
    end

    methods(Access=protected)
        function updateAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end

        function notifyImportAudioSignalsComplete(this,clientID,evtDataStruct)
            this.Dispatcher.publishToClient(clientID,...
            'importAudioFilesController','importComplete',evtDataStruct);
        end
    end
end
