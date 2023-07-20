classdef View<evolutions.internal.ui.tools.ToolstripPanel




    properties(Constant)
        Name char=getString(message('evolutions:ui:FileViewerTitle'));
        TagName char='fileViewer';
        GridRows={'1x'};
        GridColumns={'1x'};

        PanelFontSize(1,1)double{mustBePositive,mustBeFinite}=12;
        PreviewFilePath=fullfile(matlabroot,'toolbox','evolutions',...
        'evolutions','+evolutions','+internal','resources','layout',...
        'NoSelection.html');
    end

    properties(Access=protected)
AppView
    end

    properties
Html
    end

    methods
        function this=View(parent)
            this@evolutions.internal.ui.tools.ToolstripPanel;
            this.UIGrid.Padding=[0,0,0,0];
            this.AppView=parent;
        end

        function update(this,html)
            if nargin<2||isempty(html)
                html=this.PreviewFilePath;
            end
            drawnow;
            this.Html.HTMLSource=html;
        end
    end

    methods(Access=protected)
        function createComponents(this)
            this.Html=uihtml(this.UIGrid);
        end

        function layout(~)

        end
    end
end
