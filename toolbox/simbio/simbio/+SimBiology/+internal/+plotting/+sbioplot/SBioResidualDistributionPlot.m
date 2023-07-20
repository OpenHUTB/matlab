classdef SBioResidualDistributionPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject




    properties(Access=private)
        numVerticalPlots=2;
    end

    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.RESIDUAL_DISTRIBUTION;
        end
    end




    methods(Access=protected)
        function processAdditionalArguments(obj,definitionProps)

            set(obj.figure.props,'LinkedX',false,'LinkedY',false);

            obj.getPlotArguments().cacheTaskResult(SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.RESIDUAL_DISTRIBUTION);
        end

        function setupAxes(obj)
            obj.numTrellisCols=obj.getPlotArguments().getNumberOfParameterTypes();
            obj.numTrellisRows=obj.getPlotArguments().getNumberOfComparedResponses();


            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows*obj.numVerticalPlots;
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
            residuals=obj.getDataToPlot();
            for responseIdx=1:obj.numTrellisRows
                for residualIdx=1:obj.numTrellisCols
                    ax=obj.getAxesForTrellisPosition(responseIdx,residualIdx);
                    obj.formattedNormplot(ax(1),residuals{residualIdx}(:,responseIdx));
                    obj.createHistplot(ax(2),residuals{residualIdx}(:,responseIdx));
                end
            end
        end

        function label(obj)
            if~obj.preserveLabels
                residualNames=obj.getPlotArguments().getResidualTypes();
                responseNames=obj.getPlotArguments().getObservationResponseNames();

                if obj.numTrellisCols==1&&obj.numTrellisRows==1
                    obj.figure.setProps(struct('YLabel',[residualNames{1},' for ',responseNames{1}]));
                else
                    for residualIdx=1:obj.numTrellisCols
                        ax=obj.getAxesForSubplot(1,residualIdx);
                        ax.setProperty('Title',residualNames(residualIdx));
                    end
                    if obj.numTrellisRows==1
                        obj.figure.setProps(struct('YLabel',responseNames{1}));
                    else
                        for responseIdx=1:obj.numTrellisRows
                            ax=obj.getAxesForTrellisPosition(responseIdx,1);
                            ax(1).setProperty('YLabel',responseNames(responseIdx));
                        end
                    end
                end
            end
        end

        function format(obj)

            obj.axes.format(true);
        end
    end

    methods(Access=private)
        function residuals=getDataToPlot(obj)
            residuals=obj.getPlotArguments().getResiduals();
        end

        function axesInfo=getAxesForTrellisPosition(obj,row,column)
            rowStartIdx=(row-1)*obj.numVerticalPlots+1;
            axesInfo=obj.axes(rowStartIdx:rowStartIdx+1,column);
        end

        function formattedNormplot(obj,axesInfo,residuals)
            normplot(axesInfo.handle,residuals);
            axesInfo.handle.YTickMode='manual';
            axesInfo.handle.YTick={};
            axesInfo.handle.Box='on';
            if~obj.preserveFormats
                axesProps=struct('Title','',...
                'XLabel','',...
                'YLabel','',...
                'XGrid','off',...
                'YGrid','off');
                axesInfo.setProperties(axesProps);
            end
        end

        function createHistplot(obj,axesInfo,residuals)
            [binCounts,binEdges]=histcounts(residuals,'Normalization','pdf');
            binWidth=binEdges(2)-binEdges(1);
            binCenters=binEdges(1:end-1)+0.5*binWidth;
            bar(axesInfo.handle,binCenters,binCounts);

            axesInfo.handle.NextPlot='add';
            ax.YLim=[0,max(binCounts)*1.05];
            x2=-4:0.1:4;
            f2=normpdf(x2,0,1);
            plot(axesInfo.handle,x2,f2,'r');

            axesInfo.handle.YTickMode='manual';
            axesInfo.handle.YTick={};

            if~obj.preserveFormats
                axesProps=struct('XGrid','off',...
                'YGrid','off');
                axesInfo.setProperties(axesProps);
            end
        end
    end


    methods(Access=protected)
        function updateTrellisTickLabels(obj)

        end
    end
end