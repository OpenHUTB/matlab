classdef electricallength<rf.internal.txline.basetxline



    properties

Z0

ReferenceFrequency
    end

    properties(Access=protected,Constant)

        DefaultZ0=50;

        DefaultElectricalLength=pi/4;

        DefaultReferenceFrequency=1e9;

        DefaultName='ElectricalLength';
        HeaderDescription='ElectricalLength'
    end

    methods
        function obj=electricallength(varargin)
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
            addParameter(p,'LineLength',obj.DefaultElectricalLength);
            addParameter(p,'ReferenceFrequency',obj.DefaultReferenceFrequency);
            addParameter(p,'Termination','NotApplicable');
            addParameter(p,'StubMode','NotAStub');
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Z0=p.Results.Z0;
            obj.LineLength=p.Results.LineLength;
            obj.ReferenceFrequency=p.Results.ReferenceFrequency;
            obj.Termination=p.Results.Termination;
            obj.StubMode=p.Results.StubMode;
        end
    end

    methods

        function set.Z0(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','nonnan','finite','real','positive','scalar'},...
            'ElectricalLength','Z0')
            obj.Z0=value;
        end

        function set.ReferenceFrequency(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','nonnan','finite','real','positive','scalar'},...
            'ElectricalLength','ReferenceFrequency')
            obj.ReferenceFrequency=value;
        end

        function val=get.Z0(obj)
            val=obj.Z0;
        end

        function val=get.ReferenceFrequency(obj)
            val=obj.ReferenceFrequency;
        end
    end

    methods(Hidden)
        function[y,Z]=calckl(obj,freq)


            alphadB=0;

            el=obj.LineLength;
            refFreq=obj.ReferenceFrequency;

            Z=obj.Z0;


            beta=freq*el/refFreq;

            set(obj,'Loss',alphadB)




            y=cos(beta)-sin(beta)*1i;
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.Z0=obj.Z0;
            plist1.LineLength=obj.LineLength;
            plist1.ReferenceFrequency=obj.ReferenceFrequency;
            plist1.Termination=obj.Termination;
            plist1.StubMode=obj.StubMode;
        end
    end
end