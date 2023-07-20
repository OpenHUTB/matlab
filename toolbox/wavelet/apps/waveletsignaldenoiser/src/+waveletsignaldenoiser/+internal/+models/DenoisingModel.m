

classdef DenoisingModel<handle





    properties(Access=private)
DataModel
SignalMgr
    end

    methods

        function this=DenoisingModel(dataModel,signalMgr)
            this.DataModel=dataModel;
            this.SignalMgr=signalMgr;
        end


        function tableData=getDataForDenoisedSignalsTable(this,scenarioID)






            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            tableData=[scenarioID,scenarioParams.ScenarioName];%#ok<*AGROW> % ID and Scenario Name
        end

        function tableData=getDataForCurrentWaveletParametersTable(this,scenarioID)







            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            catalogFileName="waveletsignaldenoiser";
            stringValue=this.getStringValueFromCatalog(catalogFileName,"currentParametersTableDenoisedSignal");
            tableData=[stringValue,scenarioParams.ScenarioName];
            stringValue=this.getStringValueFromCatalog(catalogFileName,"currentParametersTableWavelet");
            tableData=[tableData;[stringValue,string(scenarioParams.WaveletName)+scenarioParams.WaveletNumber]];
            stringValue=this.getStringValueFromCatalog(catalogFileName,"currentParametersTableDenoisingMethod");
            tableData=[tableData;[stringValue,scenarioParams.DenoisingMethod]];
            stringValue=this.getStringValueFromCatalog(catalogFileName,"currentParametersTableLevels");
            tableData=[tableData;[stringValue,scenarioParams.Levels]];
            stringValue=this.getStringValueFromCatalog(catalogFileName,"currentParametersTableThresholdRule");
            tableData=[tableData;[stringValue,scenarioParams.ThresholdRule]];
            if scenarioParams.DenoisingMethod=="FDR"
                stringValue=this.getStringValueFromCatalog(catalogFileName,"currentParametersTableQValue");
                tableData=[tableData;[stringValue,scenarioParams.QValue]];
            end
            stringValue=this.getStringValueFromCatalog(catalogFileName,"currentParametersTableNoiseEstimate");
            tableData=[tableData;[stringValue,insertAfter(scenarioParams.NoiseEstimate,5," ")]];
        end

        function stringValue=getStringValueFromCatalog(~,catalogFileName,catalogKey)

            stringValue=string(getString(message("wavelet_signaldenoiser:"+catalogFileName+":"+catalogKey)));
        end

        function toolstripData=getDataForToolstrip(this,scenarioID)
            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);

            denoisingMethod=scenarioParams.DenoisingMethod;
            waveletName=string(scenarioParams.WaveletName);
            toolstripData.WaveletNames=waveletsignaldenoiser.internal.Utilities.getWaveletNames();
            toolstripData.WaveletNumbers=this.getWaveletNumber(waveletName);
            wname=waveletName+scenarioParams.WaveletNumber;
            toolstripData.MaxLevels=this.getMaxLevels(denoisingMethod,wname);
            isBlockJSNotRequired=floor(log(numel(this.getDataModel().getImportedSignalData())))==0;
            toolstripData.DenoisingMethods=waveletsignaldenoiser.internal.Utilities.getDenoisingMethods(isBlockJSNotRequired);
            toolstripData.ThresholdRules=this.getThresholdRules(denoisingMethod);

            toolstripData.WaveletNumber=scenarioParams.WaveletNumber;
            toolstripData.Levels=scenarioParams.Levels;
            toolstripData.WaveletName=scenarioParams.WaveletName;
            toolstripData.DenoisingMethod=scenarioParams.DenoisingMethod;
            toolstripData.ThresholdRule=scenarioParams.ThresholdRule;
            toolstripData.NoiseEstimate=scenarioParams.NoiseEstimate;
            if isfield(scenarioParams,'QValue')
                toolstripData.QValue=scenarioParams.QValue;
            end
        end

        function maxLevels=getMaxLevels(this,denoisingMethod,wname)
            maxLevels=this.getDataModel().getMaxLevels(denoisingMethod,wname);
        end

        function thresholdRules=getThresholdRules(~,denoisingMethod)
            thresholdRules=waveletsignaldenoiser.internal.Utilities.getThresholdRules(denoisingMethod);
        end

        function[originalCoefficientSignalIDs,denoisedSignalID,coefficientsSignalIDs]=createSignalIDs(this,scenarioID)
            scenariosParams=this.getDataModel().getScenarioParams(scenarioID);

            numberOfSignalIDsToBeCreated=2*(scenariosParams.Levels+1)+1;
            signalIDs=string(this.getSignalMgr().createSignalIDs(numberOfSignalIDsToBeCreated));
            denoisedSignalID=signalIDs(1);
            coefficientsSignalIDs=signalIDs(2:end);
            this.getDataModel().setDenoisedSignalIDInScenario(scenarioID,denoisedSignalID);
            this.getDataModel().setCoefficientsSignalIDsInScenario(scenarioID,coefficientsSignalIDs);
            originalCoefficientSignalIDs=this.getOriginalCoefficientSignalIDsForScenario(scenarioID);
        end

        function[importedSignalID,approxSignalID]=createSignalIDForImportedAndApproxSignals(this)
            signalIDs=string(this.getSignalMgr().createSignalIDs(2));
            importedSignalID=signalIDs(1);
            approxSignalID=signalIDs(2);
            this.getDataModel().setSignalIDForImportedSignal(importedSignalID);
            this.getDataModel().setSignalIDForApproxSignal(approxSignalID);
        end

        function signalIDsToBeAdded=addCoefficientsSignalIDs(this,scenarioID,numberOfSignals)
            signalIDs=this.getSignalMgr().createSignalIDs(2*numberOfSignals);
            this.getDataModel().addCoefficientsSignalIDsInScenario(scenarioID,signalIDs);
            signalIDsToBeAdded=signalIDs(1:numel(signalIDs)/2);
        end

        function originalCoefficientSignalIDsRemoved=removeCoefficientsSignalIDs(this,scenarioID,numberOfSignalsToBeRemoved)
            originalCoefficientSignalIDs=this.getOriginalCoefficientSignalIDsForScenario(scenarioID);
            originalCoefficientSignalIDsRemoved=originalCoefficientSignalIDs(end-numberOfSignalsToBeRemoved:end-1);
            denoisedCoefficientSignalIDs=this.getDenoisedCoefficientSignalIDsForScenario(scenarioID);
            denoisedCoefficientSignalIDsRemoved=denoisedCoefficientSignalIDs(end-numberOfSignalsToBeRemoved:end-1);
            this.removeSignalIDs([originalCoefficientSignalIDsRemoved,denoisedCoefficientSignalIDsRemoved]);
            this.getDataModel().removeCoefficientsSignalIDsFromScenario(scenarioID,originalCoefficientSignalIDsRemoved,denoisedCoefficientSignalIDsRemoved);
        end

        function removeSignalIDs(this,signalIDs)
            this.getSignalMgr().removeSignalIDs(signalIDs);
        end

        function signalData=getSignalData(this,scenarioID,originalCoefficientsVisibility,denoisedCoefficientsVisibility)

            checkForVisibility=true;
            if nargin<3
                checkForVisibility=false;
            end

            scenarioData=this.getDataModel().getDenoisedDataForScenario(scenarioID);
            denoisedSignalData=this.getDataModel().getDenoisedSignalDataForAllScenario();
            importedData=this.getDataModel().getImportedSignalData();
            coefficientsData=this.getDataModel().getCoefficientsDataForScenario(scenarioID);
            dataToBePlotted=[importedData,scenarioData.Approximation,denoisedSignalData,...
            coefficientsData.OriginalCoefficients,coefficientsData.DenoisedCoefficients];
            originalCoefficientSignalIDs=this.getOriginalCoefficientSignalIDsForScenario(scenarioID);
            denoisedCoefficientSignalIDs=this.getDenoisedCoefficientSignalIDsForScenario(scenarioID);
            signalIDForImportedSignal=this.getSignalIDForImportedSignal();
            signalIDForApproxSignal=this.getSignalIDForApproxSignal();
            allDenoisedSignalIDs=this.getDataModel().getAllDenoisedSignalIDs();
            denoisedSignalID=this.getDenoisedSignalIDInScenario(scenarioID);


            index=1;
            plottingMap.AxesIDs(index)=signalIDForImportedSignal;
            plottingMap.SignalIDs(index)=signalIDForImportedSignal;
            plottingMap.LegendLabels(index)=this.getDataModel().getImportedSignalName();
            plottingMap.LineWidth(index)=1;
            plottingMap.PlotType(index)="Line";
            plottingMap.LineStyle(index)="Solid";
            if checkForVisibility
                plottingMap.IsVisible(index)=true;
            end


            index=index+1;
            plottingMap.AxesIDs(index)=signalIDForImportedSignal;
            plottingMap.SignalIDs(index)=signalIDForApproxSignal;
            plottingMap.LegendLabels(index)="Approximation";
            plottingMap.LineWidth(index)=1;
            plottingMap.PlotType(index)="Line";
            plottingMap.LineStyle(index)="Dash";
            if checkForVisibility
                plottingMap.IsVisible(index)=true;
            end

            scenariosNames=this.getDataModel().getAllScenariosNames();
            numberOfDesnoisedSignalIDs=numel(allDenoisedSignalIDs);
            for idx=1:numberOfDesnoisedSignalIDs

                index=index+1;
                plottingMap.AxesIDs(index)=signalIDForImportedSignal;
                plottingMap.SignalIDs(index)=allDenoisedSignalIDs(idx);
                plottingMap.LegendLabels(index)=scenariosNames(idx);
                plottingMap.LineWidth(index)=(allDenoisedSignalIDs(idx)==denoisedSignalID)+1;
                plottingMap.PlotType(index)="Line";
                plottingMap.LineStyle(index)="Solid";
                if checkForVisibility
                    plottingMap.IsVisible(index)=true;
                end
            end

            numberOfOriginalCoefficientSignalIDs=numel(originalCoefficientSignalIDs);
            for idx=1:numberOfOriginalCoefficientSignalIDs

                index=index+1;
                plottingMap.AxesIDs(index)=originalCoefficientSignalIDs(idx);
                plottingMap.SignalIDs(index)=originalCoefficientSignalIDs(idx);
                plottingMap.LineWidth(index)=2;
                plottingMap.LegendLabels(index)=string(getString(message("wavelet_signaldenoiser:waveletsignaldenoiser:coefficientsOriginalLegend")));
                plottingMap.PlotType(index)="Stem";
                plottingMap.LineStyle(index)="Solid";
                if checkForVisibility
                    plottingMap.IsVisible(index)=originalCoefficientsVisibility;
                end
            end

            numberOfDenoisedCoefficientSignalIDs=numel(denoisedCoefficientSignalIDs);
            for idx=1:numberOfDenoisedCoefficientSignalIDs

                index=index+1;
                plottingMap.AxesIDs(index)=originalCoefficientSignalIDs(idx);
                plottingMap.SignalIDs(index)=denoisedCoefficientSignalIDs(idx);
                plottingMap.LineWidth(index)=2;
                plottingMap.LegendLabels(index)=string(getString(message("wavelet_signaldenoiser:waveletsignaldenoiser:coefficientsDenoisedLegend")));
                plottingMap.PlotType(index)="Stem";
                plottingMap.LineStyle(index)="Solid";
                if checkForVisibility
                    plottingMap.IsVisible(index)=denoisedCoefficientsVisibility;
                end
            end

            dataSize=size(dataToBePlotted);
            dataToBePlotted=mat2cell(dataToBePlotted,dataSize(1),ones(1,dataSize(2)));


            signalData.SignalIDs=[signalIDForImportedSignal,signalIDForApproxSignal,allDenoisedSignalIDs,...
            originalCoefficientSignalIDs,denoisedCoefficientSignalIDs];
            signalData.SignalData=dataToBePlotted;
            signalData.PlottingMap=plottingMap;
        end



        function[signalIDsToBeAddedOrRemoved,numberOfNewLevels,approxSignalID,isDenoisingRequired]=denoise(this,scenarioID,newScenarioParams)
            oldScenarioParams=this.getDataModel().getScenarioParams(scenarioID);
            isDenoisingRequired=this.isDenoisingRequired(oldScenarioParams,newScenarioParams);
            signalIDsToBeAddedOrRemoved=[];
            numberOfNewLevels=0;
            approxSignalID=[];

            if isDenoisingRequired
                this.getDataModel().setScenarioParams(scenarioID,newScenarioParams);
                this.getDataModel().computeScenario(scenarioID);
                newScenarioParams=this.getDataModel().getScenarioParams(scenarioID);
                numberOfNewLevels=newScenarioParams.Levels-oldScenarioParams.Levels;
                approxSignalID=oldScenarioParams.OriginalCoefficientsSignalIDs(end);
                if numberOfNewLevels>0
                    signalIDsToBeAddedOrRemoved=this.addCoefficientsSignalIDs(scenarioID,numberOfNewLevels);
                elseif numberOfNewLevels<0
                    signalIDsToBeAddedOrRemoved=this.removeCoefficientsSignalIDs(scenarioID,abs(numberOfNewLevels));
                end
            end
        end

        function scenarioID=addNewScenario(this)
            scenarioID=this.getDataModel().addScenario();
        end

        function newScenarioID=duplicateScenario(this,scenarioID)
            newScenarioID=this.getDataModel().duplicateScenario(scenarioID);
        end

        function flag=isDenoisingRequired(~,oldScenarioParams,newScenarioParams)
            flag=string(oldScenarioParams.WaveletName)==newScenarioParams.WaveletName&&...
            oldScenarioParams.WaveletNumber==newScenarioParams.WaveletNumber&&...
            string(oldScenarioParams.DenoisingMethod)==newScenarioParams.DenoisingMethod&&...
            oldScenarioParams.Levels==newScenarioParams.Levels&&...
            string(oldScenarioParams.ThresholdRule)==newScenarioParams.ThresholdRule&&...
            string(oldScenarioParams.NoiseEstimate)==newScenarioParams.NoiseEstimate;
            if oldScenarioParams.DenoisingMethod=="FDR"&&newScenarioParams.DenoisingMethod=="FDR"
                flag=flag&&oldScenarioParams.QValue==newScenarioParams.QValue;
            end
            flag=~flag;
        end

        function originalCoefficientSignalIDs=deleteScenario(this,scenarioID)
            originalCoefficientSignalIDs=this.getOriginalCoefficientSignalIDsForScenario(scenarioID);
            denoisedCoefficientSignalIDs=this.getDataModel().getDenoisedCoefficientSignalIDsForScenario(scenarioID);
            denoisedSignalID=this.getDenoisedSignalIDInScenario(scenarioID);
            this.removeSignalIDs([originalCoefficientSignalIDs,denoisedCoefficientSignalIDs,denoisedSignalID]);
            this.getDataModel().deleteScenario(scenarioID);
        end


        function[originalCoefficientSignalIDs,allSignalIDsToBeRemoved]=resetDataModel(this)
            originalCoefficientSignalIDs=this.getAllOriginalCoefficientSignalIDs();
            denoisedCoefficientSignalIDs=this.getAllDenoisedCoefficientSignalIDs();
            signalIDForImportedSignal=this.getSignalIDForImportedSignal();
            signalIDForApproxSignal=this.getSignalIDForApproxSignal();
            denoisedSignalIDsRemoved=this.getDataModel().getAllDenoisedSignalIDs();

            allSignalIDsToBeRemoved=[denoisedSignalIDsRemoved,signalIDForApproxSignal,signalIDForImportedSignal,...
            originalCoefficientSignalIDs,denoisedCoefficientSignalIDs];
            this.getDataModel().resetModel();
        end

        function setImportedSignalName(this,signalName)
            this.getDataModel().setImportedSignalName(signalName);
        end

        function setImportedSignalData(this,signalData)
            this.getDataModel().setImportedSignalData(signalData)
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

        function signalIDs=getOriginalCoefficientSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getDataModel().getOriginalCoefficientSignalIDsForScenario(scenarioID);
        end

        function signalIDs=getDenoisedCoefficientSignalIDsForScenario(this,scenarioID)
            signalIDs=this.getDataModel().getDenoisedCoefficientSignalIDsForScenario(scenarioID);
        end

        function flag=isAppHasSignal(this)
            flag=~isempty(fieldnames(this.getDataModel().getImportedAndApproxSignalInfo()));
        end

        function scenarioSignals=getDenoisedSignalDataForScenario(this,scenarioID)
            scenarioSignals=this.getDataModel().getDenoisedDataForScenario(scenarioID).DenoisedSignal;
        end

        function waveletNumbers=getWaveletNumber(~,waveletName)
            waveletNumbers=waveletsignaldenoiser.internal.Utilities.getFilterNumbers(waveletName);
        end

        function[outScriptText,timeStamp]=generateMATLABScriptText(this,scenarioID)

            scenarioParams=this.getDataModel().getScenarioParams(scenarioID);

            wname=string(scenarioParams.WaveletName)+string(scenarioParams.WaveletNumber);
            timeStamp=wavelet.internal.wtbxfileheader('','wavelet');
            denoisingMethod=scenarioParams.DenoisingMethod;

            if denoisingMethod=="Universal Threshold"
                denoisingMethod="UniversalThreshold";
            end

            if denoisingMethod=="FDR"
                denoisingMethod="{'"+denoisingMethod+"' "+scenarioParams.QValue+"}";
            else
                denoisingMethod="'"+denoisingMethod+"'";
            end

            outScriptText="% Denoise signal using the Discrete Wavelet Transform (DWT)"+newline+newline+...
            timeStamp+newline+newline+...
            scenarioParams.ScenarioName+" = wdenoise("+...
            this.getDataModel().getImportedSignalName()+","+...
            string(scenarioParams.Levels)+", ..."+newline+...
            "Wavelet='"+wname+"', ..."+newline+...
            "DenoisingMethod="+denoisingMethod+", ..."+newline+...
            "ThresholdRule='"+scenarioParams.ThresholdRule+"', ..."+newline+...
            "NoiseEstimate='"+scenarioParams.NoiseEstimate+"');"+newline;
        end

        function signalID=getDenoisedSignalIDInScenario(this,scenarioID)
            signalID=this.getDataModel().getDenoisedSignalIDInScenario(scenarioID);
        end

        function signalID=getSignalIDForApproxSignal(this)
            signalID=this.getDataModel().getSignalIDForApproxSignal();
        end

        function scenariosNames=getAllScenariosNames(this)
            scenariosNames=this.getDataModel().getAllScenariosNames();
            scenariosNames=[scenariosNames;this.DataModel().getImportedSignalName];
        end

        function signalIDs=getAllOriginalCoefficientSignalIDs(this)
            signalIDs=this.getDataModel().getAllOriginalCoefficientSignalIDs();
        end

        function signalIDs=getAllDenoisedCoefficientSignalIDs(this)
            signalIDs=this.getDataModel().getAllDenoisedCoefficientSignalIDs();
        end

        function scenarioName=getScenarioName(this,scenarioID)
            scenarioName=this.getDataModel().getScenarioParams(scenarioID).ScenarioName;
        end
    end
end