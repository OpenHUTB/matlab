classdef WebView<matlab.ui.internal.FigureDocument





    properties(Constant)
        Name char=getString(message('evolutions:ui:WebViewReport'));
        AppDelay(1,1)double{mustBeNonnegative,mustBeFinite}=2;
        Margin(1,1)double{mustBeNonnegative,mustBeFinite}=30;
    end


    properties

ReportView
    end

    properties(Access=protected)
GridLayout
        GridRows={'1x'};
        GridColumns={'1x'};
    end

    properties(Constant)
        TotalSummaryViews(1,1)double{mustBePositive,mustBeFinite}=1;
    end

    methods
        function this=WebView(parent)
            parentDocGroup=getDocGroup(parent);
            configuration.Title=getString(message('evolutions:ui:WebViewReport'));
            configuration.DocumentGroupTag=parentDocGroup.Tag;
            configuration.Closable=1;
            this@matlab.ui.internal.FigureDocument(configuration);
            this.GridLayout=uigridlayout(this.Figure,'RowHeight',this.GridRows,...
            'ColumnWidth',this.GridColumns);

            add(getToolGroup(parent),this);
        end

    end

    methods
        function setTitle(this,val)
            if isempty(val)
                set(this.FigureHandle,'Name',this.Name);
            else
                set(this.FigureHandle,'Name',val);
            end
        end
    end

    methods
        function createDocumentComponents(this,path)
            this.ReportView=uihtml(this.GridLayout);
            this.ReportView.HTMLSource=path;
        end

        function layoutDocument(this)
            this.ReportView.Layout.Row=1;
            this.ReportView.Layout.Column=1;
        end

        function setUrl(this,url)
            this.ReportView.HTMLSource=url;
        end

    end
end
