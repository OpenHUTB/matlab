classdef(Abstract)SimulationModeHandler<handle





    properties(SetAccess=protected,GetAccess=public)
TopModel
        ModelMode=fixed.internal.simulationmodehandler.Model.empty;
    end

    methods
        function this=SimulationModeHandler(topModel)
            if nargin<1
                [msg,identifier]=fxptui.message('incorrectInputArgsModel');
                e=MException(identifier,msg);
                throwAsCaller(e);
            end

            this.TopModel=topModel;
            this.setModelMode();
        end

        function delete(this)
            this.ModelMode=fixed.internal.simulationmodehandler.Model.empty;
        end

    end

    methods(Access=protected)
        setModelMode(this);
    end
end

