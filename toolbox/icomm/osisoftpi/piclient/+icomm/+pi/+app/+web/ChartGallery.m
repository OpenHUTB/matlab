classdef ChartGallery<icomm.pi.app.Container






    properties(GetAccess=public,Constant)
        Height=icomm.pi.app.web.ChartGallery.IconHeight+20
    end

    properties(GetAccess=public,SetAccess=public,Dependent)
        SelectedChartType(1,1)string
    end

    properties(GetAccess=public,SetAccess=private)
        ChartButtons matlab.ui.control.StateButton
    end

    properties(GetAccess=private,Constant)
        IconHeight=46
        IconWidth=60
        ChartTypeMap=[...
        "Timeseries",fullfile(icomm.pi.internal.piclientroot,'icons','plottype-plot.gif');...
        "PlotMatrix",fullfile(icomm.pi.internal.piclientroot,'icons','plottype-plotmatrix.gif');...
        ]
    end

    events(ListenAccess=public,NotifyAccess=private)
ChartTypeChanged
    end

    methods

        function value=get.SelectedChartType(this)
            value=this.ChartButtons([this.ChartButtons.Value]).Tag;
        end

        function set.SelectedChartType(this,value)
            tag=validatestring(value,string({this.ChartButtons.Tag}));
            chartIndex={this.ChartButtons.Tag}==tag;
            [this.ChartButtons.Value]=deal(false);
            this.ChartButtons(chartIndex).Value=true;
            this.notify('ChartTypeChanged');
        end

    end

    methods(Access=public)

        function this=ChartGallery(varargin)
            box=uigridlayout(...
            'Parent',[],...
            'Scrollable',true);
            this@icomm.pi.app.Container(box,varargin{:});
        end

    end

    methods(Access=protected)

        function initialize(this)

            numCharts=size(this.ChartTypeMap,1);
            this.UiContainer.ColumnWidth=repmat({this.IconWidth},1,numCharts);
            this.UiContainer.RowHeight={this.IconHeight};
            for chartIndex=1:numCharts
                this.ChartButtons(end+1)=uibutton('state',...
                'Tag',this.ChartTypeMap{chartIndex,1},...
                'Parent',this.UiContainer,...
                'Text','',...
                'Value',chartIndex==1,...
                'Icon',this.ChartTypeMap{chartIndex,2},...
                'ValueChangedFcn',@this.onButtonPushed);
            end
        end

    end

    methods(Access=private)

        function onButtonPushed(this,button,~)

            if~button.Value
                button.Value=true;
                return
            end

            this.SelectedChartType=button.Tag;
        end

    end

end