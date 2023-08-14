function[B,A]=designHPEQFilter(N,G0,G,GB,w0,BW,dType)








%#codegen

    coder.inline('never');
    coder.allowpcode('plain');
    coder.noImplicitExpansionInFunction;

    zeroCast=cast(0,dType);
    halfCast=cast(0.5,dType);
    oneCast=cast(1,dType);
    twoCast=cast(2,dType);
    piCast=cast(pi,dType);

    N=cast(N,dType);
    r=rem(N,twoCast);
    L=(N-r)/twoCast;

    WB=tan(piCast.*BW/twoCast);
    e=sqrt((G-GB)/(GB-G0));
    g=G.^(oneCast/(twoCast.*N));
    g0=G0^(oneCast/(twoCast.*N));

    a=e^(oneCast/N);
    b=g0*a;

    if r==zeroCast
        offset=zeros(1,1,dType);
    else
        offset=ones(1,1,dType);
    end

    Ba=zeros(L+offset,3,dType);
    Aa=zeros(L+offset,3,dType);

    if r~=zeroCast
        Ba(1,:)=[g*WB,b,zeroCast];
        Aa(1,:)=[WB,a,zeroCast];
    end

    if L>zeroCast
        i=(oneCast:L)';
        ui=(twoCast*i-oneCast)/N;
        si=sin(piCast*ui/twoCast);
        v=ones(L,1,dType);

        Ba(offset+i,:)=[g^twoCast*WB^twoCast*v,twoCast*g*b*si*WB,b^twoCast*v];
        Aa(offset+i,:)=[WB^twoCast*v,twoCast*a*si*WB,a^twoCast*v];
    end



    K=size(Ba,1);

    B=zeros(K,5,dType);
    A=zeros(K,5,dType);
    Bhat=zeros(K,3,dType);
    Ahat=zeros(K,3,dType);

    B0=Ba(:,1);
    B1=Ba(:,2);
    B2=Ba(:,3);
    A0=Aa(:,1);
    A1=Aa(:,2);
    A2=Aa(:,3);

    if w0==zeroCast

        c0=ones(1,1,dType);
    elseif w0==oneCast
        c0=-ones(1,1,dType);
    elseif w0==halfCast
        c0=zeros(1,1,dType);
    else
        c0=cos(piCast*w0);
    end

    i1idx=cast(find((B1~=zeroCast|A1~=zeroCast)&(B2==zeroCast&A2==zeroCast)),dType);

    if~isempty(i1idx)
        i1=i1idx(1);
        D=A0(i1)+A1(i1);
        Bhat(i1,1)=(B0(i1)+B1(i1))./D;
        Bhat(i1,2)=(B0(i1)-B1(i1))./D;
        Ahat(i1,1)=oneCast;
        Ahat(i1,2)=(A0(i1)-A1(i1))./D;
    end

    i2idx=cast(find(B2~=zeroCast|A2~=zeroCast),dType);

    for k=1:length(i2idx)

        i2=i2idx(k);
        D=A0(i2)+A1(i2)+A2(i2);
        Bhat(i2,1)=(B0(i2)+B1(i2)+B2(i2))./D;
        Bhat(i2,2)=twoCast*(B0(i2)-B2(i2))./D;
        Bhat(i2,3)=(B0(i2)-B1(i2)+B2(i2))./D;
        Ahat(i2,1)=oneCast;
        Ahat(i2,2)=twoCast*(A0(i2)-A2(i2))./D;
        Ahat(i2,3)=(A0(i2)-A1(i2)+A2(i2))./D;
    end


    if c0==oneCast||c0==-oneCast
        B(:,1:3)=Bhat;
        A(:,1:3)=Ahat;
        B(:,2)=c0*B(:,2);
        A(:,2)=c0*A(:,2);

    else
        if~isempty(i1idx)
            i1=i1idx(1);
            B(i1,1)=Bhat(i1,1);
            B(i1,2)=c0*(Bhat(i1,2)-Bhat(i1,1));
            B(i1,3)=-Bhat(i1,2);
            A(i1,1)=oneCast;
            A(i1,2)=c0*(Ahat(i1,2)-oneCast);
            A(i1,3)=-Ahat(i1,2);
        end

        for k=1:length(i2idx)

            i2=i2idx(k);
            B(i2,1)=Bhat(i2,1);
            B(i2,2)=c0*(Bhat(i2,2)-twoCast*Bhat(i2,1));
            B(i2,3)=(Bhat(i2,1)-Bhat(i2,2)+Bhat(i2,3))*c0^twoCast-Bhat(i2,2);
            B(i2,4)=c0*(Bhat(i2,2)-twoCast*Bhat(i2,3));
            B(i2,5)=Bhat(i2,3);

            A(i2,1)=oneCast;
            A(i2,2)=c0*(Ahat(i2,2)-twoCast);
            A(i2,3)=(oneCast-Ahat(i2,2)+Ahat(i2,3))*c0^twoCast-Ahat(i2,2);
            A(i2,4)=c0*(Ahat(i2,2)-twoCast*Ahat(i2,3));
            A(i2,5)=Ahat(i2,3);
        end
    end
