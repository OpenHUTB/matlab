classdef Antenna<rf.internal.apps.budget.Element




    properties
Gain
Zin
    end

    methods(Hidden)
        function out=autoforward(obj)
            out=rfantenna;
            out.Name=matlab.lang.makeValidName(obj.Name);
            out.Gain=obj.Gain;
            out.Zin=obj.Zin;
        end
    end
end
