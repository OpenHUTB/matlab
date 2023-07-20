classdef ShuntRLC<rf.internal.apps.budget.Element




    properties
R
L
C
NumPorts
Terminals
    end

    methods(Hidden)
        function out=autoforward(obj)
            out=shuntrlc;
            out.Name=matlab.lang.makeValidName(obj.Name);
            out.R=obj.R;
            out.L=obj.L;
            out.C=obj.C;
            out.NumPorts=obj.NumPorts;
            out.Terminals=obj.Terminals;
        end
    end
end
