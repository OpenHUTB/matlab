classdef MetricEngineManager<handle





    properties(Access=private)
        Engine;
    end

    methods
        function setEngine(this,e)
            this.clear();
            this.Engine=e;
        end

        function clear(this)
            if isa(this.Engine,'slmetric.Engine')
                this.Engine.delete();
                this.Engine=[];
            end
        end

        function e=getEngine(this)
            e=this.Engine;
        end

        function delete(this)
            this.clear();
        end
    end

    methods(Access=private)

        function this=MetricEngineManager()

        end
    end


    methods(Static)
        function mem=getInstance()
            persistent manager;

            if isempty(manager)
                manager=ModelAdvisor.check.metriccheck.MetricEngineManager();
            end

            mem=manager;
        end
    end

end

