classdef twowire<rf.internal.txline.basetxline




    properties(Dependent)

Radius

Separation
    end

    properties

MuR

EpsilonR

LossTangent

SigmaCond
    end

    properties(Constant,Access=protected)

        HeaderDescription='TwoWire'
        DefaultName='TwoWire';
    end

    properties(Hidden,Access=protected)
privateRadius
privateSeparation
    end

    properties(Access=protected,Constant)

        DefaultRadius=0.00067;

        DefaultSeparation=0.00162;

        DefaultMuR=1;

        DefaultEpsilonR=2.3;

        DefaultLossTangent=0;

        DefaultSigmaCond=inf;
    end

    methods
        function obj=twowire(varargin)
            parserObj=makeParser(obj);
            parse(parserObj,varargin{:});
            setProperties(obj,parserObj)
            checkproperty(obj);
            checkStubMode(obj);
        end
    end

    methods(Access=protected,Hidden)
        function p=makeParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',obj.DefaultName);
            addParameter(p,'Radius',obj.DefaultRadius);
            addParameter(p,'Separation',obj.DefaultSeparation);
            addParameter(p,'MuR',obj.DefaultMuR);
            addParameter(p,'EpsilonR',obj.DefaultEpsilonR);
            addParameter(p,'LossTangent',obj.DefaultLossTangent);
            addParameter(p,'SigmaCond',obj.DefaultSigmaCond);
            addParameter(p,'LineLength',0.0100);
            addParameter(p,'Termination','NotApplicable');
            addParameter(p,'StubMode','NotAStub');
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Radius=p.Results.Radius;
            obj.Separation=p.Results.Separation;
            obj.MuR=p.Results.MuR;
            obj.EpsilonR=p.Results.EpsilonR;
            obj.LossTangent=p.Results.LossTangent;
            obj.SigmaCond=p.Results.SigmaCond;
            obj.LineLength=p.Results.LineLength;
            obj.Termination=p.Results.Termination;
            obj.StubMode=p.Results.StubMode;
        end
    end

    methods
        function set.Radius(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'twowire','Radius')

            if(2*value)>=obj.Separation
                error(message('rf:rftxline:RadiusSeparation',''));
            end
            obj.privateRadius=value;
        end

        function set.Separation(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'twowire','Separation')

            if(2*obj.Radius)>=value
                error(message('rf:rftxline:RadiusSeparation',''));
            end
            obj.privateSeparation=value;
        end

        function set.MuR(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'twowire','MuR')
            obj.MuR=value;
        end

        function set.EpsilonR(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'twowire','EpsilonR')

            if(value<=1)
                rferrhole='EpsilonR';
                error(message('rf:rftxline:LessThanOne',rferrhole));
            end
            obj.EpsilonR=value;
        end

        function set.LossTangent(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','nonnegative'},...
            'twowire','LossTangent')
            obj.LossTangent=value;
        end

        function set.SigmaCond(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','real','positive'},...
            'twowire','SigmaCond')
            obj.SigmaCond=value;
        end

        function val=get.Radius(obj)
            val=obj.privateRadius;
        end

        function val=get.Separation(obj)
            val=obj.privateSeparation;
        end

        function val=get.MuR(obj)
            val=obj.MuR;
        end
    end

    methods(Hidden)
        function[y,z0]=calckl(h,freq)






            w=2*pi*freq;
            c0=rf.physconst('LightSpeed');
            mu0=pi*4e-7;
            mu=get(h,'MuR')*mu0;
            e0=1/mu0/c0^2;


            e=get(h,'EpsilonR')*e0;
            sigmacond=get(h,'SigmaCond');
            e_imag=get(h,'LossTangent')*e;
            len=get(h,'LineLength');
            a=get(h,'Radius');
            D=get(h,'Separation');


            delta=1./sqrt(pi*sigmacond*mu*freq);


            L=mu*acosh(D/a/2)/pi;
            C=pi*e/acosh(D/a/2);
            G=pi*w*e_imag/acosh(D/a/2);
            if~isinf(sigmacond)
                R=1./(pi*a*sigmacond*delta);
            else
                R=0;
            end


            w=2*pi*freq;
            z0=sqrt((R+1j*w*L)./(G+1j*w*C));
            k=sqrt((R+1j*w*L).*(G+1j*w*C));

            pv=w./imag(k);
            set(h,'PV',pv)
            alphadB=20*log10(exp(real(k)));
            alphadB(alphadB==inf)=1/eps;
            set(h,'Loss',alphadB)
            y=exp(-k*len);
        end
    end

    methods(Hidden)
        function checkproperty(obj)

            if(2*obj.Radius)>=obj.Separation
                error(message('rf:rftxline:RadiusSeparation',''));
            end
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.Radius=obj.Radius;
            plist1.Separation=obj.Separation;
            plist1.MuR=obj.MuR;
            plist1.EpsilonR=obj.EpsilonR;
            plist1.LossTangent=obj.LossTangent;
            plist1.SigmaCond=obj.SigmaCond;
            plist1.LineLength=obj.LineLength;
            plist1.Termination=obj.Termination;
            plist1.StubMode=obj.StubMode;
        end
    end
end
