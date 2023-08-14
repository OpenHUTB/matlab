classdef ModelBlock<fixed.internal.simulationmodehandler.Model




    methods

        function this=ModelBlock(name)
            this.Name=name;
            this.initialize();
        end

        function switchSimulationMode(this,value)




            if~strcmpi(this.CurrentSimulationMode,value)
                try
                    set_param(this.Name,'SimulationMode',value);
                    this.CurrentSimulationMode=value;
                catch e %#ok<NASGU>

                end
            end
        end

    end

    methods(Access={?fixed.internal.simulationmodehandler.Model,?ModeHandlerTestCase})

        function initialize(this)

            this.setOriginalSimulationMode();
        end

    end
end

