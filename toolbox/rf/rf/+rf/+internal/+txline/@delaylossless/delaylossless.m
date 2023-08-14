classdef delaylossless<rf.internal.txline.basetxline



    properties

Z0

TimeDelay
    end

    properties(Access=protected,Constant)

        DefaultZ0=50;

        DefaultTimeDelay=1e-12;

        DefaultName='DelayLossless';
        HeaderDescription='DelayLossless'
    end

    methods
        function obj=delaylossless(varargin)
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
            addParameter(p,'TimeDelay',obj.DefaultTimeDelay);
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Z0=p.Results.Z0;
            obj.TimeDelay=p.Results.TimeDelay;
        end
    end

    methods

        function set.Z0(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','nonnan','finite','real','positive','scalar'},...
            'DelayLossless','Z0')
            obj.Z0=value;
        end

        function set.TimeDelay(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
            'DelayLossless','TimeDelay')
            obj.TimeDelay=value;
        end

        function val=get.Z0(obj)
            val=obj.Z0;
        end

        function val=get.TimeDelay(obj)
            val=obj.TimeDelay;
        end
    end

    methods(Hidden)
        function[y,Z]=calckl(obj,freq)


            alphadB=0;

            delay=obj.TimeDelay;

            Z=obj.Z0;


            beta=360*freq*delay;

            set(obj,'Loss',alphadB)





            y=cosd(beta)-sind(beta)*1i;
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.Z0=obj.Z0;
            plist1.TimeDelay=obj.TimeDelay;
        end
    end
end