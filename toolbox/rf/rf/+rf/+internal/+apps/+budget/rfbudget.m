classdef rfbudget





    properties
InputFrequency
AvailableInputPower
SignalBandwidth
Elements
    end

    properties(SetAccess=private)
StageName
StageInputFrequency
StageAvailableGain
StageNF
StageOIP3
StagePowerGain
StageIIP3
StageS
StageABCD
StageCA
CascadeOutputFrequency
CascadeOutputPower
CascadeTransducerGain
CascadeNF
CascadeOIP3
CascadePowerGain
CascadeIIP3
CascadeSNR
CascadeS
CascadeABCD
CascadeCA
    end

    properties(Constant,Access=private)
        Version=1.0
        kT=290*rf.physconst('Boltzmann')
    end

    methods

        function obj=rfbudget(elements,inputFreq,bandwidth,inputPwr)


            narginchk(4,4)
            obj.Elements=elements;
            obj.InputFrequency=inputFreq;
            obj.SignalBandwidth=bandwidth;
            obj.AvailableInputPower=inputPwr;
        end

        function obj=set.Elements(obj,val)
            validateattributes(val,{'rf.internal.apps.budget.Element'},...
            {'nonempty','vector'},'','Elements')
            obj.Elements=val;
        end

        function obj=set.InputFrequency(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','nonnegative'},'',...
            'InputFrequency')
            obj.InputFrequency=val;
        end

        function obj=set.AvailableInputPower(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real'},'',...
            'AvailableInputPower')
            obj.AvailableInputPower=val;
        end

        function obj=set.SignalBandwidth(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},'',...
            'SignalBandwidth')
            obj.SignalBandwidth=val;
        end
    end

    methods

        function out=autoforward(obj)




            out=rfbudget;
            out.Elements=obj.Elements;
            out.InputFrequency=obj.InputFrequency;
            out.SignalBandwidth=obj.SignalBandwidth;
            out.AvailableInputPower=obj.AvailableInputPower;
        end
    end
end


