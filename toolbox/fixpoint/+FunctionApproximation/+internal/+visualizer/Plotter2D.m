classdef Plotter2D<FunctionApproximation.internal.visualizer.Plotter




    methods
        function plotData(this)
            set(0,'CurrentFigure',this.PlotHandle);

            colors=parula(8);
            edgeColor='k';
            edgeAlpha=0.2;

            originalColor=colors(1,:);
            approximationColor=colors(5,:);

            subplot(1,2,1);
            surf(this.DataContext.Breakpoints{1},this.DataContext.Breakpoints{2},this.DataContext.Original,...
            max(this.DataContext.Original(:))*ones(size(this.DataContext.Original)),...
            'FaceAlpha',0.85,'EdgeColor',edgeColor,'FaceColor',originalColor,'EdgeAlpha',edgeAlpha);
            hold on
            surf(this.DataContext.Breakpoints{1},this.DataContext.Breakpoints{2},this.DataContext.Approximate,...
            'FaceAlpha',1,'EdgeColor',edgeColor,'FaceColor',approximationColor,'EdgeAlpha',edgeAlpha);
            hold off

            absDiffColor=colors(end,:);
            absDiffColor(2)=0;
            maxDiffColor=colors(5,:);

            subplot(1,2,2);
            surf(this.DataContext.Breakpoints{1},this.DataContext.Breakpoints{2},this.DataContext.AbsDiff,...
            'FaceAlpha',1,'EdgeColor',edgeColor,'FaceColor',absDiffColor,'EdgeAlpha',edgeAlpha);
            hold on
            surf(this.DataContext.Breakpoints{1},this.DataContext.Breakpoints{2},this.DataContext.MaxDiff,...
            max(this.DataContext.MaxDiff(:))*ones(size(this.DataContext.MaxDiff)),...
            'FaceAlpha',0.85,'EdgeColor',edgeColor,'FaceColor',maxDiffColor,'EdgeAlpha',edgeAlpha);
            hold off
        end

        function labelPlots(this)
            this.PlotHandle.Children(2).XLabel.String=message('SimulinkFixedPoint:functionApproximation:plotterInputDimX',1).getString();
            this.PlotHandle.Children(2).YLabel.String=message('SimulinkFixedPoint:functionApproximation:plotterInputDimX',2).getString();
            this.PlotHandle.Children(2).ZLabel.String=message('SimulinkFixedPoint:functionApproximation:plotterFunctionValue').getString();

            this.PlotHandle.Children(1).XLabel.String=this.PlotHandle.Children(2).XLabel.String;
            this.PlotHandle.Children(1).YLabel.String=this.PlotHandle.Children(2).YLabel.String;
            this.PlotHandle.Children(1).ZLabel.String=message('SimulinkFixedPoint:functionApproximation:plotterErrors').getString();
        end

        function addLegend(this)
            legend(this.PlotHandle.Children(2).Children,...
            this.ApproximateLegend,...
            this.OriginalLegend,...
            'Location','best');
            legend(this.PlotHandle.Children(1).Children,...
            this.MaxDiffLegend,...
            this.AbsDiffLegend,...
            'Location','best');
        end

        function addBorders(this)
            axesIndices=arrayfun(@(x)isa(x,'matlab.graphics.axis.Axes'),this.PlotHandle.Children);
            children=this.PlotHandle.Children(axesIndices);
            for iChild=1:numel(children)
                child=children(iChild);
                child.Box='on';
                child.XGrid='on';
                child.XMinorGrid='on';
                child.YGrid='on';
                child.YMinorGrid='on';
                child.ZGrid='on';
                child.LineWidth=1.5;
            end
        end
    end
end
