classdef equationbased<rf.internal.txline.basetxline




    properties(Dependent)

Frequency

PhaseVelocity

Z0

LossDB
    end

    properties

IntpType
    end

    properties(Constant,Access=protected)

        HeaderDescription='EquationBased'
        DefaultName='EquationBased';
    end

    properties(Hidden,Access=protected)
privateFrequency
privatePhaseVelocity
privateZ0
privateLossDB
    end

    properties(Access=protected,Constant)

        DefaultFrequency=1e9;

        DefaultZ0=50;

        DefaultPhaseVelocity=rf.physconst('LightSpeed');

        DefaultLossDB=0;

        DefaultIntpType='Linear';
    end

    properties(Hidden,Constant)

        IntpTypeValues={'Linear','Cubic','Spline'};
    end

    methods
        function obj=equationbased(varargin)
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
            addParameter(p,'Frequency',obj.DefaultFrequency);
            addParameter(p,'Z0',obj.DefaultZ0);
            addParameter(p,'PhaseVelocity',obj.DefaultPhaseVelocity);
            addParameter(p,'LossDB',obj.DefaultLossDB);
            addParameter(p,'IntpType',obj.DefaultIntpType);
            addParameter(p,'LineLength',0.0100);
            addParameter(p,'Termination','NotApplicable');
            addParameter(p,'StubMode','NotAStub');
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Frequency=p.Results.Frequency;
            obj.Z0=p.Results.Z0;
            obj.PhaseVelocity=p.Results.PhaseVelocity;
            obj.LossDB=p.Results.LossDB;
            obj.IntpType=p.Results.IntpType;
            obj.LineLength=p.Results.LineLength;
            obj.Termination=p.Results.Termination;
            obj.StubMode=p.Results.StubMode;
        end
    end

    methods
        function set.Frequency(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','positive','vector','ndims',2,},...
                'EquationBased','Frequency')
                if~isrow(value)
                    value=value';
                end
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','positive','scalar'},...
                'EquationBased','Frequency')
            end
            obj.privateFrequency=value;
        end

        function set.Z0(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','vector','ndims',2},...
                'EquationBased','Z0')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','scalar'},...
                'EquationBased','Z0')
            end
            if any(real(value)<=0)
                error(message('rf:rftxline:BadZ0'))
            end
            if~isrow(value)
                value=value.';
            end
            obj.validateDim(obj.privateFrequency,value,'Z0')
            obj.privateZ0=value;
        end

        function set.LossDB(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','vector','ndims',2,},...
                '','LossDB')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
                '','LossDB')
            end
            if~isrow(value)
                value=value';
            end

            obj.validateDim(obj.Frequency,value,'LossDB')
            obj.privateLossDB=value;
        end

        function val=get.LossDB(obj)
            val=obj.privateLossDB;
        end

        function set.PhaseVelocity(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','vector','ndims',2,},...
                'EquationBased','PhaseVelocity')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
                'EquationBased','PhaseVelocity')
            end
            if~isrow(value)
                value=value';
            end
            obj.validateDim(obj.privateFrequency,value,'PhaseVelocity')
            obj.privatePhaseVelocity=value;
        end

        function set.IntpType(obj,value)
            validstr=validatestring(value,obj.IntpTypeValues,...
            'EquationBased','IntpType');
            obj.IntpType=validstr;
        end

        function val=get.Frequency(obj)
            val=obj.privateFrequency;
        end

        function val=get.Z0(obj)
            val=obj.privateZ0;
        end

        function val=get.PhaseVelocity(obj)
            val=obj.privatePhaseVelocity;
        end

    end

    methods(Hidden)
        function[y,z0]=calckl(obj,freq)

            z0=obj.Z0;
            len=obj.LineLength;
            alphadB=obj.LossDB;
            pv=obj.PhaseVelocity;


            if length(z0)==1
                z0=z0*ones(size(freq));
            else
                z0=interpolate(obj,obj.Frequency,z0,freq,obj.IntpType);
            end
            z0=z0(:);


            if length(alphadB)==1
                alphadB=alphadB*ones(size(freq));
            else
                alphadB=interpolate(obj,obj.Frequency,alphadB,freq,obj.IntpType);
            end
            alphadB=alphadB(:);


            if length(pv)==1
                pv=pv*ones(size(freq));
            else
                pv=interpolate(obj,obj.Frequency,pv,freq,obj.IntpType);
            end
            pv=pv(:);

            set(obj,'PV',pv)


            beta=2*pi*freq./pv;


            e_negalphal=(10.^(-alphadB./20)).^len;

            y=e_negalphal.*exp(-1j*beta*len);
        end
    end
    methods(Hidden)

        function checkproperty(obj)


            freq=get(obj,'Frequency');
            alphadB=get(obj,'LossDB');
            pv=get(obj,'PhaseVelocity');
            z0=get(obj,'Z0');
            n=length(freq);
            m1=length(z0);
            m2=length(pv);
            m3=length(alphadB);

            rferrhole2='';

            if~(((n==1||n==0)&&(m1==1))||(n>1)&&(m1==1||n==m1))
                rferrhole2='Z0';
            end

            if~(((n==1||n==0)&&(m2==1))||(n>1)&&(m2==1||n==m2))
                rferrhole2='PhaseVelocity';
            end

            if~(((n==1||n==0)&&(m3==1))||(n>1)&&(m3==1||n==m3))
                rferrhole2='LossDB';
            end
            if~isempty(rferrhole2)
                rferrhole1='EquationBased';
                error(message('rf:rftxline:WrongDataSize',...
                rferrhole1,rferrhole2));
            end

            if n~=0
                [freq,index]=sort(freq);
                if n==length(alphadB)
                    alphadB=alphadB(index);
                end
                if n==length(pv)
                    pv=pv(index);
                end
                if n==length(z0)
                    z0=z0(index);
                end
            end

            set(obj,'Frequency',freq,'PhaseVelocity',pv,'LossDB',alphadB,'Z0',z0);
        end

        function rStr=convertVectorToString(~,val)


            [y,e]=engunits(val);


            if numel(val)~=1
                rStr=mat2str(y,15);
            else
                rStr=sprintf('%.15g',y);
            end

            if e~=1
                rStr=sprintf('%s*1e%d',rStr,round(log10(1/e)));
            end

        end

        function validateDim(~,freq,propVal,nameStr)

            n=length(freq);
            m=length(propVal);

            rferrhole2='';
            if~(((n==1||n==0)&&(m==1))||(n>1)&&(m==1||n==m))
                rferrhole2=nameStr;
            end

            if~isempty(rferrhole2)
                rferrhole1='EquationBased';
                error(message('rf:rftxline:WrongDataSize',...
                rferrhole1,rferrhole2));
            end
        end

        function newy=interpolate(~,x,y,newx,method)





            newy=[];
            if isempty(y)
                return
            end
            x=x(:);
            y=y(:);
            newx=newx(:);


            if nargin<5
                method='linear';
            elseif strcmpi(method,'cubic')
                method='pchip';
            end
            N=numel(newx);


            M=numel(x);
            if(M==0)||(M==1)

                newy(1:N)=y(1);
                newy=newy(:);
            elseif(numel(x)==numel(newx))&&all(x==newx)

                newy=y;
            else

                [x,xindex]=sort(x);
                y=y(xindex);


                newy=interp1(x,y,newx,lower(method),NaN);


                newy(newx<x(1))=y(1);
                newy(newx>x(end))=y(end);
            end
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.Frequency=obj.Frequency;
            plist1.Z0=obj.Z0;
            plist1.LossDB=obj.LossDB;
            plist1.PhaseVelocity=obj.PhaseVelocity;
            plist1.IntpType=obj.IntpType;
            plist1.LineLength=obj.LineLength;
            plist1.Termination=obj.Termination;
            plist1.StubMode=obj.StubMode;
        end
    end
end
