classdef coaxial<rf.internal.txline.basetxline




    properties(Dependent)

OuterRadius

InnerRadius
    end

    properties

MuR

EpsilonR

LossTangent

SigmaCond
    end

    properties(Constant,Access=protected)

        HeaderDescription='Coaxial'
        DefaultName='Coaxial';
    end

    properties(Hidden,Access=protected)
privateOuterRadius
privateInnerRadius
    end

    properties(Access=protected,Constant)

        DefaultOuterRadius=0.00257;

        DefaultInnerRadius=7.2500e-04;

        DefaultMuR=1;

        DefaultEpsilonR=2.3;

        DefaultLossTangent=0;

        DefaultSigmaCond=inf;
    end

    methods
        function obj=coaxial(varargin)
            parserObj=makeParser(obj);
            parse(parserObj,varargin{:});
            setProperties(obj,parserObj);

            checkStubMode(obj);
        end
    end

    methods(Access=protected,Hidden)
        function p=makeParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',obj.DefaultName);
            addParameter(p,'OuterRadius',obj.DefaultOuterRadius);
            addParameter(p,'InnerRadius',obj.DefaultInnerRadius);
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
            obj.OuterRadius=p.Results.OuterRadius;
            obj.InnerRadius=p.Results.InnerRadius;
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
        function set.OuterRadius(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'coaxial','OuterRadius')

            if(obj.InnerRadius>=value)
                error(message('rf:rftxline:OuterInner',''));
            end
            obj.privateOuterRadius=value;
        end

        function set.InnerRadius(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'coaxial','InnerRadius')

            if(value>=obj.OuterRadius)
                error(message('rf:rftxline:OuterInner',''));
            end
            obj.privateInnerRadius=value;
        end

        function set.MuR(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'coaxial','MuR')
            obj.MuR=value;
        end

        function set.EpsilonR(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'coaxial','EpsilonR')


            if(value<=1)
                rferrhole='EpsilonR';
                error(message('rf:rftxline:LessThanOne',rferrhole));
            end
            obj.EpsilonR=value;
        end

        function set.LossTangent(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','nonnegative'},...
            'coaxial','LossTangent')
            obj.LossTangent=value;
        end

        function set.SigmaCond(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','real','positive'},...
            'coaxial','SigmaCond')
            obj.SigmaCond=value;
        end

        function val=get.OuterRadius(obj)
            val=obj.privateOuterRadius;
        end

        function val=get.InnerRadius(obj)
            val=obj.privateInnerRadius;
        end

        function val=get.MuR(obj)
            val=obj.MuR;
        end
    end

    methods(Hidden)
        function[y,Z0_f]=calckl(h,freq)




            w=2*pi*freq;
            c0=rf.physconst('LightSpeed');
            mu0=pi*4e-7;
            mu=get(h,'MuR')*mu0;
            e0=1/mu0/c0^2;


            e=get(h,'EpsilonR')*e0;
            sigmacond=get(h,'SigmaCond');
            e_imag=get(h,'LossTangent')*e;
            a=get(h,'InnerRadius');
            b=get(h,'OuterRadius');
            len=get(h,'LineLength');


            delta=1./sqrt(pi*sigmacond*mu*freq);




            L=mu*log(b/a)/pi/2;
            C=2*pi*e/log(b/a);
            G=2*pi*w*e_imag/log(b/a);
            if~isinf(sigmacond)
                R=1./(2*pi*sigmacond.*delta)*(1/a+1/b);
            else
                R=0;
            end


            Z0_f=sqrt((R+1j*w*L)./(G+1j*w*C));
            k=sqrt((R+1j*w*L).*(G+1j*w*C));

            pv=w./imag(k);
            set(h,'PV',pv)
            alphadB=20*log10(exp(real(k)));
            alphadB(alphadB==inf)=1/eps;
            set(h,'Loss',alphadB)
            y=exp(-k*len);
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.OuterRadius=obj.OuterRadius;
            plist1.InnerRadius=obj.InnerRadius;
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
