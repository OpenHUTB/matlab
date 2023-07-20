classdef EvolutionTreePlotter<handle





    properties(SetAccess=protected)

TreeFigure
TreeAxes
NodeMap
NodeTable
EdgeTable
Digraph
TreePlot
LayoutInfo
IndexToXY
CurrentPoint
RootEi
CurrentEi
ActiveEi
    end


    properties(Constant)

        NodeColor=[0,0,0];
        BackgroundColor=[1,1,1];
        SelectedBackgroundColor=[0,153/255,255/255,0.5];
        NodeEdgeWeight=1.5;
        NodeCurvature=.15;
        LineWeight=.75;
        TextFillRatio=.9;
        SingleXRowNodeFill=.5;
        MultipleXRowNodeFill=.75;
        SingleYRowNodeFill=.25;
        MultipleYRowNodeFill=.5;
    end



    methods
        function this=EvolutionTreePlotter(rootEi)
            this.RootEi=rootEi;
            this.createCanvas;
            this.plotTree;
        end

        function delete(this)
            delete(this.TreeFigure);
        end

    end

    methods(Access=protected)
        createCanvas(this)
        plotTree(this,rootEvolution)
    end

end


