function[x,lambda,status,iA]=qpkwik(Linv,Hinv,f,Ac,b,iA,maxiter,m,n,meq,FeasTol)

%#codegen
    coder.allowpcode('plain');
    ONE=ones('like',b);
    ZERO=zeros('like',b);
    ONEINT=ones('like',n);
    ZEROINT=zeros('like',n);

    x=zeros(n,ONEINT,'like',b);
    lambda=zeros(m,ONEINT,'like',b);
    status=ONEINT;

    if m==ZEROINT
        x=Unconstrained(Hinv,f,x,n);
        return
    end

    LamTol=ONE*1e-12;
    RescaleFeasibilityTolerance=ONE*1e-3;

    r=zeros(n,ONEINT,'like',b);
    rMin=ZERO;

    RLinv=coder.nullcopy(Linv);
    D=coder.nullcopy(Linv);
    H=coder.nullcopy(Linv);
    U=coder.nullcopy(Linv);

    cTol=ones(m,ONEINT,'like',b);
    cTolComputed=false;

    iC=zeros(m,ONEINT,'like',ONEINT);
    nA=ZEROINT;
    for i=ONEINT:m
        if iA(i)
            nA=nA+ONEINT;
            iC(nA)=i;
        end
    end

    if nA>ZEROINT
        Opt=zeros(2*n,ONEINT,'like',b);
        Rhs=[f;zeros(n,ONEINT,'like',b)];
        DualFeasible=false;
        tmp=cast((0.3*ONE)*cast(nA,'like',ONE),'like',nA);
        if tmp<=(5*ONEINT)
            MaxWSiter=5*ONEINT;
        else
            MaxWSiter=tmp;
        end
        ColdReset=false;
        while~DualFeasible&&nA>ZEROINT&&status<=maxiter
            [RLinv,D,H,Stat]=KWIKfactor(Ac,iC,nA,Linv,RLinv,D,H,n);
            if Stat<ZERO
                if ColdReset

                    status=-2*ONEINT;
                    return
                else
                    [nA,iA,iC]=ResetToColdStart(m,meq);
                    ColdReset=true;
                end
            else
                for j=ONEINT:nA
                    Rhs(n+j)=b(iC(j));
                    for i=j:nA
                        U(i,j)=ZERO;
                        for k=ONEINT:nA
                            U(i,j)=U(i,j)+RLinv(i,k)*RLinv(j,k);
                        end
                        U(j,i)=U(i,j);
                    end
                end
                for i=ONEINT:n
                    Opt(i)=H(i,:)*Rhs(ONEINT:n,ONEINT);
                    for k=ONEINT:nA
                        Opt(i)=Opt(i)+D(i,k)*Rhs(n+k);
                    end
                end
                for i=ONEINT:nA
                    Opt(n+i)=D(:,i)'*Rhs(ONEINT:n,ONEINT);
                    for k=ONEINT:nA
                        Opt(n+i)=Opt(n+i)+U(i,k)*Rhs(n+k);
                    end
                end
                lambdamin=-LamTol;
                kDrop=ZEROINT;
                for i=ONEINT:nA
                    lambda(iC(i))=Opt(n+i);

                    if Opt(n+i)<lambdamin&&i<=(nA-meq)
                        kDrop=i;
                        lambdamin=Opt(n+i);
                    end
                end
                if kDrop<=ZEROINT

                    DualFeasible=true;
                    x=Opt(ONEINT:n);
                else

                    status=status+ONEINT;
                    if status>MaxWSiter

                        [nA,iA,iC]=ResetToColdStart(m,meq);
                        ColdReset=true;
                    else
                        lambda(iC(kDrop))=ZERO;
                        [iA,nA,iC]=DropConstraint(kDrop,iA,nA,iC);
                    end
                end
            end
        end
        if nA<=ZEROINT
            lambda=zeros(m,ONEINT,'like',b);
            x=Unconstrained(Hinv,f,x,n);
        end
    else
        x=Unconstrained(Hinv,f,x,n);
    end

    Xnorm0=norm(x);
    while status<=maxiter
        cMin=-FeasTol;
        kNext=ZEROINT;
        for i=ONEINT:(m-meq)
            if~cTolComputed
                cTol(i)=max(cTol(i),max(abs(Ac(i,:).*x')));
            end
            if~iA(i)

                cVal=(Ac(i,:)*x-b(i))/cTol(i);
                if cVal<cMin
                    cMin=cVal;
                    kNext=i;
                end
            end
        end
        cTolComputed=true;
        if kNext<=ZEROINT

            return
        end
        if status==maxiter

            status=ZEROINT;
            return
        end
        while kNext>ZEROINT&&status<=maxiter
            AcRow=Ac(kNext,:);
            if nA==ZEROINT
                z=Hinv*AcRow';
            else
                [RLinv,D,H,Stat]=KWIKfactor(Ac,iC,nA,Linv,RLinv,D,H,n);
                if Stat<=ZERO

                    status=-2*ONEINT;
                    return
                end
                z=-H*AcRow';
                for i=ONEINT:nA
                    r(i)=AcRow*D(:,i);
                end
            end

            kDrop=ZEROINT;
            t1=ZERO;
            isT1Inf=true;

            tempOK=true;
            if nA>meq
                for ct=ONEINT:nA-meq
                    if r(ct)>=LamTol
                        tempOK=false;
                        break;
                    end
                end
            end

            if~((nA==meq)||tempOK)

                for i=ONEINT:(nA-meq)
                    if r(i)>LamTol

                        rVal=lambda(iC(i))/r(i);
                        if kDrop==ZEROINT||rVal<rMin
                            rMin=rVal;
                            kDrop=i;
                        end
                    end
                end
                if kDrop>ZEROINT
                    t1=rMin;
                    isT1Inf=false;
                end
            end
            zTa=z'*AcRow';
            if zTa<=ZERO
                t2=ZERO;
                isT2Inf=true;
            else
                t2=(b(kNext)-AcRow*x)/zTa;
                isT2Inf=false;
            end

            if isT1Inf&&isT2Inf

                status=-ONEINT;
                return
            elseif isT2Inf
                t=t1;
            elseif isT1Inf
                t=t2;
            elseif t1<t2
                t=t1;
            else
                t=t2;
            end

            for i=ONEINT:nA
                k=iC(i);

                lambda(k)=lambda(k)-t*r(i);


                if k<=(m-meq)&&lambda(k)<ZERO
                    lambda(k)=ZERO;
                end
            end

            lambda(kNext)=lambda(kNext)+t;
            if abs(t-t1)<eps(ONE)
                [iA,nA,iC]=DropConstraint(kDrop,iA,nA,iC);
            end
            if~isT2Inf

                x=x+t*z;
                if abs(t-t2)<eps(ONE)

                    if nA==n
                        status=-ONEINT;
                        return
                    end


                    nA=nA+ONEINT;
                    iC(nA)=kNext;

                    for i=nA:-ONEINT:ONEINT*2
                        if iC(i)>iC(i-ONEINT)
                            break
                        else
                            iSave=iC(i);
                            iC(i)=iC(i-ONEINT);
                            iC(i-ONEINT)=iSave;
                        end
                    end
                    iA(kNext)=true;
                    kNext=ZEROINT;
                end
            end
            status=status+ONEINT;
        end

        Xnorm=norm(x);
        if abs(Xnorm-Xnorm0)>RescaleFeasibilityTolerance
            Xnorm0=Xnorm;
            cTol=max(abs(b),ONE);
            cTolComputed=false;
        end
    end


    function[RLinv,D,H,Status]=KWIKfactor(Ac,iC,nA,Linv,RLinv,D,H,n)

%#codegen
        TL=coder.nullcopy(Linv);
        ONE=ones('like',Linv);
        ZERO=zeros('like',Linv);
        ONEINT=ones('like',nA);
        Status=ONE;
        RLinv(:,:)=ZERO;
        FactorizationSingularityTolerance=ONE*1e-12;
        for i=ONEINT:nA
            RLinv(:,i)=Linv*Ac(iC(i),:)';
        end
        [QQ,RR]=qr(RLinv);

        for i=ONEINT:nA
            if abs(RR(i,i))<FactorizationSingularityTolerance

                Status=-2*ONE;
                return
            end
        end
        for i=ONEINT:n
            for j=ONEINT:n
                TL(i,j)=Linv(:,i)'*QQ(:,j);
            end
        end

        RLinv(:,:)=ZERO;
        for j=nA:-ONEINT:ONEINT
            RLinv(j,j)=ONE;
            for k=j:nA
                RLinv(j,k)=RLinv(j,k)/RR(j,j);
            end
            if j>ONEINT
                for i=ONEINT:j-ONEINT
                    for k=j:nA
                        RLinv(i,k)=RLinv(i,k)-RR(i,j)*RLinv(j,k);
                    end
                end
            end
        end

        for i=ONEINT:n
            for j=i:n
                H(i,j)=ZERO;
                for k=nA+ONEINT:n
                    H(i,j)=H(i,j)-TL(i,k)*TL(j,k);
                end
                H(j,i)=H(i,j);
            end
        end
        for j=ONEINT:nA
            for i=ONEINT:n
                D(i,j)=ZERO;

                for k=j:nA
                    D(i,j)=D(i,j)+TL(i,k)*RLinv(j,k);
                end
            end
        end

        function[iA,nA,iC]=DropConstraint(kDrop,iA,nA,iC)

            ZEROINT=zeros('like',nA);
            ONEINT=ones('like',nA);
            if kDrop>ZEROINT
                iA(iC(kDrop))=false;
                if kDrop<nA
                    for i=kDrop:nA-ONEINT
                        iC(i)=iC(i+ONEINT);
                    end
                end
                iC(nA)=ZEROINT;
                nA=nA-ONEINT;
            end

            function[nA,iA,iC]=ResetToColdStart(m,meq)

                ONEINT=ones('like',m);
                ZEROINT=zeros('like',m);
                nA=meq;
                iA=false(m,ONEINT);
                iC=zeros(m,ONEINT,'like',m);
                if meq>ZEROINT
                    for i=ONEINT:meq
                        ix=m-meq+i;
                        iA(ix)=true;
                        iC(i)=ix;
                    end
                end


                function x=Unconstrained(Hinv,f,x,n)

                    ONEINT=ones('like',n);
                    for i=ONEINT:n
                        x(i)=-Hinv(i,:)*f;
                    end

