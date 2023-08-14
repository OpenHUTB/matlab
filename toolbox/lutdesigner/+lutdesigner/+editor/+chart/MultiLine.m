classdef(Sealed)MultiLine<lutdesigner.editor.chart.ViewModel

    properties(Constant,Access=private)
        IVDataColorMap=parula
    end

    properties(Access=private)
DataPlot
SelectionPlot
IV1Data
        IV2Label=''
IV2Data
IV2DataMin
IV2DataMax
    end

    methods
        function this=MultiLine(axes)
            this@lutdesigner.editor.chart.ViewModel(axes);
            axtoolbar(this.Axes,{'pan','zoomin','zoomout','restoreview'});
        end
    end

    methods(Access=protected)
        function plotImpl(this,iv1Data,iv2Data,dvData)
            this.IV1Data=iv1Data;
            this.IV2Data=iv2Data;
            this.IV2DataMin=min(iv2Data);
            this.IV2DataMax=max(iv2Data);
            hold(this.Axes,'on');
            this.DataPlot=arrayfun(@(i)this.plotRowImpl(iv1Data,this.IV2Data(i),dvData(i,:),['Data',num2str(i)]),1:numel(this.IV2Data));
            hold(this.Axes,'off');
        end

        function updateSelectionMarkImpl(this,coords)
            delete(this.SelectionPlot);
            if~isempty(coords)
                hold(this.Axes,'on');
                this.SelectionPlot=plot(this.Axes,...
                this.DataPlot(1).XData(coords(:,1)),...
                arrayfun(@(x,y)this.DataPlot(y).YData(x),coords(:,1),coords(:,2)),...
                'o','MarkerFaceColor','red','Tag','Selection');
                hold(this.Axes,'off');
            end
        end

        function updateIndependentVariableLabelImpl(this,index,label)
            if index==1
                xlabel(this.Axes,label,'Interpreter','None');
                if strlength(label)>0
                    for i=1:numel(this.DataPlot)
                        this.DataPlot(i).DataTipTemplate.DataTipRows(1).Label=label;
                    end
                else
                    for i=1:numel(this.DataPlot)
                        this.DataPlot(i).DataTipTemplate.DataTipRows(1).Label='X';
                    end
                end
            else
                this.IV2Label=label;
                if strlength(label)>0
                    for i=1:numel(this.DataPlot)
                        this.DataPlot(i).DataTipTemplate.DataTipRows(2).Label=createIV2DataTipLabel(this.IV2Label,this.IV2Data(i));
                    end
                else
                    for i=1:numel(this.DataPlot)
                        this.DataPlot(i).DataTipTemplate.DataTipRows(2).Label=createIV2DataTipLabel('C',this.IV2Data(i));
                    end
                end
            end
        end

        function updateDependentVariableLabelImpl(this,label)
            ylabel(this.Axes,label,'Interpreter','None');
            if strlength(label)>0
                for i=1:numel(this.DataPlot)
                    this.DataPlot(i).DataTipTemplate.DataTipRows(3).Label=label;
                end
            else
                for i=1:numel(this.DataPlot)
                    this.DataPlot(i).DataTipTemplate.DataTipRows(3).Label='Y';
                end
            end
        end

        function updateIndependentVariableDataImpl(this,index,data)
            if index==1
                this.IV1Data=data;
                if numel(this.DataPlot(1).XData)==numel(this.IV1Data)
                    for i=1:numel(this.DataPlot)
                        this.DataPlot(i).XData=this.IV1Data;
                    end
                end
            else
                this.IV2Data=data;
                this.IV2DataMin=min(data);
                this.IV2DataMax=max(data);
                if numel(this.DataPlot)==numel(this.IV2Data)
                    for i=1:numel(this.IV2Data)
                        this.DataPlot(i).Color=this.calculateColorForIV2Data(this.IV2Data(i));
                        if strlength(this.IV2Label)>0
                            this.DataPlot(i).DataTipTemplate.DataTipRows(2).Label=createIV2DataTipLabel(this.IV2Label,this.IV2Data(i));
                        else
                            this.DataPlot(i).DataTipTemplate.DataTipRows(2).Label=createIV2DataTipLabel('C',this.IV2Data(i));
                        end
                    end
                end
            end
        end

        function updateDependentVariableDataImpl(this,data)
            if numel(this.DataPlot)==size(data,1)&&numel(this.DataPlot(1).XData)==size(data,2)
                for i=1:size(data,1)
                    this.DataPlot(i).YData=data(i,:);
                end
            else
                this.plot(this.IV1Data,this.IV2Data,data);
            end
        end
    end

    methods(Access=private)
        function c=calculateColorForIV2Data(this,data)
            if this.IV2DataMax==this.IV2DataMin
                idx=round(size(this.IVDataColorMap,1)/2);
            else
                idx=1+round((size(this.IVDataColorMap,1)-1)*(data-this.IV2DataMin)/(this.IV2DataMax-this.IV2DataMin));
            end
            c=this.IVDataColorMap(idx,:);
        end

        function p=plotRowImpl(this,iv1Data,iv2Value,dvDataRow,tag)
            p=plot(this.Axes,iv1Data,dvDataRow,...
            'Marker','o','LineStyle','-',...
            'Color',this.calculateColorForIV2Data(iv2Value),...
            'Tag',tag);
            if strlength(this.IV2Label)>0
                iv2DataTipRow=dataTipTextRow(createIV2DataTipLabel(this.IV2Label,iv2Value),'');
            else
                iv2DataTipRow=dataTipTextRow(createIV2DataTipLabel('C',iv2Value),'');
            end
            p.DataTipTemplate.DataTipRows=[
            p.DataTipTemplate.DataTipRows(1)
iv2DataTipRow
            p.DataTipTemplate.DataTipRows(2)
            ];
        end
    end
end

function label=createIV2DataTipLabel(label,value)
    label=[label,': ',num2str(value)];
end
