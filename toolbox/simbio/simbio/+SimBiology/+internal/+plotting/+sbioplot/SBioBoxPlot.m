classdef SBioBoxPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.BOX;
        end
    end




    methods(Access=protected)

        function processAdditionalArguments(obj,definitionProps)

            set(obj.figure.props,'LinkedX',false,'LinkedY',false);

            obj.getPlotArguments().cacheTaskResult(SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.BOX);
        end

        function setupAxes(obj)
            obj.numTrellisCols=1;
            obj.numTrellisRows=1;
            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;
            obj.resetAxes();
        end

        function resetAxes(obj)
            resetAxes@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj);

            if~obj.preserveFormats&&obj.hasData()

                obj.axes.setProperty('XGrid','off');
                obj.axes.setProperty('YGrid','off');
            end
        end

        function createPlot(obj)
            if obj.isUsingTiledLayout



                warningState=warning('off','stats:boxplot:BadObjectType');
                cleanupObj=onCleanup(@()warning(warningState));
            end
            [beta,transformedNames]=obj.getDataToPlot();
            boxplot(obj.axes.handle,beta,transformedNames);
        end

        function label(obj)
            if~obj.preserveLabels
                globalLabels=struct('YLabel',obj.getPlotArguments().getEstimatedParametersDescriptionString());
                obj.figure.setProps(globalLabels);
            end
        end
    end

    methods(Access=private)
        function[beta,transformedNames]=getDataToPlot(obj)
            beta=obj.getPlotArguments().getEstimatedParameterData();
            transformedNames=obj.getPlotArguments().getTransformedEstimatedParameterNames();
        end
    end


    methods(Access=protected)
        function updateTrellisTickLabels(obj)

        end
    end
end