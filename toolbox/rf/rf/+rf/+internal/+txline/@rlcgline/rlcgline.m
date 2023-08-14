classdef rlcgline<rf.internal.txline.basetxline




    properties(Dependent)

Frequency

R

L

C

G
    end

    properties

IntpType
    end

    properties(Constant,Access=protected)

        HeaderDescription='RLCGLine'
        DefaultName='RLCGLine';
    end
    properties(Hidden,Access=protected)
privateFrequency
privateR
privateL
privateC
privateG
    end

    properties(Access=protected,Constant)

        DefaultFrequency=1e9;

        DefaultR=0;

        DefaultL=0;

        DefaultC=0;

        DefaultG=0;

        DefaultIntpType='Linear';
    end

    properties(Hidden,Constant)

        IntpTypeValues={'Linear','Cubic','Spline'};
    end

    methods
        function obj=rlcgline(varargin)
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
            addParameter(p,'R',obj.DefaultR);
            addParameter(p,'L',obj.DefaultL);
            addParameter(p,'C',obj.DefaultC);
            addParameter(p,'G',obj.DefaultG);
            addParameter(p,'IntpType',obj.DefaultIntpType);
            addParameter(p,'LineLength',0.0100);
            addParameter(p,'Termination','NotApplicable');
            addParameter(p,'StubMode','NotAStub');
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Frequency=p.Results.Frequency;
            obj.R=p.Results.R;
            obj.L=p.Results.L;
            obj.C=p.Results.C;
            obj.G=p.Results.G;
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
                'rlcgline','Frequency')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','positive','scalar'},...
                'rlcgline','Frequency')
            end
            if~isrow(value)
                value=value';
            end
            obj.privateFrequency=value;
        end

        function set.R(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','vector','ndims',2,},...
                'rlcgline','R')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
                'rlcgline','R')
            end
            if~isrow(value)
                value=value';
            end
            obj.validateDim(obj.privateFrequency,value,'R')
            obj.privateR=value;
        end

        function set.L(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','vector','ndims',2,},...
                'rlcgline','L')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
                'rlcgline','L')
            end
            if~isrow(value)
                value=value';
            end
            obj.validateDim(obj.privateFrequency,value,'L')
            obj.privateL=value;
        end

        function set.C(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','vector','ndims',2,},...
                'rlcgline','C')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
                'rlcgline','C')
            end
            if~isrow(value)
                value=value';
            end
            obj.validateDim(obj.privateFrequency,value,'C')
            obj.privateC=value;
        end

        function set.G(obj,value)
            if~isscalar(value)
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','vector','ndims',2,},...
                'rlcgline','G')
            else
                validateattributes(value,{'numeric'},...
                {'nonempty','nonnan','finite','real','nonnegative','scalar'},...
                'rlcgline','G')
            end
            if~isrow(value)
                value=value';
            end
            obj.validateDim(obj.privateFrequency,value,'G')
            obj.privateG=value;
        end

        function set.IntpType(obj,value)
            validstr=validatestring(value,obj.IntpTypeValues,...
            'rlcgline','IntpType');
            obj.IntpType=validstr;
        end

        function val=get.Frequency(obj)
            val=obj.privateFrequency;
        end

        function val=get.R(obj)
            val=obj.privateR;
        end

        function val=get.L(obj)
            val=obj.privateL;
        end

        function val=get.C(obj)
            val=obj.privateC;
        end

        function val=get.G(obj)
            val=obj.privateG;
        end
    end

    methods(Hidden)
        function[y,z0]=calckl(h,freq)




            R1=get(h,'R');
            L1=get(h,'L');
            C1=get(h,'C');
            G1=get(h,'G');
            len=get(h,'LineLength');

            w=2*pi*freq;
            L1(L1==0)=eps;
            C1(C1==0)=eps;

            if length(R1)==1
                R1=R1*ones(size(freq));
            else
                R1=interpolate(h,h.Frequency,R1,freq,h.IntpType);
            end
            R1=R1(:);


            if length(L1)==1
                L1=L1*ones(size(freq));
            else
                L1=interpolate(h,h.Frequency,L1,freq,h.IntpType);
            end
            L1=L1(:);


            if length(C1)==1
                C1=C1*ones(size(freq));
            else
                C1=interpolate(h,h.Frequency,C1,freq,h.IntpType);
            end
            C1=C1(:);


            if length(G1)==1
                G1=G1*ones(size(freq));
            else
                G1=interpolate(h,h.Frequency,G1,freq,h.IntpType);
            end
            G1=G1(:);


            z0=sqrt((R1+1i*w.*L1)./(G1+1i*w.*C1));
            k=sqrt((R1+1i*w.*L1).*(G1+1i*w.*C1));

            pv=w./imag(k);
            set(h,'PV',pv);
            alphadB=20*log10(exp(real(k)));
            alphadB(alphadB==inf)=1/eps;
            set(h,'Loss',alphadB);
            y=exp(-k*len);
        end

    end
    methods

        function checkproperty(h)




            freq=get(h,'Frequency');
            R2=get(h,'R');
            L2=get(h,'L');
            C2=get(h,'C');
            G2=get(h,'G');
            n=length(freq);
            m1=length(R2);
            m2=length(L2);
            m3=length(C2);
            m4=length(G2);


            rferrhole2='';
            if~(((n==1||n==0)&&(m1==1))||(n>1)&&(m1==1||n==m1))
                rferrhole2='R';
            end

            if~(((n==1||n==0)&&(m2==1))||(n>1)&&(m2==1||n==m2))
                rferrhole2='L';
            end

            if~(((n==1||n==0)&&(m3==1))||(n>1)&&(m3==1||n==m3))
                rferrhole2='C';
            end

            if~(((n==1||n==0)&&(m4==1))||(n>1)&&(m4==1||n==m4))
                rferrhole2='G';
            end

            if~isempty(rferrhole2)
                rferrhole1='RLCGline';
                error(message('rf:rftxline:WrongDataSize',...
                rferrhole1,rferrhole2));
            end

            if n~=0
                [freq,index]=sort(freq);
                if n==length(R2)
                    R2=R2(index);
                end
                if n==length(L2)
                    L2=L2(index);
                end
                if n==length(C2)
                    C2=C2(index);
                end
                if n==length(G2)
                    G2=G2(index);
                end
            end

            set(h,'Frequency',freq,'R',R2,'L',L2,'C',C2,'G',G2);
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.Frequency=obj.Frequency;
            plist1.R=obj.R;
            plist1.L=obj.L;
            plist1.C=obj.C;
            plist1.G=obj.G;
            plist1.IntpType=obj.IntpType;
            plist1.LineLength=obj.LineLength;
            plist1.Termination=obj.Termination;
            plist1.StubMode=obj.StubMode;
        end
    end

    methods(Hidden)
        function rStr=convertVectorToString(~,val)


            [y,e]=engunits(val);


            if numel(val)~=1
                rStr=mat2str(y,7);
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
                rferrhole1='RLCGline';

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
end