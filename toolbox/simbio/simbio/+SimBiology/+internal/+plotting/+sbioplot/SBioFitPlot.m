classdef SBioFitPlot<SimBiology.internal.plotting.sbioplot.SBioTimeLinePlot

    properties(Access=private)
        argumentsToPlot=SimBiology.internal.plotting.sbioplot.PlotArgument.empty;
    end




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.FIT;
        end

        function flag=isTrellis(obj)
            flag=strcmp(obj.getProps().Layout,SimBiology.internal.plotting.sbioplot.definition.FitPlotDefinitionProps.TRELLIS);
        end

        function flag=isPopulation(obj)
            flag=strcmp(obj.getProps().Type,SimBiology.internal.plotting.sbioplot.definition.FitPlotDefinitionProps.POPULATION);
        end

        function fitType=getType(obj)
            fitType=obj.definition.props.Type;
        end

        function setType(obj,fitType)
            obj.definition.props.Type=fitType;
        end

        function createResponseSetCategory(obj)
            observedNames=obj.getPlotArguments().getObservationResponseNames();
            predictedNames=obj.getPlotArguments().getPredictionResponseNames();

            for r=numel(observedNames):-1:1
                observedResponseBin=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue;
                observedResponseBin.value=SimBiology.internal.plotting.sbioplot.Response;
                observedResponseBin.dataSource=obj.getPrimaryPlotArguments().dataSource;
                observedResponseBin.value.independentVar='time';
                observedResponseBin.value.dependentVar=observedNames{r};

                predictedResponseBin=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue;
                predictedResponseBin.dataSource=obj.getPredictedPlotArgument().dataSource;
                predictedResponseBin.value=SimBiology.internal.plotting.sbioplot.Response;
                predictedResponseBin.value.independentVar='time';
                predictedResponseBin.value.dependentVar=predictedNames{r};

                responseBins=[observedResponseBin;predictedResponseBin];

                responseSetBins(r,1)=SimBiology.internal.plotting.categorization.BinSettings;

                newBinValue=SimBiology.internal.plotting.categorization.binvalue.ResponseSetBinValue;
                newBinValue.value=observedNames{r};
                newBinValue.responseBinValues=responseBins;
                responseSetBins(r,1).value=newBinValue;
            end

            responseSetCategory=SimBiology.internal.plotting.categorization.CategoryDefinition(SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE_SET);
            responseSetCategory.binSettings=responseSetBins;
            if obj.isTrellis
                responseSetCategory.style=SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR;
            else
                responseSetCategory.style=SimBiology.internal.plotting.categorization.CategoryDefinition.VERTICAL;
            end


            categories(1)=responseSetCategory;
            obj.setCategories(categories);
        end

        function flag=matchGroupsAcrossDataSources(obj)
            flag=true;
        end

        function flag=hasMultipleDataSources(obj)
            flag=true;
        end
    end

    methods(Access=protected)
        function plotArguments=getArgumentsToPlot(obj)
            plotArguments=obj.argumentsToPlot;
        end

        function plotArgument=getPredictedPlotArgument(obj)
            plotArgument=obj.argumentsToPlot(2);
        end
    end




    methods(Access=protected)
        function processAdditionalArguments(obj,definitionProps)
            if~obj.preserveFormats
                set(obj.figure.props,'LinkedX',true,'LinkedY',obj.isTrellis);
            end

            obj.getPlotArguments().cacheTaskResult(SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.FIT,obj.getType());

            obj.setUnitConversion(obj.getPlotArguments().shouldApplyUnitConversion());

            if~isempty(definitionProps)

                categories=definitionProps.Categories;
                if isempty(categories)||isstruct(categories)
                    obj.setCategories(SimBiology.internal.plotting.categorization.CategoryDefinition(categories));
                end
            end


            if~obj.getPlotArguments().supportsPopulationFit()
                obj.setType(SimBiology.internal.plotting.sbioplot.definition.FitPlotDefinitionProps.INDIVIDUAL);
            end


            [obsPlotArg,predPlotArg]=obj.getPlotArguments().getFitPlotArguments(obj.isPopulation());
            obj.primaryPlotArguments=obsPlotArg;
            obj.argumentsToPlot=[obsPlotArg,predPlotArg];


            obj.createResponseSetCategory();
            categories=obj.getCategories().update(obj.getArgumentsToPlot(),obj);


            responseCategory=categories.getResponseCategory();
            responseCategory.style=SimBiology.internal.plotting.categorization.CategoryDefinition.LINESTYLE;

            obsDataSource=obj.getPrimaryPlotArguments().dataSource;
            for i=1:numel(responseCategory.binSettings)
                if responseCategory.binSettings(i).value.dataSource.isEqual(obsDataSource)
                    responseCategory.binSettings(i).linespec.linestyle='none';
                    responseCategory.binSettings(i).linespec.marker='o';
                    responseCategory.binSettings(i).color='#000000';
                else
                    responseCategory.binSettings(i).linespec.linestyle='-';
                    responseCategory.binSettings(i).linespec.marker='none';
                    responseCategory.binSettings(i).color='#000000';
                end
            end

            groupCategory=categories.getGroupCategory();
            if~isempty(groupCategory)
                groupCategory.categoryVariable.name='Groups';
                if obj.isTrellis
                    groupCategory.style=SimBiology.internal.plotting.categorization.CategoryDefinition.GRID;
                else
                    groupCategory.style=SimBiology.internal.plotting.categorization.CategoryDefinition.COLOR;
                end
            end

            obj.setCategories(categories);
        end

        function updateLabelsForCategories(obj)

            updateLabelsForCategories@SimBiology.internal.plotting.sbioplot.SBioCategoricalPlot(obj);
            obj.figure.setProps(struct('Title',{''}));
        end
    end


    methods(Access=public)
        function flag=useAlternateLabelsForLegend(obj)
            flag=true;
        end
    end
end