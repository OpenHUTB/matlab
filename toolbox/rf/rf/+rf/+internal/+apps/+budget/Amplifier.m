classdef Amplifier<rf.internal.apps.budget.Element




    properties
Gain
NoiseFigure
OIP3
ZInput
ZOutput
    end

    methods(Hidden)
        function out=autoforward(obj)
            out=amplifier;
            out.Name=matlab.lang.makeValidName(obj.Name);
            out.Gain=obj.Gain;
            out.NF=obj.NoiseFigure;
            out.OIP3=obj.OIP3;
            out.Zin=obj.ZInput;
            out.Zout=obj.ZOutput;
        end
    end
end
