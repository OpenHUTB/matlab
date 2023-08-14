classdef FromCircuit<rf.internal.groupdelay.Calculator

    properties(Access=protected)
Impedance
    end


    properties(Constant,Access=protected)
        MinNumArguments=2
        SourceClass='circuit'
    end
    properties(Dependent,Access=protected)
NumPorts
    end


    methods
        function obj=FromCircuit(srcobj)
            obj@rf.internal.groupdelay.Calculator(srcobj)
        end
    end


    methods(Access=protected)
        function preParseCheck(obj)%#ok<MANU>

        end

        function parseInputs(obj,gdfreq,varargin)

            rf.internal.checkfreq(gdfreq)
            obj.Frequencies=gdfreq(:);


            numports=obj.NumPorts;
            p=inputParser;
            addOptional(p,'I',1+(numports==2),...
            @(x)validateattributes(x,{'numeric'},...
            {'nonempty','real','scalar','integer','positive',...
            '<=',numports},'groupdelay','I'))
            addOptional(p,'J',1,@(x)validateattributes(x,{'numeric'},...
            {'nonempty','real','scalar','integer','positive',...
            '<=',numports},'groupdelay','J'))
            addParameter(p,'Aperture',obj.defaultAperture(gdfreq),...
            @(x)validateattributes(x,{'numeric'},...
            {'nonempty','real','positive','nonnan','finite',...
            'vector'},'groupdelay','Aperture'))
            addParameter(p,'Impedance',50,@rf.internal.checkz0)
            parse(p,varargin{:})


            ijdef=[true;true];
            ijdef(1)=any(strcmp(p.UsingDefaults,'I'));
            ijdef(2)=any(strcmp(p.UsingDefaults,'J'));
            obj.AreIJUsingDefaults=ijdef;


            obj.FirstIndex=p.Results.I;
            obj.SecondIndex=p.Results.J;
            obj.Aperture=p.Results.Aperture(:);
            obj.Impedance=p.Results.Impedance;
        end

        function gd=calculate(obj)
            gd=standardGroupDelayCalculation(obj);
        end

        function[leftfreq,rghtfreq]=getLeftAndRightFrequencies(obj)
            gdfreq=obj.Frequencies;
            aper=obj.Aperture;

            leftfreq=max(gdfreq-aper/2,0);
            rghtfreq=gdfreq+aper/2;
        end

        function angIJ=getSijAngle(obj,freq)
            S=sparameters(obj.SourceObject,freq,obj.Impedance);
            I=obj.FirstIndex;
            J=obj.SecondIndex;
            angIJ=unwrap(angle(rfparam(S,I,J)));
        end
    end


    methods
        function np=get.NumPorts(obj)
            ckt=obj.SourceObject;
            np=ckt.NumPorts;
        end
    end

end