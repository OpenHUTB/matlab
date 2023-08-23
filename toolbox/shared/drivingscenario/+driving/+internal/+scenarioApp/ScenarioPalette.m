classdef ScenarioPalette<handle

    properties
FigureHandle
AxesHandles
    end


    properties(Hidden)
ZoomInButton
ZoomOutButton
    end


    methods
        function this=ScenarioPalette(figH,axesH,varargin)

            narginchk(4,inf);
            if isempty(figH)||~ishandle(figH)||...
                ~strcmp(get(figH,'Type'),'figure')
                error(message('Controllib:gui:PlotTabErrInput'));
            else
                this.FigureHandle=figH;
                this.AxesHandles=axesH;
                this.createPushButtons(varargin{:});
            end
        end
    end


    methods(Access=protected)

        function createPushButtons(this,varargin)
            for i=1:numel(this.AxesHandles)
                tb=axtoolbar(this.AxesHandles(i));
                tb.Visible='on';
                this.createAxesPushButtons(tb,varargin{:});
            end
        end


        function createAxesPushButtons(this,tb,zoomInCallback,zoomOutCallback)
            this.ZoomOutButton=this.createZoomOutBtn(tb,zoomOutCallback);
            this.ZoomInButton=this.createZoomInBtn(tb,zoomInCallback);
        end
    end


    methods(Static,Access=protected)
        function btn=createZoomOutBtn(tb,callback)
            btn=axtoolbarbtn(tb,'push');
            btn.ButtonPushedFcn=callback;
            btn.Icon=fullfile(matlab.graphics.chart.internal.maps.mapdatadir,'icons','zoomout.png');
            btn.Tooltip=getString(message('Controllib:gui:PlotTabZoomZoomOut'));
            btn.Tag='btnZoomOut';
        end


        function btn=createZoomInBtn(tb,callback)
            btn=axtoolbarbtn(tb,'push');
            btn.ButtonPushedFcn=callback;
            btn.Icon=fullfile(matlab.graphics.chart.internal.maps.mapdatadir,'icons','zoomin.png');
            btn.Tooltip=getString(message('Controllib:gui:PlotTabZoomZoomIn'));
            btn.Tag='btnZoomIn';
        end
    end
end

