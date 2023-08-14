classdef AudioDataRepository<handle




    properties(SetAccess=protected)
LabelerModel
    end

    methods(Static)
        function ret=getModel()

            persistent modelObj;
            mlock;
            if isempty(modelObj)||~isvalid(modelObj)
                labelerModelObj=signal.labeler.models.LabelDataRepository.getModel();
                modelObj=audio.labeler.internal.AudioDataRepository(labelerModelObj);
            end


            ret=modelObj;
        end
    end

    methods(Access=protected)
        function this=AudioDataRepository(labelerModelObj)

            this.LabelerModel=labelerModelObj;
        end
    end


    methods
        function info=addImportedAudioFilesToDatastore(this,importMetaData)

            info.success=false;
            info.errorMsg='';
            info.errorID='';
            info.newFileNames={};
            info.signalVarNames={};
            info.isSignalVarNamesInfile=false;
            info.mode=[];
            info.Fs='';
            info.Ts='';
            info.St='';
            info.Tv='';


            try
                dataStoreToAdd=audioDatastore(importMetaData.fileOrFolderName,...
                'FileExtensions',importMetaData.fileExtensions,...
                'IncludeSubfolders',importMetaData.includeSubfolders);


                dataStoreForApp=this.getDatastoreForApp();
                if~isempty(dataStoreForApp)
                    currFiles=string(dataStoreForApp.Files);
                    newFiles=string(dataStoreToAdd.Files);
                    newIndexes=~ismember(newFiles,currFiles);
                    if~any(newIndexes)

                        info.success=false;
                        info.errorID='NoNewMembersToImport';
                        info.errorMsg='';
                        info.errorType='DataStoreCreationFailed';
                        return;
                    end
                    dataStoreToAdd.Files=newFiles(newIndexes);
                end
                info.newFileNames=dataStoreToAdd.Files;
                info.success=true;
            catch ex
                info.success=false;
                info.errorID=this.parseErrorID(ex.identifier);
                info.errorMsg=ex.message;
                info.errorType='DataStoreCreationFailed';
                return;
            end


            dataStoreForApp=this.getDatastoreForApp();
            if~isempty(dataStoreForApp)
                try

                    mergerLSS=labeledSignalSet(dataStoreForApp).merge(labeledSignalSet(dataStoreToAdd));
                    this.setDatastoreForApp(mergerLSS.getPrivateSourceData);
                catch ex
                    info.success=false;
                    info.errorID=this.parseErrorID(ex.identifier);
                    info.errorMsg=ex.message;
                    info.errorType='DataStoreCreationFailed';
                    return;
                end
            else
                this.setDatastoreForApp(dataStoreToAdd);
            end


            fileModeSettings=this.getFileModeSettings();
            fileModeSettings.isSampleRateSpecified=true;
            this.setFileModeSettings(fileModeSettings);
            this.setIsTimeSpecified(true);
        end
    end


    methods
        function[validFlag,errorID]=isValidStateForAudioPlayback(this)





            validFlag=isAppHasMembers(this);
            errorID='';
            if~validFlag
                errorID='NoMembersForAudioPlayback';
                return;
            end


            appDataMode=getAppDataMode(this);
            if strcmp(appDataMode,'audioFile')
                validFlag=true;
            elseif strcmp(appDataMode,'signalFile')
                fileModeSettings=getFileModeSettings(this);
                validFlag=fileModeSettings.isSampleRateSpecified;
            else
                isTimeSpecified=getIsTimeSpecified(this);
                validFlag=~isempty(isTimeSpecified)&&isTimeSpecified;
            end
            if~validFlag
                errorID='UnsupportedAppDataModeForAudioPlayback';
                return;
            end



            [signalIDs,memberIDs]=getCheckedSignalAndMemberIDs(this);
            memberIDs=unique(memberIDs,'stable');
            validFlag=numel(memberIDs)==1;
            if numel(memberIDs)==0
                errorID='NoPlottedSignalForAudioPlayback';
                return;
            elseif numel(memberIDs)>1
                errorID='InvalidSignalParentForAudioPlayback';
                return;
            end





            if~strcmp(appDataMode,'audioFile')
                labelerModel=this.getLabelerModel();
                eng=labelerModel.Engine;
                sampleRates=zeros(numel(signalIDs),1);
                for idx=1:numel(signalIDs)
                    signalID=signalIDs(idx);
                    tmMode=labelerModel.getSignalTmMode(signalID);
                    if tmMode=="inherentLabeledSignalSet"
                        tmMode=labelerModel.getTmModeLabeledSignalSet(signalID);
                    end
                    validFlag=strcmp(tmMode,'fs');
                    if validFlag
                        freqUnits=eng.getSignalTmSampleRateUnits(signalID);
                        mFreqUnits=signal.sigappsshared.Utilities.getFrequencyMultiplier(freqUnits);
                        sampleRates(idx)=eng.getSignalTmSampleRate(signalID)*mFreqUnits;
                    else
                        errorID='InvalidTimeModeForAudioPlayback';
                        return;
                    end
                end
                validFlag=validFlag&&...
                all(abs(sampleRates-sampleRates(1))<=sqrt(eps))&&...
                (sampleRates(1)>=1000)&&(sampleRates(1)<=384000);
                if~validFlag
                    errorID='InvalidSampleRateForAudioPlayback';
                end
            end
        end
    end


    methods
        function labelerModel=getLabelerModel(this)
            labelerModel=this.LabelerModel;
        end

        function y=isDirty(this)
            y=this.getLabelerModel().isDirty;
        end

        function dirtyStateChanged=setDirty(this,dirtyStatus)
            dirtyStateChanged=setDirty(this.getLabelerModel(),dirtyStatus);
        end

        function ds=getDatastoreForApp(this)
            ds=getDataStoreForApp(this.getLabelerModel());
        end

        function setDatastoreForApp(this,ds)
            setDataStoreForApp(this.getLabelerModel(),ds);
        end

        function y=getAppDataMode(this)
            y=getAppDataMode(this.getLabelerModel());
        end

        function setAppDataMode(this,appDataMode)
            setAppDataMode(this.getLabelerModel(),appDataMode);
        end

        function y=getFileModeSettings(this)
            y=getFileModeSettings(this.getLabelerModel());
        end

        function setFileModeSettings(this,y)
            setFileModeSettings(this.getLabelerModel(),y);
        end

        function setIsTimeSpecified(this,isTimeSpecified)
            setIsTimeSpecified(this.getLabelerModel(),isTimeSpecified);
        end

        function y=getIsTimeSpecified(this)
            y=getIsTimeSpecified(this.getLabelerModel());
        end

        function y=isAppHasMembers(this)
            y=isAppHasMembers(this.getLabelerModel());
        end

        function[signalIDs,memberIDs]=getCheckedSignalAndMemberIDs(this)
            labelerModel=this.getLabelerModel();
            signalIDs=labelerModel.getCheckedSignalIDs();
            memberIDs=[];
            if numel(signalIDs)>0
                [signalIDs,memberIDs]=getCheckedSignalAndMemberIDs(labelerModel);
            end
        end

        function[y,fs]=getSignalData(this,signalIDs)


            numOfSignals=numel(signalIDs);
            signalLength=0;
            fs=[];
            labelerModel=this.getLabelerModel();
            engine=labelerModel.Engine;
            if numel(signalIDs)>=1
                firstSignalID=signalIDs(1);
                signalLength=engine.getSignalTmNumPoints(firstSignalID);
                fs=engine.getSignalTmSampleRate(firstSignalID);
                units=engine.getSignalTmSampleRateUnits(firstSignalID);
                fs=fs*signal.sigappsshared.Utilities.getFrequencyMultiplier(units);
            end
            y=zeros(signalLength,numOfSignals);
            for idx=1:numOfSignals
                sigValues=engine.getSignalObject(signalIDs(idx)).Values;
                y(:,idx)=sigValues.Data(:);
            end
        end

        function y=parseErrorID(~,errorIdentifier)
            parsedValues=strsplit(errorIdentifier,':');
            y=parsedValues{end};
        end
    end
end
