classdef Zoom<matlabshared.application.Zoom

    methods(Hidden)

        function initializeFloatingPalette(this,fig,ax)
            this.FloatingPalette=driving.internal.scenarioApp.ScenarioPalette(fig,ax,...
            @(~,~)zoomIn(this),@(~,~)zoomOut(this));
        end
    end
end


