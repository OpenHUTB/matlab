classdef(Sealed)Line<lutdesigner.editor.chart.ViewModel

    properties(Access=private)
DataPlot
SelectionPlot
    end

    methods
        function this=Line(axes)
            this@lutdesigner.editor.chart.ViewModel(axes);
            axtoolbar(this.Axes,{'pan','zoomin','zoomout','restoreview'});
        end
    end

    methods(Access=protected)
        function plotImpl(this,ivData,dvData)
            this.DataPlot=plot(this.Axes,ivData,dvData,'-o','Tag','Data');
        end

        function updateSelectionMarkImpl(this,coords)
            delete(this.SelectionPlot);
            if~isempty(coords)
                hold(this.Axes,'on');
                this.SelectionPlot=plot(this.Axes,...
                this.DataPlot.XData(coords),this.DataPlot.YData(coords),...
                'o','MarkerFaceColor','red','Tag','Selection');
                hold(this.Axes,'off');
            end
        end

        function updateIndependentVariableLabelImpl(this,index,label)
            assert(index==1);
            xlabel(this.Axes,label,'Interpreter','None');
            if strlength(label)>0
                this.DataPlot.DataTipTemplate.DataTipRows(1).Label=label;
            else
                this.DataPlot.DataTipTemplate.DataTipRows(1).Label='X';
            end
        end

        function updateDependentVariableLabelImpl(this,label)
            ylabel(this.Axes,label,'Interpreter','None');
            this.DataPlot.DataTipTemplate.DataTipRows(2).Label=label;
            if strlength(label)>0
                this.DataPlot.DataTipTemplate.DataTipRows(2).Label=label;
            else
                this.DataPlot.DataTipTemplate.DataTipRows(2).Label='Y';
            end
        end

        function updateIndependentVariableDataImpl(this,index,data)
            assert(index==1);
            this.DataPlot.XData=data;
        end

        function updateDependentVariableDataImpl(this,data)
            this.DataPlot.YData=data;
        end
    end
end
