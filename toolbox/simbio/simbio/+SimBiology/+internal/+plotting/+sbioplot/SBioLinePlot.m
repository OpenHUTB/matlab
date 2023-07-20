classdef SBioLinePlot<SimBiology.internal.plotting.sbioplot.SBioCategoricalPlot

    properties(Access=protected)
        primaryPlotArguments=[];
    end




    methods(Access=public)
        function flag=supportsMatchGroups(obj)
            flag=true;
        end

        function flag=matchGroupsAcrossDataSources(obj)
            flag=obj.getProps().MatchGroupsAcrossDataSources;
        end

        function flag=applyMatchGroupAcrossDataSources(obj)
            flag=obj.matchGroupsAcrossDataSources()&&obj.hasMultipleDataSources()&&any(obj.getArgumentsToPlot().getNumberOfGroups>1);
        end

        function flag=hasMatchedGroups(obj)

            flag=obj.applyMatchGroupAcrossDataSources()&&...
            (numel(obj.getArgumentsToPlot())>numel(obj.primaryPlotArguments));
        end

        function primaryPlotArguments=getPrimaryPlotArguments(obj)
            if isempty(obj.primaryPlotArguments)
                primaryPlotArguments=obj.getPlotArguments();
            else
                primaryPlotArguments=obj.primaryPlotArguments;
            end
        end

        function flag=hasOneToOneGroupMatchingOnly(obj)
            flag=~obj.hasMultipleDataSources||...
            all(obj.getArgumentsToPlot().hasOneToOneGroupMatchingOnly());
        end

        function flag=excludeAssociatedGroupParameters(obj)
            flag=~obj.hasMultiplePrimaryPlotArguments();
        end
    end




    methods(Access=protected)
        function processPlotArguments(obj)
            if obj.applyMatchGroupAcrossDataSources
                obj.primaryPlotArguments=obj.getArgumentsToPlot().matchDataSources(obj.getCategories());
            else
                obj.primaryPlotArguments=[];
                obj.getPlotArguments().resetMatchedDataSources();
            end


            obj.getArgumentsToPlot().cacheGroups();
        end

        function plotBin(obj,compoundBin)
            ax=obj.getAxesForSubplot(compoundBin.style.row,compoundBin.style.column);
            formats=compoundBin.getPlotFormatOptions();
            bins=compoundBin.getAllBins();

            for j=1:numel(compoundBin.dataSeries)

                lineHandles=plot(ax.handle,compoundBin.dataSeries(j).independentVariableData,compoundBin.dataSeries(j).dependentVariableData,formats{:});

                set(lineHandles,'UserData',struct('CategoryBinValues',bins));
            end
        end
    end




    methods(Access=protected)
        function plotElementHandles=getAllPlotElementHandles(obj)
            plotElementHandles=findobj(obj.figure.handle,'-depth',2,'type','line');
        end
    end
end