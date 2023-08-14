classdef Modulator<rf.internal.apps.budget.Amplifier




    properties
LOFrequency
ConverterType
    end

    properties(Hidden)
InputFrequency
    end

    methods(Hidden)
        function out=autoforward(obj)
            out=modulator;
            out.Name=matlab.lang.makeValidName(obj.Name);
            out.Gain=obj.Gain;
            out.NF=obj.NoiseFigure;
            out.OIP3=obj.OIP3;
            out.LO=obj.LOFrequency;
            out.ConverterType=obj.ConverterType;
            out.Zin=obj.ZInput;
            out.Zout=obj.ZOutput;
        end
    end
end
