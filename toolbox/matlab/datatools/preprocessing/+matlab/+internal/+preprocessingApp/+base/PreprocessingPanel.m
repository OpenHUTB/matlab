classdef PreprocessingPanel<matlab.ui.internal.FigurePanel...
    &matlab.internal.preprocessingApp.base.UpdateInteractable




    methods
        function this=PreprocessingPanel(varargin)
            this@matlab.ui.internal.FigurePanel(varargin{:});

            panelWidth=round((1/4)*this.ParentSize(3));
            this.PreferredWidth=panelWidth;
        end
    end
end

