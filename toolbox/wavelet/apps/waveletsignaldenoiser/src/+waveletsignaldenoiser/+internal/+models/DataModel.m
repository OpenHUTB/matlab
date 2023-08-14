

classdef DataModel<handle





    properties(Access=private)
ImportedAndApproxSignalInfo
Scenarios
ScenarioCount
    end

    methods

        function this=DataModel(inputSignal)
            this.resetModel();
            if~isempty(inputSignal)
                this.setImportedSignalData(inputSignal{1});
                this.setImportedSignalName(inputSignal{2});
            end
        end


        function scenarioID=addScenario(this)
            scenarioID=this.createScenarioID();
            this.createScenarioName(scenarioID);
            this.resetScenario(scenarioID);
            this.computeScenario(scenarioID);
        end

        function computeScenario(this,scenarioID)
            scenarioParams=this.getScenarioParams(scenarioID);
            wname=string(scenarioParams.WaveletName)+scenarioParams.WaveletNumber;
            signalData=this.getImportedSignalData();
            denoisingMethod=scenarioParams.DenoisingMethod;
            if denoisingMethod=="FDR"
                denoisingMethod={denoisingMethod,scenarioParams.QValue};
            elseif denoisingMethod=="Universal Threshold"
                denoisingMethod="UniversalThreshold";
            end
            [denoisedSignal,denoisedCoeffs,originalCoeffs]=...
            wdenoise(signalData,...
            scenarioParams.Levels,...
            'Wavelet',wname,...
            'DenoisingMethod',denoisingMethod,...
            'ThresholdRule',scenarioParams.ThresholdRule,...
            'NoiseEstimate',scenarioParams.NoiseEstimate);

            this.Scenarios.(scenarioID).DenoisedData.DenoisedSignal=denoisedSignal(:);
            this.Scenarios.(scenarioID).Coefficients.DenoisedCoefficients=denoisedCoeffs;
            this.Scenarios.(scenarioID).Coefficients.OriginalCoefficients=originalCoeffs;

            numberDenoisedCoeffs=cellfun(@numel,denoisedCoeffs);


            numberDenoisedCoeffs=[fliplr(numberDenoisedCoeffs),numel(signalData)];
            coeffs=flip(originalCoeffs);
            coeffs=cat(1,coeffs{:});
            approximation=wrcoef('a',coeffs,numberDenoisedCoeffs,wname);
            this.Scenarios.(scenarioID).DenoisedData.Approximation=approximation(:);
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


        function resetModel(this)
            this.ImportedAndApproxSignalInfo=struct;
            this.Scenarios=struct;
            this.ScenarioCount=0;
        end

        function newScenarioID=duplicateScenario(this,scenarioID)
            newScenarioID=this.createScenarioID();
            this.Scenarios.(newScenarioID)=this.Scenarios.(scenarioID);


            newScenarioName=this.Scenarios.(scenarioID).Parameters.ScenarioName+"Copy";
            allScenarioNames=this.getAllScenariosNames();
            newScenarioName=matlab.lang.makeUniqueStrings(newScenarioName,allScenarioNames);


            this.Scenarios.(newScenarioID).Parameters.ScenarioName=newScenarioName;



            this.Scenarios.(newScenarioID).Parameters=rmfield(this.Scenarios.(newScenarioID).Parameters,"OriginalCoefficientsSignalIDs");
            this.Scenarios.(newScenarioID).Parameters=rmfield(this.Scenarios.(newScenarioID).Parameters,"DenoisedCoefficientsSignalIDs");
        end

        function resetScenario(this,scenarioID)
            scenarioParams=this.getDefaultScenarioParams();
            this.setScenarioParams(scenarioID,scenarioParams);
        end

        function setScenarioParams(this,scenarioID,scenarioParams)
            this.Scenarios.(scenarioID).Parameters.WaveletName=string(scenarioParams.WaveletName);
            this.Scenarios.(scenarioID).Parameters.WaveletNumber=scenarioParams.WaveletNumber;
            this.Scenarios.(scenarioID).Parameters.Levels=scenarioParams.Levels;
            this.Scenarios.(scenarioID).Parameters.DenoisingMethod=string(scenarioParams.DenoisingMethod);
            this.Scenarios.(scenarioID).Parameters.ThresholdRule=string(scenarioParams.ThresholdRule);
            this.Scenarios.(scenarioID).Parameters.NoiseEstimate=string(scenarioParams.NoiseEstimate);
            if scenarioParams.DenoisingMethod=="FDR"
                this.Scenarios.(scenarioID).Parameters.QValue=scenarioParams.QValue;
            end
        end

        function setImportedSignalName(this,signalName)
            if isempty(signalName)
                this.ImportedAndApproxSignalInfo.SignalName="Signal";
            else
                this.ImportedAndApproxSignalInfo.SignalName=string(signalName);
            end
        end

        function setImportedSignalData(this,signalData)
            this.ImportedAndApproxSignalInfo.SignalData=signalData(:);
        end

        function setCoefficientsSignalIDsInScenario(this,scenarioID,signalIDs)
            halfIndex=numel(signalIDs)/2;
            this.Scenarios.(scenarioID).Parameters.OriginalCoefficientsSignalIDs=signalIDs(1:halfIndex);
            this.Scenarios.(scenarioID).Parameters.DenoisedCoefficientsSignalIDs=signalIDs(halfIndex+1:end);
        end

        function setDenoisedSignalIDInScenario(this,scenarioID,signalID)
            this.Scenarios.(scenarioID).Parameters.DenoisedSignalID=signalID;
        end

        function addCoefficientsSignalIDsInScenario(this,scenarioID,signalIDsToBeAdded)

            oldSignalIDs=this.getOriginalCoefficientSignalIDsForScenario(scenarioID);
            halfIndex=numel(signalIDsToBeAdded)/2;
            newSignalDs=[oldSignalIDs(1:end-1),signalIDsToBeAdded(1:halfIndex),oldSignalIDs(end)];
            this.Scenarios.(scenarioID).Parameters.OriginalCoefficientsSignalIDs=newSignalDs;


            oldSignalIDs=this.getDenoisedCoefficientSignalIDsForScenario(scenarioID);
            newSignalDs=[oldSignalIDs(1:end-1),signalIDsToBeAdded(halfIndex+1:end),oldSignalIDs(end)];
            this.Scenarios.(scenarioID).Parameters.DenoisedCoefficientsSignalIDs=newSignalDs;
        end

        function removeCoefficientsSignalIDsFromScenario(this,scenarioID,originalSignalIDs,denoisedSignalIDs)

            newSignalIDs=setdiff(this.getScenarioParams(scenarioID).OriginalCoefficientsSignalIDs,originalSignalIDs,'stable');
            this.Scenarios.(scenarioID).Parameters.OriginalCoefficientsSignalIDs=newSignalIDs;

            newSignalIDs=setdiff(this.getScenarioParams(scenarioID).DenoisedCoefficientsSignalIDs,denoisedSignalIDs,'stable');
            this.Scenarios.(scenarioID).Parameters.DenoisedCoefficientsSignalIDs=newSignalIDs;
        end

        function setSignalIDForImportedSignal(this,signalID)
            this.ImportedAndApproxSignalInfo.ImportedSignalID=signalID;
        end

        function setSignalIDForApproxSignal(this,signalID)
            this.ImportedAndApproxSignalInfo.ApproxSignalID=signalID;
        end

        function deleteScenario(this,scenarioID)
            this.Scenarios=rmfield(this.Scenarios,scenarioID);
        end

        function renameScenario(this,scenarioID,newScenarioName)
            this.Scenarios.(scenarioID).Parameters.ScenarioName=newScenarioName;
        end



        function ImportedAndApproxSignalInfo=getImportedAndApproxSignalInfo(this)
            ImportedAndApproxSignalInfo=this.ImportedAndApproxSignalInfo;
        end

        function signalData=getImportedSignalData(this)
            signalData=this.getImportedAndApproxSignalInfo().SignalData;
        end

        function signalName=getImportedSignalName(this)
            signalName=this.getImportedAndApproxSignalInfo().SignalName;
        end

        function denoisedData=getDenoisedDataForScenario(this,scenarioID)
            denoisedData=this.Scenarios.(scenarioID).DenoisedData;
        end

        function coefficientData=getCoefficientsDataForScenario(this,scenarioID)
            coefficients=this.Scenarios.(scenarioID).Coefficients;
            scenarioParams=this.getScenarioParams(scenarioID);
            wname=string(scenarioParams.WaveletName)+scenarioParams.WaveletNumber;
            data.SignalDataInternal=this.getImportedSignalData();
            data.Level=scenarioParams.Levels;
            data.DenoisedCoefficients=coefficients.DenoisedCoefficients;
            [coeffsOriginal,coeffsDenoise]=wavelet.internal.upsampleDWTCoefs(data,wname);
            coefficientData.OriginalCoefficients=coeffsOriginal;
            coefficientData.DenoisedCoefficients=coeffsDenoise;
        end

        function scenarioParams=getScenarioParams(this,scenarioID)
            scenarioParams=this.Scenarios.(scenarioID).Parameters;
        end

        function scenarioParams=getDefaultScenarioParams(this)
            scenarioParams.WaveletName="sym";
            scenarioParams.WaveletNumber=4;
            scenarioParams.DenoisingMethod="Bayes";
            scenarioParams.ThresholdRule="Median";
            scenarioParams.NoiseEstimate="LevelIndependent";
            wname=string(scenarioParams.WaveletName)+scenarioParams.WaveletNumber;
            maxLevel=this.getMaxLevels(scenarioParams.DenoisingMethod,wname);
            levels=min(wmaxlev(numel(this.getImportedSignalData()),wname),maxLevel);
            if levels==0
                levels=maxLevel;
            end
            scenarioParams.Levels=levels;
        end

        function maxLevels=getMaxLevels(this,denoisingMethod,wname)
            if denoisingMethod=="BlockJS"
                maxLevels=this.getMaxBlockJSLevelByWavelet(wname);
            else
                maxLevels=floor(log2(numel(this.getImportedSignalData())));
            end
        end

        function maxLevels=getMaxBlockJSLevelByWavelet(this,wname)
            sigLength=numel(this.getImportedSignalData());
            numCoeffsByLevel=wavelet.internal.numcfsbylev(sigLength,wname);
            maxLevels=find(numCoeffsByLevel>=floor(log(sigLength)),1,'last');
        end

        function signalIDs=getOriginalCoefficientSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getScenarioParams(scenarioID).OriginalCoefficientsSignalIDs;
        end

        function signalIDs=getDenoisedCoefficientSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getScenarioParams(scenarioID).DenoisedCoefficientsSignalIDs;
        end

        function signalID=getDenoisedSignalIDInScenario(this,scenarioID)
            signalID=this.getScenarioParams(scenarioID).DenoisedSignalID;
        end

        function signalID=getSignalIDForImportedSignal(this)
            signalID=this.ImportedAndApproxSignalInfo.ImportedSignalID;
        end

        function signalID=getSignalIDForApproxSignal(this)
            signalID=this.ImportedAndApproxSignalInfo.ApproxSignalID;
        end

        function originalCoefficientIDs=getAllOriginalCoefficientSignalIDs(this)
            originalCoefficientIDs=[];
            allScenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(allScenarioIDs)
                originalCoefficientIDs=[originalCoefficientIDs,this.getOriginalCoefficientSignalIDsForScenario(allScenarioIDs(idx))];
            end
        end

        function denoisedCoefficientIDs=getAllDenoisedCoefficientSignalIDs(this)
            denoisedCoefficientIDs=[];
            allScenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(allScenarioIDs)
                denoisedCoefficientIDs=[denoisedCoefficientIDs,this.getDenoisedCoefficientSignalIDsForScenario(allScenarioIDs(idx))];
            end
        end

        function scenarioNames=getAllScenariosNames(this)
            scenarioNames=[];
            allScenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(allScenarioIDs)
                scenarioNames=[scenarioNames;this.Scenarios.(allScenarioIDs(idx)).Parameters.ScenarioName];%#ok<*AGROW>
            end
        end

        function signalIDs=getAllDenoisedSignalIDs(this)
            signalIDs=[];
            scenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(scenarioIDs)
                signalIDs=[signalIDs,this.getDenoisedSignalIDInScenario(scenarioIDs(idx))];
            end
        end

        function scenariosNames=getAllScenarioIDs(this)
            scenariosNames=string(fieldnames(this.Scenarios));
        end

        function denoisedDataData=getDenoisedSignalDataForAllScenario(this)
            denoisedDataData=[];
            scenarioIDs=this.getAllScenarioIDs();
            for idx=1:numel(scenarioIDs)
                denoisedDataData=[denoisedDataData,this.getDenoisedDataForScenario(scenarioIDs(idx)).DenoisedSignal];
            end
        end
    end
end