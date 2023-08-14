classdef Generic<rf.internal.apps.budget.Amplifier
    methods(Hidden)
        function out=autoforward(obj)
            out=rfelement;
            out.Name=matlab.lang.makeValidName(obj.Name);
            out.Gain=obj.Gain;
            out.NF=obj.NoiseFigure;
            out.OIP3=obj.OIP3;
            out.Zin=obj.ZInput;
            out.Zout=obj.ZOutput;
        end
    end
end
