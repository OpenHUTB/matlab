classdef ChartTable<metric.dashboard.widgets.Widget&metric.dashboard.widgets.WidgetContainer&metric.dashboard.CustomProps
    properties(Constant,Hidden)
        HeightLimit=80;
        TooltipLocations=cell.empty(1,0);
        CustomProperties={'LegendMode','ShowTableHeader'};
        LegendModeEnum=struct('Category','category','Range','range');
    end

    properties(Dependent)
RowLabels
ColumnWidths
RowHeights
    end

    properties(Access=protected)
Configuration
    end

    methods

        function set.RowLabels(this,labels)
            try
                labels=string(labels);
                this.MF0Widget.RowLabels.clear;
                for i=1:numel(labels)
                    this.MF0Widget.RowLabels.add(labels(i));
                end
            catch ME
                error(message('dashboard:uidatamodel:WrongInputType',...
                message('dashboard:uidatamodel:StringOrCell').getString()));
            end
        end

        function labels=get.RowLabels(this)
            labels=this.MF0Widget.RowLabels.toArray;
            if isempty(labels)
                labels={};
            end
        end


        function set.ColumnWidths(this,widths)
            try
                widths=string(widths);
                this.MF0Widget.ColumnWidths.clear;
                for i=1:numel(widths)
                    this.MF0Widget.ColumnWidths.add(widths(i));
                end
            catch ME
                error(message('dashboard:uidatamodel:WrongInputType',...
                message('dashboard:uidatamodel:StringOrCell').getString()));
            end
        end

        function widths=get.ColumnWidths(this)
            widths=this.MF0Widget.ColumnWidths.toArray;
            if isempty(widths)
                widths={};
            end
        end



        function widths=get.RowHeights(this)
            widths=this.MF0Widget.RowHeights.toArray;
        end

        function set.RowHeights(this,heights)
            if~all((heights>=0))||...
                ~all(floor(heights)==heights)
                error(message('dashboard:uidatamodel:WrongWidths'));
            end
            this.MF0Widget.RowHeights.clear;
            for i=1:numel(heights)
                this.MF0Widget.RowHeights.add(uint32(heights(i)));
            end
        end

        function verify(this)
            if(numel(this.RowLabels)*numel(this.Labels))~=numel(this.Widgets)
                error(message('dashboard:uidatamodel:ChartTableNotEnoughWidgets'));
            end
            w=this.Widgets;
            for i=1:numel(w)
                w(i).verify();
            end
        end
    end

    methods(Access=protected)
        function mf0Obj=getMF0Object(this)
            mf0Obj=this.MF0Widget;
        end
    end

    methods(Access={?metric.dashboard.WidgetFactory,?metric.dashboard.widgets.ChartTable})
        function obj=ChartTable(element,config)
            obj@metric.dashboard.widgets.Widget(element);
            obj@metric.dashboard.CustomProps(element.CustomProperties,mf.zero.getModel(element));
            if isempty(obj.LegendMode)
                obj.LegendMode=obj.LegendModeEnum.Category;
            end
            if isempty(obj.ShowTableHeader)
                obj.ShowTableHeader='on';
            end
            obj.Configuration=config;
            obj.MF0Widget.ContainsWidgets=true;
        end
    end

end

