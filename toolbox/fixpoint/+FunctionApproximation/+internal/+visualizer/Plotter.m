classdef Plotter<handle





    properties(Constant)
        OriginalLegendString=message('SimulinkFixedPoint:functionApproximation:plotterOriginal').getString();
        OriginalSaturatedLegendString=message('SimulinkFixedPoint:functionApproximation:plotterOriginalSaturated').getString();
        ApproximateLegend=message('SimulinkFixedPoint:functionApproximation:plotterApproximation').getString();
    end

    properties(SetAccess=private)
OriginalLegend
AbsDiffLegend
MaxDiffLegend
    end

    properties(SetAccess=protected)
        PlotHandle matlab.ui.Figure
        DataContext FunctionApproximation.internal.visualizer.DataContext
    end

    methods
        function h=plot(this,dataContext)

            setDataContext(this,dataContext);
            setLegendStrings(this);
            initializePlot(this);
            plotData(this);
            formatFigure(this);

            h=this.PlotHandle;
            set(h,'Visible','on');
        end
    end

    methods(Abstract)
        plotData(this)
        labelPlots(this)
        addLegend(this)
        addBorders(this)
    end

    methods(Sealed)
        function setLegendStrings(this)
            if this.DataContext.Options.SaturateToOutputType
                this.OriginalLegend=this.OriginalSaturatedLegendString;
            else
                this.OriginalLegend=this.OriginalLegendString;
            end

            this.AbsDiffLegend=message('SimulinkFixedPoint:functionApproximation:plotterAbsDiff',this.OriginalLegend,this.ApproximateLegend).getString();
            this.MaxDiffLegend=message('SimulinkFixedPoint:functionApproximation:plotterMaxDiff',this.OriginalLegend).getString();
        end

        function initializePlot(this)





            screenSize=get(0,'ScreenSize');
            screenWidth=screenSize(3);
            screenHeight=screenSize(4);
            this.PlotHandle=figure('OuterPosition',...
            [screenWidth*0.03125,screenHeight*0.0625,screenWidth*0.9375,screenHeight*0.875],'Visible','off');
        end

        function formatFigure(this)

            labelPlots(this);
            drawnow('nocallbacks');
            addLegend(this);
            drawnow('nocallbacks');
            addTitles(this);
            drawnow('nocallbacks');
            addBorders(this);
            drawnow('nocallbacks');
        end

        function addTitles(this)
            this.PlotHandle.Children(4).Title.String=message('SimulinkFixedPoint:functionApproximation:functionComparisonTitle',this.OriginalLegend,this.ApproximateLegend).getString();

            feasibility=message('SimulinkFixedPoint:functionApproximation:infeasibleState').getString();
            if this.DataContext.Feasible
                feasibility=message('SimulinkFixedPoint:functionApproximation:feasibleState').getString();
            end
            this.PlotHandle.Children(2).Title.String=...
            sprintf('%s: %s\nAbsTol = %s\nRelTol = %s',...
            message('SimulinkFixedPoint:functionApproximation:feasibilityOfSolution').getString(),...
            feasibility,...
            fixed.internal.compactButAccurateNum2Str(this.DataContext.Options.AbsTol),...
            fixed.internal.compactButAccurateNum2Str(this.DataContext.Options.RelTol));
        end

        function setDataContext(this,dataContext)
            this.DataContext=dataContext;
        end
    end
end
