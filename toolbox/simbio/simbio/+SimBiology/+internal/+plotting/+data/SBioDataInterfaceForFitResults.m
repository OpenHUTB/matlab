classdef SBioDataInterfaceForFitResults<SimBiology.internal.plotting.data.SBioDataInterface

    properties(Access=private)
        taskResult=[];
    end



    methods(Access=public)
        function obj=SBioDataInterfaceForFitResults(sbiodata,dataSource,~,~)
            obj.dataSource=dataSource;

            obj.data=sbiodata;
        end
    end




    methods(Access=public)
        function flag=supportsPopulationFit(obj)
            flag=obj.isNLME;
        end

        function cacheTaskResult(obj,plotType,varargin)
            if isempty(obj.taskResult)
                if obj.isNLME
                    [strictTimes,fitType]=obj.getNLMETaskResultArgumentsForPlotType(plotType,varargin{:});
                    obj.taskResult=obj.data.constructTaskResult(fitType,strictTimes);
                else
                    obj.taskResult=obj.data.constructTaskResult();
                end
                if~isfield(obj.taskResult,'TaskInfo')
                    error(message('SimBiology:fitplots:INVALID_PLOT_TYPE'));
                end
            end
        end

        function[obsPlotArg,predPlotArg]=getFitPlotArguments(obj,isPopulation)
            [obsTimeUnits,predTimeUnits]=obj.getTimeUnits();
            [obsResponseUnits,predResponseUnits]=obj.getResponseUnits();
            groupNames=obj.getGroupNames();

            obsPlotArg=obj.getObservationPlotArgument(obsTimeUnits,obsResponseUnits,groupNames);
            predPlotArg=obj.getPredictionPlotArgument(predTimeUnits,predResponseUnits,isPopulation,obsPlotArg,groupNames);
        end

        function numParameterTypes=getNumberOfParameterTypes(obj)
            if obj.isNLME
                numParameterTypes=2;
            else
                numParameterTypes=1;
            end
        end

        function numResponses=getNumberOfComparedResponses(obj)
            observedResponseNames=obj.taskResult.TaskInfo.PKData.DependentVarLabel;
            if iscell(observedResponseNames)
                numResponses=numel(observedResponseNames);
            else
                numResponses=1;
            end
        end

        function numGroups=getNumberOfGroups(obj)
            numGroups=numel(obj.taskResult.DataToFit);
        end

        function names=getGroupNames(obj)
            for i=obj.getNumberOfGroups():-1:1
                if isstruct(obj.taskResult.DataToFit(i).UserData)&&isfield(obj.taskResult.DataToFit(i).UserData,'Group')
                    group=obj.taskResult.DataToFit(i).UserData.Group;
                    if iscell(group)
                        names(i)=group;
                    elseif isnumeric(group)
                        names{i}=num2str(i);
                    else
                        names{i}=group;
                    end
                else
                    names{i}=num2str(i);
                end
            end
        end

        function names=getObservationResponseNames(obj)
            names=obj.taskResult.TaskInfo.PKData.DependentVarLabel;
            if~iscell(names)
                names={names};
            end
        end

        function names=getPredictionResponseNames(obj)
            names=transpose(obj.taskResult.TaskInfo.PKModelMap.Observed);
        end

        function flag=shouldApplyUnitConversion(obj)
            flag=~isempty(obj.taskResult.SimdataI(1).RunInfo.ConfigSet)&&...
            obj.taskResult.SimdataI(1).RunInfo.ConfigSet.CompileOptions.UnitConversion;
        end

        function data=getObservedDataForTime(obj)
            simdata=obj.getObservationSimData();
            for g=numel(simdata):-1:1
                idx=any(~isnan(simdata(g).Data),2);
                data{g,1}=simdata(g).Time(idx);
            end
        end

        function data=getObservedDataForResponses(obj)
            simdata=obj.getObservationSimData();
            for g=numel(simdata):-1:1
                idx=any(~isnan(simdata(g).Data),2);
                data{g,1}=simdata(g).Data(idx,:);
            end
        end

        function data=getPredictedDataForTime(obj,resample,varargin)
            if resample
                data=obj.getObservedDataForTime();
                return;
            end

            isPopulation=varargin{1};
            if isPopulation
                simdata=obj.taskResult.SimdataP;
            else
                simdata=obj.taskResult.SimdataI;
            end
            data=transpose({simdata.Time});

            if obj.shouldApplyUnitConversion()
                [observedUnits,predictedUnits]=obj.getTimeUnits();
                if~isempty(observedUnits)&&~isempty(predictedUnits)
                    for g=1:numel(data)
                        data{g}=sbiounitcalculator(predictedUnits,observedUnits,data{g});
                    end
                end
            end
        end

        function data=getPredictedDataForResponses(obj,isPopulation,resample)
            if isPopulation
                simdata=obj.getPopulationPredictedSimData(resample);
            else
                simdata=obj.getIndividualPredictedSimData(resample);
            end

            data=transpose({simdata.Data});

            if obj.shouldApplyUnitConversion()
                numResponses=obj.getNumberOfComparedResponses();
                [observedUnits,predictedUnits]=getResponseUnits(obj);
                for g=1:numel(data)
                    for r=1:numResponses
                        if~isempty(observedUnits{r})&&~isempty(predictedUnits{r})
                            data{g}(:,r)=sbiounitcalculator(predictedUnits{r},observedUnits{r},data{g}(:,r));
                        end
                    end
                end
            end
        end

        function[observedUnits,predictedUnits]=getResponseUnits(obj)
            observedUnits={};
            predictedUnits={};
            if obj.shouldApplyUnitConversion()
                observedData=obj.getObservationSimData();
                predictedData=obj.getIndividualPredictedSimData(false);
                predDataInfo=predictedData(1).DataInfo;
                obsDataInfo=observedData(1).DataInfo;
                for i=obj.getNumberOfComparedResponses():-1:1
                    predictedUnits{i,1}=predDataInfo{i}.Units;
                    observedUnits{i,1}=obsDataInfo{i}.Units;
                end
            end
        end

        function[observedUnits,predictionUnits]=getTimeUnits(obj)
            observedData=obj.getObservationSimData();
            predictedData=obj.getIndividualPredictedSimData(false);
            observedUnits=observedData(1).TimeUnits;
            predictionUnits=predictedData(1).TimeUnits;
        end
    end

    methods(Static,Access=private)
        function[strictTimes,fitType]=getNLMETaskResultArgumentsForPlotType(plotType,varargin)
            import SimBiology.internal.plotting.sbioplot.definition.*;
            switch(plotType)
            case PlotDefinition.FIT
                strictTimes=false;
                fitType=varargin{1};
            case{PlotDefinition.ACTUAL_VS_PREDICTED,PlotDefinition.RESIDUALS,PlotDefinition.RESIDUAL_DISTRIBUTION}
                strictTimes=true;
                fitType='population';
            case PlotDefinition.BOX
                strictTimes=false;
                fitType='population';
            end
        end
    end

    methods(Access=private)
        function flag=isNLME(obj)
            flag=isa(obj.data,'SimBiology.fit.NLMEResults');
        end

        function flag=isFO(obj)
            flag=strcmp(obj.taskResult.TaskInfo.AlgorithmName,'NLMEFIT')&&strcmpi(obj.taskResult.TaskInfo.ApproximationType,'FO');
        end

        function obsSimData=getObservationSimData(obj)
            obsSimData=selectbyname(obj.taskResult.DataToFit,obj.getObservationResponseNames());
        end

        function predSimData=getIndividualPredictedSimData(obj,resample)
            predSimData=selectbyname(obj.taskResult.SimdataI,obj.getPredictionResponseNames());

            if resample
                predSimData=obj.resamplePredictedSimData(predSimData);
            end
        end

        function predSimData=getPopulationPredictedSimData(obj,resample)
            predSimData=selectbyname(obj.taskResult.SimdataP,obj.getPredictionResponseNames());

            if resample
                predSimData=obj.resamplePredictedSimData(predSimData);
            end
        end

        function predSimData=resamplePredictedSimData(obj,predSimData)
            unitConversion=obj.shouldApplyUnitConversion();
            if unitConversion
                [obsTimeUnits,predTimeUnits]=obj.getTimeUnits();
            end

            obsTimes=obj.getObservedDataForTime();
            for g=1:numel(obsTimes)
                obsTime=obsTimes{g};

                if unitConversion
                    obsTime=sbiounitcalculator(obsTimeUnits,predTimeUnits,obsTime);
                end

                if numel(predSimData(g).Time)~=numel(obsTime)||~all(predSimData(g).Time==obsTime)
                    predSimData(g)=predSimData(g).resample(obsTime);
                end
            end
        end

        function obsPlotArg=getObservationPlotArgument(obj,timeUnits,responseUnits,groupNames)
            obsPlotArg=obj.constructPlotArgument(obj.getObservationSimData(),...
            obj.getObservedDataSource(),...
            obj.getObservationResponseNames(),...
            timeUnits,responseUnits,...
            groupNames);

            obsPlotArg.setMatchedDataSource(obsPlotArg,obsPlotArg.dataSource.key);
        end

        function predPlotArg=getPredictionPlotArgument(obj,timeUnits,responseUnits,isPopulation,observationPlotArg,groupNames)
            if isPopulation
                data=obj.getPopulationPredictedSimData(false);
            else
                data=obj.getIndividualPredictedSimData(false);
            end

            predPlotArg=obj.constructPlotArgument(data,...
            obj.getPredictedDataSource(isPopulation),...
            obj.getPredictionResponseNames(),...
            timeUnits,responseUnits,...
            groupNames);

            predPlotArg.setMatchedDataSource(observationPlotArg,observationPlotArg.dataSource.key);
        end

        function plotArg=constructPlotArgument(obj,data,dataSource,responseNames,timeUnits,responseUnits,groupNames)
            plotArg=SimBiology.internal.plotting.sbioplot.PlotArgument;
            plotArg.dataSource=dataSource;


            for i=numel(responseNames):-1:1
                responses(i,1)=SimBiology.internal.plotting.sbioplot.Response;
                responses(i,1).independentVar='time';
                responses(i,1).dependentVar=responseNames{i};
            end
            plotArg.responses=responses;


            if isempty(responseUnits)
                allUnits='';
            else
                allUnits=[{timeUnits};responseUnits];
            end
            columnInfo=struct('name',[{'time'};responseNames],'units',allUnits);

            dataInfo=struct('associatedDataSources',SimBiology.internal.plotting.data.DataSource.empty,...
            'scalarParameters',SimBiology.internal.plotting.categorization.ScalarParameter.empty,...
            'runNames',{groupNames});
            plotArg.setData(data,columnInfo,dataInfo);
        end

        function obsDataSource=getObservedDataSource(obj)
            obsDataSource=SimBiology.internal.plotting.data.DataSource;
            obsDataSource.dataName='Observed';
        end

        function predDataSource=getPredictedDataSource(obj,isPopulation)
            predDataSource=SimBiology.internal.plotting.data.DataSource;
            predDataSource.dataName='Predicted';
            if obj.isNLME
                if isPopulation
                    predDataSource.dataName=[predDataSource.dataName,' - population'];
                else
                    predDataSource.dataName=[predDataSource.dataName,' - individual'];
                end
            end
        end
    end




    methods(Access=public)
        function residualTypes=getResidualTypes(obj)
            if obj.isNLME
                if obj.isFO
                    residualTypes={'PWRES';'IWRES'};
                else
                    residualTypes={'CWRES';'IWRES'};
                end
            else
                residualTypes={'Individual Residuals'};
            end
        end

        function residuals=getResiduals(obj)
            if obj.isNLME
                residuals=getResidualsForNLME(obj);
            else
                residuals={vertcat(obj.taskResult.Results.R)};
            end

            if any(cellfun(@(res)isempty(res),residuals))
                error(message('SimBiology:fitplots:ResidualDistributionPlot_NoWeightedResiduals'));
            end

            if obj.shouldApplyUnitConversion()
                residuals=obj.unitConvertResiduals(residuals);
            end
        end

        function stackedTimes=getStackedTimes(obj)
            stackedTimes=obj.getPredictedDataForTime(true);
            stackedTimes=vertcat(stackedTimes{:});
        end

        function stackedObservations=getStackedObservations(obj)
            obsData=obj.getObservedDataForResponses();
            stackedObservations=vertcat(obsData{:});
        end

        function stackedPredictions=getStackedPredictions(obj)
            if obj.isNLME
                stackedPredictions={obj.getStackedPredictionsForType(true);obj.getStackedPredictionsForType(false)};
            else
                stackedPredictions={obj.getStackedPredictionsForType(false)};
            end
        end

        function stackedGroups=getStackedGroups(obj)
            data=obj.getPredictedDataForTime(true);
            for i=1:numel(data)
                data{i}(:)=i;
            end
            stackedGroups=vertcat(data{:});
        end
    end

    methods(Access=private)
        function residuals=getResidualsForNLME(obj)
            if isfield(obj.taskResult.Results.stats,'cwres')
                if obj.isFO
                    residuals={obj.taskResult.Results.stats.pwres;obj.taskResult.Results.stats.iwres};
                else
                    residuals={obj.taskResult.Results.stats.cwres;obj.taskResult.Results.stats.iwres};
                end
            else

                residuals=calculateResidualsFromData(obj);
            end
        end

        function residuals=calculateResidualsFromData(obj)


            residuals={};
        end


        function residuals=unitConvertResiduals(obj,residuals)
            [observedUnits,predictedUnits]=obj.getResponseUnits();
            for r=1:numel(residuals)
                for i=1:obj.getNumberOfComparedResponses()
                    residuals{r}(:,i)=sbiounitcalculator(predictedUnits{i},observedUnits{i},residuals{r}(:,i));
                end
            end
        end

        function stackedPredictions=getStackedPredictionsForType(obj,isPopulation)
            predData=obj.getPredictedDataForResponses(isPopulation,true);
            stackedPredictions=vertcat(predData{:});
        end
    end




    methods(Access=public)
        function beta=getEstimatedParameterData(obj)
            if obj.isNLME
                beta=obj.getRandomEffectsMatrix();
            else
                beta=obj.getTransformedPhiMatrix();
            end
        end

        function transformedNames=getTransformedEstimatedParameterNames(obj)
            if obj.isNLME
                names=obj.getRandomEffectNames;
            else
                names=obj.getEstimatedParameterNames;
            end
            transform=obj.taskResult.TaskInfo.ParamTransform;
            transformFn={'','log','probit','logit'};
            transformedNames=names;
            for i=1:length(transformedNames)
                if transform(i)~=0
                    transformedNames{i}=[transformFn{transform(i)+1},'(',names{i},')'];
                end
            end
        end

        function displayString=getEstimatedParametersDescriptionString(obj)
            if obj.isNLME
                displayString='Random Effects (b)';
            else
                displayString='Individual Transformed Estimated Values (beta)';
            end
        end
    end

    methods(Access=private)
        function beta=getTransformedPhiMatrix(obj)
            phiMatrix=obj.taskResult.Results.constructPhiMatrix();
            paramTransformer=SimBiology.internal.ParamTransformer(obj.taskResult.TaskInfo.ParamTransform);
            beta=paramTransformer.transform(phiMatrix);
        end

        function beta=getRandomEffectsMatrix(obj)
            randomEffects=obj.taskResult.Results.RandomEffects;
            if istable(randomEffects)
                beta=randomEffects.Estimate;
            else

                beta=double(randomEffects);
            end
        end

        function names=getEstimatedParameterNames(obj)
            names=obj.taskResult.TaskInfo.PKModelMap.Estimated;
        end

        function names=getRandomEffectNames(obj)
            names=obj.taskResult.TaskInfo.PKModelMap.Estimated(obj.taskResult.TaskInfo.RandomEffects);
        end
    end
end