classdef SBioActualVsPredictedPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.ACTUAL_VS_PREDICTED;
        end
    end

    methods(Access=private)

        function configureParameterTypeCategory(obj)






            parameterTypeCategoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(SimBiology.internal.plotting.categorization.CategoryVariable.COVARIATE);
            parameterTypeCategoryVariable.subtype=SimBiology.internal.plotting.categorization.CategoryVariable.CATEGORICAL;
            parameterTypeCategoryVariable.name=SimBiology.internal.plotting.sbioplot.definition.ActualVsPredictedDefinitionProps.PARAMETER_TYPE;

            if(obj.getPlotArguments().getNumberOfParameterTypes()==1)
                parameterTypes={SimBiology.internal.plotting.sbioplot.definition.ActualVsPredictedDefinitionProps.INDIVIDUAL};
            else
                parameterTypes={SimBiology.internal.plotting.sbioplot.definition.ActualVsPredictedDefinitionProps.POPULATION;...
                SimBiology.internal.plotting.sbioplot.definition.ActualVsPredictedDefinitionProps.INDIVIDUAL};
            end
            parameterTypeBins=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue(parameterTypes);

            parameterTypeCategory=SimBiology.internal.plotting.categorization.CategoryDefinition(parameterTypeCategoryVariable);
            parameterTypeCategory.style=SimBiology.internal.plotting.categorization.CategoryDefinition.MIXED_FORMAT;
            parameterTypeCategory.binSettings=SimBiology.internal.plotting.categorization.BinSettings(parameterTypeBins);

            colorOrder=SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER();
            markerOrder=SimBiology.internal.plotting.categorization.BinSettings.MARKER_OPTIONS();
            for i=1:numel(parameterTypeBins)
                parameterTypeCategory.binSettings(i).color=colorOrder{i};
                parameterTypeCategory.binSettings(i).linespec=struct('linestyle','none',...
                'linewidth',0.5,...
                'marker',markerOrder{i});
                parameterTypeCategory.binSettings(i).transparency=1.0;
                parameterTypeCategory.binSettings(i).value.index=i;
            end

            set(obj.getProps(),'ParameterTypeCategory',parameterTypeCategory);
        end
    end




    methods(Access=protected)

        function processAdditionalArguments(obj,definitionProps)
            if~obj.preserveFormats
                set(obj.figure.props,'LinkedX',false,'LinkedY',false);
            end

            obj.getPlotArguments().cacheTaskResult(SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.ACTUAL_VS_PREDICTED);

            obj.configureParameterTypeCategory();
        end

        function setupAxes(obj)
            obj.numTrellisCols=1;
            obj.numTrellisRows=obj.getPlotArguments().getNumberOfComparedResponses();

            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;
            obj.resetAxes();
        end

        function createPlot(obj)
            [observedData,predictedData]=getDataToPlot(obj);
            parameterTypeCategory=obj.getProps().ParameterTypeCategory;

            for parameterIdx=1:obj.getPlotArguments().getNumberOfParameterTypes()
                predictedDataForParameterType=predictedData{parameterIdx};
                paramterTypeBin=parameterTypeCategory.binSettings(parameterIdx);

                for responseIdx=1:obj.numTrellisRows
                    ax=obj.getAxesForSubplot(responseIdx,1);

                    lineHandles=plot(ax.handle,...
                    predictedDataForParameterType(:,responseIdx),observedData(:,responseIdx),...
                    'color',paramterTypeBin.color,...
                    'marker',paramterTypeBin.linespec.marker,...
                    'markersize',6,...
                    'linestyle',paramterTypeBin.linespec.linestyle);


                    set(lineHandles,'UserData',struct('CategoryBinValues',...
                    struct('categoryVariableKey',parameterTypeCategory.categoryVariable.key,...
                    'binIndex',paramterTypeBin.value.index)));
                end
            end
        end

        function label(obj)
            if~obj.preserveLabels
                observedNames=obj.getPlotArguments().getObservationResponseNames();
                predictedNames=obj.getPlotArguments().getPredictionResponseNames();
                responseUnits=obj.getPlotArguments().getComparedResponseUnits();


                if~isempty(responseUnits)
                    observedNames=cellfun(@(name,units)[name,' (',units,')'],observedNames,responseUnits,'UniformOutput',false);
                    predictedNames=cellfun(@(name,units)[name,' (',units,')'],predictedNames,responseUnits,'UniformOutput',false);
                end

                globalLabels=struct('Title','','XLabel','','YLabel','');

                if obj.numTrellisRows==1
                    globalLabels.XLabel=['Predicted Value of ',observedNames{1}];
                    globalLabels.YLabel=['Observed Value of ',observedNames{1}];
                else
                    globalLabels.XLabel='Predicted Value';
                    globalLabels.YLabel='Observed Value';
                    obj.axes.setProperty('XLabel',predictedNames);
                    obj.axes.setProperty('YLabel',observedNames);
                end

                obj.figure.setProps(globalLabels);
            end
        end
    end

    methods(Access=private)
        function[observedData,predictedData]=getDataToPlot(obj)
            observedData=obj.getPlotArguments().getStackedObservations();
            predictedData=obj.getPlotArguments().getStackedPredictions();
        end
    end

    methods(Access=public)
        function categories=getCategories(obj)
            categories=obj.getProps().ParameterTypeCategory;
        end
    end

    methods(Access=protected)
        function category=getCategoryForCategoryVariable(obj,categoryVariable)
            category=obj.getCategories();
        end
    end


    methods(Access=protected)
        function flag=supportsReferenceLines(obj)
            flag=true;
        end

        function redrawReferenceLines(obj)
            obj.addReferenceLine(1,0);
        end
    end
end