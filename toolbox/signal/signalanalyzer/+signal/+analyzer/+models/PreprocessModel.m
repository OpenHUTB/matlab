

classdef PreprocessModel<handle


    properties(Access=private)
        Engine;
        PreprocessedSignalIDs;
        CreatedSignalIDs;
        SelectedSignalsFlagsForMainApp;
        BackupSignalIDsMapForImportedSignals;
CurrentPlottedSignalIDs
    end

    methods(Static)
        function ret=getModel()

            persistent modelObj;
            mlock;
            if isempty(modelObj)||~isvalid(modelObj)
                modelObj=signal.analyzer.models.PreprocessModel();
            end


            ret=modelObj;
        end
    end


    methods(Access=protected)
        function this=PreprocessModel()
            this.Engine=Simulink.sdi.Instance.engine;
            this.resetModel();
            import signal.analyzer.models.PreprocessModel;
        end
    end



    methods

        function resetModel(this)
            this.PreprocessedSignalIDs=[];
            this.CreatedSignalIDs=[];
            this.SelectedSignalsFlagsForMainApp=struct;
            this.BackupSignalIDsMapForImportedSignals=containers.Map('KeyType','int32','ValueType','double');
        end

        function childrenIDs=getSignalIDsForTableSignals(this,signalIDs)

            childrenIDs=[];
            for idx=1:numel(signalIDs)
                leafSignalIDs=signal.analyzer.SignalUtilities.getSignalLeafChildren(this.Engine,signalIDs(idx));
                if isempty(leafSignalIDs)

                    leafSignalIDs=signalIDs(idx);
                end
                childrenIDs=[childrenIDs;leafSignalIDs(:)];
            end
            childrenIDs=unique(childrenIDs,"stable");
        end

        function tableData=getSignalsTableData(this,signalIDs)
            tableData=this.Engine.safeTransaction(@getSignalsTableDataImpl,this,signalIDs);
            function tableData=getSignalsTableDataImpl(this,signalIDs)
                tableData=[];

                appliedActionNames=this.getGetPreprocessingActionNamesForSignals(signalIDs);

                timeColumnsData=signal.analyzer.SignalUtilities.getSignalTableColumnTimeData(this.Engine,signalIDs);
                for idx=1:numel(signalIDs)
                    signalID=signalIDs(idx);
                    signalName=this.Engine.sigRepository.getSignalName(signalID);

                    metaData=this.getMetaDataPropertiesForSignalsTable(signalID);
                    metaData.appliedActionNames=appliedActionNames{idx};
                    metaData.cachedActionNames=[];
                    actionNameThatCreatedSignal=this.Engine.getMetaDataV2(signalID,'ActionNameThatCreatedSignal');
                    if isempty(actionNameThatCreatedSignal)
                        actionNameThatCreatedSignal="";
                    end
                    metaData.actionNameThatCreatedSignal=actionNameThatCreatedSignal;

                    infoData.label="";

                    rowData={string(signalID),metaData,string(signalName),infoData,...
                    timeColumnsData(idx).timeValues,timeColumnsData(idx).startTimeValues,timeColumnsData(idx).samplesValues};

                    tableData=[tableData,rowData];
                end
            end
        end

        function metaDataProperties=getMetaDataPropertiesForSignalsTable(this,signalIDs)
            isComplex=logical.empty;
            tmMode=[];
            isFinite=logical.empty;
            isNonUniform=logical.empty;
            for idx=1:numel(signalIDs)
                signalID=signalIDs(idx);
                signalProperties=signal.analyzer.SignalUtilities.getSignalProperties(this.Engine,signalID);
                isComplex=[isComplex;signalProperties.Complexity];
                tmMode=[tmMode;string(signalProperties.TmMode)];
                isFinite=[isFinite;signalProperties.isFinite];
                isNonUniform=[isNonUniform;signalProperties.TmResampledSigID~=-1];
            end
            metaDataProperties.isComplex=isComplex;
            metaDataProperties.tmMode=tmMode;
            metaDataProperties.isFinite=isFinite;
            metaDataProperties.isNonUniform=isNonUniform;
        end

        function appliedActionNames=getGetPreprocessingActionNamesForSignals(this,signalIDs)
            appliedActionNames={};
            for idx=1:numel(signalIDs)
                signalID=signalIDs(idx);
                backupSignalIDs=this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(signalID);
                appliedActionNames{idx}=[];
                for jdx=1:numel(backupSignalIDs)
                    preprocessMetaData=jsondecode(this.Engine.getMetaDataV2(backupSignalIDs(jdx),'SaPreprocessSettings'));
                    appliedActionNames{idx}=[appliedActionNames{idx};string(preprocessMetaData.ActionName)];
                end
            end
        end

        function outData=getSignalsPlotData(this,signalIDs)
            engine=this.Engine;

            outData=engine.safeTransaction(@getSignalsPlotDataImpl,engine,signalIDs);

            function outData=getSignalsPlotDataImpl(engine,signalIDs)

















                outData=[];

                for idx=1:numel(signalIDs)

                    signalID=signalIDs(idx);
                    sigData=signal.analyzer.SignalUtilities.getSignalProperties(engine,signalID);
                    signalObj=Simulink.sdi.getSignal(signalID);
                    sigData.signal_id=signalObj.ID;
                    sigData.name=signalObj.Name;
                    temp=dec2hex(round(255.*signalObj.LineColor));
                    sigData.color=['#',temp(1,:),temp(2,:),temp(3,:)];
                    sigData.plot_indices=1;
                    sigData.isEnum=false;
                    sigData.is_enum=false;
                    sigData.is_string=false;
                    sigData.linestyle='-';
                    sigData.type='checked';
                    outData=[outData;sigData];
                end
            end
        end

        function addPreprocessedSignalIDs(this,signalIDs)
            this.PreprocessedSignalIDs=unique([this.PreprocessedSignalIDs;signalIDs(:)],'stable');
            this.PreprocessedSignalIDs=this.PreprocessedSignalIDs(:);
        end

        function addCreatedSignalIDs(this,signalIDs)
            this.CreatedSignalIDs=[this.CreatedSignalIDs;signalIDs(:)];
        end

        function setSelectedSignalsFlagsForMainApp(this,selectedSignalsFlags)
            this.SelectedSignalsFlagsForMainApp=selectedSignalsFlags;
        end

        function createBackupSignalIDsMapForImportedSignals(this,importedSignalIDs)


            for idx=1:numel(importedSignalIDs)
                importedSignalID=importedSignalIDs(idx);
                this.BackupSignalIDsMapForImportedSignals(importedSignalID)=...
                numel(this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(importedSignalID));
            end
        end

        function setCurrentPreprocessingIdxForSignals(this,signalIDs,currentPreprocessingIdx)
            for idx=1:numel(signalIDs)
                this.Engine.setMetaDataV2(signalIDs(idx),'CurrentPreprocessingIdx',currentPreprocessingIdx);
            end
        end

        function lastActionBackupSignalIDs=getLastActionBackupSignalID(this,signalIDs)
            for idx=1:numel(signalIDs)
                lastActionBackupSignalIDs=this.Engine.getMetaDataV2(signalIDs(idx),'LastActionBackupSignalID');
            end
        end

        function map=getBackupSignalIDsMapForImportedSignals(this)
            map=this.BackupSignalIDsMapForImportedSignals;
        end

        function numberOfStoredBackupSignalIDs=getStoredNumberOfBackupSignalIDsMapForSignals(this,signalIDs)
            numberOfStoredBackupSignalIDs=[];
            for idx=1:numel(signalIDs)
                if(isKey(this.BackupSignalIDsMapForImportedSignals,signalIDs(idx)))
                    numberOfBackupSignalIDs=this.BackupSignalIDsMapForImportedSignals(signalIDs(idx));
                else


                    numberOfBackupSignalIDs=0;
                end
                numberOfStoredBackupSignalIDs=[numberOfStoredBackupSignalIDs;numberOfBackupSignalIDs];
            end
        end

        function signalData=getSignalDataValues(this,signalID)
            runID=this.Engine.sigRepository.getAllRunIDs('sigAnalyzer');
            signalData=signal.sigappsshared.SignalUtilities.getSignalValue(this.Engine,runID,signalID,true);
        end

        function selectedSignalsFlags=getSelectedSignalsFlagsForMainApp(this)
            selectedSignalsFlags=this.SelectedSignalsFlagsForMainApp;
        end

        function preprocessedSignalIDs=getPreprocessedSignalIDs(this)
            preprocessedSignalIDs=this.PreprocessedSignalIDs;
        end

        function createdSignalIDs=getCreatedSignalIDs(this)
            createdSignalIDs=this.CreatedSignalIDs;
        end

        function allSignalIDs=getAllInModePreprocessBackupIDs(this)

            allSignalIDs=[];
            preprocessedSignalIDs=this.PreprocessedSignalIDs;


            preprocessedSignalIDs=[preprocessedSignalIDs;this.getCreatedSignalIDs()];
            for idx=1:numel(preprocessedSignalIDs)
                preprocessedSignalID=preprocessedSignalIDs(idx);
                storedNumberOfBackupSignalIDs=this.getStoredNumberOfBackupSignalIDsMapForSignals(preprocessedSignalID);
                preprocessBackupIDs=this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(preprocessedSignalID);
                allSignalIDs=[allSignalIDs;preprocessBackupIDs(1:end-storedNumberOfBackupSignalIDs)];
            end
        end

        function allSignalIDs=getAllPreprocessBackupIDs(this)
            allSignalIDs=[];
            preprocessedSignalIDs=this.PreprocessedSignalIDs;
            for idx=1:numel(preprocessedSignalIDs)
                preprocessBackupIDs=this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(preprocessedSignalIDs(idx));
                allSignalIDs=[allSignalIDs;preprocessBackupIDs(:)];%#ok<*AGROW>
            end
        end

        function backupSignalID=getBackupSignalIDs(this,signalID)
            backupSignalID=this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(signalID);
        end

        function selectedSignalsFlags=getSelectedSignalsFlagsForPreprocessedSignalIDs(this)
            preprocessedSignalIDs=this.PreprocessedSignalIDs;
            selectedSignalsFlags=this.SelectedSignalsFlagsForMainApp;
            selectedSignalsFlags.isFlagsValid=false;
            for idx=1:numel(preprocessedSignalIDs)
                signalID=preprocessedSignalIDs(idx);
                tmMode=this.Engine.getSignalTmMode(signalID);
                isCurrentSignalNonUniform=this.Engine.getSignalTmResampledSigID(signalID)~=-1;
                isCurrentSignalFinite=signal.sigappsshared.SignalUtilities.getIsFiniteMetaDataFlag(signalID);

                selectedSignalsFlags=signal.analyzer.SignalUtilities.updateRequestedSigIDsMetaData(selectedSignalsFlags,...
                strcmp(tmMode,'samples'),isCurrentSignalNonUniform,isCurrentSignalFinite);
                selectedSignalsFlags.isFlagsValid=true;
            end
            selectedSignalsFlags.isEnableUndoPreprocessForSignalsSelected=...
            selectedSignalsFlags.isEnableUndoPreprocessForSignalsSelected||~isempty(this.getAllPreprocessBackupIDs());
        end

        function resetSignalSaPreprocessBackupIDs(this)


            preprocessedSignalIDs=this.PreprocessedSignalIDs;

            preprocessedSignalIDs=setdiff(preprocessedSignalIDs,this.getCreatedSignalIDs(),'stable');
            for idx=1:numel(preprocessedSignalIDs)
                preprocessedSignalID=preprocessedSignalIDs(idx);
                storedNumberOfBackupSignalIDs=this.getStoredNumberOfBackupSignalIDsMapForSignals(preprocessedSignalID);
                preprocessBackupIDs=this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(preprocessedSignalID);
                this.Engine.sigRepository.setSignalSaPreprocessBackupIDs(preprocessedSignalIDs(idx),preprocessBackupIDs(end-storedNumberOfBackupSignalIDs+1:end));
            end
        end

        function setCurrentPlottedSignalIDs(this,signalIDs)
            this.CurrentPlottedSignalIDs=signalIDs;
        end

        function signalIDs=getCurrentPlottedSignalIDs(this)
            signalIDs=this.CurrentPlottedSignalIDs;
        end
    end
end