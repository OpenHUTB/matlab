classdef(Sealed)Contour<lutdesigner.editor.chart.ViewModel

    properties(Access=private)
DataPlot
SelectionPlot
    end

    methods
        function this=Contour(axes)
            this@lutdesigner.editor.chart.ViewModel(axes);
            axtoolbar(this.Axes,{'pan','zoomin','zoomout','restoreview'});
        end
    end

    methods(Access=protected)
        function plotImpl(this,iv1Data,iv2Data,dvData)




            isIV1Valid=all(diff(iv1Data));
            isIV2Valid=all(diff(iv2Data));
            isDVValid=max(dvData(:))-min(dvData(:))>0;

            initIV1Data=iv1Data;
            if~isIV1Valid
                initIV1Data=1:numel(initIV1Data);
            end
            initIV2Data=iv2Data;
            if~isIV2Valid
                initIV2Data=1:numel(initIV2Data);
            end
            initDVData=dvData;
            if~isDVValid
                initDVData=zeros(size(initDVData));
                initDVData(1)=1;
            end

            [~,this.DataPlot]=contour(this.Axes,initIV1Data,initIV2Data,initDVData,'Tag','Data');

            if~isIV1Valid
                this.updateIndependentVariableData(1,iv1Data);
            end
            if~isIV2Valid
                this.updateIndependentVariableData(2,iv2Data);
            end
            if~isDVValid
                this.updateDependentVariableData(dvData);
            end
        end

        function updateSelectionMarkImpl(this,coords)
            delete(this.SelectionPlot);
            if~isempty(coords)
                hold(this.Axes,'on');
                this.SelectionPlot=plot(this.Axes,...
                this.DataPlot.XData(coords(:,1)),this.DataPlot.YData(coords(:,2)),...
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
