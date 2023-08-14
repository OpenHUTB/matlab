classdef ImportSignalsFromWorkspace<handle




%#ok<*AGROW>

    properties(Hidden)

        Dispatcher;
    end

    properties(Constant)
        ControllerID='ImportSignalsFromWorkspace';
        WorkspaceName='signal.labeler.FilteredWorkspace';
        WorkspaceChannel='/SigLabelerWSBChannel';
    end

    properties(Access=protected)
        WSB;
        WSBEventListener;
        ClientID=[];
        Engine;
        Model;
        TimeMetadataDialogSettings;
        ImportToJetstreamCtrl;
        TmportToLabelerAppCtrl;
        TimeMetadataCtrl;
        LabelDefinitionCtrl;
    end

    events
ImportSignalsFromWorkspaceComplete
ReadyToShowDialog
WSBSelectionChange
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
                lblDefCtrl=signal.labeler.controllers.LabelDefinitionController.getController();

                ctrlObj=signal.labeler.controllers.ImportSignalsFromWorkspace(...
                dispatcherObj,modelObj,sdiEngine,importToJetstreamCtrl,importToLabelerAppCtrl,timeMetadataCtrl,lblDefCtrl);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)
        function this=ImportSignalsFromWorkspace(dispatcherObj,modelObj,sdiEngine,importToJetstreamCtrl,importToLabelerAppCtrl,timeMetadataCtrl,lblDefCtrl)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            this.ImportToJetstreamCtrl=importToJetstreamCtrl;
            this.TmportToLabelerAppCtrl=importToLabelerAppCtrl;
            this.TimeMetadataCtrl=timeMetadataCtrl;
            this.LabelDefinitionCtrl=lblDefCtrl;
            this.Engine=sdiEngine;

            this.TimeMetadataDialogSettings=struct(...
            'sampleRateValue',"",...
            'sampleRateUnits',"Hz",...
            'sampleTimeValue',"",...
            'sampleTimeUnits',"s",...
            'timeValuesValue',"");

            import signal.labeler.controllers.ImportSignalsFromWorkspace;


            this.Dispatcher.subscribe(...
            [ImportSignalsFromWorkspace.ControllerID,'/','preshowimportsignalsfromworkspace'],...
            @(arg)cb_preshowDialog(this,arg));


            this.Dispatcher.subscribe(...
            [ImportSignalsFromWorkspace.ControllerID,'/','importsignalsfromworkspace'],...
            @(arg)cb_import(this,arg));

            this.Dispatcher.subscribe(...
            [ImportSignalsFromWorkspace.ControllerID,'/','closeimportsignalsfromworkspace'],...
            @(arg)cb_onDialogClose(this,arg));
        end
    end



    methods(Hidden)




        function updateWSBFilterState(this,appDataMode,appTimeMode)
            if appDataMode=="inMemory"
                this.WSB.Workspace.isIncludeFileData=false;
                this.WSB.Workspace.isIncludeInMemoryData=true;
                this.WSB.Workspace.filteredSources=["signalDatastore","audioDatastore"];
            elseif appDataMode=="signalFile"||appDataMode=="audioFile"
                this.WSB.Workspace.isIncludeFileData=true;
                this.WSB.Workspace.isIncludeInMemoryData=false;
                this.WSB.Workspace.filteredSources=string(class(this.Model.getDataStoreForApp()));
            else
                this.WSB.Workspace.isIncludeFileData=true;
                this.WSB.Workspace.isIncludeInMemoryData=true;
            end



            if appDataMode=="signalFile"||appDataMode=="audioFile"
                this.WSB.Workspace.isIncludeLSSInSamples=false;
                this.WSB.Workspace.isIncludeDataWithTime=false;
            elseif appTimeMode=="none"
                this.WSB.Workspace.isIncludeLSSInSamples=true;
                this.WSB.Workspace.isIncludeDataWithTime=true;
            elseif appTimeMode=="samples"
                this.WSB.Workspace.isIncludeLSSInSamples=true;
                this.WSB.Workspace.isIncludeDataWithTime=false;
            else
                this.WSB.Workspace.isIncludeLSSInSamples=false;
                this.WSB.Workspace.isIncludeDataWithTime=true;
            end
            this.updateVariablesInWSB();
        end

        function updateVariablesInWSB(this)

            this.WSB.Workspace.updateVariables(evalin('base','who'));
        end

        function y=getWSB(this)
            y=this.WSB;
        end



        function cb_preshowDialog(this,args)

            this.ClientID=args.clientID;


            wsb=getWSBInstance(this);
            suscribeToWSBEvents(this,wsb);
            this.WSB=wsb;
            this.updateWSBFilterState(this.Model.getAppDataMode(),args.data.appTimeMode);

            infoStruct.selectionState=getCurrentWSBSelectionData(this,false);
            infoStruct.timeMetadataDialogSettings=this.TimeMetadataDialogSettings;

            this.notify('ReadyToShowDialog',...
            signal.internal.SAEventData(struct('clientID',this.ClientID,'data',infoStruct)));
        end

        function cb_wsbSelectionChangedEvent(this,~,evtData)
            if string(evtData.EventData.key)=="Selection"
                infoStruct=getCurrentWSBSelectionData(this,false);
                this.notify('WSBSelectionChange',...
                signal.internal.SAEventData(struct('clientID',this.ClientID,'data',infoStruct)));
            end
        end

        function cb_onDialogClose(this,args)
            currentSettings=args.data.timeMetadataSettings;
            settingsToSave=struct(...
            'sampleRateValue',"",...
            'sampleRateUnits',"Hz",...
            'sampleTimeValue',"",...
            'sampleTimeUnits',"s",...
            'timeValuesValue',"");
            if string(currentSettings.sampleRateValueErrorState)=="normal"
                settingsToSave.sampleRateValue=currentSettings.sampleRateValue;
                settingsToSave.sampleRateUnits=currentSettings.sampleRateUnits;
            end
            if string(currentSettings.sampleTimeValueErrorState)=="normal"
                settingsToSave.sampleTimeValue=currentSettings.sampleTimeValue;
                settingsToSave.sampleTimeUnits=currentSettings.sampleTimeUnits;
            end
            if string(currentSettings.timeValuesValueErrorState)=="normal"
                settingsToSave.timeValuesValue=currentSettings.timeValuesValue;
            end
            this.TimeMetadataDialogSettings=settingsToSave;
        end

        function cb_import(this,args)







            clientID=args.clientID;
            timeMetadataSettings=args.data.timeMetadataSettings;

            if(isfield(args.data,"signalColoringType"))
                signalColoringType=args.data.signalColoringType;
            else
                signalColoringType="differentColors";
            end




            isTimeMetadataInfoAvailable=...
            timeMetadataSettings.isTimeInfoControlsActive&&string(timeMetadataSettings.timeMode)=="time";



            appTimeMode=string(args.data.appTimeMode);
            hImportToJetStream=this.ImportToJetstreamCtrl;
            hAddLblDef=this.LabelDefinitionCtrl;
            hImportToApp=this.TmportToLabelerAppCtrl;

            evtDataStruct=struct('isNewDataImported',false,'newAppTimeMode','',...
            'exceptions',struct('LSSException',"",'MetadataErorMsg',"",...
            'InvalidTimeInherentDataException',"",'UniqueNamesException',""));

            sigInfoStruct=getCurrentWSBSelectionData(this,true);


            [concatLSS,isTimeLSS,lssException,uniqueLblDefsInConcatLSS]=verifyLSSSelections(...
            this,sigInfoStruct.lssWithNoTimeData,sigInfoStruct.lssWithTimeData,sigInfoStruct.lssWithFileDataStoreData);
            if~isempty(lssException)

                evtDataStruct.exceptions.LSSException=lssException;
            end


            if~checkUniqueMemberNames(this,[sigInfoStruct.nonInherentVars;sigInfoStruct.inherentVars],concatLSS)
                evtDataStruct.exceptions.UniqueNamesException="LSSFailedMergeMembers";
                notifyImportFromWorkspaceComplete(this,evtDataStruct);
                return;
            end

            if~isempty(concatLSS)

                if numel(uniqueLblDefsInConcatLSS)>0
                    addLabelDefinitions(hAddLblDef,clientID,uniqueLblDefsInConcatLSS);
                end
            end

            evtDataStruct.newAppTimeMode=appTimeMode;
            newImportedSignalIDs=[];
            varsToImport=[];
            if appTimeMode=="samples"

                varsToImport=sigInfoStruct.nonInherentVars;
                dataToImport=sigInfoStruct.nonInherentData;
                metaStruct=getMetaStruct(this,'samples',[],[],[],[]);
                importToRepositoryInfo=updateRepository(hImportToJetStream,...
                varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
            elseif appTimeMode=="time"


                if~isempty(sigInfoStruct.inherentVars)
                    varsToImport=sigInfoStruct.inherentVars;
                    dataToImport=sigInfoStruct.inherentData;
                    metaStruct=getMetaStruct(this,"inherent",[],[],[],[]);
                    importToRepositoryInfo=updateRepository(hImportToJetStream,...
                    varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                    newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
                    if~isempty(importToRepositoryInfo.errorIDForUnImportedInherentVars)
                        evtDataStruct.exceptions.InvalidTimeInherentDataException=importToRepositoryInfo.errorIDForUnImportedInherentVars;
                    end
                end
                if isTimeMetadataInfoAvailable&&~isempty(sigInfoStruct.nonInherentVars)
                    [successFlag,metaStruct,metadataErrorMsg]=...
                    checkTimeMetadata(this,timeMetadataSettings,sigInfoStruct.nonInherentData);
                    if successFlag
                        varsToImport=sigInfoStruct.nonInherentVars;
                        dataToImport=sigInfoStruct.nonInherentData;
                        importToRepositoryInfo=updateRepository(hImportToJetStream,...
                        varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                        newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
                    else
                        evtDataStruct.exceptions.MetadataErorMsg=metadataErrorMsg;
                        sigInfoStruct.nonInherentVars=[];
                        sigInfoStruct.nonInherentData=[];
                    end
                end
            else




                if~isempty(sigInfoStruct.nonInherentVars)&&~isTimeMetadataInfoAvailable
                    metaStruct=getMetaStruct(this,'samples',[],[],[],[]);
                    evtDataStruct.newAppTimeMode="samples";
                    varsToImport=sigInfoStruct.nonInherentVars;
                    dataToImport=sigInfoStruct.nonInherentData;
                    importToRepositoryInfo=updateRepository(hImportToJetStream,...
                    varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                    newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
                end
                if~isempty(sigInfoStruct.inherentVars)
                    metaStruct=getMetaStruct(this,"inherent",[],[],[],[]);
                    evtDataStruct.newAppTimeMode="time";
                    varsToImport=sigInfoStruct.inherentVars;
                    dataToImport=sigInfoStruct.inherentData;
                    importToRepositoryInfo=updateRepository(hImportToJetStream,...
                    varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                    newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
                    if~isempty(importToRepositoryInfo.errorIDForUnImportedInherentVars)
                        evtDataStruct.exceptions.InvalidTimeInherentDataException=importToRepositoryInfo.errorIDForUnImportedInherentVars;
                    end
                end
                if~isempty(concatLSS)
                    evtDataStruct.newAppTimeMode="samples";
                    if isTimeLSS
                        evtDataStruct.newAppTimeMode="time";
                    end
                end

                if~isempty(sigInfoStruct.nonInherentVars)
                    [successFlag,metaStruct,metadataErrorMsg]=...
                    checkTimeMetadata(this,timeMetadataSettings,sigInfoStruct.nonInherentData);

                    if successFlag
                        if isTimeMetadataInfoAvailable
                            evtDataStruct.newAppTimeMode="time";
                        end
                        varsToImport=sigInfoStruct.nonInherentVars;
                        dataToImport=sigInfoStruct.nonInherentData;
                        importToRepositoryInfo=updateRepository(hImportToJetStream,...
                        varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                        newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
                    else
                        evtDataStruct.exceptions.MetadataErorMsg=metadataErrorMsg;
                        sigInfoStruct.nonInherentVars=[];
                        sigInfoStruct.nonInherentData=[];
                    end
                end

            end
            isLSSWithDataStore=false;
            if~isempty(concatLSS)
                if isa(concatLSS.getPrivateSourceData,'signalDatastore')||isa(concatLSS.getPrivateSourceData,'audioDatastore')
                    isLSSWithDataStore=true;
                    varsToImport=concatLSS.getPrivateSourceData.Files;
                    metaStruct=getMetaStruct(this,'file','','','','');

                    dataToImport=[0,0];
                    importToRepositoryInfo=updateRepository(hImportToJetStream,...
                    varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                    newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
                else
                    varsToImport=getUniqueLSSName(this);
                    dataToImport={concatLSS};
                    metaStruct=getMetaStruct(this,"inherentLabeledSignalSet",[],[],[],[]);
                    importToRepositoryInfo=updateRepository(hImportToJetStream,...
                    varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataToImport);
                    newImportedSignalIDs=[newImportedSignalIDs;importToRepositoryInfo.newImportedSignalIDs];
                end
            end
            if isempty(varsToImport)||isempty(newImportedSignalIDs)
                notifyImportFromWorkspaceComplete(this,evtDataStruct);
                return;
            end


            [successFlag,isShowIncompatibleLabelWarning]=importSignal(hImportToApp,clientID,newImportedSignalIDs,concatLSS,signalColoringType);
            if~successFlag
                error(message('SDI:dialogsLabeler:ImportToAppError'));
            end
            evtDataStruct.isNewDataImported=true;
            evtDataStruct.isShowIncompatibleLabelWarning=isShowIncompatibleLabelWarning;
            if isempty(this.Model.getAppDataMode())
                newDataMode='inMemory';
                if isLSSWithDataStore&&isa(concatLSS.getPrivateSourceData,'audioDatastore')
                    newDataMode='audioFile';
                elseif isLSSWithDataStore
                    newDataMode='signalFile';
                end
                this.Model.setAppDataMode(newDataMode);
                this.updateWSBFilterState(newDataMode,evtDataStruct.newAppTimeMode);
                evtDataStruct.newAppDataMode=newDataMode;
            end

            notifyImportFromWorkspaceComplete(this,evtDataStruct);


            dirtyStateChanged=this.Model.setDirty(true);
            if dirtyStateChanged
                this.changeAppTitle(this.Model.isDirty());
                this.notify('DirtyStateChanged',...
                signal.internal.SAEventData(struct('clientID',str2double(args.clientID))));
            end
        end
    end



    methods(Access=protected)

        function[successFlag,metaStruct,errMsg]=checkTimeMetadata(this,timeMetadataSettings,data)

            metaStruct=getMetaStruct(this,'time',[],[],[],[]);


            args=getValidationArguments(this,timeMetadataSettings);
            tmd=this.TimeMetadataCtrl;
            [successFlag,errMsg,parsedMetadata]=checkTimeMetadata(tmd,args);

            if~successFlag
                return
            end

            if string(parsedMetadata.TmMode)=="tv"

                for idx=1:numel(data)
                    dataToCheck=data{idx};
                    [successFlag,errMsg]=checkTimeVectorSize(this,parsedMetadata.tv,dataToCheck);
                    if~successFlag
                        return;
                    end
                end
                metaStruct=getMetaStruct(this,parsedMetadata.TmMode,[],[],[],parsedMetadata.tv);

            elseif string(parsedMetadata.TmMode)=="fs"
                m=signal.sigappsshared.Utilities.getFrequencyMultiplier(lower(timeMetadataSettings.sampleRateUnits));
                fs=parsedMetadata.fs*m;
                metaStruct=getMetaStruct(this,parsedMetadata.TmMode,fs,[],0,[]);
            else
                m=signal.sigappsshared.Utilities.getTimeMultiplier(lower(timeMetadataSettings.sampleTimeUnits));
                ts=parsedMetadata.ts*m;
                metaStruct=getMetaStruct(this,parsedMetadata.TmMode,[],ts,0,[]);
            end
        end

        function args=getValidationArguments(~,settings)


            args.updateObjectFlag=false;
            args.validateSignalLengthFlag=false;
            args.sendWarningFlag=false;
            switch string(settings.timeSpecValue)
            case "fs"
                args.tmMode='fs';
                args.sampleTimeOrRate=settings.sampleRateValue;
                args.startTime='0';
            case "ts"
                args.tmMode='ts';
                args.sampleTimeOrRate=settings.sampleTimeValue;
                args.startTime='0';
            case "tv"
                args.tmMode='tv';
                args.timeVector=settings.timeValuesValue;
            end
        end

        function[flag,errMsg]=checkTimeVectorSize(~,tv,dataToCheck)
            errMsg="";
            if~isvector(tv)
                errMsg=getString(message('SDI:dialogsLabeler:InvalidTimeMetadataTimeValuesSize'));
                flag=false;
            else
                if iscell(dataToCheck)


                    lengths=cellfun(@length,dataToCheck);
                    flag=all(lengths==length(tv));
                elseif isvector(dataToCheck)
                    flag=(length(tv)==length(dataToCheck));
                else
                    flag=(length(tv)==size(dataToCheck,1));
                end

                if~flag
                    errMsg=getString(message('SDI:dialogsLabeler:InvalidTimeMetadataTimeValuesSize'));
                end
            end
        end

        function args=getMetaStruct(this,mode,Fs,Ts,St,Tv)
            args=signal.sigappsshared.Utilities.getMetaStruct(mode,Fs,Ts,St,Tv,this.ClientID);
        end

        function WSB=getWSBInstance(this)
            WSB=internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.createWorkspaceBrowser(this.WorkspaceName,this.WorkspaceChannel);
        end

        function selectionIndices=getWSBSelection(~,wsb)
            selectionIndices=wsb.Documents.ViewModel.getSelection;
        end

        function d=getWSBRenderedData(~,wsb)
            wsbSize=wsb.Documents.ViewModel.DataModel.CachedSize(1);
            d=wsb.Documents.ViewModel.getRenderedData(1,wsbSize,1,4);
        end

        function data=getWSBDatabyName(~,wsb,varName)
            data=wsb.Documents.ViewModel.DataModel.Workspace.(varName);
        end

        function suscribeToWSBEvents(this,wsb)
            wsb.Documents.ViewModel.setTableModelProperty('ShowValueColumn',false);
            this.WSBEventListener=...
            event.listener(wsb.Documents.ViewModel.PeerNode,'PropertySet',...
            @(src,eventData)cb_wsbSelectionChangedEvent(this,src,eventData));
        end

        function infoStruct=getCurrentWSBSelectionData(this,returnDataFlag)





            infoStruct.numSelectedVars=0;
            infoStruct.inherentVars=[];
            infoStruct.nonInherentVars=[];
            infoStruct.lssWithTimeVars=[];
            infoStruct.lssWithNoTimeVars=[];
            infoStruct.lssWithFileDataStore=[];

            if returnDataFlag
                infoStruct.inherentData={};
                infoStruct.nonInherentData={};
                infoStruct.lssWithTimeData={};
                infoStruct.lssWithNoTimeData={};
                infoStruct.lssWithFileDataStoreData={};
            end

            wsb=this.WSB;
            selectionIndices=getWSBSelection(this,wsb);
            rowSelectionIndices=selectionIndices{1};





            d=getWSBRenderedData(this,wsb);
            infoStruct.numSelectedVars=size(rowSelectionIndices,1);
            for idx=1:infoStruct.numSelectedVars




                propStruct=jsondecode(d{rowSelectionIndices(idx,1)});

                className=string(propStruct.class);
                varName=string(propStruct.value);

                if className=="timetable"
                    infoStruct.inherentVars=[infoStruct.inherentVars;varName];
                    if returnDataFlag
                        infoStruct.inherentData=[infoStruct.inherentData;{getWSBDatabyName(this,wsb,varName)}];
                    end
                elseif className=="cell"
                    data=getWSBDatabyName(this,wsb,varName);
                    if istimetable(data{1})
                        infoStruct.inherentVars=[infoStruct.inherentVars;varName];
                        if returnDataFlag
                            infoStruct.inherentData=[infoStruct.inherentData;{data}];
                        end
                    else
                        infoStruct.nonInherentVars=[infoStruct.nonInherentVars;varName];
                        if returnDataFlag
                            infoStruct.nonInherentData=[infoStruct.nonInherentData;{data}];
                        end
                    end
                elseif className=="labeledSignalSet"
                    data=wsb.Documents.ViewModel.DataModel.Workspace.(varName);
                    if isa(data.getPrivateSourceData,'signalDatastore')||isa(data.getPrivateSourceData,'audioDatastore')
                        infoStruct.lssWithFileDataStore=[infoStruct.lssWithFileDataStore;varName];
                        if returnDataFlag
                            infoStruct.lssWithFileDataStoreData=[infoStruct.lssWithFileDataStoreData;{data}];
                        end
                    elseif data.TimeInformation=="none"
                        infoStruct.lssWithNoTimeVars=[infoStruct.lssWithNoTimeVars;varName];
                        if returnDataFlag
                            infoStruct.lssWithNoTimeData=[infoStruct.lssWithNoTimeData;{data}];
                        end
                    else
                        infoStruct.lssWithTimeVars=[infoStruct.lssWithTimeVars;varName];
                        if returnDataFlag
                            infoStruct.lssWithTimeData=[infoStruct.lssWithTimeData;{data}];
                        end
                    end
                else
                    infoStruct.nonInherentVars=[infoStruct.nonInherentVars;varName];
                    if returnDataFlag
                        infoStruct.nonInherentData=[infoStruct.nonInherentData;{getWSBDatabyName(this,wsb,varName)}];
                    end
                end
            end

            haveNonInherentVars=~isempty(infoStruct.nonInherentVars);
            haveInherentVars=~isempty(infoStruct.inherentVars);
            haveLSSWithNoTimeVars=~isempty(infoStruct.lssWithNoTimeVars);
            haveLSSWithTimeVars=~isempty(infoStruct.lssWithTimeVars);
            haveLSSWithFileDatastore=~isempty(infoStruct.lssWithFileDataStore);

            if haveNonInherentVars&&haveInherentVars
                infoStruct.selectionModeForVars="combination";
            elseif haveNonInherentVars&&~haveInherentVars
                infoStruct.selectionModeForVars="allNonInherent";
            elseif~haveNonInherentVars&&haveInherentVars
                infoStruct.selectionModeForVars="allInherent";
            else
                infoStruct.selectionModeForVars="none";
            end

            if haveLSSWithFileDatastore
                if haveLSSWithNoTimeVars||haveLSSWithTimeVars
                    infoStruct.selectionModeForLSS="combinationWithFileDatastore";
                else
                    infoStruct.selectionModeForLSS="allFileDatastore";
                end
            elseif haveLSSWithNoTimeVars&&haveLSSWithTimeVars
                infoStruct.selectionModeForLSS="combination";
            elseif haveLSSWithNoTimeVars&&~haveLSSWithTimeVars
                infoStruct.selectionModeForLSS="allNoTime";
            elseif~haveLSSWithNoTimeVars&&haveLSSWithTimeVars
                infoStruct.selectionModeForLSS="allTime";
            else
                infoStruct.selectionModeForLSS="none";
            end
        end

        function[concatLSS,isTimeLSS,exceptionKeyword,uniqueLblDefsInConcatLSS]=verifyLSSSelections(this,lssWithNoTimeData,lssWithTimeData,lssWithFileDataStore)





            concatLSS=[];
            exceptionKeyword="";
            isTimeLSS=[];
            isLSSWithFileDataStores=false;
            uniqueLblDefsInConcatLSS=[];
            if isempty(lssWithNoTimeData)&&isempty(lssWithTimeData)&&isempty(lssWithFileDataStore)
                return;
            elseif~isempty(lssWithFileDataStore)
                lssData=lssWithFileDataStore;
                isTimeLSS=false;
                isLSSWithFileDataStores=true;
            elseif~isempty(lssWithNoTimeData)

                lssData=lssWithNoTimeData;
                isTimeLSS=false;
            else

                lssData=lssWithTimeData;
                isTimeLSS=true;
            end



            if numel(lssData)>1
                try
                    concatLSS=merge(lssData{:});
                catch ME
                    if strcmp(ME.identifier,'shared_signallabelutils:labeledSignalSet:InvalidMergeMembers')
                        exceptionKeyword="LSSFailedMergeMembers";
                    elseif strcmp(ME.identifier,'shared_signallabelutils:labeledSignalSet:InvalidMergeSources')
                        exceptionKeyword="InvalidMergeSources";
                    elseif strcmp(ME.identifier,'signal:signalDatastore:signalDatastore:IncompatibleTimeInformation')
                        exceptionKeyword="IncompatibleTimeInformation";
                    elseif strcmp(ME.identifier,'signal:signalDatastore:signalDatastore:IncompatibleFileTypes')
                        exceptionKeyword="IncompatibleFileTypes";
                    elseif strcmp(ME.identifier,'signal:signalDatastore:signalDatastore:IncompatibleSignalVariableNames')
                        exceptionKeyword="IncompatibleSignalVariableNames";
                    elseif strcmp(ME.identifier,'signal:signalDatastore:signalDatastore:IncompatibleSampleRateVariableName')
                        exceptionKeyword="IncompatibleSampleRateVariableName";
                    elseif strcmp(ME.identifier,'signal:signalDatastore:signalDatastore:IncompatibleSampleTimeVariableName')
                        exceptionKeyword="IncompatibleSampleTimeVariableName";
                    elseif strcmp(ME.identifier,'signal:signalDatastore:signalDatastore:IncompatibleTimeValuesVariableName')
                        exceptionKeyword="IncompatibleTimeValuesVariableName";
                    elseif strcmp(ME.identifier,'shared_signallabelutils:labeledSignalSet:InvalidMergeLabelDefinitions')
                        exceptionKeyword="LSSFailedMergeLabelDefinitions";
                    end
                    concatLSS=[];
                    return;
                end
            else


                concatLSS=copy(lssData{1});
            end







            if~this.Model.isAppHasLabelsDef()
                if~verifyDefinitionCompatibleWithSignalLabeler(concatLSS)
                    exceptionKeyword="LSSInvalidLabelDefType";
                    concatLSS=[];
                    return;
                end
                uniqueLblDefsInConcatLSS=getLabelDefinitions(concatLSS);
            else
                [isSuccess,~,uniqueLblDefsInConcatLSS]=this.Model.validateCompatibleLabelDefinitionsForMerge(getLabelDefinitions(concatLSS));
                if~isSuccess
                    exceptionKeyword="LSSFailedMergeLabelDefinitions";
                    concatLSS=[];
                    return;
                end
            end
            if~isLSSWithFileDataStores


                numMember=numel(concatLSS.getMemberNames);
                for mdx=1:numMember
                    memberData=concatLSS.getSignal(mdx);
                    if iscell(memberData)
                        memberData=memberData{:,:};
                    end
                    if istimetable(memberData)
                        memberData=memberData{:,:};
                    end

                    if~allfinite(memberData)
                        exceptionKeyword="InvalidMemberDataInforNan";
                        concatLSS=[];
                        return;
                    end

                end
            end
            if isLSSWithFileDataStores

                [isSuccess,exceptionKeyword]=this.Model.updateDataStoreAndFileModeSettings(concatLSS.getPrivateSourceData);
                if~isSuccess
                    concatLSS=[];
                end
            end
        end

        function flag=checkUniqueMemberNames(this,varNames,newLSS)
            flag=true;
            lblRepository=this.Model;
            newLSSMemberNames=[];
            if~isempty(newLSS)
                newLSSMemberNames=newLSS.getMemberNames();
            end
            repositoryMemberIDs=lblRepository.getMemberIDs();
            repositoryMemberNames=strings(numel(repositoryMemberIDs),1);
            for idx=1:numel(repositoryMemberIDs)
                repositoryMemberNames(idx)=string(this.Engine.getSignalName(repositoryMemberIDs(idx)));
            end

            names=[newLSSMemberNames(:);repositoryMemberNames(:);varNames(:)];
            if numel(unique(names))~=numel(names)
                flag=false;
            end
        end

        function name=getUniqueLSSName(~)
            name="ImportedLSS"+regexprep(matlab.lang.internal.uuid(),'-','');
        end

        function notifyImportFromWorkspaceComplete(this,evtData)
            this.notify('ImportSignalsFromWorkspaceComplete',...
            signal.internal.SAEventData(struct('clientID',this.ClientID,'data',evtData)));
        end

    end

    methods
        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end
    end
end
