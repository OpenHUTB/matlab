classdef Attenuator<rf.internal.apps.budget.Element




    properties
Attenuation
Zin
Zout
NumPorts
Terminals
    end

    methods(Hidden)
        function out=autoforward(obj)
            out=attenuator;
            out.Name=matlab.lang.makeValidName(obj.Name);
            out.Attenuation=obj.Attenuation;
            out.Zin=obj.Zin;
            out.Zout=obj.Zout;
            out.NumPorts=obj.NumPorts;
            out.Terminals=obj.Terminals;
        end
    end
end
