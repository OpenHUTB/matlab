classdef ScenarioCanvasPalette<driving.internal.scenarioApp.ScenarioPalette





    properties(Hidden)
FitToViewButton
    end

    methods(Access=protected)

        function createAxesPushButtons(this,tb,zoomInCallback,zoomOutCallback,fitToViewCallback)
            this.FitToViewButton=this.createFitToViewBtn(tb,fitToViewCallback);
            this.ZoomOutButton=this.createZoomOutBtn(tb,zoomOutCallback);
            this.ZoomInButton=this.createZoomInBtn(tb,zoomInCallback);
        end

    end

    methods(Static,Access=protected)
        function btn=createFitToViewBtn(tb,callback)
            btn=axtoolbarbtn(tb,'push');
            btn.ButtonPushedFcn=callback;
            btn.Icon='restoreview';
            btn.Tooltip=getString(message('driving:scenarioApp:CanvasFitToViewTooltip'));
            btn.Tag='btnFitToView';
        end
    end

end