classdef DataModel<handle









    properties(Access=private)
ImportedSignalInfo
Scenarios
ScenarioCount
TimeInfo
    end

    methods

        function this=DataModel(inputSignal)
            this.resetModel();
            if~isempty(inputSignal)
                this.setImportedSignalData(inputSignal{1});
                this.setImportedSignalName(inputSignal{2});
            end
        end


        function scenarioID=addScenario(this,scenarioType)
            scenarioID=this.createScenarioID();
            this.createScenarioName(scenarioID);
            this.resetScenario(scenarioID,scenarioType);
            this.computeScenario(scenarioID);
        end

        function computeScenario(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            if scenarioParams.Type=="modwtmra"
                this.computeMODWTMRA(scenarioID);
                this.computeMODWTMRAFrequencyRanges(scenarioID);
                this.computeMODDWTEnergyByLevel(scenarioID);
            elseif scenarioParams.Type=="emd"
                this.computeEMD(scenarioID);
                this.computeFrequencyRanges(scenarioID);
                this.computeEMDEnergyByLevel(scenarioID);
            elseif scenarioParams.Type=="tqwtmra"
                this.computeTQWTMRA(scenarioID);

                this.computeTQWTMRAEnergyByLevel(scenarioID);
            elseif scenarioParams.Type=="ewtmra"
                this.computeEWTMRA(scenarioID);
                this.computeFrequencyRanges(scenarioID);
                this.computeEWTMRAEnergyByLevel(scenarioID);
            elseif scenarioParams.Type=="vmd"
                this.computeVMD(scenarioID);
                this.computeFrequencyRanges(scenarioID);
                this.computeVMDEMDEnergyByLevel(scenarioID);
            end
        end

        function computeMODWTMRA(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            wname=string(scenarioParams.WaveletName)+scenarioParams.WaveletNumber;
            coefficients=modwt(this.getImportedSignalData(),wname,scenarioParams.Levels);
            this.Scenarios.(scenarioID).DecompositionData.Signals=modwtmra(coefficients,wname);
            this.Scenarios.(scenarioID).DecompositionData.Coefficients=coefficients;
        end

        function computeEMD(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            [imf,residual]=emd(this.getImportedSignalData(),...
            'SiftRelativeTolerance',scenarioParams.SiftRelativeTolerance,...
            'SiftMaxIterations',scenarioParams.SiftMaxIterations,...
            'MaxNumIMF',scenarioParams.MaxNumIMF,...
            'MaxNumExtrema',scenarioParams.MaxNumExtrema,...
            'MaxEnergyRatio',scenarioParams.MaxEnergyRatio,...
            'Interpolation',scenarioParams.Interpolation,...
            'Display',0);
            this.Scenarios.(scenarioID).DecompositionData.Signals=[imf,residual]';
        end

        function computeTQWTMRA(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            signal=this.getImportedSignalData();
            signalLength=numel(signal);
            [coefficients,info]=tqwt(signal,...
            'level',scenarioParams.TQWTLevels,...
            'QualityFactor',scenarioParams.QualityFactor);
            this.Scenarios.(scenarioID).DecompositionData.Signals=...
            tqwtmra(coefficients,signalLength,...
            "QualityFactor",scenarioParams.QualityFactor);
            this.Scenarios.(scenarioID).DecompositionData.Coefficients=coefficients;
            this.Scenarios.(scenarioID).DecompositionData.Info=info;
            this.computeTQWTFrequencyRanges(scenarioID);
        end

        function computeEWTMRA(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            signal=this.getImportedSignalData();

            if scenarioParams.MaxNumPeaksFlag
                scenarioParams.FieldName="MaxNumPeaks";
                scenarioParams.FieldValue=scenarioParams.MaxNumPeaks;
            else
                scenarioParams.FieldName="PeakThresholdPercent";
                scenarioParams.FieldValue=scenarioParams.PeakThresholdPercent;
            end

            flag=scenarioParams.GeometricMean&&~scenarioParams.LocalMinimum;
            scenarioParams.SegmentMethod=this.getSegmentMethod(flag);

            [mra,cfs]=ewt(signal,...
            scenarioParams.FieldName,scenarioParams.FieldValue,...
            "SegmentMethod",scenarioParams.SegmentMethod,...
            "FrequencyResolution",scenarioParams.FrequencyResolution,...
            "LogSpectrum",scenarioParams.LogSpectrum);

            this.Scenarios.(scenarioID).DecompositionData.Signals=mra.';
            this.Scenarios.(scenarioID).DecompositionData.Coefficients=cfs;
        end

        function computeVMD(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            scenarioParams=this.parseVMDParameters(scenarioParams);

            [imf,residual]=vmd(this.getImportedSignalData(),...
            'AbsoluteTolerance',scenarioParams.AbsoluteTolerance,...
            'RelativeTolerance',scenarioParams.RelativeTolerance,...
            'MaxIterations',scenarioParams.MaxIterations,...
            'NumIMF',scenarioParams.NumIMF,...
            'InitialIMFs',scenarioParams.InitialIMFs,...
            'PenaltyFactor',scenarioParams.PenaltyFactor,...
            'InitialLM',scenarioParams.InitialLM,...
            'LMUpdateRate',scenarioParams.LMUpdateRate,...
            scenarioParams.IMFFrequenciesName,scenarioParams.IMFFrequenciesValue,...
            'Display',0);
            this.Scenarios.(scenarioID).DecompositionData.Signals=[imf,residual]';
        end

        function scenarioParams=parseVMDParameters(~,scenarioParams)
            if strcmpi(scenarioParams.InitializeMethod,"Specify")
                scenarioParams.IMFFrequenciesName="CentralFrequencies";
                scenarioParams.IMFFrequenciesValue=scenarioParams.VMDUserSpecificCentralFrequencies;
            else
                scenarioParams.IMFFrequenciesName="InitializeMethod";
                if strcmpi(scenarioParams.InitializeMethod,"Peaks")
                    scenarioParams.IMFFrequenciesValue="peaks";
                elseif strcmpi(scenarioParams.InitializeMethod,"Random")
                    scenarioParams.IMFFrequenciesValue="random";
                else
                    scenarioParams.IMFFrequenciesValue="grid";
                end
            end
        end

        function createScenarioName(this,scenarioID)


            scenarioName=string(this.getImportedSignalName())+this.ScenarioCount;
            allScenarioNames=this.getAllScenariosNames();
            scenarioName=matlab.lang.makeUniqueStrings(scenarioName,allScenarioNames);
            this.Scenarios.(scenarioID).Parameters.ScenarioName=scenarioName;
        end

        function scenarioID=createScenarioID(this)
            this.ScenarioCount=this.ScenarioCount+1;
            scenarioID="scenarioID_"+this.ScenarioCount;
        end

        function computeMODWTMRAFrequencyRanges(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            wname=string(scenarioParams.WaveletName)+scenarioParams.WaveletNumber;
            timeMode=this.TimeInfo.TimeMode;
            levels=scenarioParams.Levels;
            signalLength=numel(this.getImportedSignalData());

            if timeMode=="sampleRate"
                sampleRate=this.TimeInfo.SampleRate;
                filterBank=dwtfilterbank(...
                'SignalLength',signalLength,...
                'Wavelet',wname,...
                'SamplingFrequency',sampleRate,...
                'Level',levels);
            elseif timeMode=="samplePeriod"
                samplePeriod=this.TimeInfo.SamplePeriod;
                samplePeriodFunc=str2func(this.TimeInfo.SamplePeriodUnit);
                FsEquiv=1/seconds(samplePeriodFunc(samplePeriod));
                filterBank=dwtfilterbank(...
                'SignalLength',signalLength,...
                'Wavelet',wname,...
                'SamplingFrequency',FsEquiv,...
                'Level',levels);
            elseif timeMode=="samples"
                filterBank=dwtfilterbank(...
                'SignalLength',signalLength,...
                'Wavelet',wname,...
                'Level',levels);
            end

            powerBandwidth=filterBank.powerbw();
            lowFrequencies=[powerBandwidth.Wavelet3dBBandwidth(:,1);powerBandwidth.Scaling3dBBandwidth(end,1)];
            highFrequencies=[powerBandwidth.Wavelet3dBBandwidth(:,2);powerBandwidth.Scaling3dBBandwidth(end,2)];

            if timeMode=="samplePeriod"
                lowFrequencies=samplePeriodFunc(seconds(1./lowFrequencies));
                highFrequencies=samplePeriodFunc(seconds(1./highFrequencies));
            end

            this.Scenarios.(scenarioID).Parameters.LowFrequencies=lowFrequencies(:);
            this.Scenarios.(scenarioID).Parameters.HighFrequencies=highFrequencies(:);
        end

        function computeFrequencyRanges(this,scenarioID)
            Fs=1;
            timeMode=this.TimeInfo.TimeMode;

            if timeMode=="sampleRate"
                Fs=this.TimeInfo.SampleRate;
            elseif timeMode=="samplePeriod"
                samplePeriodFunc=str2func(this.TimeInfo.SamplePeriodUnit);
                Fs=1./seconds(samplePeriodFunc(this.TimeInfo.SamplePeriod));
            end
            inputDecSignal=this.getDecompositionDataForScenario(scenarioID).Signals';
            [~,lowFrequencies,highFrequencies]=wavelet.internal.obw(inputDecSignal,Fs,90);

            if timeMode=="samplePeriod"
                lowFrequencies=samplePeriodFunc(seconds(1./lowFrequencies));
                highFrequencies=samplePeriodFunc(seconds(1./highFrequencies));
            end

            this.Scenarios.(scenarioID).Parameters.LowFrequencies=lowFrequencies(:);
            this.Scenarios.(scenarioID).Parameters.HighFrequencies=highFrequencies(:);
        end

        function computeTQWTFrequencyRanges(this,scenarioID)
            timeMode=this.TimeInfo.TimeMode;
            info=this.Scenarios.(scenarioID).DecompositionData.Info;
            centralFreq=info.CenterFrequencies;
            lowFrequencies=centralFreq-0.5*info.Bandwidths;
            highFrequencies=centralFreq+0.5*info.Bandwidths;
            highFrequencies=[highFrequencies,lowFrequencies(end)];
            lowFrequencies=[lowFrequencies,0.0];

            if timeMode=="samplePeriod"
                samplePeriodFunc=str2func(this.TimeInfo.SamplePeriodUnit);
                lowFrequencies=samplePeriodFunc(seconds(1./lowFrequencies));
                highFrequencies=samplePeriodFunc(seconds(1./highFrequencies));
            end

            this.Scenarios.(scenarioID).Parameters.LowFrequencies=lowFrequencies(:);
            this.Scenarios.(scenarioID).Parameters.HighFrequencies=highFrequencies(:);
        end

        function computeMODDWTEnergyByLevel(this,scenarioID)
            coefficients=this.getDecompositionDataForScenario(scenarioID).Coefficients;
            energyByLevel=sum(coefficients.^2,2);
            energyByLevel=energyByLevel./sum(this.getImportedSignalData().^2);
            this.Scenarios.(scenarioID).Parameters.EnergyByLevel=energyByLevel(:);
        end

        function computeEMDEnergyByLevel(this,scenarioID)
            signals=this.getDecompositionDataForScenario(scenarioID).Signals;
            energyByLevel=sum(signals.^2,2);
            energyByLevel=energyByLevel./sum(energyByLevel);
            this.Scenarios.(scenarioID).Parameters.EnergyByLevel=energyByLevel(:);
        end

        function computeTQWTMRAEnergyByLevel(this,scenarioID)
            coefficients=this.getDecompositionDataForScenario(scenarioID).Coefficients;
            energyByLevel=cellfun(@(x)norm(x,2)^2,coefficients);
            energyByLevel=energyByLevel./norm(this.getImportedSignalData(),2)^2;
            this.Scenarios.(scenarioID).Parameters.EnergyByLevel=energyByLevel(:);
        end

        function computeEWTMRAEnergyByLevel(this,scenarioID)
            coefficients=this.getDecompositionDataForScenario(scenarioID).Coefficients;
            energyByLevel=sum(coefficients.^2,1);
            energyByLevel=energyByLevel./sum(this.getImportedSignalData().^2);
            this.Scenarios.(scenarioID).Parameters.EnergyByLevel=energyByLevel(:);
        end

        function computeVMDEMDEnergyByLevel(this,scenarioID)
            signals=this.getDecompositionDataForScenario(scenarioID).Signals;
            energyByLevel=sum(signals.^2,2);
            energyByLevel=energyByLevel./sum(energyByLevel);
            this.Scenarios.(scenarioID).Parameters.EnergyByLevel=energyByLevel(:);
        end

        function reconstructionData=computeReconstructionDataForScenario(this,scenarioID)
            decompositionSignals=this.getDecompositionDataForScenario(scenarioID).Signals;
            isIncluded=logical(this.getScenarioParams(scenarioID).IsIncluded);
            if any(isIncluded)
                reconstructionData=sum(decompositionSignals(isIncluded,:),1);
            else
                reconstructionData=zeros(1,size(decompositionSignals,2));
            end
        end

        function reconstructionData=computeReconstructionDataForAllScenario(this)
            reconstructionData=[];
            scenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(scenarioIDs)
                reconstructionData=[reconstructionData;this.computeReconstructionDataForScenario(scenarioIDs(idx))];
            end
        end


        function resetModel(this)
            this.ImportedSignalInfo=struct;
            this.Scenarios=struct;
            this.ScenarioCount=0;
            this.resetTimeInfo();
        end

        function setMODWTMRAScenarioParams(this,scenarioID,scenarioParams)
            this.Scenarios.(scenarioID).Parameters.WaveletName=scenarioParams.WaveletName;
            this.Scenarios.(scenarioID).Parameters.WaveletNumber=scenarioParams.WaveletNumber;
            this.Scenarios.(scenarioID).Parameters.Levels=scenarioParams.Levels;
            this.Scenarios.(scenarioID).Parameters.Type=scenarioParams.Type;
        end

        function setEMDScenarioParams(this,scenarioID,scenarioParams)
            this.Scenarios.(scenarioID).Parameters.Interpolation=scenarioParams.Interpolation;
            this.Scenarios.(scenarioID).Parameters.SiftRelativeTolerance=scenarioParams.SiftRelativeTolerance;
            this.Scenarios.(scenarioID).Parameters.SiftMaxIterations=scenarioParams.SiftMaxIterations;
            this.Scenarios.(scenarioID).Parameters.MaxNumIMF=scenarioParams.MaxNumIMF;
            this.Scenarios.(scenarioID).Parameters.MaxNumExtrema=scenarioParams.MaxNumExtrema;
            this.Scenarios.(scenarioID).Parameters.MaxEnergyRatio=scenarioParams.MaxEnergyRatio;
            this.Scenarios.(scenarioID).Parameters.Type=scenarioParams.Type;
        end

        function setTQWTMRAScenarioParams(this,scenarioID,scenarioParams)
            this.Scenarios.(scenarioID).Parameters.TQWTLevels=scenarioParams.TQWTLevels;
            this.Scenarios.(scenarioID).Parameters.QualityFactor=scenarioParams.QualityFactor;
            this.Scenarios.(scenarioID).Parameters.Type=scenarioParams.Type;
            this.Scenarios.(scenarioID).Parameters.SigLength=numel(this.getImportedSignalData());
        end

        function setEWTMRAScenarioParams(this,scenarioID,scenarioParams)
            this.Scenarios.(scenarioID).Parameters.PeakThresholdPercent=scenarioParams.PeakThresholdPercent;
            this.Scenarios.(scenarioID).Parameters.GeometricMean=scenarioParams.GeometricMean;
            this.Scenarios.(scenarioID).Parameters.LocalMinimum=scenarioParams.LocalMinimum;
            this.Scenarios.(scenarioID).Parameters.MaxNumPeaks=scenarioParams.MaxNumPeaks;
            this.Scenarios.(scenarioID).Parameters.xrLength=scenarioParams.xrLength;
            this.Scenarios.(scenarioID).Parameters.Npad=scenarioParams.Npad;
            this.Scenarios.(scenarioID).Parameters.FrequencyResolution=scenarioParams.FrequencyResolution;
            this.Scenarios.(scenarioID).Parameters.MaxNumPeaksFlag=scenarioParams.MaxNumPeaksFlag;
            this.Scenarios.(scenarioID).Parameters.PeakThresholdPercentFlag=scenarioParams.PeakThresholdPercentFlag;
            this.Scenarios.(scenarioID).Parameters.SigLength=numel(this.getImportedSignalData());
            this.Scenarios.(scenarioID).Parameters.LogSpectrum=scenarioParams.LogSpectrum;
            this.Scenarios.(scenarioID).Parameters.Type=scenarioParams.Type;
        end

        function setVMDScenarioParams(this,scenarioID,scenarioParams)
            this.Scenarios.(scenarioID).Parameters.AbsoluteTolerance=scenarioParams.AbsoluteTolerance;
            this.Scenarios.(scenarioID).Parameters.RelativeTolerance=scenarioParams.RelativeTolerance;
            this.Scenarios.(scenarioID).Parameters.MaxIterations=scenarioParams.MaxIterations;
            this.Scenarios.(scenarioID).Parameters.NumIMF=scenarioParams.NumIMF;
            this.Scenarios.(scenarioID).Parameters.PenaltyFactor=scenarioParams.PenaltyFactor;
            this.Scenarios.(scenarioID).Parameters.LMUpdateRate=scenarioParams.LMUpdateRate;
            this.Scenarios.(scenarioID).Parameters.InitializeMethod=scenarioParams.InitializeMethod;
            this.Scenarios.(scenarioID).Parameters.InitialIMFs=scenarioParams.InitialIMFs;
            this.Scenarios.(scenarioID).Parameters.InitialLM=scenarioParams.InitialLM;
            this.Scenarios.(scenarioID).Parameters.InitialIMFsSelectedString=scenarioParams.InitialIMFsSelectedString;
            this.Scenarios.(scenarioID).Parameters.InitialLMSelectedString=scenarioParams.InitialLMSelectedString;
            this.Scenarios.(scenarioID).Parameters.VMDInitialIMFsValidFlag=scenarioParams.VMDInitialIMFsValidFlag;
            this.Scenarios.(scenarioID).Parameters.VMDInitialLMValidFlag=scenarioParams.VMDInitialLMValidFlag;
            this.Scenarios.(scenarioID).Parameters.SigLength=scenarioParams.SigLength;
            this.Scenarios.(scenarioID).Parameters.VMDNumHalfFreqSamples=scenarioParams.VMDNumHalfFreqSamples;
            this.Scenarios.(scenarioID).Parameters.Type=scenarioParams.Type;
            this.Scenarios.(scenarioID).Parameters.VMDUserSpecificCentralFrequenciesSelectedString=scenarioParams.VMDUserSpecificCentralFrequenciesSelectedString;
            this.Scenarios.(scenarioID).Parameters.VMDUserSpecificCentralFrequencies=scenarioParams.VMDUserSpecificCentralFrequencies;
            this.Scenarios.(scenarioID).Parameters.VMDUserSpecificCentralFrequenciesValidFlag=...
            scenarioParams.VMDUserSpecificCentralFrequenciesValidFlag;
            this.Scenarios.(scenarioID).Parameters.VMDInitialIMFsDisableFlag=scenarioParams.VMDInitialIMFsDisableFlag;
            this.Scenarios.(scenarioID).Parameters.VMDUserSpecificCentralFrequenciesDisableFlag=scenarioParams.VMDUserSpecificCentralFrequenciesDisableFlag;
        end

        function newScenarioID=duplicateScenario(this,scenarioID)
            newScenarioID=this.createScenarioID();
            this.Scenarios.(newScenarioID)=this.Scenarios.(scenarioID);


            newScenarioName=this.Scenarios.(scenarioID).Parameters.ScenarioName+"Copy";
            allScenarioNames=this.getAllScenariosNames();
            newScenarioName=matlab.lang.makeUniqueStrings(newScenarioName,allScenarioNames);


            this.Scenarios.(newScenarioID).Parameters.ScenarioName=newScenarioName;


            this.Scenarios.(newScenarioID).Parameters=rmfield(this.Scenarios.(newScenarioID).Parameters,"DecompositionSignalIDs");
            this.Scenarios.(newScenarioID).Parameters=rmfield(this.Scenarios.(newScenarioID).Parameters,"ReconstructionSignalID");
        end

        function resetScenario(this,scenarioID,scenarioType)
            if scenarioType=="modwtmra"
                scenarioParams=this.getDefaultMODWTMRAScenarioParams();
            elseif scenarioType=="emd"
                scenarioParams=this.getDefaultEMDScenarioParams();
            elseif scenarioType=="tqwtmra"
                scenarioParams=this.getDefaultTQWTMRAScenarioParams();
            elseif scenarioType=="ewtmra"
                scenarioParams=this.getDefaultEWTMRAScenarioParams();
            elseif scenarioType=="vmd"
                scenarioParams=this.getDefaultVMDScenarioParams();
            end
            this.setScenarioParams(scenarioID,scenarioParams);
        end

        function setScenarioParams(this,scenarioID,scenarioParams)
            scenarioType=scenarioParams.Type;
            if scenarioType=="modwtmra"
                this.setMODWTMRAScenarioParams(scenarioID,scenarioParams);
            elseif scenarioType=="emd"
                this.setEMDScenarioParams(scenarioID,scenarioParams);
            elseif scenarioType=="tqwtmra"
                this.setTQWTMRAScenarioParams(scenarioID,scenarioParams);
            elseif scenarioType=="ewtmra"
                this.setEWTMRAScenarioParams(scenarioID,scenarioParams);
            elseif scenarioType=="vmd"
                this.setVMDScenarioParams(scenarioID,scenarioParams);
            end
        end

        function setImportedSignalName(this,signalName)
            if isempty(signalName)
                this.ImportedSignalInfo.Name="Signal";
            else
                this.ImportedSignalInfo.Name=signalName;
            end
        end

        function setImportedSignalData(this,signalData)
            this.ImportedSignalInfo.Data=signalData(:);
        end

        function setDecompositionSignalIDsInScenario(this,scenarioID,signalIDs)
            this.Scenarios.(scenarioID).Parameters.DecompositionSignalIDs=signalIDs;
        end

        function setReconstructionSignalIDInScenario(this,scenarioID,signalID)
            this.Scenarios.(scenarioID).Parameters.ReconstructionSignalID=signalID;
        end

        function setTimeInfo(this,timeInfo)
            this.TimeInfo.TimeMode=timeInfo.TimeMode;
            this.TimeInfo.SampleRate=timeInfo.SampleRate;
            this.TimeInfo.SamplePeriod=timeInfo.SamplePeriod;
            this.TimeInfo.SamplePeriodUnit=timeInfo.SamplePeriodUnit;
        end

        function resetTimeInfo(this)
            timeInfo.TimeMode="samples";
            timeInfo.SampleRate=1;
            timeInfo.SamplePeriod=1;
            timeInfo.SamplePeriodUnit="seconds";

            this.setTimeInfo(timeInfo);
        end

        function addDecompositionSignalIDsInScenario(this,scenarioID,signalIDsToBeAdded)
            oldSignalIDs=this.getDecompositionSignalIDsForScenario(scenarioID);
            newSignalDs=[oldSignalIDs(1:end-1),signalIDsToBeAdded,oldSignalIDs(end)];
            this.setDecompositionSignalIDsInScenario(scenarioID,newSignalDs);
            this.addToIsIncludedStatusInScenario(scenarioID,numel(signalIDsToBeAdded));
            this.addToIsShownStatusInScenario(scenarioID,numel(signalIDsToBeAdded));
        end

        function removeDecompositionSignalIDsFromScenario(this,scenarioID,signalIDsToBeRemoved)
            newSignalIDs=setdiff(this.getScenarioParams(scenarioID).DecompositionSignalIDs,signalIDsToBeRemoved,'stable');
            this.setDecompositionSignalIDsInScenario(scenarioID,newSignalIDs);
            this.removeFromIsIncludedStatusInScenario(scenarioID,numel(signalIDsToBeRemoved));
            this.removeFromIsShownStatusInScenario(scenarioID,numel(signalIDsToBeRemoved));
        end

        function setSignalIDForImportedSignal(this,signalID)
            this.ImportedSignalInfo.SignalID=signalID;
        end

        function deleteScenario(this,scenarioID)
            this.Scenarios=rmfield(this.Scenarios,scenarioID);
        end

        function setIsIncludedStatusInScenario(this,scenarioID,status)
            this.Scenarios.(scenarioID).Parameters.IsIncluded=status;
        end

        function addToIsIncludedStatusInScenario(this,scenarioID,numberOfSignalsToBeAdded)
            oldIsIncluded=this.Scenarios.(scenarioID).Parameters.IsIncluded;


            if oldIsIncluded(end)
                isIncludedStatusToBeAdded=ones(numberOfSignalsToBeAdded,1);
            else
                isIncludedStatusToBeAdded=zeros(numberOfSignalsToBeAdded,1);
            end
            newIsIncluded=[oldIsIncluded(1:end-1);isIncludedStatusToBeAdded;oldIsIncluded(end)];
            this.setIsIncludedStatusInScenario(scenarioID,newIsIncluded);
        end

        function removeFromIsIncludedStatusInScenario(this,scenarioID,numberOfSignalsToBeRemoved)
            oldIsIncluded=this.Scenarios.(scenarioID).Parameters.IsIncluded;
            newIsIncluded=[oldIsIncluded(1:end-numberOfSignalsToBeRemoved-1);oldIsIncluded(end)];
            this.setIsIncludedStatusInScenario(scenarioID,newIsIncluded);
        end

        function updateIsIncludedInScenarios(this,scenarioID,decompositionSignalID)
            decompostionSignalIDs=this.getDecompositionSignalIDsForScenario(scenarioID);
            idx=decompostionSignalIDs==decompositionSignalID;
            isIncluded=this.getScenarioParams(scenarioID).IsIncluded;
            isIncluded(idx)=isIncluded(idx)~=1;
            this.setIsIncludedStatusInScenario(scenarioID,isIncluded);
        end

        function setIsShownStatusInScenario(this,scenarioID,status)
            this.Scenarios.(scenarioID).Parameters.IsShown=status;
        end

        function addToIsShownStatusInScenario(this,scenarioID,numberOfSignalsToBeAdded)
            oldIsShown=this.Scenarios.(scenarioID).Parameters.IsShown;


            newIsShown=[oldIsShown(1:end-1);ones(numberOfSignalsToBeAdded,1);oldIsShown(end)];
            this.setIsShownStatusInScenario(scenarioID,newIsShown);
        end

        function removeFromIsShownStatusInScenario(this,scenarioID,numberOfSignalsToBeRemoved)
            oldIsShown=this.Scenarios.(scenarioID).Parameters.IsShown;
            newIsShown=[oldIsShown(1:end-numberOfSignalsToBeRemoved-1);oldIsShown(end)];
            this.setIsShownStatusInScenario(scenarioID,newIsShown);
        end

        function shownSignalIDs=updateIsShownInScenarios(this,scenarioID,decompositionSignalID)
            decompostionSignalIDs=this.getDecompositionSignalIDsForScenario(scenarioID);
            idx=decompostionSignalIDs==decompositionSignalID;


            signalIDs=decompostionSignalIDs(find(idx)+1:end);
            isShown=this.getScenarioParams(scenarioID).IsShown;
            shownSignalIDs=decompostionSignalIDs(logical(isShown));
            shownSignalIDs=shownSignalIDs(ismember(shownSignalIDs,signalIDs));


            isShown(idx)=isShown(idx)~=1;


            this.setIsShownStatusInScenario(scenarioID,isShown);
        end

        function renameScenario(this,scenarioID,newScenarioName)
            this.Scenarios.(scenarioID).Parameters.ScenarioName=newScenarioName;
        end



        function importedSignalInfo=getImportedSignalInfo(this)
            importedSignalInfo=this.ImportedSignalInfo;
        end

        function signalData=getImportedSignalData(this)
            signalData=this.getImportedSignalInfo().Data;
        end

        function signalName=getImportedSignalName(this)
            signalName=this.getImportedSignalInfo().Name;
        end

        function scenarioData=getDecompositionDataForScenario(this,scenarioID)
            scenarioData=this.Scenarios.(scenarioID).DecompositionData;
        end

        function scenarioParams=getScenarioParams(this,scenarioID)
            scenarioParams=this.Scenarios.(scenarioID).Parameters;
        end

        function scenariosParams=getDefaultMODWTMRAScenarioParams(this)
            scenariosParams.WaveletName="sym";
            scenariosParams.WaveletNumber=4;
            scenariosParams.Levels=min(4,this.getMODWTMRAMaxLevels);
            scenariosParams.Type="modwtmra";
        end

        function maxLevels=getMODWTMRAMaxLevels(this)
            maxLevels=min(20,floor(log2(numel(this.getImportedSignalData()))));
        end

        function scenariosParams=getDefaultEMDScenarioParams(~)
            scenariosParams.Interpolation="spline";
            scenariosParams.SiftRelativeTolerance=0.2;
            scenariosParams.SiftMaxIterations=100;
            scenariosParams.MaxNumIMF=5;
            scenariosParams.MaxNumExtrema=1;
            scenariosParams.MaxEnergyRatio=20;
            scenariosParams.Type="emd";
        end

        function scenariosParams=getDefaultTQWTMRAScenarioParams(this)
            scenariosParams.QualityFactor=1;
            scenariosParams.TQWTLevels=4;
            scenariosParams.SigLength=numel(this.getImportedSignalData());
            scenariosParams.Type="tqwtmra";
        end

        function[minLvl,maxLvl]=getTQWTMRALevels(this,qualityFactor)
            numSamples=numel(this.getImportedSignalData());
            minLvl=floor(log2(numSamples));
            numer=log2(numSamples/(4*qualityFactor+4));
            denom=log2((3*qualityFactor+3)/(3*qualityFactor+1));
            maxLvl=floor(numer/denom);
        end

        function scenariosParams=getDefaultEWTMRAScenarioParams(this)
            scenariosParams.PeakThresholdPercent=70;
            scenariosParams.GeometricMean=true;
            scenariosParams.LocalMinimum=false;
            scenariosParams.MaxNumPeaksFlag=false;
            scenariosParams.PeakThresholdPercentFlag=true;
            scenariosParams.SigLength=length(this.getImportedSignalData());
            scenariosParams.LogSpectrum=false;
            scenariosParams.FrequencyResolution=5.5/(max(64,scenariosParams.SigLength));
            [scenariosParams.xrLength,scenariosParams.Npad,scenariosParams.MaxNumPeaks]=...
            this.getMaxNumPeaks(scenariosParams.FrequencyResolution);
            scenariosParams.Type="ewtmra";
        end

        function[xrLength,Npad,maxNumPeaks]=getMaxNumPeaks(this,freqResolution)
            x=this.getImportedSignalData();
            Norig=length(x(:));
            if Norig<64
                Npad=64;
            else
                Npad=Norig;
            end
            numtapers=round((Npad+1)*freqResolution-0.5);
            xr=[x;zeros(Npad-Norig,1)];
            xrLength=length(xr);
            bw=(numtapers+1/2)/(xrLength+1);
            bw=ceil(xrLength*bw);
            maxNumPeaks=round(length(xr)/bw);
        end

        function segmentMethod=getSegmentMethod(~,flag)
            if flag
                segmentMethod="geomean";
            else
                segmentMethod="localmin";
            end
        end

        function scenariosParams=getDefaultVMDScenarioParams(this)
            scenariosParams.AbsoluteTolerance=5e-6;
            scenariosParams.RelativeTolerance=(5e-6)*1e3;
            scenariosParams.MaxIterations=500;
            scenariosParams.NumIMF=5;
            scenariosParams.PenaltyFactor=1000;
            scenariosParams.LMUpdateRate=0.01;
            scenariosParams.Type="vmd";
            scenariosParams.SigLength=length(this.getImportedSignalData());
            scenariosParams.VMDNumHalfFreqSamples=this.getVMDIntialLM(scenariosParams.SigLength);
            scenariosParams.InitialLM=complex(zeros(scenariosParams.VMDNumHalfFreqSamples,1));
            scenariosParams.InitialIMFs=zeros(scenariosParams.SigLength,5);
            scenariosParams.VMDInitialIMFsValidFlag=true;
            scenariosParams.VMDInitialLMValidFlag=true;
            scenariosParams.InitialIMFsSelectedString="0";
            scenariosParams.InitialLMSelectedString="0";
            scenariosParams.InitializeMethod="Peaks";
            scenariosParams.VMDUserSpecificCentralFrequenciesSelectedString="0.5";
            scenariosParams.VMDUserSpecificCentralFrequencies=0.5*ones(scenariosParams.NumIMF,1);
            scenariosParams.VMDUserSpecificCentralFrequenciesValidFlag=true;
            scenariosParams.VMDInitialIMFsDisableFlag=true;
            scenariosParams.VMDUserSpecificCentralFrequenciesDisableFlag=false;
        end

        function numHalfFreqSamples=getVMDIntialLM(~,signalLength)
            halfSignalLength=fix(signalLength/2);
            mirroredSignalLength=signalLength*2+(halfSignalLength...
            -ceil(signalLength/2));
            FFTLength=mirroredSignalLength;
            if~mod(FFTLength,2)
                numHalfFreqSamples=FFTLength/2+1;
            else
                numHalfFreqSamples=(FFTLength+1)/2;
            end
        end

        function[validInput,isValidInput]=getValidVMDInput(this,parameterName,parameterValue,reqLength)
            isValidInput=false;
            try
                validInput=evalin('base',['[',parameterValue,']']);
                validInput=this.modifyVMDInput(parameterName,validInput,reqLength);
                isValidInput=this.checkVMDValidType(parameterName,validInput,reqLength);
            catch
                validInput=[];
            end
        end

        function isVMDValidType=checkVMDValidType(~,parameterName,value,reqLength)
            isVMDValidType=false;
            if parameterName=="InitialLM"
                isVMDValidType=(isa(value,'double')||isa(value,'single'))...
                &&any(isfinite(value),'all')&&isvector(value)...
                &&length(value)==reqLength;
            elseif parameterName=="InitialIMFs"
                isVMDValidType=(isa(value,'double')||isa(value,'single'))...
                &&isreal(value)...
                &&any(isfinite(value),'all')...
                &&isequal(size(value),reqLength);
            elseif parameterName=="CentralFrequencies"
                isVMDValidType=(isa(value,'double')||isa(value,'single'))...
                &&any(isfinite(value),'all')&&isvector(value)...
                &&length(value)==reqLength...
                &&all(value<=0.5)&&all(value>=0);
            end
        end

        function validInput=modifyVMDInput(~,parameterName,validInput,reqLength)
            if isscalar(reqLength)
                reqLength=[reqLength,1];
            end

            if isscalar(validInput)
                validInput=repmat(validInput,reqLength);
            elseif isvector(validInput)&&parameterName=="InitialIMFs"
                validInput=repmat(validInput(:),[1,reqLength(2)]);
            end

            if parameterName=="InitialLM"&&isreal(validInput)
                validInput=complex(validInput);
            end

        end

        function signalIDs=getDecompositionSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getScenarioParams(scenarioID).DecompositionSignalIDs;
        end

        function signalIDs=getShownDecompositionSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getScenarioParams(scenarioID).DecompositionSignalIDs;
            isShown=this.getScenarioParams(scenarioID).IsShown;
            signalIDs=signalIDs(logical(isShown));
        end

        function signalID=getReconstructionSignalIDInScenario(this,scenarioID)
            signalID=this.getScenarioParams(scenarioID).ReconstructionSignalID;
        end

        function signalID=getSignalIDForImportedSignal(this)
            signalID=this.ImportedSignalInfo.SignalID;
        end

        function signalIDs=getAllDecompositionSignalIDs(this)
            signalIDs=[];
            allScenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(allScenarioIDs)
                signalIDs=[signalIDs,this.getDecompositionSignalIDsForScenario(allScenarioIDs(idx))];%#ok<*AGROW>
            end
        end

        function scenarioNames=getAllScenariosNames(this)
            scenarioNames=[];
            allScenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(allScenarioIDs)
                scenarioNames=[scenarioNames;this.Scenarios.(allScenarioIDs(idx)).Parameters.ScenarioName];%#ok<*AGROW>
            end
        end

        function signalIDs=getAllReconstructionSignalIDs(this)
            signalIDs=[];
            scenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(scenarioIDs)
                signalIDs=[signalIDs,this.getReconstructionSignalIDInScenario(scenarioIDs(idx))];
            end
        end

        function timeInfo=getTimeInfo(this)
            timeInfo=this.TimeInfo;
        end

        function scenariosNames=getAllScenarioIDs(this)
            scenariosNames=string(fieldnames(this.Scenarios));
        end
    end
end
