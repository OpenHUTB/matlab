classdef SignalUtilities<handle





    methods(Static,Hidden)
        function requestPlotUpdates(signalIDs,clientID,plotFlag,actionName)



            engine=Simulink.sdi.Instance.engine;

            Simulink.sdi.plotSignalsAndUpdateTableChecks(...
            engine.sigRepository,clientID,int32(signalIDs),plotFlag,actionName);
        end

        function notifyTableUpdates(signalIDs)

            engine=Simulink.sdi.Instance.engine;
            for idx=1:numel(signalIDs)
                signalID=signalIDs(idx);
                value=engine.getSignalTmMode(signalID);
                notify(engine,'treeSignalPropertyEvent',...
                Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',signalID,value,'tmMode'));
            end
        end

        function currentRequestedSigIDsMetaData=updateRequestedSigIDsMetaData(currentRequestedSigIDsMetaData,isCurrentSignalInSamples,isCurrentSignalNonUniform,isCurrentSignalFinite)
            isCurrentSignalsHomogeneousUniform=~isCurrentSignalInSamples&&~isCurrentSignalNonUniform;
            if currentRequestedSigIDsMetaData.isFlagsValid
                currentRequestedSigIDsMetaData.isHomogeneousSampleSignalsSelected=currentRequestedSigIDsMetaData.isHomogeneousSampleSignalsSelected&&isCurrentSignalInSamples;
                currentRequestedSigIDsMetaData.isHomogeneousUniformSignalsSelected=currentRequestedSigIDsMetaData.isHomogeneousUniformSignalsSelected&&isCurrentSignalsHomogeneousUniform;
                currentRequestedSigIDsMetaData.isHomogeneousNonUniformSignalsSelected=currentRequestedSigIDsMetaData.isHomogeneousNonUniformSignalsSelected&&isCurrentSignalNonUniform;
                currentRequestedSigIDsMetaData.isAllFiniteSelected=currentRequestedSigIDsMetaData.isAllFiniteSelected&&isCurrentSignalFinite;
                currentRequestedSigIDsMetaData.isAnyFiniteSelected=currentRequestedSigIDsMetaData.isAnyFiniteSelected||isCurrentSignalFinite;
            else
                currentRequestedSigIDsMetaData.isHomogeneousSampleSignalsSelected=isCurrentSignalInSamples;
                currentRequestedSigIDsMetaData.isHomogeneousUniformSignalsSelected=isCurrentSignalsHomogeneousUniform;
                currentRequestedSigIDsMetaData.isHomogeneousNonUniformSignalsSelected=isCurrentSignalNonUniform;
                currentRequestedSigIDsMetaData.isAllFiniteSelected=isCurrentSignalFinite;
                currentRequestedSigIDsMetaData.isAnyFiniteSelected=isCurrentSignalFinite;
                currentRequestedSigIDsMetaData.isFlagsValid=true;
            end
        end

        function notifyWithUpdatedTableSelectionFlags(currentRequestedSigIDsMetaData)


            clientData.messageID='updatedSelectionFlags';

            isTimeMixedSignalsSelected=~currentRequestedSigIDsMetaData.isHomogeneousUniformSignalsSelected;
            clientData.data=struct('isHomogeneousUniformSignalsSelected',currentRequestedSigIDsMetaData.isHomogeneousUniformSignalsSelected,...
            'isHomogeneousNonUniformSignalsSelected',currentRequestedSigIDsMetaData.isHomogeneousNonUniformSignalsSelected,...
            'isHomogeneousSampleSignalsSelected',currentRequestedSigIDsMetaData.isHomogeneousSampleSignalsSelected,...
            'isTimeMixedSignalsSelected',isTimeMixedSignalsSelected,...
            'isAllFiniteSelected',currentRequestedSigIDsMetaData.isAllFiniteSelected,...
            'isAnyFiniteSelected',currentRequestedSigIDsMetaData.isAnyFiniteSelected,...
            'isEnableUndoPreprocessForSignalsSelected',currentRequestedSigIDsMetaData.isEnableUndoPreprocessForSignalsSelected,...
            'isEnableGenerateFunctionForSignalsSelected',currentRequestedSigIDsMetaData.isEnableGenerateFunctionForSignalsSelected);
            message.publish('/sdi/tableApplication',clientData);
        end

        function resetImagValuesForDeinterleavedComplexChannel(signalID)

            engine=Simulink.sdi.Instance.engine;
            if engine.sigRepository.getSignalComplexityAndLeafPath(signalID).IsComplex
                parentID=engine.getSignalParent(signalID);
                childIDs=engine.getSignalChildren(parentID);

                if length(childIDs)==2
                    runID=engine.sigRepository.getAllRunIDs('sigAnalyzer');
                    data=signal.sigappsshared.SignalUtilities.getSignalValue(engine,runID,signalID,true);
                    data.Data=imag(data.Data);
                    engine.setSignalDataValues(childIDs(2),data);
                end
            end
        end

        function deleteAllSignalsAfterCurrentPreprocessingIdx(sigIDs)



            engine=Simulink.sdi.Instance.engine;

            for idx=1:numel(sigIDs)
                sigID=sigIDs(idx);
                backupIDsVector=engine.sigRepository.getSignalSaPreprocessBackupIDs(sigID);
                if~isempty(backupIDsVector)
                    currentPreprocessingIdx=engine.getMetaDataV2(sigID,'CurrentPreprocessingIdx');

                    if currentPreprocessingIdx>0

                        signalIDsToBeDeleted=backupIDsVector(1:currentPreprocessingIdx);
                        signal.sigappsshared.SignalUtilities.deleteSignalsAndResampledSignalsInEngine(signalIDsToBeDeleted);

                        backupIDsVector(1:currentPreprocessingIdx)=[];
                        engine.sigRepository.setSignalSaPreprocessBackupIDs(sigID,backupIDsVector);
                    end
                end
            end
        end

        function deleteLastActionBackupSignalID(sigIDs)
            engine=Simulink.sdi.Instance.engine;
            for idx=1:numel(sigIDs)
                sigID=sigIDs(idx);
                lastActionBackupSignalID=int32(engine.getMetaDataV2(sigID,'LastActionBackupSignalID'));
                signal.sigappsshared.SignalUtilities.deleteSignalsAndResampledSignalsInEngine(lastActionBackupSignalID);
                engine.setMetaDataV2(sigID,'LastActionBackupSignalID',-1);
            end
        end

        function[tmMode,isCurrentSignalNonUniform,isCurrentSignalFinite]=updateData(sigID,data,currentClientID,notifyFlag)

            engine=Simulink.sdi.Instance.engine;
            tmMode=engine.getSignalTmMode(sigID);


            if any(strcmp(tmMode,{'fs','ts'}))
                signalEffectiveFsBeforePreprocess=signal.sigappsshared.Utilities.getEffectiveSampleRate(sigID);
                startTimeBeforePreprocess=engine.getSignalTmStartTime(sigID);

            end

            sigObj=engine.getSignalObject(sigID);
            sigObj.Values=data;

            signal.sigappsshared.SignalUtilities.updateIsFiniteMetaDataFlag(engine,sigID,data.Data,false);




            engine.setSignalTmNumPoints(sigID,numel(data.Data));
            engine.setSignalTmTimeRange(sigID,[data.Time(1),data.Time(end)]);
            isCurrentSignalNonUniform=false;
            isCurrentSignalFinite=logical(engine.getMetaDataV2(sigID,'IsFinite'));
            if any(strcmp(tmMode,{'inherentTimetable','inherentTimeseries','tv'}))

                tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                isCurrentSignalNonUniform=tmd.updateResampledSignal(sigID,data,[],[],notifyFlag);
            elseif~strcmp(tmMode,'samples')

                [signalEffectiveFsAfterPreprocess,isIrregular]=signal.internal.utilities.getEffectiveFs(data.Time);
                tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
                startTimeUnitsAfterPreprocess=engine.getSignalTmStartTimeUnits(sigID);
                startTimeAfterPreprocess=signal.sigappsshared.Utilities.convertFromSecondsToTimeUnits(data.Time(1),startTimeUnitsAfterPreprocess);
                if isIrregular


                    tmd.updateResampledSignal(sigID,data,[],[],notifyFlag);
                    engine.setSignalTmMode(sigID,'tv');

                    evt.clientID=currentClientID;
                    evt.signalIDs=sigID;
                    evt.tmMode='tv';
                    evt.needsResampling=true;
                    outStruct=tmd.checkCompatibilityWithDisplay(evt);
                    evt.eventData=outStruct.evt;
                    tmd.notifyClientOfTimeMetadataChange(evt);
                    isCurrentSignalNonUniform=true;
                elseif signalEffectiveFsBeforePreprocess~=signalEffectiveFsAfterPreprocess||...
                    startTimeBeforePreprocess~=startTimeAfterPreprocess



                    if strcmp(tmMode,'fs')
                        sampleTimeOrRateUnits=engine.getSignalTmSampleRateUnits(sigID);
                        sampleTimeOrRate=signal.sigappsshared.Utilities.convertFromHzToFreqUnits(signalEffectiveFsAfterPreprocess,sampleTimeOrRateUnits);
                        fhdl=@tmd.setTimeMetadataByFs;

                    else
                        sampleTimeOrRateUnits=engine.getSignalTmSampleTimeUnits(sigID);
                        sampleTimeOrRate=signal.sigappsshared.Utilities.convertFromSecondsToTimeUnits(1/signalEffectiveFsAfterPreprocess,sampleTimeOrRateUnits);
                        fhdl=@tmd.setTimeMetadataByTs;
                    end
                    safeTransaction(engine,...
                    fhdl,...
                    sigID,...
                    sampleTimeOrRate,sampleTimeOrRateUnits,...
                    startTimeAfterPreprocess,startTimeUnitsAfterPreprocess,...
                    [],true,false,true,notifyFlag);
                end
            end
        end

        function setDirtyAppState()

            if signal.analyzer.Instance.isSDIRunning()
                engine=Simulink.sdi.Instance.engine;
                engine.dirty=true;
                gui=signal.analyzer.Instance.gui();
                gui.updateSessionInfo();
                gui.dirty=true;
            end
        end

        function children=getSignalLeafChildren(engine,varID)


            leafSigs=int32(Simulink.HMI.findAllLeafSigIDsForThisRoot(engine.sigRepository,varID));



            children=setdiff(leafSigs,varID);


            removeIdx=false(1,numel(children));
            for idx=1:numel(children)
                removeIdx(idx)=(engine.getSignalNumberOfPoints(children(idx))==0);
            end
            children(removeIdx)=[];
        end

        function updateResampledSignal(signalIDs,notifyFlag)

            if nargin<2
                notifyFlag=true;
            end
            engine=Simulink.sdi.Instance.engine;
            tmd=signal.sigappsshared.controllers.TimeMetadataDialog.getController();
            for idx=1:length(signalIDs)
                signalID=signalIDs(idx);
                if signalID>0
                    if strcmp(engine.getSignalTmMode(signalID),'tv')
                        tmd.updateResampledSignal(signalID,[],[],[],notifyFlag);
                    end
                end
            end
        end

        function notifySignalsInsertedEvent(runID)
            eng=Simulink.sdi.Instance.engine;
            if nargin<1
                runID=signal.analyzer.getAllRunIDs();
            end
            notify(eng,'signalsInsertedEvent',Simulink.sdi.internal.SDIEvent('signalsInsertedEvent',runID));
        end

        function sigProperties=getSignalProperties(engine,signalID)
            sigProperties=engine.safeTransaction(@getSignalPropertiesImpl,engine,signalID);
            function sigProperties=getSignalPropertiesImpl(engine,signalID)
                sigProperties.Complexity=engine.sigRepository.getSignalComplexityAndLeafPath(signalID).IsComplex;
                sigProperties.TmMode=engine.getSignalTmMode(signalID);
                sigProperties.TmModeLSS=signal.sigappsshared.SignalUtilities.getTmModeLabeledSignalSet(engine,signalID);
                sigProperties.TmResampledSigID=engine.getSignalTmResampledSigID(signalID);
                sigProperties.isFinite=signal.sigappsshared.SignalUtilities.getIsFiniteMetaDataFlag(signalID);
            end
        end

        function getSignalTableColumnTimeData=getSignalTableColumnTimeData(engine,signalIDs)
            getSignalTableColumnTimeData=engine.safeTransaction(@getSignalTableColumnTimeDataImpl,engine,signalIDs);
            function getSignalTableColumnTimeData=getSignalTableColumnTimeDataImpl(engine,signalIDs)
                for idx=1:numel(signalIDs)
                    signalID=signalIDs(idx);
                    [dispLabel,dispValue,dispUnits]=signal.sigappsshared.SignalUtilities.getSampleRateOrTimeDisplayValue(engine,signalID);
                    if isempty(dispLabel)
                        getSignalTableColumnTimeData(idx).timeValues="";%#ok<*AGROW>
                    else
                        getSignalTableColumnTimeData(idx).timeValues=dispLabel+dispValue+" "+dispUnits;
                    end
                    [dispValue,dispUnits]=signal.sigappsshared.SignalUtilities.getStartTimeDisplayValues(engine,signalID);
                    if isempty(dispValue)
                        getSignalTableColumnTimeData(idx).startTimeValues="";
                    else
                        getSignalTableColumnTimeData(idx).startTimeValues=dispValue+" "+dispUnits;
                    end
                    getSignalTableColumnTimeData(idx).samplesValues=engine.getSignalNumberOfPoints(signalID);
                end
            end
        end
    end
end