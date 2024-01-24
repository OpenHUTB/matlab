function[B,A]=designParamEQ(N,G,Wo,BW,varargin)

%#codegen

    narginchk(4,7);
    nargoutchk(0,2);
    coder.allowpcode('plain');

    if nargin<5||nargin==6
        sosmode='sos';
        params=audio.internal.designParamEQValidator(varargin{:});
    else
        sosmode=varargin{1};
        params=audio.internal.designParamEQValidator(varargin{2:end});
    end

    orientation=params.Orientation;

    validateattributes(Wo,{'numeric'},{'real','finite','row','nonnegative'},...
    'designParamEQ','Wo',3);
    dType=class(Wo);
    zeroCast=cast(0,dType);
    oneCast=cast(1,dType);
    twoCast=cast(2,dType);
    Wo(Wo>oneCast)=ones(1,1,'like',Wo);

    Nfilts=cast(length(Wo),dType);

    if isscalar(N)
        validateattributes(N,{'numeric'},{'real','finite','integer','even',...
        'positive'},'designParamEQ','N',1);
        Nnew=N*ones(1,Nfilts,'like',N);
    else
        validateattributes(N,{'numeric'},{'real','finite','row','integer','even',...
        'positive','numel',Nfilts},'designParamEQ','N',1);
        Nnew=N;
    end

    if isscalar(G)
        validateattributes(G,{'numeric'},{'real'},...
        'designParamEQ','G',2);
        Gnew=G*ones(1,Nfilts,'like',G);
    else
        validateattributes(G,{'numeric'},{'real','row','numel',Nfilts},...
        'designParamEQ','G',2);
        Gnew=G;
    end

    if isscalar(BW)
        validateattributes(BW,{'numeric'},{'real','finite'},...
        'designParamEQ','BW',4);
        BWnew=BW*ones(1,Nfilts,'like',BW);
    else
        validateattributes(BW,{'numeric'},{'real','finite','row','numel',Nfilts},...
        'designParamEQ','BW',4);
        BWnew=BW;
    end
    BWnew(BWnew>oneCast)=ones(1,1,'like',BW);
    BWnew(BWnew<zeroCast)=zeros(1,1,'like',BW);

    sosmode=validatestring(sosmode,{'sos','fos'},'designParamEQ','m',5);
    if strcmpi(sosmode,'sos')
        m=oneCast;
        L=cast(3,dType);
        Nsections=sum(Nnew/twoCast);
    else
        m=twoCast;
        L=cast(5,dType);
        fourCast=twoCast+twoCast;
        Nsections=sum(ceil(Nnew/fourCast));
    end

    if Nfilts==oneCast
        [B0,A0]=designEachParamEQ(Nnew(1),Gnew(1),Wo(1),BWnew(1),m,dType);
    else
        B0=zeros(L,Nsections,'like',G);
        A0=zeros(L-1,Nsections,'like',G);

        startIdx=oneCast;
        for k=oneCast:Nfilts
            Nk=Nnew(k);
            incr=ceil(Nk/(twoCast*m));
            [B0(1:L,startIdx:startIdx+incr-1),...
            A0(1:L-1,startIdx:startIdx+incr-1)]=...
            designEachParamEQ(Nk,Gnew(k),Wo(k),BWnew(k),m,dType);
            startIdx=startIdx+incr;
        end
    end

    if strcmp(orientation,'row')
        B=B0';
        A=[ones(size(A0,2),1),A0'];
    else
        B=B0;
        A=A0;
    end

    function[B,A]=designEachParamEQ(N,G,w0,BW,m,dType)

        zeroCast=cast(0,dType);
        halfCast=cast(0.5,dType);
        oneCast=cast(1,dType);
        twoCast=cast(2,dType);
        fourCast=cast(4,dType);
        tenCast=cast(10,dType);

        G0=zeros(1,1,'like',G);
        GB=G/twoCast;
        if isinf(G)&&G<0
            gain=halfCast*ones(1,1,'like',G);
            GB=tenCast*log10(gain);
        end

        No2=N/twoCast;

        if m==oneCast
            B=zeros(3,No2,'like',G);
            B(1,1:No2)=oneCast;
            A=zeros(2,No2,'like',G);
        else
            N4=ceil(N/fourCast);
            B=zeros(5,N4,'like',G);
            B(1,1:N4)=oneCast;
            A=zeros(4,N4,'like',G);
        end

        if abs(G-G0)<=eps(dType)
            return;
        end

        G0sq=ones(1,1,'like',G);
        Gsq=tenCast^(G/tenCast);
        GBsq=tenCast^(GB/tenCast);

        if abs(Gsq-GBsq)<=eps(dType)||abs(GBsq-G0sq)<=eps(dType)
            return;
        end
        [Bf,Af]=audio.internal.designHPEQFilter(No2,G0sq,Gsq,GBsq,w0,BW,dType);

        if m==twoCast
            B=Bf';
            A=Af(:,2:end)';
        else

            if all(all(Bf(:,4:5)==zeroCast,oneCast),twoCast)&&all(all(Af(:,4:5)==zeroCast,oneCast),twoCast)
                N4=ceil(N/fourCast);
                B(1:3,1:N4)=Bf(:,1:3)';
                A(1:2,1:N4)=Af(:,2:3)';
            else

                if rem(No2,twoCast)
                    B(:,1)=Bf(1,1:3)';
                    A(:,1)=Af(1,2:3)';

                    nextidx=twoCast;
                    Br=Bf(2:end,:);
                    Ar=Af(2:end,:);
                else
                    nextidx=oneCast;

                    Br=Bf;
                    Ar=Af;
                end

                for k=nextidx:twoCast:No2-1
                    m=ceil(k/2);
                    [z,p,gain]=audio.internal.fos2zpk(Br(m,:),Ar(m,:));
                    [Btmp,Atmp]=audio.internal.zpk2sos(z,p,gain);
                    A(1:2,k:k+1)=Atmp(:,2:end).';
                    B(1:3,k:k+1)=Btmp.';
                end

            end
        end
