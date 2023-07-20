

classdef Preprocessor<handle




    properties(Hidden)
        Engine;
        Model;
    end

    properties(Access=protected)
        Dispatcher;
        ProcessingObj;
        CurrentParameters;
        CurrentActionName;
        CurrentClientID;
        CurrentSignalIDs;
ExceptionKeywordArray

        RequestedSigIDs;

RequestedSigIDsMetaData


        SuccessSigIDs;
    end

    properties(Constant)
        ControllerID='preprocessingController';
    end

    events
FinalizePreprocessApplyComplete
FinalizeUndoOperationComplete
FinalizeRedoOperationComplete
FinalizeDuplicateOperationComplete
FinalizeExtractOperationComplete
FinalizeSplitOperationComplete
UpdatePreprocessProgressBarComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.analyzer.models.PreprocessModel.getModel();
                ctrlObj=signal.analyzer.controllers.Preprocessing.Preprocessor(modelObj,dispatcherObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Hidden)
        function this=Preprocessor(modelObj,dispatcherObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Model=modelObj;
            this.Dispatcher=dispatcherObj;
            import signal.analyzer.controllers.Preprocessing.Preprocessor;

            this.Dispatcher.subscribe(...
            [Preprocessor.ControllerID,'/','preprocessapply'],...
            @(arg)cb_PreprocessApply(this,arg));
        end




        function cb_PreprocessApply(this,args)

            reset(this);
            data=args.data;

            switch data.actionName
            case 'smooth'
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Smoother(data.settings);
            case{'lowpassfilter','highpassfilter'}
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.LpHpFilter(data.settings);
            case{'bandpassfilter','bandstopfilter'}
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.BpBsFilter(data.settings);
            case 'resample'
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Resample(data.settings);
            case 'detrend'
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Detrender(data.settings);
            case 'envelope'
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Enveloper(data.settings);
            case 'denoise'
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Denoiser(data.settings);
            case{'trimleft','trimright'}
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Trim(data.settings);
            case{'clipabove','clipbelow'}
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Clip(data.settings);
            case 'crop'
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.Crop(data.settings);
            otherwise
                data.settings.actionName=data.actionName;
                this.ProcessingObj=signal.analyzer.controllers.Preprocessing.UserDefinedPreprocessor(data.settings);
            end




            this.RequestedSigIDs=parseSignalIDs(this,data);
            this.CurrentActionName=data.displayedActionName;
            this.CurrentParameters=data.settings;
            this.CurrentClientID=data.clientID;

            for idx=1:numel(this.RequestedSigIDs)
                backupAndProcessData(this,this.RequestedSigIDs(idx));

                preprocessProgressBarData.clientID=num2str(this.CurrentClientID);
                preprocessProgressBarData.messageID='updatePreprocessProgressBar';
                preprocessProgressBarData.data=idx;
                this.notify('UpdatePreprocessProgressBarComplete',signal.internal.SAEventData(preprocessProgressBarData));
            end




            finalizePreprocessApply(this);
        end

        function cleanupForProcessData(this)


            if this.ProcessingObj.NeedCleanUp
                this.ExceptionKeywordArray=[this.ExceptionKeywordArray,{'PreprocessCleanUp'}];
                finalizePreprocessApply(this);
            end
        end




        function backupAndProcessData(this,sigID)
            safeTransaction(this.Engine,@this.backupAndProcessDataImpl,sigID);
        end


        function backupAndProcessDataImpl(this,sigID)


            cleanupHandle=@()cleanupForProcessData(this);
            [successFlag,data,exceptionKeyword,currentParameters]=this.ProcessingObj.processData(sigID,cleanupHandle,this.CurrentParameters);
            this.ExceptionKeywordArray=[this.ExceptionKeywordArray,{exceptionKeyword}];
            if successFlag



                backupSigID=createBackupSignal(this,sigID);

                this.SuccessSigIDs=[this.SuccessSigIDs,sigID];

                this.Model.addPreprocessedSignalIDs(sigID);

                this.updateData(sigID,data);

                this.addPreprocessingSettingsToBackupSignal(backupSigID,this.CurrentActionName,currentParameters);


                signal.analyzer.SignalUtilities.deleteAllSignalsAfterCurrentPreprocessingIdx(sigID);


                signal.analyzer.SignalUtilities.deleteLastActionBackupSignalID(sigID);


                this.storeBackupSignal(sigID,backupSigID);




                signal.sigappsshared.SignalUtilities.removeDomainSignals(this.Engine,sigID);
            else


                tmMode=this.Engine.getSignalTmMode(sigID);
                isCurrentSignalNonUniform=this.Engine.getSignalTmResampledSigID(sigID)~=-1;
                isCurrentSignalFinite=logical(this.Engine.getMetaDataV2(sigID,'IsFinite'));
                this.RequestedSigIDsMetaData=...
                signal.analyzer.SignalUtilities.updateRequestedSigIDsMetaData(this.RequestedSigIDsMetaData,...
                strcmp(tmMode,'samples'),isCurrentSignalNonUniform,isCurrentSignalFinite);
            end
        end


        function updateData(this,sigID,data)
            [tmMode,isCurrentSignalNonUniform,isCurrentSignalFinite]=signal.analyzer.SignalUtilities.updateData(sigID,data,num2str(this.CurrentClientID),false);
            this.RequestedSigIDsMetaData=...
            signal.analyzer.SignalUtilities.updateRequestedSigIDsMetaData(this.RequestedSigIDsMetaData,...
            strcmp(tmMode,'samples'),isCurrentSignalNonUniform,isCurrentSignalFinite);
            this.RequestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected=true;
            this.RequestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected=true;
        end


        function backupSigID=createBackupSignal(this,sigID)

            backupSigID=signal.sigappsshared.SignalUtilities.createPreprocessBackupSignal(this.Engine,sigID);
        end


        function addPreprocessingSettingsToBackupSignal(this,backupSignalID,actionName,paramStruct)


            structToAdd.ActionName=actionName;
            structToAdd.Parameters=paramStruct;

            jsonStr=jsonencode(structToAdd);





            actionName=structToAdd.ActionName;
            this.Engine.setMetaDataV2(backupSignalID,'SaPreprocessSettings',jsonStr);
            this.Engine.sigRepository.setSignalSaPreprocessAction(backupSignalID,actionName);
        end


        function storeBackupSignal(this,sigID,backupSigID)


            backupIDsVector=this.Engine.sigRepository.getSignalSaPreprocessBackupIDs(sigID);
            backupIDsVector=[int32(backupSigID);backupIDsVector];
            this.Engine.sigRepository.setSignalSaPreprocessBackupIDs(sigID,backupIDsVector);






            this.Model.setCurrentPreprocessingIdxForSignals(sigID,0);
        end


        function finalizePreprocessApply(this)
            if~isempty(this.SuccessSigIDs)

                plotSelectedSignalsData.clientID=this.CurrentClientID;
                plotSelectedSignalsData.messageID='updateSignalsInDisplay';
                plotSelectedSignalsData.data=this.Model.getSignalsPlotData(this.Model.getCurrentPlottedSignalIDs());
                plotSelectedSignalsData.actionName='preprocessApply';
                this.notify('FinalizePreprocessApplyComplete',signal.internal.SAEventData(plotSelectedSignalsData));


                tableUpdateData.clientID=num2str(this.CurrentClientID);
                tableUpdateData.messageID='updateRowsDataInTable';
                tableUpdateData.data.signalIDs=this.SuccessSigIDs;
                tableUpdateData.data.actionName=this.CurrentActionName;
                metaDataProperties=this.Model.getMetaDataPropertiesForSignalsTable(this.SuccessSigIDs);
                tableUpdateData.data.metaDataProperties.isFinite=metaDataProperties.isFinite;
                tableUpdateData.data.metaDataProperties.isNonUniform=metaDataProperties.isNonUniform;
                tableUpdateData.data.timeColumnsData=signal.analyzer.SignalUtilities.getSignalTableColumnTimeData(this.Engine,this.SuccessSigIDs);
                tableUpdateData.data.operationType="preprocess";
                this.notify('FinalizePreprocessApplyComplete',signal.internal.SAEventData(tableUpdateData));
            end



            msgStruct.SignalIDs=this.SuccessSigIDs;
            msgStruct.Action='preprocessApply';
            msgStruct.CurrentActionName=this.CurrentActionName;
            msgStruct.NumRequestedIds=numel(this.RequestedSigIDs);
            msgStruct.NumSuccessIds=numel(this.SuccessSigIDs);
            msgStruct.Messages=this.ExceptionKeywordArray;
            signal.sigappsshared.Utilities.publishSignalCreationCompleted(msgStruct);
        end



        function reset(this)

            this.ProcessingObj=[];
            this.CurrentParameters=[];
            this.CurrentActionName=[];
            this.CurrentClientID=[];
            this.CurrentSignalIDs=[];
            this.ExceptionKeywordArray={};
            this.RequestedSigIDs=[];
            this.RequestedSigIDsMetaData=struct('isHomogeneousUniformSignalsSelected',false,...
            'isHomogeneousNonUniformSignalsSelected',false,...
            'isHomogeneousSampleSignalsSelected',false,...
            'isEnableUndoPreprocessForSignalsSelected',false,...
            'isEnableGenerateFunctionForSignalsSelected',false,...
            'isAllFiniteSelected',true,...
            'isAnyFiniteSelected',false,...
            'isFlagsValid',false);
            this.SuccessSigIDs=[];
        end


        function leafChildren=parseSignalIDs(this,data)



            if isfield(data,'selectedViewIndices')
                [~,leafChildren]=signal.sigappsshared.SignalUtilities.getUniqueSetOfSelectedSignalIDsByViewIndex(...
                this.Engine,data.selectedViewIndices,data.clientID);
            else


                leafChildren=signal.sigappsshared.SignalUtilities.getUniqueSetOfSelectedSignalIDsByID(...
                this.Engine,data.signalIDs);
            end
        end
    end

    methods(Static)

        function finalizeUndoOperation(signalIDs,requestedSignalIIDs,clientID)





            eng=Simulink.sdi.Instance.engine;
            if(~isempty(signalIDs))
                safeTransaction(eng,@handleFinalizeUndoOperation,signalIDs,requestedSignalIIDs,clientID,false);
            end


            signal.analyzer.SignalUtilities.requestPlotUpdates(signalIDs,clientID,false,'preprocessUndo');


            msgStruct.SignalIDs=signalIDs;
            msgStruct.Action='preprocessUndo';
            signal.sigappsshared.Utilities.publishSignalCreationCompleted(msgStruct);
        end


        function finalizeRedoOperation(signalIDs,requestedSignalIIDs,clientID,varargin)




            eng=Simulink.sdi.Instance.engine;
            if(~isempty(signalIDs))
                safeTransaction(eng,@handleFinalizeRedoOperation,signalIDs,requestedSignalIIDs,clientID,varargin{:});
            end
        end


        function finalizeUndoOperationPreprocessingMode(signalIDs,requestedSignalIIDs,clientID,varargin)




            eng=Simulink.sdi.Instance.engine;
            if(~isempty(signalIDs))
                safeTransaction(eng,@handleFinalizeUndoOperation,signalIDs,requestedSignalIIDs,clientID,true,varargin{:});
            end
        end


        function finalizeDuplicateSignal(signalIDs,clientID)





            eng=Simulink.sdi.Instance.engine;
            if(~isempty(signalIDs))
                safeTransaction(eng,@handleFinalizeDuplicateOperation,signalIDs,clientID);
            end
        end


        function finalizeExtractSignal(signalIDs,clientID)



            eng=Simulink.sdi.Instance.engine;
            if(~isempty(signalIDs))
                safeTransaction(eng,@handleFinalizeExtractOperation,signalIDs,clientID);
            end
        end


        function finalizeSplitSignal(signalIDs,exceptionKeyword,clientID)



            eng=Simulink.sdi.Instance.engine;
            safeTransaction(eng,@handleFinalizeSplitOperation,signalIDs,exceptionKeyword,clientID);
        end


        function isNonUniform=handleResampledSignal(signalIDs,notifyFlag)




            isNonUniform=logical.empty;
            engine=Simulink.sdi.Instance.engine;
            for idx=1:length(signalIDs)
                signalID=signalIDs(idx);
                tmMode=engine.getSignalTmMode(signalID);
                if any(strcmp(tmMode,{'tv','inherentTimeseries','inherentTimetable'}))
                    tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                    isNonUniform=[isNonUniform;tmd.updateResampledSignal(signalID,[],[],[],notifyFlag)];%#ok<*AGROW>
                elseif any(strcmp(tmMode,{'fs','ts'}))
                    tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                    tmd.clearResampledSignal(signalID);
                    isNonUniform=[isNonUniform;false];
                else
                    isNonUniform=[isNonUniform;false];
                end
            end
        end
    end
end




function handleFinalizeUndoOperation(signalIDs,requestedSignalIIDs,clientID,isPreprocessingMode,varargin)



    eng=Simulink.sdi.Instance.engine;
    this=signal.analyzer.controllers.Preprocessing.Preprocessor.getController();
    if~isPreprocessingMode

        requestedSigIDsMetaData=struct('isHomogeneousUniformSignalsSelected',false,...
        'isHomogeneousNonUniformSignalsSelected',false,...
        'isHomogeneousSampleSignalsSelected',false,...
        'isEnableUndoPreprocessForSignalsSelected',false,...
        'isEnableGenerateFunctionForSignalsSelected',false,...
        'isAllFiniteSelected',true,...
        'isAnyFiniteSelected',false,...
        'isFlagsValid',false);

        unchangedSignalIDs=setdiff(requestedSignalIIDs,signalIDs);

        for idx=1:length(unchangedSignalIDs)
            signalID=unchangedSignalIDs(idx);
            tmMode=eng.getSignalTmMode(signalID);
            isCurrentSignalNonUniform=eng.getSignalTmResampledSigID(signalID)~=-1;
            isCurrentSignalFinite=logical(eng.getMetaDataV2(signalID,'IsFinite'));
            requestedSigIDsMetaData=...
            signal.analyzer.SignalUtilities.updateRequestedSigIDsMetaData(requestedSigIDsMetaData,...
            strcmp(tmMode,'samples'),isCurrentSignalNonUniform,isCurrentSignalFinite);
            if~requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected


                preprocessBackupIDs=eng.sigRepository.getSignalSaPreprocessBackupIDs(signalID);
                requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected=requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected||numel(preprocessBackupIDs)~=0;
            end
            if~requestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected


                actionNameThatCreatedSignal=eng.getMetaDataV2(signalID,'ActionNameThatCreatedSignal');
                requestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected=requestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected||...
                requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected||~isempty(actionNameThatCreatedSignal);
            end
        end

        for idx=1:length(signalIDs)
            signalID=signalIDs(idx);
            tmMode=eng.getSignalTmMode(signalID);
            isCurrentSignalFinite=logical(eng.getMetaDataV2(signalID,'IsFinite'));
            isCurrentSignalNonUniform=this.handleResampledSignal(signalID,true);
            requestedSigIDsMetaData=...
            signal.analyzer.SignalUtilities.updateRequestedSigIDsMetaData(requestedSigIDsMetaData,...
            strcmp(tmMode,'samples'),isCurrentSignalNonUniform,isCurrentSignalFinite);
            if~requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected


                preprocessBackupIDs=eng.sigRepository.getSignalSaPreprocessBackupIDs(signalID);
                requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected=requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected||numel(preprocessBackupIDs)~=0;
            end
            if~requestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected


                actionNameThatCreatedSignal=eng.getMetaDataV2(signalID,'ActionNameThatCreatedSignal');
                requestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected=requestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected||...
                requestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected||~isempty(actionNameThatCreatedSignal);
            end
        end


        for idx=1:length(signalIDs)
            signal.analyzer.SignalUtilities.notifyTableUpdates(signalIDs(idx));
        end
    else


        this.Model.addPreprocessedSignalIDs(signalIDs);

        isNonUniform=this.handleResampledSignal(signalIDs,false);
    end


    for idx=1:length(signalIDs)
        signal.analyzer.SignalUtilities.resetImagValuesForDeinterleavedComplexChannel(signalIDs(idx));
    end

    if~isPreprocessingMode

        signal.analyzer.SignalUtilities.notifyWithUpdatedTableSelectionFlags(requestedSigIDsMetaData);
    else

        tableUpdateData.clientID=num2str(clientID);
        tableUpdateData.messageID='updateRowsDataInTable';
        tableUpdateData.data.signalIDs=signalIDs;
        tableUpdateData.data.operationType="undo";
        tableUpdateData.data.metaDataProperties.isFinite=varargin{1};
        tableUpdateData.data.metaDataProperties.isNonUniform=isNonUniform;
        tableUpdateData.data.timeColumnsData=signal.analyzer.SignalUtilities.getSignalTableColumnTimeData(this.Engine,signalIDs);
        this.notify('FinalizeUndoOperationComplete',signal.internal.SAEventData(tableUpdateData));


        plotSelectedSignalsData.clientID=clientID;
        plotSelectedSignalsData.messageID='updateSignalsInDisplay';
        plotSelectedSignalsData.data=this.Model.getSignalsPlotData(this.Model.getCurrentPlottedSignalIDs());
        plotSelectedSignalsData.actionName='preprocessApply';
        this.notify('FinalizeUndoOperationComplete',signal.internal.SAEventData(plotSelectedSignalsData));
    end
end

function handleFinalizeRedoOperation(signalIDs,~,clientID,varargin)




    for idx=1:length(signalIDs)
        signalID=signalIDs(idx);
        signal.analyzer.SignalUtilities.resetImagValuesForDeinterleavedComplexChannel(signalID);
    end


    this=signal.analyzer.controllers.Preprocessing.Preprocessor.getController();
    isNonUniform=this.handleResampledSignal(signalIDs,false);


    tableUpdateData.clientID=num2str(clientID);
    tableUpdateData.messageID='updateRowsDataInTable';
    tableUpdateData.data.signalIDs=signalIDs;
    tableUpdateData.data.operationType="redo";
    tableUpdateData.data.metaDataProperties.isFinite=varargin{1};
    tableUpdateData.data.metaDataProperties.isNonUniform=isNonUniform;
    tableUpdateData.data.timeColumnsData=signal.analyzer.SignalUtilities.getSignalTableColumnTimeData(this.Engine,signalIDs);
    this.notify('FinalizeRedoOperationComplete',signal.internal.SAEventData(tableUpdateData));


    plotSelectedSignalsData.clientID=clientID;
    plotSelectedSignalsData.messageID='updateSignalsInDisplay';
    plotSelectedSignalsData.data=this.Model.getSignalsPlotData(this.Model.getCurrentPlottedSignalIDs());
    plotSelectedSignalsData.actionName='preprocessApply';
    this.notify('FinalizeRedoOperationComplete',signal.internal.SAEventData(plotSelectedSignalsData));
end

function handleFinalizeDuplicateOperation(signalIDs,clientID,varargin)
    this=signal.analyzer.controllers.Preprocessing.Preprocessor.getController();


    this.Model.addCreatedSignalIDs(signalIDs);


    tableData.clientID=num2str(clientID);
    tableData.messageID='addSignalsToTable';
    tableData.data.data=this.Model.getSignalsTableData(signalIDs);
    tableData.data.isSelectFirstRow=false;
    tableData.data.signalIDs=signalIDs;
    this.notify('FinalizeDuplicateOperationComplete',signal.internal.SAEventData(tableData));

end

function handleFinalizeExtractOperation(signalIDs,clientID)



    signal.analyzer.SignalUtilities.updateResampledSignal(signalIDs,false);

    this=signal.analyzer.controllers.Preprocessing.Preprocessor.getController();


    this.Model.addCreatedSignalIDs(signalIDs);




    tableData.clientID=num2str(clientID);
    tableData.messageID='addSignalsToTable';
    tableData.data.data=this.Model.getSignalsTableData(signalIDs);
    tableData.data.isSelectFirstRow=false;
    tableData.data.signalIDs=signalIDs;
    this.notify('FinalizeExtractOperationComplete',signal.internal.SAEventData(tableData));

end

function handleFinalizeSplitOperation(signalIDs,exceptionKeyword,clientID)



    this=signal.analyzer.controllers.Preprocessing.Preprocessor.getController();

    if(~isempty(signalIDs))
        signal.analyzer.SignalUtilities.updateResampledSignal(signalIDs,false);


        this.Model.addCreatedSignalIDs(signalIDs);



        tableData.clientID=num2str(clientID);
        tableData.messageID='addSignalsToTable';
        tableData.data.data=this.Model.getSignalsTableData(signalIDs);
        tableData.data.isSelectFirstRow=false;
        tableData.data.signalIDs=signalIDs;
        this.notify('FinalizeSplitOperationComplete',signal.internal.SAEventData(tableData));
    end

    if exceptionKeyword~=""

        toolstripData.clientID=num2str(clientID);
        toolstripData.messageID='showSplitWarningDialog';
        toolstripData.data=exceptionKeyword;
        this.notify('FinalizeSplitOperationComplete',signal.internal.SAEventData(toolstripData));
    end

end