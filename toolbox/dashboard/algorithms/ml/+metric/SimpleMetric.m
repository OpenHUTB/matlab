classdef SimpleMetric<metric.DirectMetric




    methods
        function obj=SimpleMetric()

        end
    end

    methods(Abstract)



        result=algorithm(obj,resultfactory,artifacts);
    end

    methods(Hidden)

        function value=get(obj,propName)
            value=get@metric.Algorithm(obj,propName);
        end
    end
end

