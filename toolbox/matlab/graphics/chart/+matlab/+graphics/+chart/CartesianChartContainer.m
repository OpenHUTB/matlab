classdef(AllowedSubclasses={?matlab.graphics.chart.ParallelCoordinatesPlot,...
    ?SineWaveChartCartesian,...
    ?MockCartesianChartContainer})...
    CartesianChartContainer<matlab.graphics.chart.internal.ChartBaseProxy






    properties(Dependent,Hidden,Access={?ChartUnitTestFriend,...
        ?matlab.graphics.chart.CartesianChartContainer})


        Axes matlab.graphics.axis.AbstractAxes
    end

    methods(Sealed,Access={?matlab.graphics.chart.Chart,?matlab.graphics.chart.internal.PositionalbleChartWithAxes})
        function tl=getLayout(~,varargin)
            tl=matlab.graphics.layout.TiledChartLayout.empty;
        end
    end

    methods(Access=protected)
        function ax=createAxes(obj)
            ax=matlab.graphics.axis.Axes();
            obj.addNode(ax);
        end

        function obj=CartesianChartContainer(varargin)
            obj=obj@matlab.graphics.chart.internal.ChartBaseProxy(varargin{:});
            obj=obj.doSetupInternal;
        end

        function obj=doSetupInternal(obj)

            obj.SetupUpdateBlock=true;


            obj.Type_I=lower(class(obj));

            ax=obj.getAxes();


            bh=hggetbehavior(ax,'brush');
            bh.Enable=false;
            bh.Serialize=false;


            nextplot=ax.NextPlot;
            ax.NextPlot='add';


            if obj.useGcaBehavior
                fparent=ancestor(obj,'matlab.ui.Figure');
                cax=fparent.CurrentAxes;
                fparent.CurrentAxes=ax;
            end

            obj.setup;

            if obj.useGcaBehavior
                fparent.CurrentAxes=cax;
            end

            ax.NextPlot=nextplot;


            if~isempty(obj.CtorArgs(:))
                matlab.graphics.chart.internal.ctorHelper(obj,obj.CtorArgs);
            end


            if obj.useGcaBehavior
                fig=ancestor(obj,'figure');
                if isscalar(fig)
                    fig.CurrentAxes=obj;
                end
            end

            obj.SetupUpdateBlock=false;

            MarkDirty(obj,'chart');

            if~isa(obj,'matlab.graphics.chart.internal.UserChartUpdateShim')

                enableDefaultInteractivity(ax);
            end

        end

        function val=getPositionManager(~)
            val=gobjects(0);
        end
    end

    properties(Hidden,AffectsObject,NonCopyable)
        GridVisible matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
    end

    properties(Hidden,Dependent)
        XLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        YLabel matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
    end

    properties(Hidden,Dependent)
DimensionNames
        XGrid matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
        YGrid matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
        XMinorGrid matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
        YMinorGrid matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
    end

    properties(Hidden)
        XLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
        YLabel_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
    end

    methods
        function ax=get.Axes(hObj)
            ax=hObj.getAxes();
        end


        function set.GridVisible(obj,vis)
            ax=obj.getAxes;
            if~isempty(ax)
                grid(ax,char(vis));
            end
            obj.GridVisible=vis;
        end

        function v=get.GridVisible(obj)
            v=obj.GridVisible;
        end


        function set.XLabel(obj,label)
            obj.XLabel_I=label;
        end

        function s=get.XLabel(obj)
            s=obj.XLabel_I;
        end

        function set.XLabel_I(obj,str)
            ax=obj.getAxes;
            if isvalid(ax.XLabel)
                labelh=ax.XLabel;
                labelh.String_I=str;
                labelh.StringMode='manual';
            end
            obj.XLabel_I=str;
        end

        function s=get.XLabel_I(obj)
            ax=obj.getAxes;
            if isvalid(ax.XLabel)
                s=ax.XLabel.String_I;
            else
                s=obj.XLabel_I;
            end
        end

        function set.YLabel(obj,label)
            obj.YLabel_I=label;
        end

        function s=get.YLabel(obj)
            s=obj.YLabel_I;
        end

        function set.YLabel_I(obj,str)
            ax=obj.getAxes;
            if isvalid(ax.YLabel)
                labelh=ax.YLabel;
                labelh.String_I=str;
                labelh.StringMode='manual';
            end
            obj.YLabel_I=str;
        end

        function s=get.YLabel_I(obj)
            ax=obj.getAxes;
            if isvalid(ax.YLabel)
                s=ax.YLabel.String_I;
            else
                s=obj.YLabel_I;
            end
        end

        function v=get.DimensionNames(obj)
            ax=obj.getAxes;
            v=ax.DimensionNames;
        end

        function set.DimensionNames(obj,v)
            ax=obj.getAxes;
            ax.DimensionNames=v;
        end

        function v=get.XGrid(obj)
            ax=obj.getAxes;
            v=ax.XGrid;
        end

        function set.XGrid(obj,v)
            ax=obj.getAxes;
            ax.XGrid=v;
        end

        function v=get.YGrid(obj)
            ax=obj.getAxes;
            v=ax.YGrid;
        end

        function set.YGrid(obj,v)
            ax=obj.getAxes;
            ax.YGrid=v;
        end

        function v=get.XMinorGrid(obj)
            ax=obj.getAxes;
            v=ax.XMinorGrid;
        end

        function set.XMinorGrid(obj,v)
            ax=obj.getAxes;
            ax.XMinorGrid=v;
        end

        function v=get.YMinorGrid(obj)
            ax=obj.getAxes;
            v=ax.YMinorGrid;
        end

        function set.YMinorGrid(obj,v)
            ax=obj.getAxes;
            ax.YMinorGrid=v;
        end
    end

    properties(Dependent)
        Title matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
    end

    properties(Hidden)
        Title_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString=''
    end

    methods
        function set.Title(obj,str)
            obj.Title_I=str;
        end

        function str=get.Title(obj)
            str=obj.Title_I;
        end

        function set.Title_I(obj,str)
            if isvalid(obj.Axes.Title)
                titleh=obj.Axes.Title;
                titleh.String_I=str;
                titleh.StringMode='manual';
            end
            obj.Title_I=str;
        end

        function v=hasZProperties(obj)
            v=false;
        end
    end
end
