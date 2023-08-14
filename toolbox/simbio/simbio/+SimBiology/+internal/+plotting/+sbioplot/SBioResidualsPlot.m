classdef SBioResidualsPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.RESIDUALS;
        end
    end

    methods(Access=private)
        function flag=xAxisType(obj)
            flag=obj.definition.getProperty('XAxis');
        end

        function configureResidualsCategory(obj)






            residualsCategoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(SimBiology.internal.plotting.categorization.CategoryVariable.COVARIATE);
            residualsCategoryVariable.subtype=SimBiology.internal.plotting.categorization.CategoryVariable.CATEGORICAL;
            residualsCategoryVariable.name=SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps.RESIDUALS_TYPE;

            residualsBins=SimBiology.internal.plotting.categorization.binvalue.CategoricalBinValue(obj.getPlotArguments().getResidualTypes());

            residualsCategory=SimBiology.internal.plotting.categorization.CategoryDefinition(residualsCategoryVariable);
            residualsCategory.style=SimBiology.internal.plotting.categorization.CategoryDefinition.MIXED_FORMAT;
            residualsCategory.binSettings=SimBiology.internal.plotting.categorization.BinSettings(residualsBins);

            colorOrder=SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER();
            markerOrder=SimBiology.internal.plotting.categorization.BinSettings.MARKER_OPTIONS();
            for i=1:numel(residualsBins)
                residualsCategory.binSettings(i).color=colorOrder{i};
                residualsCategory.binSettings(i).linespec=struct('linestyle','none',...
                'linewidth',0.5,...
                'marker',markerOrder{i});
                residualsCategory.binSettings(i).transparency=1.0;
                residualsCategory.binSettings(i).value.index=i;
            end

            set(obj.getProps(),'ResidualsCategory',residualsCategory);
        end
    end




    methods(Access=protected)

        function processAdditionalArguments(obj,definitionProps)
            if~obj.preserveFormats
                set(obj.figure.props,'LinkedX',false,'LinkedY',false);
            end

            obj.getPlotArguments().cacheTaskResult(SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.RESIDUALS);

            obj.configureResidualsCategory();
        end

        function setupAxes(obj)
            obj.numTrellisCols=1;
            obj.numTrellisRows=obj.getPlotArguments().getNumberOfComparedResponses();

            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;
            obj.resetAxes();
        end

        function createPlot(obj)
            [residuals,xaxisData]=obj.getDataToPlot();
            residualsCategory=obj.getProps().ResidualsCategory;

            for residualIdx=1:obj.getPlotArguments().getNumberOfParameterTypes()
                residualData=residuals{residualIdx};
                residualsBin=residualsCategory.binSettings(residualIdx);

                for responseIdx=1:obj.numTrellisRows
                    if strcmp(obj.xAxisType(),SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps.PREDICTIONS)
                        xData=xaxisData{residualIdx}(:,responseIdx);
                    else
                        xData=xaxisData;
                    end
                    ax=obj.getAxesForSubplot(responseIdx,1);
                    lineHandles=plot(ax.handle,xData,residualData(:,responseIdx),...
                    'color',residualsBin.color,...
                    'marker',residualsBin.linespec.marker,...
                    'markersize',6,...
                    'linestyle',residualsBin.linespec.linestyle);


                    set(lineHandles,'UserData',struct('CategoryBinValues',...
                    struct('categoryVariableKey',residualsCategory.categoryVariable.key,...
                    'binIndex',residualsBin.value.index)));
                end
            end
        end

        function label(obj)
            if~obj.preserveLabels
                observedNames=obj.getPlotArguments().getObservationResponseNames();

                globalLabels=struct('Title','','XLabel','','YLabel','');

                if obj.numTrellisRows==1
                    globalLabels.YLabel=['Residuals for ',observedNames{1}];
                else
                    globalLabels.YLabel='Residuals';
                    obj.axes.setProperty('YLabel',observedNames);
                end

                xAxis=obj.xAxisType();
                globalLabels.XLabel=[upper(xAxis(1)),xAxis(2:end)];

                obj.figure.setProps(globalLabels);
            end
        end
    end

    methods(Access=private)
        function[residuals,xaxisData]=getDataToPlot(obj)
            residuals=obj.getPlotArguments().getResiduals();
            switch(obj.xAxisType())
            case SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps.TIME
                xaxisData=obj.getPlotArguments().getStackedTimes();
            case SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps.GROUP
                xaxisData=obj.getPlotArguments().getStackedGroups();
            case SimBiology.internal.plotting.sbioplot.definition.ResidualsDefinitionProps.PREDICTIONS
                xaxisData=obj.getPlotArguments().getStackedPredictions();
            end
        end
    end

    methods(Access=public)
        function categories=getCategories(obj)
            categories=obj.getProps().ResidualsCategory;
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
            obj.addReferenceLine(0,0);
        end
    end
end