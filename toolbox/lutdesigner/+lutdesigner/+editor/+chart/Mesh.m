classdef(Sealed)Mesh<lutdesigner.editor.chart.ViewModel

    properties(Access=private)
DataPlot
SelectionPlot
    end

    methods
        function this=Mesh(axes)
            this@lutdesigner.editor.chart.ViewModel(axes);
            axtoolbar(this.Axes,{'rotate','pan','zoomin','zoomout','restoreview'});
        end
    end

    methods(Access=protected)
        function plotImpl(this,iv1Data,iv2Data,dvData)
            this.DataPlot=mesh(this.Axes,iv1Data,iv2Data,dvData,'Tag','Data');
            view(this.Axes,3);
        end

        function updateSelectionMarkImpl(this,coords)
            delete(this.SelectionPlot);
            if~isempty(coords)
                hold(this.Axes,'on');
                this.SelectionPlot=plot3(this.Axes,...
                this.DataPlot.XData(coords(:,1)),this.DataPlot.YData(coords(:,2)),...
                arrayfun(@(x,y)this.DataPlot.ZData(x,y),coords(:,2),coords(:,1)),...
                'o','MarkerFaceColor','red','Tag','Selection');
                hold(this.Axes,'off');
            end
        end

        function updateIndependentVariableLabelImpl(this,index,label)
            if index==1
                xlabel(this.Axes,label,'Interpreter','None');
                if strlength(label)>0
                    this.DataPlot.DataTipTemplate.DataTipRows(1).Label=label;
                else
                    this.DataPlot.DataTipTemplate.DataTipRows(1).Label='X';
                end
            else
                ylabel(this.Axes,label,'Interpreter','None');
                if strlength(label)>0
                    this.DataPlot.DataTipTemplate.DataTipRows(2).Label=label;
                else
                    this.DataPlot.DataTipTemplate.DataTipRows(2).Label='Y';
                end
            end
        end

        function updateDependentVariableLabelImpl(this,label)
            zlabel(this.Axes,label,'Interpreter','None');
            this.DataPlot.DataTipTemplate.DataTipRows(3).Label=label;
            if strlength(label)>0
                this.DataPlot.DataTipTemplate.DataTipRows(3).Label=label;
            else
                this.DataPlot.DataTipTemplate.DataTipRows(3).Label='Z';
            end
        end

        function updateIndependentVariableDataImpl(this,index,data)
            if index==1
                this.DataPlot.XData=data;
            else
                this.DataPlot.YData=data;
            end
        end

        function updateDependentVariableDataImpl(this,data)
            this.DataPlot.ZData=data;
        end
    end
end
