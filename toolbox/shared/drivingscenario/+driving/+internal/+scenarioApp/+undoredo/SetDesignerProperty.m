classdef SetDesignerProperty<matlabshared.application.undoredo.SetProperty

    methods
        function this=SetDesignerProperty(varargin)
            this@matlabshared.application.undoredo.SetProperty(varargin{:});
        end

        function execute(this)
            execute@matlabshared.application.undoredo.SetProperty(this);
            updateScenario(this);
        end

        function undo(this)
            undo@matlabshared.application.undoredo.SetProperty(this);



            updateScenario(this);
        end
    end

    methods(Access=protected)
        function updateScenario(this)

        end
    end
end


