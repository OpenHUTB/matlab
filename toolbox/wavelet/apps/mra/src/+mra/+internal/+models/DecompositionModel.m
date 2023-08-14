classdef DecompositionModel<handle








    properties(Access=private)
DataModel
SignalMgr
    end

    methods

        function this=DecompositionModel(dataModel,signalMgr)
            this.DataModel=dataModel;
            this.SignalMgr=signalMgr;
        end


        function tableData=getDataForDecompositionSignalsTable(this,scenarioID)






            tableData=[];
            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            rowData=[scenarioID,scenarioParams.ScenarioName];%#ok<*AGROW> % ID and Scenario Name
            scenarioType=scenarioParams.Type;
            logicalIdx=[strcmpi(scenarioType,"modwtmra"),strcmpi(scenarioType,"tqwtmra"),...
            strcmpi(scenarioType,"ewtmra")];
            reqStrings=["MODWT","TQWT","EWT"];
            if any(logicalIdx)



                rowData=[rowData,reqStrings(logicalIdx)];
            else
                rowData=[rowData,upper(scenarioParams.Type)];
            end

            tableData=[tableData;rowData];
        end

        function tableData=getDataForLevelSelectionTable(this,scenarioID)







            tableData=[];
            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            energyByLevel=string(num2str(scenarioParams.EnergyByLevel*100,'%.2f'));
            lowFrequencies=string(num2str(scenarioParams.LowFrequencies,3));
            highFrequencies=string(num2str(scenarioParams.HighFrequencies,3));
            numberOfRows=numel(energyByLevel);
            isIncluded=scenarioParams.IsIncluded;
            isShown=scenarioParams.IsShown;
            decompositionSignalIDs=string(scenarioParams.DecompositionSignalIDs);

            if any(strcmpi(scenarioParams.Type,["modwtmra","tqwtmra"]))
                firstColumnTag="Level ";
                lastRowLevelLabel="Approx.";
            elseif any(strcmpi(scenarioParams.Type,["emd","vmd"]))
                firstColumnTag="IMF ";
                lastRowLevelLabel="Residual";
            elseif strcmpi(scenarioParams.Type,"ewtmra")
                firstColumnTag="Passband ";
                lastRowLevelLabel="Approx.";
            end

            for idx=1:numberOfRows
                rowData=[];
                rowData=[rowData,decompositionSignalIDs(idx)];
                if idx==numberOfRows
                    rowData=[rowData,lastRowLevelLabel];
                else
                    rowData=[rowData,firstColumnTag+idx];
                end
                rowData=[rowData,lowFrequencies(idx)+" - "+highFrequencies(idx)];
                rowData=[rowData,energyByLevel(idx)+"%"];
                rowData=[rowData,isIncluded(idx)];
                rowData=[rowData,isShown(idx)];
                tableData=[tableData;rowData];
            end
        end

        function toolstripData=getDataForToolstrip(this,scenarioID,isTimeInfoNeeded)
            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            scenarioType=scenarioParams.Type;
            if scenarioType=="modwtmra"
                toolstripData.WaveletSectionData=this.getWaveletSectionDataForMODWTMRA(scenarioParams);
            elseif scenarioType=="emd"
                toolstripData.WaveletSectionData=this.getWaveletSectionDataForToolstripForEMD(scenarioParams);
            elseif scenarioType=="tqwtmra"
                toolstripData.WaveletSectionData=this.getWaveletSectionDataForToolstripForTQWTMRA(scenarioParams);
            elseif scenarioType=="ewtmra"
                toolstripData.WaveletSectionData=this.getWaveletSectionDataForToolstripForEWTMRA(scenarioParams);
            elseif scenarioType=="vmd"
                toolstripData.WaveletSectionData=this.getWaveletSectionDataForToolstripForVMD(scenarioParams);
            end
            toolstripData.WaveletSectionData.Type=scenarioType;

            if isTimeInfoNeeded
                toolstripData.TimeInfo=this.getTimeInfo();
                toolstripData.TimeInfo.SamplePeriodUnits=mra.internal.Utilities.getSamplePeriodUnits();
                toolstripData.TimeInfo.SamplePeriodUnitLabels=mra.internal.Utilities.getSamplePeriodUnitLabels();
            end
        end

        function waveletSectionData=getWaveletSectionDataForMODWTMRA(this,scenarioParams)
            waveletSectionData.WaveletNames=mra.internal.Utilities.getWaveletNames();
            waveletSectionData.WaveletNumbers=this.getWaveletNumber(scenarioParams.WaveletName);
            waveletSectionData.WaveletNumber=string(scenarioParams.WaveletNumber);
            waveletSectionData.WaveletName=scenarioParams.WaveletName;
            waveletSectionData.Levels=scenarioParams.Levels;
            waveletSectionData.MaxLevels=this.getDataModel().getMODWTMRAMaxLevels();
            waveletSectionData.SigLength=numel(this.getDataModel().getImportedSignalData());
        end

        function waveletSectionData=getWaveletSectionDataForToolstripForEMD(this,scenarioParams)
            waveletSectionData.Interpolations=mra.internal.Utilities.getInterpolations();
            waveletSectionData.Interpolation=scenarioParams.Interpolation;
            waveletSectionData.SiftRelativeTolerance=string(scenarioParams.SiftRelativeTolerance);
            waveletSectionData.SiftMaxIterations=scenarioParams.SiftMaxIterations;
            waveletSectionData.MaxNumIMF=scenarioParams.MaxNumIMF;
            waveletSectionData.MaxNumExtrema=scenarioParams.MaxNumExtrema;
            waveletSectionData.MaxEnergyRatio=string(scenarioParams.MaxEnergyRatio);
            waveletSectionData.SigLength=numel(this.getDataModel().getImportedSignalData());
        end

        function waveletSectionData=getWaveletSectionDataForToolstripForTQWTMRA(this,scenarioParams)
            waveletSectionData.QualityFactor=string(scenarioParams.QualityFactor);
            waveletSectionData.TQWTLevels=scenarioParams.TQWTLevels;
            [~,MaxLevel]=this.getDataModel().getTQWTMRALevels(1);
            waveletSectionData.MaxLevels=MaxLevel;
            waveletSectionData.SigLength=numel(this.getDataModel().getImportedSignalData());
            waveletSectionData.validQ=wavelet.internal.tqwt.maxQ(waveletSectionData.SigLength,[1,20]);
            waveletSectionData.validQ=waveletSectionData.validQ(2);
        end

        function waveletSectionData=getWaveletSectionDataForToolstripForEWTMRA(this,scenarioParams)
            waveletSectionData.PeakThresholdPercent=string(scenarioParams.PeakThresholdPercent);
            [waveletSectionData.xrLength,waveletSectionData.Npad,waveletSectionData.MaxNumPeaksMaxValue]=...
            this.getDataModel().getMaxNumPeaks(scenarioParams.FrequencyResolution);
            waveletSectionData.MaxNumPeaks=min(4,waveletSectionData.MaxNumPeaksMaxValue);
            waveletSectionData.FrequencyResolution=string(scenarioParams.FrequencyResolution);
            waveletSectionData.SigLength=numel(this.getDataModel().getImportedSignalData());
            waveletSectionData.MinFrequencyResolution=string(2.5/(max(64,waveletSectionData.SigLength)+1));
            waveletSectionData.LogSpectrum=scenarioParams.LogSpectrum;
            waveletSectionData.GeometricMean=scenarioParams.GeometricMean;
            waveletSectionData.LocalMinimum=scenarioParams.LocalMinimum;
            waveletSectionData.MaxNumPeaksFlag=scenarioParams.MaxNumPeaksFlag;
            waveletSectionData.PeakThresholdPercentFlag=scenarioParams.PeakThresholdPercentFlag;
        end

        function waveletSectionData=getWaveletSectionDataForToolstripForVMD(~,scenarioParams)
            waveletSectionData.AbsoluteTolerance=string(scenarioParams.AbsoluteTolerance);
            waveletSectionData.RelativeTolerance=string(scenarioParams.RelativeTolerance);
            waveletSectionData.MaxIterations=scenarioParams.MaxIterations;
            waveletSectionData.NumIMF=scenarioParams.NumIMF;
            waveletSectionData.SigLength=scenarioParams.SigLength;
            waveletSectionData.VMDNumHalfFreqSamples=scenarioParams.VMDNumHalfFreqSamples;
            waveletSectionData.PenaltyFactor=string(scenarioParams.PenaltyFactor);
            waveletSectionData.LMUpdateRate=string(scenarioParams.LMUpdateRate);
            waveletSectionData.InitializeMethods=mra.internal.Utilities.getVMDInitializeMethod();
            waveletSectionData.InitializeMethod=scenarioParams.InitializeMethod;
            waveletSectionData.InitialIMFs=unique([mra.internal.Utilities.getVMDWorkSpace("InitialIMFs",[scenarioParams.SigLength,scenarioParams.NumIMF]);...
            "0"]);
            waveletSectionData.InitialIMFsSelectedString=scenarioParams.InitialIMFsSelectedString;
            waveletSectionData.VMDInitialIMFsValidFlag=logical(scenarioParams.VMDInitialIMFsValidFlag);
            waveletSectionData.InitialLM=unique([mra.internal.Utilities.getVMDWorkSpace("InitialLM",waveletSectionData.VMDNumHalfFreqSamples);...
            "0"]);
            waveletSectionData.InitialLMSelectedString=scenarioParams.InitialLMSelectedString;
            waveletSectionData.VMDInitialLMValidFlag=logical(scenarioParams.VMDInitialLMValidFlag);
            waveletSectionData.VMDUserSpecificCentralFrequencies=unique([mra.internal.Utilities.getVMDWorkSpace("CentralFrequencies",scenarioParams.NumIMF);...
            "0.5"]);
            waveletSectionData.VMDUserSpecificCentralFrequenciesSelectedString=scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString;
            waveletSectionData.VMDUserSpecificCentralFrequenciesValidFlag=...
            logical(scenarioParams.VMDUserSpecificCentralFrequenciesValidFlag);
            waveletSectionData.VMDInitialIMFsDisableFlag=logical(scenarioParams.VMDInitialIMFsDisableFlag);
            waveletSectionData.VMDUserSpecificCentralFrequenciesDisableFlag=logical(scenarioParams.VMDUserSpecificCentralFrequenciesDisableFlag);
        end

        function waveletNumbers=getWaveletNumber(~,waveletName)
            waveletNumbers=mra.internal.Utilities.getFilterNumbers(waveletName);
        end

        function errorFlag=getTQWTQFactor(this,qFactor)
            signalLength=numel(this.getDataModel().getImportedSignalData());
            minSigLen=ceil(exp(log(4*qFactor+4)-log(3*qFactor+1)+log(3*qFactor+3)));
            errorFlag=minSigLen>signalLength;
        end

        function[decompositionSignalIDs,reconstructionSignalID]=createSignalIDs(this,scenarioID,resetIncludedAndShowStatus)
            scenariosParams=this.getDataModel().getScenarioParams(scenarioID);
            numberOfSignalIDsToBeCreated=numel(scenariosParams.EnergyByLevel)+1;
            signalIDs=string(this.getSignalMgr().createSignalIDs(numberOfSignalIDsToBeCreated));
            decompositionSignalIDs=signalIDs(1:end-1);
            reconstructionSignalID=signalIDs(end);
            this.getDataModel().setDecompositionSignalIDsInScenario(scenarioID,decompositionSignalIDs);
            this.getDataModel().setReconstructionSignalIDInScenario(scenarioID,reconstructionSignalID);

            if resetIncludedAndShowStatus
                isIncludedStatus=zeros(numberOfSignalIDsToBeCreated-1,1);
                isIncludedStatus(end)=1;
            else
                isIncludedStatus=scenariosParams.IsIncluded;
            end
            this.getDataModel().setIsIncludedStatusInScenario(scenarioID,isIncludedStatus);

            if resetIncludedAndShowStatus
                isShownStatus=ones(numberOfSignalIDsToBeCreated-1,1);
            else
                isShownStatus=scenariosParams.IsShown;
            end

            this.getDataModel().setIsShownStatusInScenario(scenarioID,isShownStatus);
        end

        function signalID=createSignalIDForImportedSignal(this)
            signalID=string(this.getSignalMgr().createSignalIDs(1));
            this.getDataModel().setSignalIDForImportedSignal(signalID);
        end

        function signalIDs=addDecompositionSignalIDs(this,scenarioID,numberOfSignals)
            signalIDs=this.getSignalMgr().createSignalIDs(numberOfSignals);
            this.getDataModel().addDecompositionSignalIDsInScenario(scenarioID,signalIDs);
        end

        function signalIDs=removeDecompositionSignalIDs(this,scenarioID,numberOfSignalsToBeRemoved)
            signalIDs=this.getDecompositionSignalIDsForScenario(scenarioID);
            signalIDs=signalIDs(end-numberOfSignalsToBeRemoved:end-1);
            this.removeSignalIDs(signalIDs);
            this.getDataModel().removeDecompositionSignalIDsFromScenario(scenarioID,signalIDs);
        end

        function removeSignalIDs(this,signalIDs)
            this.getSignalMgr().removeSignalIDs(signalIDs);
        end

        function signalData=getSignalData(this,scenarioID)
            scenarioData=this.getDataModel().getDecompositionDataForScenario(scenarioID);
            reconstructionData=this.getDataModel().computeReconstructionDataForAllScenario();
            importedData=this.getDataModel().getImportedSignalData()';
            dataToBePlotted=[scenarioData.Signals;importedData;reconstructionData]';
            decompositionSignalIDs=this.getDecompositionSignalIDsForScenario(scenarioID);
            signalIDForImportedSignal=this.getSignalIDForImportedSignal();
            allReconstructionSignalIDs=this.getDataModel().getAllReconstructionSignalIDs();
            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            isIncluded=scenarioParams.IsIncluded;
            reconstrcutionSignalID=this.getDataModel().getReconstructionSignalIDInScenario(scenarioID);

            numberOfDecompositionSignalIDs=numel(decompositionSignalIDs);
            numberOfReconstructionSignalIDs=numel(allReconstructionSignalIDs);
            for idx=1:numel(decompositionSignalIDs)

                plottingMap.AxesIDs(idx)=decompositionSignalIDs(idx);
                plottingMap.SignalIDs(idx)=decompositionSignalIDs(idx);
                plottingMap.LegendLabels(idx)="";
                plottingMap.IsIncluded(idx)=isIncluded(idx);
                plottingMap.LineWidth(idx)=isIncluded(idx)+1;
            end


            index=idx+1;
            plottingMap.AxesIDs(index)=signalIDForImportedSignal;
            plottingMap.SignalIDs(index)=signalIDForImportedSignal;
            plottingMap.LegendLabels(index)=this.getDataModel().getImportedSignalName();
            plottingMap.IsIncluded(index)=1;
            plottingMap.LineWidth(index)=1;


            scenariosNames=this.getAllScenariosNames();
            for idx=1:numberOfReconstructionSignalIDs

                index=idx+numberOfDecompositionSignalIDs+1;
                plottingMap.AxesIDs(index)=signalIDForImportedSignal;
                plottingMap.SignalIDs(index)=allReconstructionSignalIDs(idx);
                plottingMap.LegendLabels(index)=scenariosNames(idx);
                plottingMap.IsIncluded(index)=1;
                plottingMap.LineWidth(index)=(allReconstructionSignalIDs(idx)==reconstrcutionSignalID)+1;
            end

            dataSize=size(dataToBePlotted);
            dataToBePlotted=mat2cell(dataToBePlotted,dataSize(1),ones(1,dataSize(2)));

            signalData.SignalIDs=[decompositionSignalIDs,signalIDForImportedSignal,allReconstructionSignalIDs];
            signalData.SignalData=dataToBePlotted;
            signalData.PlottingMap=plottingMap;
        end

        function signalData=getSignalDataOnInclude(this,scenarioID)
            reconstructionData=this.getReconstructionDataForScenario(scenarioID)';
            reconstructionSignalIDs=this.getReconstructionSignalIDInScenario(scenarioID);
            signalIDForImportedSignal=this.getSignalIDForImportedSignal();
            plottingMap.AxesIDs=signalIDForImportedSignal;
            plottingMap.SignalIDs=reconstructionSignalIDs;

            signalData.SignalIDs=reconstructionSignalIDs;
            signalData.SignalData={reconstructionData};
            signalData.PlottingMap=plottingMap;
            signalData.PerformFitToView=false;
        end



        function[signalIDsTobeAddedOrRemoved,numberOfSignals,lastDecompositionSignalID,isDecompositionRequired,newScenarioParams]=decompose(this,scenarioID,newScenarioParams)
            oldScenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            [isDecompositionRequired,newScenarioParams]=this.isDecompositionRequired(oldScenarioParams,newScenarioParams);
            signalIDsTobeAddedOrRemoved=[];
            numberOfSignals=0;
            lastDecompositionSignalID=[];
            newScenarioParams.Type=oldScenarioParams.Type;

            if isDecompositionRequired
                this.getDataModel().setScenarioParams(scenarioID,newScenarioParams);
                this.getDataModel().computeScenario(scenarioID);
                oldNumberOfSignalIDs=numel(oldScenarioParams.EnergyByLevel);
                newScenarioParams=this.getDataModel().getScenarioParams(scenarioID);
                newNumberOfSignalIDs=numel(newScenarioParams.EnergyByLevel);
                numberOfSignals=newNumberOfSignalIDs-oldNumberOfSignalIDs;

                if newScenarioParams.IsShown(end)
                    signalIDs=this.getDecompositionSignalIDsForScenario(scenarioID);
                    lastDecompositionSignalID=signalIDs(end);
                end

                if numberOfSignals>0
                    signalIDsTobeAddedOrRemoved=this.addDecompositionSignalIDs(scenarioID,numberOfSignals);
                elseif numberOfSignals<0
                    signalIDsTobeAddedOrRemoved=this.removeDecompositionSignalIDs(scenarioID,abs(numberOfSignals));
                end
            end
        end

        function scenarioID=addNewScenario(this,scenarioType)
            scenarioID=this.getDataModel().addScenario(scenarioType);
        end

        function newScenarioID=duplicateScenario(this,scenarioID)
            newScenarioID=this.getDataModel().duplicateScenario(scenarioID);
        end

        function[flag,newScenarioParams]=isDecompositionRequired(this,oldScenarioParams,newScenarioParams)
            flag=true;

            if oldScenarioParams.Type=="modwtmra"&&...
                string(oldScenarioParams.WaveletName)==newScenarioParams.WaveletName&&...
                oldScenarioParams.WaveletNumber==newScenarioParams.WaveletNumber&&...
                oldScenarioParams.Levels==newScenarioParams.Levels
                flag=false;
            elseif oldScenarioParams.Type=="emd"&&...
                string(oldScenarioParams.Interpolation)==newScenarioParams.Interpolation&&...
                oldScenarioParams.SiftRelativeTolerance==newScenarioParams.SiftRelativeTolerance&&...
                oldScenarioParams.SiftMaxIterations==newScenarioParams.SiftMaxIterations&&...
                oldScenarioParams.MaxNumIMF==newScenarioParams.MaxNumIMF&&...
                oldScenarioParams.MaxNumExtrema==newScenarioParams.MaxNumExtrema&&...
                oldScenarioParams.MaxEnergyRatio==newScenarioParams.MaxEnergyRatio
                flag=false;
            elseif oldScenarioParams.Type=="tqwtmra"&&...
                oldScenarioParams.QualityFactor==newScenarioParams.QualityFactor&&...
                oldScenarioParams.TQWTLevels==newScenarioParams.TQWTLevels
                flag=false;
            elseif oldScenarioParams.Type=="ewtmra"
                if newScenarioParams.PeakThresholdPercentFlag
                    flag=~(oldScenarioParams.PeakThresholdPercentFlag==newScenarioParams.PeakThresholdPercentFlag&&...
                    oldScenarioParams.PeakThresholdPercent==newScenarioParams.PeakThresholdPercent&&...
                    oldScenarioParams.FrequencyResolution==newScenarioParams.FrequencyResolution&&...
                    oldScenarioParams.LogSpectrum==newScenarioParams.LogSpectrum&&...
                    oldScenarioParams.GeometricMean==newScenarioParams.GeometricMean&&...
                    oldScenarioParams.LocalMinimum==newScenarioParams.LocalMinimum);
                elseif newScenarioParams.MaxNumPeaksFlag
                    flag=~(oldScenarioParams.MaxNumPeaksFlag==newScenarioParams.MaxNumPeaksFlag&&...
                    oldScenarioParams.MaxNumPeaks==newScenarioParams.MaxNumPeaks&&...
                    oldScenarioParams.FrequencyResolution==newScenarioParams.FrequencyResolution&&...
                    oldScenarioParams.LogSpectrum==newScenarioParams.LogSpectrum&&...
                    oldScenarioParams.GeometricMean==newScenarioParams.GeometricMean&&...
                    oldScenarioParams.LogSpectrum==newScenarioParams.LocalMinimum);
                end
            elseif oldScenarioParams.Type=="vmd"
                partialCheck=oldScenarioParams.AbsoluteTolerance==newScenarioParams.AbsoluteTolerance&&...
                oldScenarioParams.RelativeTolerance==newScenarioParams.RelativeTolerance&&...
                oldScenarioParams.MaxIterations==newScenarioParams.MaxIterations&&...
                oldScenarioParams.PenaltyFactor==newScenarioParams.PenaltyFactor&&...
                oldScenarioParams.LMUpdateRate==newScenarioParams.LMUpdateRate&&...
                string(oldScenarioParams.InitializeMethod)==string(newScenarioParams.InitializeMethod)&&...
                oldScenarioParams.NumIMF==newScenarioParams.NumIMF;

                if~isnumeric(newScenarioParams.InitialIMFs)
                    newScenarioParams.InitialIMFsSelectedString=newScenarioParams.InitialIMFs;
                    [newScenarioParams.InitialIMFs,newScenarioParams.VMDInitialIMFsValidFlag]=...
                    this.getDataModel().getValidVMDInput("InitialIMFs",newScenarioParams.InitialIMFs,...
                    [newScenarioParams.SigLength,newScenarioParams.NumIMF]);
                end

                partialCheck=partialCheck&&isequal(oldScenarioParams.InitialIMFs,newScenarioParams.InitialIMFs);

                if~isnumeric(newScenarioParams.InitialLM)
                    newScenarioParams.InitialLMSelectedString=newScenarioParams.InitialLM;
                    [newScenarioParams.InitialLM,newScenarioParams.VMDInitialLMValidFlag]=...
                    this.getDataModel().getValidVMDInput("InitialLM",newScenarioParams.InitialLM,newScenarioParams.VMDNumHalfFreqSamples);
                end

                partialCheck=partialCheck&&isequal(oldScenarioParams.InitialLM,newScenarioParams.InitialLM);

                if~isnumeric(newScenarioParams.VMDUserSpecificCentralFrequencies)
                    newScenarioParams.VMDUserSpecificCentralFrequenciesSelectedString=...
                    newScenarioParams.VMDUserSpecificCentralFrequencies;
                    [newScenarioParams.VMDUserSpecificCentralFrequencies,newScenarioParams.VMDUserSpecificCentralFrequenciesValidFlag]=...
                    this.getDataModel().getValidVMDInput("CentralFrequencies",newScenarioParams.VMDUserSpecificCentralFrequencies,newScenarioParams.NumIMF);
                end

                partialCheck=partialCheck&&isequal(oldScenarioParams.VMDUserSpecificCentralFrequencies,newScenarioParams.VMDUserSpecificCentralFrequencies);

                flag=~partialCheck;

                if~newScenarioParams.VMDInitialIMFsValidFlag||~newScenarioParams.VMDInitialLMValidFlag||~newScenarioParams.VMDUserSpecificCentralFrequenciesValidFlag
                    flag=false;
                end
            end
        end

        function decompositionSignalIDsRemoved=deleteScenario(this,scenarioID)
            decompositionSignalIDs=this.getDecompositionSignalIDsForScenario(scenarioID);
            reconstructionSignalID=this.getReconstructionSignalIDInScenario(scenarioID);
            this.removeSignalIDs([decompositionSignalIDs,reconstructionSignalID]);
            decompositionSignalIDsRemoved=this.getShownDecompositionSignalIDsForScenario(scenarioID);
            this.getDataModel().deleteScenario(scenarioID);
        end

        function updateFrequencyRangesForScenario(this,scenarioID)
            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            scenarioType=scenarioParams.Type;
            if scenarioType=="modwtmra"
                this.getDataModel().computeMODWTMRAFrequencyRanges(scenarioID);
            elseif scenarioType=="tqwtmra"
                this.getDataModel().computeTQWTFrequencyRanges(scenarioID);
            elseif any(strcmpi(scenarioType,["emd","ewtmra","vmd"]))
                this.getDataModel().computeFrequencyRanges(scenarioID);
            end
        end


        function[decompositionSignalIDsRemoved,allSignalIDsToBeRemoved]=resetModel(this)
            decompositionSignalIDsRemoved=this.getDataModel().getAllDecompositionSignalIDs();
            allSignalIDsToBeRemoved=[decompositionSignalIDsRemoved,this.getDataModel().getAllReconstructionSignalIDs()];
            this.getDataModel().resetModel();
            this.SignalMgr.release();
        end

        function updateIsIncludedInScenarios(this,scenarioID,decompositionSignalID)
            this.getDataModel().updateIsIncludedInScenarios(scenarioID,decompositionSignalID);
        end

        function signalIDs=updateIsShownInScenarios(this,scenarioID,decompositionSignalID)
            signalIDs=this.getDataModel().updateIsShownInScenarios(scenarioID,decompositionSignalID);
        end

        function setImportedSignalName(this,signalName)
            this.getDataModel().setImportedSignalName(signalName);
        end

        function setImportedSignalData(this,signalData)
            this.getDataModel().setImportedSignalData(signalData)
        end

        function updateTimeInfo(this,timeInfo)
            this.getDataModel().setTimeInfo(timeInfo);
        end

        function renameScenario(this,scenarioID,newScenarioName)
            this.getDataModel().renameScenario(scenarioID,newScenarioName);
        end


        function dataModel=getDataModel(this)
            dataModel=this.DataModel;
        end

        function signalMgr=getSignalMgr(this)
            signalMgr=this.SignalMgr;
        end

        function signalID=getSignalIDForImportedSignal(this)
            signalID=this.getDataModel().getSignalIDForImportedSignal();
        end

        function signalIDs=getDecompositionSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getDataModel().getDecompositionSignalIDsForScenario(scenarioID);
        end

        function signalIDs=getShownDecompositionSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getDataModel().getShownDecompositionSignalIDsForScenario(scenarioID);
        end

        function flag=isAppHasSignal(this)
            flag=~isempty(fieldnames(this.getDataModel().getImportedSignalInfo()));
        end

        function reconstructionData=getReconstructionDataForScenario(this,scenarioID)
            reconstructionData=this.getDataModel().computeReconstructionDataForScenario(scenarioID);
        end

        function scenarioSignals=getDecompositionSignalForScenario(this,scenarioID)
            scenarioSignals=this.getDataModel().getDecompositionDataForScenario(scenarioID).Signals;
        end

        function[outScriptText,timeStamp]=generateMATLABScriptText(this,selectedScenarioID)
            scenarioParams=this.getDataModel().getScenarioParams(selectedScenarioID);
            if scenarioParams.Type=="modwtmra"
                [outScriptText,timeStamp]=this.generateMATLABScriptTextForMODWTMRA(scenarioParams);
            elseif scenarioParams.Type=="emd"
                [outScriptText,timeStamp]=this.generateMATLABScriptTextForEMD(scenarioParams);
            elseif scenarioParams.Type=="tqwtmra"
                [outScriptText,timeStamp]=this.generateMATLABScriptTextForTQWTMRA(scenarioParams);
            elseif scenarioParams.Type=="ewtmra"
                [outScriptText,timeStamp]=this.generateMATLABScriptTextForEWTMRA(scenarioParams);
            elseif scenarioParams.Type=="vmd"
                [outScriptText,timeStamp]=this.generateMATLABScriptTextForVMD(scenarioParams);
            end
        end

        function[outScriptText,timeStamp]=generateMATLABScriptTextForMODWTMRA(this,scenarioParams)


            wname=string(scenarioParams.WaveletName)+string(scenarioParams.WaveletNumber);
            isIncludedText=string(logical(scenarioParams.IsIncluded));
            isIncludedText=strjoin(isIncludedText,",");
            timeStamp=wavelet.internal.wtbxfileheader('','wavelet');

            outScriptText="% Decompose signal using the MODWT"+newline+newline+...
            timeStamp+newline+newline+...
            "% Logical array for selecting reconstruction elements"+newline+...
            "levelForReconstruction = "+"["+isIncludedText+"];"+newline+newline+...
            "% Perform the decomposition using modwt"+newline+"wt = modwt("+...
            this.getDataModel().getImportedSignalName()+","+"'"+wname+"',"+...
            string(scenarioParams.Levels)+");"+newline+newline+...
            "% Construct MRA matrix using modwtmra"+newline+...
            "mra = modwtmra(wt,'"+wname+"');"+newline+newline+...
            "% Sum down the rows of the selected multiresolution signals"+newline+...
            scenarioParams.ScenarioName+" = sum(mra(levelForReconstruction,:),1);"+newline;
        end

        function[outScriptText,timeStamp]=generateMATLABScriptTextForEMD(this,scenarioParams)


            isIncludedText=string(logical(scenarioParams.IsIncluded));
            isIncludedText=strjoin(isIncludedText,",");
            timeStamp=wavelet.internal.wtbxfileheader('','wavelet');

            outScriptText="% Decompose signal using the EMD"+newline+newline+...
            timeStamp+newline+newline+...
            "% Logical array for selecting reconstruction elements"+newline+...
            "levelForReconstruction = "+"["+isIncludedText+"];"+newline+newline+...
            "% Perform the decomposition using EMD"+newline+"[imf,residual,info] = emd("+...
            this.getDataModel().getImportedSignalName()+", ..."+newline+...
            "    SiftRelativeTolerance="+string(scenarioParams.SiftRelativeTolerance)+", ..."+newline+...
            "    SiftMaxIterations="+string(scenarioParams.SiftMaxIterations)+", ..."+newline+...
            "    MaxNumIMF="+string(scenarioParams.MaxNumIMF)+", ..."+newline+...
            "    MaxNumExtrema="+string(scenarioParams.MaxNumExtrema)+", ..."+newline+...
            "    MaxEnergyRatio="+string(scenarioParams.MaxEnergyRatio)+", ..."+newline+...
            "    Interpolation='"+scenarioParams.Interpolation+"');"+newline+newline+...
            "% Construct MRA matrix by appending IMFs and residual"+newline+...
            "mra = [imf residual].';"+newline+newline+...
            "% Sum down the rows of the selected multiresolution signals"+newline+...
            scenarioParams.ScenarioName+" = sum(mra(levelForReconstruction,:),1);"+newline;
        end

        function[outScriptText,timeStamp]=generateMATLABScriptTextForTQWTMRA(this,scenarioParams)

            timeStamp=wavelet.internal.wtbxfileheader('','wavelet');
            isIncludedText=string(logical(scenarioParams.IsIncluded));
            isIncludedText=strjoin(isIncludedText,",");
            outScriptText="% Decompose signal using the TQWT"+newline+newline+...
            timeStamp+newline+newline+...
            "% Logical array for selecting reconstruction elements"+newline+...
            "levelForReconstruction = "+"["+isIncludedText+"];"+newline+newline+...
            "% Perform the decomposition using tqwt"+newline+"[wt,info] = tqwt("+...
            this.getDataModel().getImportedSignalName()+", ..."+newline+...
            "    Level="+string(scenarioParams.TQWTLevels)+", ..."+newline+...
            "    QualityFactor="+string(scenarioParams.QualityFactor)+");"+newline+newline+...
            "% Construct MRA matrix using tqwtmra"+newline+...
            "mra = tqwtmra(wt, "+string(scenarioParams.SigLength)+", "+...
            "QualityFactor="+string(scenarioParams.QualityFactor)+");"+newline+newline+...
            "% Sum down the rows of the selected multiresolution signals"+newline+...
            scenarioParams.ScenarioName+" = sum(mra(levelForReconstruction,:),1);"+newline;
        end

        function[outScriptText,timeStamp]=generateMATLABScriptTextForEWTMRA(this,scenarioParams)

            timeStamp=wavelet.internal.wtbxfileheader('','wavelet');
            isIncludedText=string(logical(scenarioParams.IsIncluded));
            isIncludedText=strjoin(isIncludedText,",");
            headerScriptText="% Decompose signal using the EWT"+newline+newline+...
            timeStamp+newline+newline+...
            "% Logical array for selecting reconstruction elements"+newline+...
            "levelForReconstruction = "+"["+isIncludedText+"];"+newline+newline+...
            "% Perform the decomposition using ewt"+newline;

            scenarioParams.SegmentMethod=...
            this.getDataModel().getSegmentMethod(scenarioParams.GeometricMean);

            if scenarioParams.MaxNumPeaksFlag
                functionScriptText="[mra,cfs,wfb,info] = ewt("+...
                this.getDataModel().getImportedSignalName()+", ..."+newline+...
                "    MaxNumPeaks="+string(scenarioParams.MaxNumPeaks)+", ..."+newline+...
                "    SegmentMethod='"+string(scenarioParams.SegmentMethod)+"', ..."+newline+...
                "    FrequencyResolution="+string(scenarioParams.FrequencyResolution)+", ..."+newline+...
                "    LogSpectrum="+string(scenarioParams.LogSpectrum)+");"+newline+newline;
            else
                functionScriptText="[mra,cfs,wfb,info] = ewt("+...
                this.getDataModel().getImportedSignalName()+", ..."+newline+...
                "    PeakThresholdPercent="+string(scenarioParams.PeakThresholdPercent)+", ..."+newline+...
                "    SegmentMethod='"+scenarioParams.SegmentMethod+"', ..."+newline+...
                "    FrequencyResolution="+string(scenarioParams.FrequencyResolution)+", ..."+newline+...
                "    LogSpectrum="+string(scenarioParams.LogSpectrum)+");"+newline+newline;
            end

            footerScriptText="% Sum down the rows of the selected multiresolution signals"+newline+...
            scenarioParams.ScenarioName+" = sum(mra(:,levelForReconstruction),2);"+newline;

            outScriptText=headerScriptText+functionScriptText+footerScriptText;
        end

        function[outScriptText,timeStamp]=generateMATLABScriptTextForVMD(this,scenarioParams)

            timeStamp=wavelet.internal.wtbxfileheader('','wavelet');
            isIncludedText=string(logical(scenarioParams.IsIncluded));
            isIncludedText=strjoin(isIncludedText,",");

            initialIMFsIntermediateValue=str2num(char(scenarioParams.InitialIMFsSelectedString));%#ok<ST2NM> 
            if isempty(initialIMFsIntermediateValue)&&mra.internal.Utilities.checkForVariableNameInWorkspace(scenarioParams.InitialIMFsSelectedString)
                initialIMFsIntermediateValue=evalin('base',['[',scenarioParams.InitialIMFsSelectedString,']']);
            end

            if scenarioParams.InitialIMFsSelectedString=="0"
                scenarioParams.InitialIMFsValue="zeros("+string(scenarioParams.SigLength)...
                +","+string(scenarioParams.NumIMF)+")";
            elseif isscalar(initialIMFsIntermediateValue)&&isfinite(initialIMFsIntermediateValue)
                scenarioParams.InitialIMFsValue="repmat("+string(scenarioParams.InitialIMFsSelectedString)...
                +","+string(scenarioParams.SigLength)+","+string(scenarioParams.NumIMF)+")";
            elseif all(isvector(initialIMFsIntermediateValue))&&all(isfinite(initialIMFsIntermediateValue))
                if isrow(initialIMFsIntermediateValue)
                    scenarioParams.InitialIMFsValue="repmat("+string(scenarioParams.InitialIMFsSelectedString)...
                    +".',1,"+string(scenarioParams.NumIMF)+")";
                else
                    scenarioParams.InitialIMFsValue="repmat("+string(scenarioParams.InitialIMFsSelectedString)...
                    +","+string(scenarioParams.NumIMF)+",1)";
                end
            else
                scenarioParams.InitialIMFsValue=scenarioParams.InitialIMFsSelectedString;
            end

            initialLMIntermediateValue=str2num(char(scenarioParams.InitialLMSelectedString));%#ok<ST2NM> 
            if isempty(initialIMFsIntermediateValue)&&mra.internal.Utilities.checkForVariableNameInWorkspace(scenarioParams.InitialIMFsSelectedString)
                initialLMIntermediateValue=evalin('base',['[',scenarioParams.InitialLMSelectedString,']']);
            end

            if scenarioParams.InitialLMSelectedString=="0"
                scenarioParams.InitialLMValue="complex(zeros("+string(scenarioParams.VMDNumHalfFreqSamples)+",1))";
            elseif isscalar(initialLMIntermediateValue)&&isfinite(initialLMIntermediateValue)
                scenarioParams.InitialLMValue="complex(repmat("+string(initialLMIntermediateValue)...
                +","+string(scenarioParams.VMDNumHalfFreqSamples)+",1))";
            else
                scenarioParams.InitialLMValue=scenarioParams.InitialLMSelectedString;
            end

            if scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString=="0.5"
                scenarioParams.VMDUserSpecificCentralFrequenciesValue="0.5*ones("+string(scenarioParams.NumIMF)+",1)";
            else
                scenarioParams.VMDUserSpecificCentralFrequenciesValue=scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString;
            end

            outScriptText="% Decompose signal using the VMD"+newline+newline+...
            timeStamp+newline+newline+...
            "% Logical array for selecting reconstruction elements"+newline+...
            "levelForReconstruction = "+"["+isIncludedText+"];"+newline+newline+...
            "% Perform the decomposition using VMD"+newline+"[imf,residual,info] = vmd("+...
            this.getDataModel().getImportedSignalName()+", ..."+newline+...
            "    AbsoluteTolerance="+string(scenarioParams.AbsoluteTolerance)+", ..."+newline+...
            "    RelativeTolerance="+string(scenarioParams.RelativeTolerance)+", ..."+newline+...
            "    MaxIterations="+string(scenarioParams.MaxIterations)+", ..."+newline+...
            "    NumIMF="+string(scenarioParams.NumIMF)+", ..."+newline+...
            "    InitialIMFs="+string(scenarioParams.InitialIMFsValue)+", ..."+newline+...
            "    PenaltyFactor="+string(scenarioParams.PenaltyFactor)+", ..."+newline+...
            "    InitialLM="+string(scenarioParams.InitialLMValue)+", ..."+newline+...
            "    LMUpdateRate="+string(scenarioParams.LMUpdateRate)+", ..."+newline;


            if strcmpi(scenarioParams.InitializeMethod,"Specify")
                intermediateCFValue=str2num(char(scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString));%#ok<ST2NM>
                if isempty(intermediateCFValue)&&mra.internal.Utilities.checkForVariableNameInWorkspace(scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString)
                    intermediateCFValue=evalin('base',['[',scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString,']']);
                end

                if isscalar(intermediateCFValue)&&isfinite(intermediateCFValue)
                    scenarioParams.VMDUserSpecificCentralFrequenciesValueString=string(scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString)+...
                    "*ones("+string(num2str(scenarioParams.NumIMF))+",1)";
                else
                    scenarioParams.VMDUserSpecificCentralFrequenciesValueString=scenarioParams.VMDUserSpecificCentralFrequencies;
                end

                outScriptText=outScriptText+"    CentralFrequencies="+...
                scenarioParams.VMDUserSpecificCentralFrequenciesValueString+");"+...
                newline+newline;
            else
                scenarioParams=this.getDataModel().parseVMDParameters(scenarioParams);
                outScriptText=outScriptText+"    InitializeMethod='"+scenarioParams.IMFFrequenciesValue+"');"+newline+newline;
            end

            outScriptText=outScriptText+"% Construct MRA matrix by appending IMFs and residual"+newline+...
            "mra = [imf residual].';"+newline+newline+...
            "% Sum down the rows of the selected multiresolution signals"+newline+...
            scenarioParams.ScenarioName+" = sum(mra(levelForReconstruction,:),1);"+newline;
        end

        function timeInfo=getTimeInfo(this)
            timeInfo=this.getDataModel().getTimeInfo();
        end

        function xLabel=getXLabelForAxes(this)
            timeInfo=this.getDataModel().getTimeInfo();
            timeMode=timeInfo.TimeMode;

            if timeMode=="samples"
                catalogMessageKey="samples";
            elseif timeMode=="sampleRate"
                catalogMessageKey="samplePeriodUnitSeconds";
            elseif timeMode=="samplePeriod"
                catalogMessageKey=mra.internal.Utilities.getCatalogMessageKeyForSamplePeriod(timeInfo);
            end

            xLabel=string(getString(message("wavelet_mraapp:toolstrip:"+catalogMessageKey)));
        end

        function signalID=getReconstructionSignalIDInScenario(this,scenarioID)
            signalID=this.getDataModel().getReconstructionSignalIDInScenario(scenarioID);
        end

        function scenariosNames=getAllScenariosNames(this)
            scenariosNames=this.getDataModel().getAllScenariosNames();
            scenariosNames=[scenariosNames;this.DataModel().getImportedSignalName];
        end

        function frequencyColumnLabel=getFrequencyColumnLabel(this)
            timeInfo=this.getDataModel().getTimeInfo();
            timeMode=timeInfo.TimeMode;

            if timeMode=="samples"
                catalogMessageKey="cyclesPerSample";
                headerLabel=string(getString(message("wavelet_mraapp:mra:levelSelectionTableFrequenciesColumn")));
            elseif timeMode=="sampleRate"
                catalogMessageKey="samplePeriodUnitHz";
                headerLabel=string(getString(message("wavelet_mraapp:mra:levelSelectionTableFrequenciesColumn")));
            elseif timeMode=="samplePeriod"
                catalogMessageKey=mra.internal.Utilities.getCatalogMessageKeyForSamplePeriod(timeInfo);
                headerLabel=string(getString(message("wavelet_mraapp:mra:levelSelectionTablePeriodsColumn")));
            end

            frequencyColumnLabel=compose(headerLabel+"\n("+string(getString(message("wavelet_mraapp:toolstrip:"+catalogMessageKey)))+")");
        end

        function includeStatus=getIncludeStatus(this,scenarioID,signalID)
            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            isIncluded=scenarioParams.IsIncluded;
            includeStatus=isIncluded(scenarioParams.DecompositionSignalIDs==signalID);
        end

        function scenarioName=getScenarioName(this,scenarioID)
            scenarioName=this.getDataModel().getScenarioParams(scenarioID).ScenarioName;
        end

        function multiplier=getMultiplierForTimeInfo(this)
            timeInfo=this.getDataModel().getTimeInfo();
            timeMode=timeInfo.TimeMode;

            if timeMode=="samplePeriod"
                multiplier=timeInfo.SamplePeriod;
            elseif timeMode=="sampleRate"
                multiplier=1/timeInfo.SampleRate;
            elseif timeMode=="samples"
                multiplier=1;
            end
        end
    end
end
