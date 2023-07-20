classdef delaylossy<rf.internal.txline.basetxline




    properties

Z0

TimeDelay

Resistance
    end

    properties(Access=protected,Constant)

        DefaultZ0=50;

        DefaultTimeDelay=4.7e-9;

        DefaultResistance=0.3;

        DefaultName='DelayLossy';
        HeaderDescription='DelayLossy'
    end

    methods
        function obj=delaylossy(varargin)
            parserObj=makeParser(obj);
            parse(parserObj,varargin{:});
            setProperties(obj,parserObj)
        end
    end

    methods(Access=protected,Hidden)
        function p=makeParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',obj.DefaultName);
            addParameter(p,'Z0',obj.DefaultZ0);
            addParameter(p,'LineLength',0.0100);
            addParameter(p,'TimeDelay',obj.DefaultTimeDelay);
            addParameter(p,'Resistance',obj.DefaultResistance);
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Z0=p.Results.Z0;
            obj.LineLength=p.Results.LineLength;
            obj.TimeDelay=p.Results.TimeDelay;
            obj.Resistance=p.Results.Resistance;
        end
    end

    methods
        function set.Z0(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','nonnan','finite','real','positive','scalar'},...
            'DelayLossy','Z0')
            obj.Z0=value;
        end

        function set.TimeDelay(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
            'DelayLossy','TimeDelay')
            obj.TimeDelay=value;
        end

        function set.Resistance(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','nonnan','finite','real','positive','scalar'},...
            'DelayLossy','Resistance')
            obj.Resistance=value;
        end

        function val=get.Z0(obj)
            val=obj.Z0;
        end

        function val=get.TimeDelay(obj)
            val=obj.TimeDelay;
        end

        function val=get.Resistance(obj)
            val=obj.Resistance;
        end
    end

    methods(Hidden)
        function[y,Z]=calckl(obj,freq)


            Z=obj.Z0;

            len=obj.LineLength;

            td=obj.TimeDelay;

            R=obj.Resistance;


            beta=360*freq*td;

            R1=(len*R);

            alpha=abs(R1/(2*Z));



            loss=20*log10(exp(alpha));
            set(obj,'Loss',loss)



            y=exp(-alpha).*cosd(beta)-sind(beta)*1i;
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.Z0=obj.Z0;
            plist1.LineLength=obj.LineLength;
            plist1.TimeDelay=obj.TimeDelay;
            plist1.Resistance=obj.Resistance;
        end
    end
end