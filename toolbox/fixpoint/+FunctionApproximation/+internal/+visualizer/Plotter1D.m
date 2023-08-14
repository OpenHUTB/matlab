classdef Plotter1D<FunctionApproximation.internal.visualizer.Plotter




    properties(Constant)
        LineStyleProperties={'LineStyle','-','LineWidth',1.25,'Marker','none'};
    end

    methods
        function plotData(this)








            set(0,'CurrentFigure',this.PlotHandle);
            subplot(2,1,1);
            plot(this.DataContext.Breakpoints{1},this.DataContext.Original,this.LineStyleProperties{:});
            hold on
            plot(this.DataContext.Breakpoints{1},this.DataContext.Approximate,this.LineStyleProperties{:});
            hold off

            colors=parula(8);
            subplot(2,1,2);
            areaColor=colors(5,:);
            absDiffColor=colors(end,:);
            absDiffColor(2)=0;
            maxDiffColor=colors(6,:);
            area(this.DataContext.Breakpoints{1},this.DataContext.MaxDiff,'LineStyle','none','FaceColor',areaColor,'FaceAlpha',0.25);
            hold on
            plot(this.DataContext.Breakpoints{1},this.DataContext.MaxDiff,'Color',maxDiffColor,this.LineStyleProperties{:});
            plot(this.DataContext.Breakpoints{1},this.DataContext.AbsDiff,'Color',absDiffColor,this.LineStyleProperties{:});
            linkaxes(this.PlotHandle.Children,'x');

            for ii=1:numel(this.PlotHandle.Children)
                this.PlotHandle.Children(ii).Position(1)=0.05;
                this.PlotHandle.Children(ii).Position(3)=0.90;
                this.PlotHandle.Children(1).XLim=this.DataContext.Breakpoints{1}([1,end]);
            end
        end

        function labelPlots(this)




            this.PlotHandle.Children(2).XLabel.String=message('SimulinkFixedPoint:functionApproximation:plotterInput').getString();
            this.PlotHandle.Children(2).YLabel.String=message('SimulinkFixedPoint:functionApproximation:plotterFunctionValue').getString();

            this.PlotHandle.Children(1).XLabel.String=this.PlotHandle.Children(2).XLabel.String;
            this.PlotHandle.Children(1).YLabel.String=message('SimulinkFixedPoint:functionApproximation:plotterErrors').getString();
        end

        function addLegend(this)




            legend(this.PlotHandle.Children(2).Children,...
            this.ApproximateLegend,...
            this.OriginalLegend);

            legend(this.PlotHandle.Children(1).Children,...
            this.AbsDiffLegend,...
            this.MaxDiffLegend,...
            message('SimulinkFixedPoint:functionApproximation:feasibleRegionLegendKey','<=').getString());



            posFunctionHandle=@(axesPos,legendPos)[axesPos(1),axesPos(2)+axesPos(4)*1.0625,legendPos(3),legendPos(4)];
            pos=this.PlotHandle.Children(4).Position;
            currentPosition=this.PlotHandle.Children(3).Position;
            this.PlotHandle.Children(3).Position=posFunctionHandle(pos,currentPosition);

            pos=this.PlotHandle.Children(2).Position;
            currentPosition=this.PlotHandle.Children(1).Position;
            this.PlotHandle.Children(1).Position=posFunctionHandle(pos,currentPosition);
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
                child.LineWidth=0.5;
            end
        end
    end
end
