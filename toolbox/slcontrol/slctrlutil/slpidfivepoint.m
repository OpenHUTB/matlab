function[P,I,D,N,achievedPM]=slpidfivepoint(type,form,frequencies,responses,targetPM,HasIntegrator,LoopSign,Ts,IF,DF)
































%#codegen
    coder.allowpcode('plain');


    datatype=class(frequencies);
    Zero=zeros(datatype);
    One=ones(datatype);
    IsDiscrete=Ts>Zero;
    TauPoints=20*One;
    COSMAX=One-max([10^(floor(log10(eps(datatype)))),One*1e-15]);


    wC=frequencies(3);
    w3=frequencies(2:4);
    gammaLow=w3(1);




    hL3=generateTargetLoop(w3,targetPM);
    gammaHigh=abs(hL3(3));


    responses=responses*LoopSign;


    hG3=responses(2:4);
    rG3=abs(hG3);
    wFirst=frequencies(1);
    rFirst=abs(responses(1));
    wLast=frequencies(5);
    rLast=abs(responses(5));


    wLowLeftBound=wFirst;
    wLowRightBound=wC/5;
    wLow=logspace(log10(wLowLeftBound),log10(wLowRightBound),50*One);
    wHighLeftBound=5*wC;
    wHighRightBound=wLast;
    wHigh=logspace(log10(wHighLeftBound),log10(wHighRightBound),50*One);
    f=10.^pchip(log10(frequencies),log10(abs(responses)),log10([wLow,wHigh]));
    fLow=f(1:50);
    fHigh=f(51:100);






















    if type==(6*One)||type==(7*One)
        if rG3(3)<rLast
            type=3*One;
        end
    end



    if(type==(4*One)||type==(5*One))&&HasIntegrator
        if rG3(3)<rLast
            type=One;
        end
    end


    crossoverWeight=5*One;
    fWeight=[One;crossoverWeight;One];


    if IsDiscrete
        [realhI,imaghI]=localGetRealImag(Ts,w3,IF,Zero,One,COSMAX);
        hI=complex(realhI,imaghI);
    else
        hI=complex(Zero,-One./w3);
    end


    [realhD,imaghD]=localGetRealImag(Ts,w3,DF,Zero,One,COSMAX);




    switch type
    case One
        if HasIntegrator

            b=[real(hL3);imag(hL3);-gammaLow];
            LS=[fWeight;fWeight;One];
            b=b.*LS;


            A=blkdiag([real(hG3);imag(hG3)],One);
            A(end,1)=-min(fLow.*wLow);
            A=A.*[LS,LS];

            x=utilLSQFixedSizeData(A,b);

            Kp=x(1);
            Ki=Zero;
            Kd=Zero;
            Tf=Zero;
        else
            Kp=One/abs(hG3(2));
            Ki=Zero;
            Kd=Zero;
            Tf=Zero;
        end
    case 2*One

        b=[real(hL3);imag(hL3);-gammaLow];
        LS=[fWeight;fWeight;One];
        b=b.*LS;


        A=blkdiag([real(hG3).*real(hI)-imag(hG3).*imag(hI);real(hG3).*imag(hI)+imag(hG3).*real(hI)],One);
        A(end,1)=-min(fLow);
        A=A.*[LS,LS];

        x=utilLSQFixedSizeData(A,b);

        Kp=Zero;
        Ki=x(1);
        Kd=Zero;
        Tf=Zero;
    case 3*One

        b=[real(hL3);imag(hL3);-gammaLow];
        LS=[fWeight;fWeight;One];
        b=b.*LS;


        A=blkdiag([real(hG3),real(hG3).*real(hI)-imag(hG3).*imag(hI);imag(hG3),real(hG3).*imag(hI)+imag(hG3).*real(hI)],One);
        A(end,2)=-min(fLow);
        A=A.*[LS,LS,LS];

        x=utilLSQFixedSizeData(A,b);

        Kp=x(1);
        Ki=x(2);
        Kd=Zero;
        Tf=Zero;
    case 4*One
        if HasIntegrator

            b=[real(hL3);imag(hL3);-gammaLow;gammaHigh];
            LS=[fWeight;fWeight;One;One];
            b=b.*LS;



            if IsDiscrete
                hD=One./complex(realhD,imaghD);
            else
                hD=complex(Zero,w3);
            end
            A=blkdiag([real(hG3),real(hG3).*real(hD)-imag(hG3).*imag(hD);imag(hG3),imag(hG3).*real(hD)+real(hG3).*imag(hD)],One,One);
            A(end-1,1)=-min(fLow.*wLow);
            A(end,1)=max(fHigh);
            A(end,2)=max(fHigh.*wHigh);
            A=A.*[LS,LS,LS,LS];

            x=utilLSQFixedSizeData(A,b);

            Kp=x(1);
            Ki=Zero;
            Kd=x(2);
            Tf=Zero;
        else
            tempKp=One/abs(hG3(2));
            tempPM=computePM(tempKp*hG3(2));
            if tempPM>targetPM

                Kp=tempKp;
                Ki=Zero;
                Kd=Zero;
                Tf=Zero;
            else


                b=[real(hL3);imag(hL3);gammaHigh];
                LS=[fWeight;fWeight;One];
                b=b.*LS;


                if IsDiscrete
                    hD=One./complex(realhD,imaghD);
                else
                    hD=complex(Zero,w3);
                end
                A=blkdiag([real(hG3),real(hG3).*real(hD)-imag(hG3).*imag(hD);imag(hG3),imag(hG3).*real(hD)+real(hG3).*imag(hD)],One);
                A(end,1)=max(fHigh);
                A(end,2)=max(fHigh.*wHigh);
                A=A.*[LS,LS,LS];

                x=utilLSQFixedSizeData(A,b);

                Kp=x(1);
                Ki=Zero;
                Kd=x(2);
                Tf=Zero;
            end
        end
    case 5*One
        if HasIntegrator

            tau=computeTAU(IsDiscrete,w3,Ts,TauPoints,DF);

            xtau=zeros(4,TauPoints,datatype);
            b=[real(hL3);imag(hL3);-gammaLow;gammaHigh];
            LS=[fWeight;fWeight;One;One];
            b=b.*LS;

            gap=zeros(TauPoints,1,datatype);
            for ct=1:TauPoints

                if IsDiscrete

                    hD=One./(complex(tau(ct)+realhD,imaghD));
                else

                    hD=1i*w3./complex(One,tau(ct)*w3);
                end



                A=blkdiag([real(hG3),real(hG3).*real(hD)-imag(hG3).*imag(hD);imag(hG3),imag(hG3).*real(hD)+real(hG3).*imag(hD)],One,One);
                A(end-1,1)=-min(fLow.*wLow);
                A(end,1)=max(fHigh);
                A(end,2)=max(fHigh.*wHigh./abs(complex(1,wHigh*tau(ct))));
                A=A.*[LS,LS,LS,LS];

                [xtau(:,ct),gap(ct)]=utilLSQFixedSizeData(A,b);
            end

            if(max(gap)-min(gap))/mean(gap)<0.1*One
                imin=1;
            else
                [~,imin]=min(gap);
            end

            if xtau(2,imin)==Zero

                Kp=xtau(1,imin);
                Ki=Zero;
                Kd=xtau(2,imin);
                Tf=Zero;
            else
                Kp=xtau(1,imin);
                Ki=Zero;
                Kd=xtau(2,imin);
                Tf=tau(imin);
            end
        else
            tempKp=One/abs(hG3(2));
            tempPM=computePM(tempKp*hG3(2));
            if tempPM>targetPM

                Kp=tempKp;
                Ki=Zero;
                Kd=Zero;
                Tf=Zero;
            else


                tau=computeTAU(IsDiscrete,w3,Ts,TauPoints,DF);

                xtau=zeros(3,TauPoints,datatype);
                b=[real(hL3);imag(hL3);gammaHigh];
                LS=[fWeight;fWeight;One];
                b=b.*LS;

                gap=zeros(TauPoints,1,datatype);
                for ct=1:TauPoints

                    if IsDiscrete

                        hD=One./(complex(tau(ct)+realhD,imaghD));
                    else

                        hD=1i*w3./complex(One,tau(ct)*w3);
                    end


                    A=blkdiag([real(hG3),real(hG3).*real(hD)-imag(hG3).*imag(hD);imag(hG3),imag(hG3).*real(hD)+real(hG3).*imag(hD)],One);
                    A(end,1)=max(fHigh);
                    A(end,2)=max(fHigh.*wHigh./abs(complex(1,wHigh*tau(ct))));
                    A=A.*[LS,LS,LS];

                    [xtau(:,ct),gap(ct)]=utilLSQFixedSizeData(A,b);
                end

                if(max(gap)-min(gap))/mean(gap)<0.1*One
                    imin=1;
                else
                    [~,imin]=min(gap);
                end

                if xtau(2,imin)==Zero

                    Kp=xtau(1,imin);
                    Ki=Zero;
                    Kd=xtau(2,imin);
                    Tf=Zero;
                else
                    Kp=xtau(1,imin);
                    Ki=Zero;
                    Kd=xtau(2,imin);
                    Tf=tau(imin);
                end
            end
        end
    case 6*One

        b=[real(hL3);imag(hL3);-gammaLow;gammaHigh];
        LS=[fWeight;fWeight;One;One];
        b=b.*LS;



        if IsDiscrete
            hD=One./complex(realhD,imaghD);
        else
            hD=complex(Zero,w3);
        end
        A=blkdiag([real(hG3),real(hG3).*real(hI)-imag(hG3).*imag(hI),real(hG3).*real(hD)-imag(hG3).*imag(hD);imag(hG3),real(hG3).*imag(hI)+imag(hG3).*real(hI),imag(hG3).*real(hD)+real(hG3).*imag(hD)],One,One);
        A(end-1,2)=-min(fLow);
        A(end,1)=max(fHigh);
        A(end,2)=max(fHigh./wHigh);
        A(end,3)=max(fHigh.*wHigh);
        A=A.*[LS,LS,LS,LS,LS];

        x=utilLSQFixedSizeData(A,b);

        Kp=x(1);
        Ki=x(2);
        Kd=x(3);
        Tf=Zero;
    case 7

        tau=computeTAU(IsDiscrete,w3,Ts,TauPoints,DF);

        xtau=zeros(5,TauPoints,datatype);
        b=[real(hL3);imag(hL3);-gammaLow;gammaHigh];
        LS=[fWeight;fWeight;One;One];
        b=b.*LS;

        gap=zeros(TauPoints,1,datatype);
        for ct=1:TauPoints

            if IsDiscrete

                hD=One./(complex(tau(ct)+realhD,imaghD));
            else

                hD=1i*w3./complex(One,tau(ct)*w3);
            end



            A=blkdiag([real(hG3),real(hG3).*real(hI)-imag(hG3).*imag(hI),real(hG3).*real(hD)-imag(hG3).*imag(hD);imag(hG3),real(hG3).*imag(hI)+imag(hG3).*real(hI),imag(hG3).*real(hD)+real(hG3).*imag(hD)],One,One);
            A(end-1,2)=-min(fLow);
            A(end,1)=max(fHigh);
            A(end,2)=max(fHigh./wHigh);
            A(end,3)=max(fHigh.*wHigh./abs(complex(1,wHigh*tau(ct))));
            A=A.*[LS,LS,LS,LS,LS];

            [xtau(:,ct),gap(ct)]=utilLSQFixedSizeData(A,b);
        end

        if(max(gap)-min(gap))/mean(gap)<0.1*One
            imin=1;
        else
            [~,imin]=min(gap);
        end

        if xtau(3,imin)==Zero

            Kp=xtau(1,imin);
            Ki=xtau(2,imin);
            Kd=Zero;
            Tf=Zero;
        else
            Kp=xtau(1,imin);
            Ki=xtau(2,imin);
            Kd=xtau(3,imin);
            Tf=tau(imin);
        end
    otherwise
        Kp=Zero;
        Ki=Zero;
        Kd=Zero;
        Tf=Zero;
    end


    Kp=Kp*LoopSign;
    Ki=Ki*LoopSign;
    Kd=Kd*LoopSign;


    if form==One

        P=Kp;
        I=Ki;
        D=Kd;
        if Tf==Zero
            N=100*One;
        else
            N=One/Tf;
        end
    else

        P=Kp;
        if Kp==Zero
            I=Zero;
            D=Zero;
        else
            I=Ki/Kp;
            D=Kd/Kp;
        end
        if Tf==Zero
            N=100*One;
        else
            N=One/Tf;
        end
    end


    L=(Kp+Ki/complex(Zero,wC)+Kd*complex(Zero,wC)/(1+complex(Zero,Tf*wC)))*hG3(2)*LoopSign;
    achievedPM=computePM(L);


    function[realX,imagX]=localGetRealImag(Ts,w,Formula,Zero,One,COSMAX)


%#codegen
        if Formula==One
            realX=-Ts/2;
        elseif Formula==2*One
            realX=Ts/2;
        else
            realX=Zero;
        end
        imagX=-Ts/2.*sin(w*Ts)./(One-min(cos(w*Ts),COSMAX));

        function tau=computeTAU(IsDiscrete,w3,Ts,n,DF)





%#codegen
            if IsDiscrete&&DF==1

                lb=min(w3(3),1.99/Ts);
                ub=min(w3(3)*10,1.99/Ts);
                tau=1./logspace(log10(lb),log10(ub),n);
            else
                tau=1./logspace(log10(w3(3)),log10(w3(3)*10),n);
            end

            function L=generateTargetLoop(w,targetPM)







%#codegen
                wC=w(2);
                theta=pi/2-targetPM/180*pi;
                Real=-sin(theta)*wC*wC./(sin(theta)*sin(theta)*(w.^2)+wC*wC*cos(theta)*cos(theta));
                Imag=-cos(theta)*wC*wC*wC./(sin(theta)*sin(theta)*(w.^3)+wC*wC*cos(theta)*cos(theta)*w);
                L=complex(Real,Imag);


                function[x,resnorm,resid,exitflag,lambda]=utilLSQFixedSizeData(C,d)


%#codegen


                    m=int16(size(C,1));
                    n=int16(size(C,2));
                    Zero=zeros('like',C);
                    One=ones('like',C);
                    ZeroInt16=zeros('int16');
                    OneInt16=ones('int16');
                    nZeros=zeros(n,1,'like',C);
                    RealMax=realmax*One;

                    tol=10*eps(class(C))*norm(C,1)*length(C);

                    P=false(n,1);

                    Z=true(n,1);

                    wz=nZeros;

                    x=nZeros;
                    resid=d-C*x;
                    w=C'*resid;

                    outeriter=ZeroInt16;
                    iter=ZeroInt16;
                    itmax=3*n;
                    exitflag=One;

                    while any(Z)&&isAnyBigW(n,w,Z,tol)

                        outeriter=outeriter+OneInt16;

                        z=nZeros;




                        for ct=OneInt16:n
                            if P(ct)
                                wz(ct)=-RealMax;
                            end
                            if Z(ct)
                                wz(ct)=w(ct);
                            end
                        end

                        [~,t]=max(wz);

                        P(t)=true;
                        Z(t)=false;


                        z=computeZ(z,C,d,P);

                        while isAnyNegativeZ(n,z,P,Zero)
                            iter=iter+1;
                            if iter>itmax
                                exitflag=Zero;
                                resnorm=sum(resid.*resid);
                                x=z;
                                lambda=w;
                                return
                            end

                            Q=(z<=Zero)&P;

                            alpha=computeAlpha(n,x,z,Q,RealMax);
                            x=x+alpha*(z-x);

                            Z=((abs(x)<tol)&P)|Z;
                            P=~Z;
                            z=nZeros;


                            z=computeZ(z,C,d,P);
                        end
                        x=z;
                        resid=d-C*x;
                        w=C'*resid;
                    end
                    lambda=w;
                    resnorm=resid'*resid;

                    function found=isAnyBigW(n,w,Z,tol)
%#codegen

                        OneInt16=ones('int16');
                        found=false;
                        for ct=OneInt16:n
                            if Z(ct)
                                if w(ct)>tol
                                    found=true;
                                    return;
                                end
                            end
                        end

                        function found=isAnyNegativeZ(n,z,P,Zero)
%#codegen

                            OneInt16=ones('int16');
                            found=false;
                            for ct=OneInt16:n
                                if P(ct)
                                    if z(ct)<=Zero
                                        found=true;
                                        return;
                                    end
                                end
                            end

                            function result=computeAlpha(n,x,z,Q,RealMax)
%#codegen

                                OneInt16=ones('int16');
                                value=ones(n,1)*RealMax;
                                for ct=OneInt16:n
                                    if Q(ct)
                                        value(ct)=x(ct)/(x(ct)-z(ct));
                                    end
                                end
                                result=min(value);

                                function Z=computeZ(Z,C,d,p)

                                    [m,n]=size(C);
                                    A=zeros(size(C),'like',C);
                                    One=ones('like',C);
                                    ncols=zeros('like',C);
                                    for k=1:n
                                        if p(k)
                                            ncols=ncols+1;
                                            A(:,ncols)=C(:,k);
                                        end
                                    end
                                    [Q,R,jpvt]=qr(A,'vector');


                                    qtd=Q'*d;
                                    rankA=min(m,ncols);
                                    z=zeros(n,1,'like',qtd);
                                    for i=1:rankA
                                        z(jpvt(i))=qtd(i);
                                    end
                                    for j=rankA:-One:One
                                        pj=jpvt(j);
                                        z(pj)=z(pj)/R(j,j);
                                        for i=One:j-One
                                            z(jpvt(i))=z(jpvt(i))-z(pj)*R(i,j);
                                        end
                                    end
                                    ct=One;
                                    for k=One:n
                                        if p(k)
                                            Z(k)=z(ct);
                                            ct=ct+One;
                                        end
                                    end

                                    function PM=computePM(L)
                                        phi=angle(L)*180/pi;
                                        PM=mod(phi,360)-180;