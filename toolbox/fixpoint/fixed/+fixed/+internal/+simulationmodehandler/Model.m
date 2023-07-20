classdef(Abstract)Model<handle&matlab.mixin.Heterogeneous




    properties(SetAccess=protected,GetAccess=public)
Name

OriginalSimulationMode
CurrentSimulationMode

    end

    methods


        switchSimulationMode(this,value);

        function restoreSimulationMode(this)

            this.switchSimulationMode(this.OriginalSimulationMode);
        end

    end

    methods(Access={?fixed.internal.simulationmodehandler.Model,?ModeHandlerTestCase})


        initialize(this);

        function setOriginalSimulationMode(this)



            this.OriginalSimulationMode=get_param(this.Name,'SimulationMode');
            this.CurrentSimulationMode=this.OriginalSimulationMode;
        end

    end
end

