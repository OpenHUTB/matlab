function[bestx,beststatus,iters,bestcost,numqpsolved,maxstacksize]=...
    miqpkwik(Q,c,A,b,Aeq,beq,vlb,vub,dvar,dvarset,Linv,Qinv,...
    maxstack,maxiter,feastol,discfeastol,V0,rounding,numdis,maxdis)
%#codegen

























































    ZERO=zeros(1,1,'like',Q);
    ONE=ones(1,1,'like',Q);
    ONEi=ones(1,1,'like',int16(1));
    ZEROi=zeros(1,1,'like',ONEi);

    bestcost=V0;

    n=size(A,2);

    bestx=zeros(n,1,'like',Q);
    beststatus=-ONE;
    iters=ZERO;
    numqpsolved=ZERO;


    p=numel(beq);
    b=[beq;b];
    A=[Aeq;A];
    nA=size(A,1);
    mmax=nA+2*n;

    ivar=(dvar>0);

    ivars=zeros(numdis,1,'like',Q);


    DSET=zeros(numdis,maxdis,'like',Q);
    k=ZEROi;
    h=ZEROi;
    dvarseti=zeros(maxdis,1,'like',Q);
    for i=1:n
        if dvar(i)>0
            h=h+ONEi;
            ivars(h)=i;
            dmaxi=dvarseti(1);
            for j=1:dvar(i)
                dvarseti(j)=dvarset(k+j);
                if dmaxi<dvarseti(j)
                    dmaxi=dvarseti(j);
                end
            end
            dmaxi=dmaxi+ONE;
            for j=dvar(i)+1:maxdis
                dvarseti(j)=dmaxi;
            end
            dvarseti=sort(dvarseti);
            for j=1:dvar(i)
                DSET(h,j)=dvarseti(j);
            end
            k=k+dvar(i);
        end
    end

    AI=zeros(numdis,2,'like',Q);
    ivlb=isfinite(vlb);
    ivub=isfinite(vub);


    for i=1:numdis
        j=ivars(i);
        vlb(j)=max(vlb(j),DSET(i,1));
        vub(j)=min(vub(j),DSET(i,dvar(j)));
        ivlb(j)=true;
        ivub(j)=true;
    end

    bv=zeros(2*n,1,'like',Q);
    Av=zeros(2*n,n,'like',Q);
    j=0;
    h=0;
    m=nA;
    for i=1:n
        if ivlb(i)
            j=j+1;
            bv(j)=-vlb(i);
            Av(j,i)=-ONE;
            m=m+1;
            if ivar(i)
                h=h+1;
                AI(h,1)=m;
            end
        end
    end
    h=0;
    for i=1:n
        if ivub(i)
            j=j+1;
            bv(j)=vub(i);
            Av(j,i)=ONE;
            m=m+1;
            if ivar(i)
                h=h+1;
                AI(h,2)=m;
            end
        end
    end
    b=[b;bv];
    A=[A;Av];

    SI=true(numdis,maxstack);
    SPeq=false(mmax,maxstack);
    SIact=zeros(mmax,maxstack,'like',ONEi);
    Svlb_ivar=zeros(numdis,maxstack,'like',Q);
    Svub_ivar=zeros(numdis,maxstack,'like',Q);


    topstack=ONE;
    SPeq(1:p,topstack)=true;
    SIact(1:p,topstack)=ONEi;
    h=0;
    for i=1:n
        if ivar(i)
            h=h+1;
            Svlb_ivar(h,topstack)=vlb(i);
            Svub_ivar(h,topstack)=vub(i);
        end
    end

    isroot=true;
    stack_full=false;
    maxstacksize=ONE;

    xi=zeros(numdis,1,'like',Q);
    dviol=zeros(numdis,1,'like',Q);
    jclosest=zeros(numdis,1,'like',Q);

    Ac=zeros(mmax,n,'like',Q);
    bc=zeros(mmax,1,'like',Q);
    indAct=zeros(mmax,1,'like',ONEi);
    indAct2=zeros(mmax,1,'like',ONEi);



    while topstack>ZERO&&~stack_full


        Peq=SPeq(:,topstack);
        I=SI(:,topstack);
        vlbi=Svlb_ivar(:,topstack);
        vubi=Svub_ivar(:,topstack);
        Iact=SIact(:,topstack);
        topstack=topstack-ONE;


        for i=1:numdis
            if vlbi(i)==vubi(i)
                h=AI(i,1);
                Peq(h)=true;
                I(i)=false;
            end
        end

        b0=b;
        b0(AI(:,1))=-vlbi;
        b0(AI(:,2))=vubi;
        for i=1:numdis
            if~I(i)
                b0(AI(i,2))=b0(AI(i,2))+1;
            end
        end

        h=0;
        for i=1:m
            if~Peq(i)
                h=h+1;
                Ac(h,:)=-A(i,:);
                bc(h,:)=-b0(i,:);
            end
        end
        meq=0;
        for i=1:m
            if Peq(i)
                h=h+1;
                meq=meq+1;
                Ac(h,:)=-A(i,:);
                bc(h,:)=-b0(i,:);
            end
        end

        h=0;
        for i=1:m
            indAct(i)=ZEROi;
            if~Peq(i)
                h=h+1;
                if Iact(i)
                    indAct(h)=ONEi;
                end
            end
            if i>m-meq
                indAct(i)=ONEi;
            end
        end

        if int32(maxiter)-int32(iters)>int32(32767)
            maxit=int16(32767);
        else
            maxit=int16(int32(maxiter)-int32(iters));
        end


        [x,~,status,indAct,QPiters]=localQPKWIK(Linv,Qinv,c,Ac,bc,indAct,...
        maxit,int16(m),int16(n),int16(meq),feastol,ONEi,bestcost,Q,mmax);






        iters=iters+QPiters;
        numqpsolved=numqpsolved+ONE;

        if isroot

            isroot=false;

            if status>0&&rounding






                for i=1:numdis
                    h=ivars(i);
                    j=ONEi;
                    dvioli=abs(x(h)-DSET(i,1));
                    for t=2:dvar(h)
                        aux=abs(x(h)-DSET(i,t));
                        if dvioli>aux
                            dvioli=aux;
                            j=t;
                        end
                    end
                    dviol(i)=dvioli;
                    xi(i)=DSET(i,j);
                end









                if int32(maxiter)-int32(iters)>int32(32767)
                    maxit=int16(32767);
                else
                    maxit=int16(int32(maxiter)-int32(iters));
                end

                b0=b;
                b0(AI(:,1))=-xi;
                b0(AI(:,2))=xi+1;
                Peq2=Peq;
                Peq2(AI(:,1))=true;

                h=0;
                for i=1:m
                    if~Peq2(i)
                        h=h+1;
                        Ac(h,:)=-A(i,:);
                        bc(h,:)=-b0(i,:);
                    end
                end
                meq2=meq+numdis;
                for i=1:m
                    if Peq2(i)
                        h=h+1;
                        meq=meq+1;
                        Ac(h,:)=-A(i,:);
                        bc(h,:)=-b0(i,:);
                    end
                end

                h=0;
                for i=1:m
                    indAct2(i)=ZEROi;
                    if~Peq(i)
                        h=h+1;
                        if Iact(i)
                            indAct2(h)=ONEi;
                        end
                    end
                    if i>m-meq2
                        indAct2(i)=ONEi;
                    end
                end

                [x2,~,status2,~,QPiters2]=localQPKWIK(Linv,Qinv,c,Ac,bc,indAct2,...
                maxit,int16(m),int16(n),int16(meq2),feastol,ONEi,bestcost,Q,mmax);
                numqpsolved=numqpsolved+ONE;
                iters=iters+QPiters2;
                if status2>0

                    V2=.5*x2'*Q*x2+c'*x2;
                    if V2<bestcost
                        bestcost=V2;
                        bestx=x2;
                        beststatus=ZERO;
                    end
                end
            end
        end


        h=0;
        for i=1:m
            if~Peq(i)
                h=h+1;
                Iact(i)=indAct(h);
            end
        end

        if status>0
            V=.5*x'*Q*x+c'*x;
            if beststatus==-ONE
                beststatus=-2*ONE;
            end
        else
            V=Inf*ONE;
        end

        if iters>=maxiter
            return
        end

        if~(status==-ONE||status==ZERO||status==-2*ONE||status==-3*ONE||(status>ZERO&&V>=bestcost))




            h=0;
            for i=1:n
                if ivar(i)
                    h=h+1;
                    xi(h)=x(i);
                end
            end

            for i=1:numdis
                h=ivars(i);
                j=ONEi;
                dvioli=abs(x(h)-DSET(i,1));
                for t=2:dvar(h)
                    aux=abs(x(h)-DSET(i,t));
                    if dvioli>aux
                        dvioli=aux;
                        j=t;
                    end
                end
                dviol(i)=dvioli;
                jclosest(i)=j;
            end


            nF=sum(dviol>discfeastol);

            if nF==0

                bestcost=V;
                bestx=x;
                beststatus=ZERO;

            else




                [~,i]=max(dviol);

                ri=DSET(i,jclosest(i));
                vlbii=vlbi;
                vubii=vubi;


                if ri-xi(i)>0


                    vubii(i)=DSET(i,jclosest(i)-1);
                    if vubii(i)>=vlbi(i)
                        topstack=topstack+ONE;
                        if topstack<=maxstack
                            SPeq(:,topstack)=Peq;
                            SI(:,topstack)=I;
                            SIact(:,topstack)=Iact;
                            Svlb_ivar(:,topstack)=vlbi;
                            Svub_ivar(:,topstack)=vubii;
                        else
                            stack_full=true;
                        end
                    end
                    vlbii(i)=ri;
                    if ri<=vubi(i)
                        topstack=topstack+ONE;
                        if topstack<=maxstack
                            SPeq(:,topstack)=Peq;
                            SI(:,topstack)=I;
                            SIact(:,topstack)=Iact;
                            Svlb_ivar(:,topstack)=vlbii;
                            Svub_ivar(:,topstack)=vubi;
                        else
                            stack_full=true;
                        end
                    end
                else

                    vlbii(i)=DSET(i,jclosest(i)+1);
                    if vlbii(i)<=vubi(i)
                        topstack=topstack+ONE;
                        if topstack<=maxstack
                            SPeq(:,topstack)=Peq;
                            SI(:,topstack)=I;
                            SIact(:,topstack)=Iact;
                            Svlb_ivar(:,topstack)=vlbii;
                            Svub_ivar(:,topstack)=vubi;
                        else
                            stack_full=true;
                        end
                    end
                    vubii(i)=ri;
                    if ri>=vlbi(i)
                        topstack=topstack+ONE;
                        if topstack<=maxstack
                            SPeq(:,topstack)=Peq;
                            SI(:,topstack)=I;
                            SIact(:,topstack)=Iact;
                            Svlb_ivar(:,topstack)=vlbi;
                            Svub_ivar(:,topstack)=vubii;
                        else
                            stack_full=true;
                        end
                    end
                end
            end
            if topstack>maxstacksize
                maxstacksize=topstack;
            end
        end
    end

    if stack_full
        if beststatus==ZERO
            beststatus=-3*ONE;
        elseif beststatus==-ONE
            beststatus=-4*ONE;
        elseif beststatus==-2*ONE
            beststatus=-5*ONE;
        end
    end

    function[x,lambda,status,iA,iters]=localQPKWIK(Linv,Hinv,f,Ac,b,iA,maxiter,m,n,meq,FeasTol,...
        ForceDualStop,V0,H0,mmax)




































































%#codegen
        coder.allowpcode('plain');
        ONE=ones('like',b);
        ZERO=zeros('like',b);
        ONEINT16=ones('int16');
        ZEROINT16=zeros('int16');

        LamTol=ONE*1e-12;
        RescaleFeasibilityTolerance=ONE*1e-3;
        status=ONE;
        iters=ZERO;
        lambda=zeros(mmax,ONEINT16,'like',b);
        x=zeros(n,ONEINT16,'like',b);

        if m==ZEROINT16
            x=Unconstrained(Hinv,f,x,n);
            return
        end

        r=zeros(n,ONEINT16,'like',b);
        rMin=ZERO;

        RLinv=coder.nullcopy(Linv);
        D=coder.nullcopy(Linv);
        H=coder.nullcopy(Linv);
        U=coder.nullcopy(Linv);

        cTol=ones(mmax,ONEINT16,'like',b);
        cTolComputed=false;


        iC=zeros(mmax,ONEINT16,'int16');
        nA=ZEROINT16;
        for i=ONEINT16:m



            if iA(i)==ONEINT16
                nA=nA+ONEINT16;
                iC(nA)=i;
            end
        end
        if nA>0

            Opt=zeros(2*n,ONEINT16,'like',b);
            Rhs=[f;zeros(n,ONEINT16,'like',b)];
            DualFeasible=false;


            MaxWSiter=max(3*nA,50*ONEINT16)/(10*ONEINT16);
            ColdReset=false;
            while~DualFeasible&&nA>ZEROINT16&&status<=maxiter
                [RLinv,D,H,Stat]=KWIKfactor(Ac,iC,nA,Linv,RLinv,D,H,n);
                if Stat<ZERO
                    if ColdReset

                        iters=status;
                        status=-2*ONE;
                        return
                    else


                        [nA,iA,iC]=ResetToColdStart(m,meq,mmax);
                        ColdReset=true;
                    end
                else

                    for j=ONEINT16:nA
                        Rhs(n+j)=b(iC(j));
                        for i=j:nA
                            U(i,j)=ZERO;
                            for k=ONEINT16:nA
                                U(i,j)=U(i,j)+RLinv(i,k)*RLinv(j,k);
                            end
                            U(j,i)=U(i,j);
                        end
                    end
                    for i=ONEINT16:n
                        Opt(i)=H(i,:)*Rhs(ONEINT16:n,ONEINT16);
                        for k=ONEINT16:nA
                            Opt(i)=Opt(i)+D(i,k)*Rhs(n+k);
                        end
                    end
                    for i=ONEINT16:nA
                        Opt(n+i)=D(:,i)'*Rhs(ONEINT16:n,ONEINT16);
                        for k=ONEINT16:nA
                            Opt(n+i)=Opt(n+i)+U(i,k)*Rhs(n+k);
                        end
                    end
                    lambdamin=-LamTol;
                    kDrop=ZEROINT16;
                    for i=ONEINT16:nA
                        lambda(iC(i))=Opt(n+i);

                        if Opt(n+i)<lambdamin&&i<=(nA-meq)
                            kDrop=i;
                            lambdamin=Opt(n+i);
                        end
                    end
                    if kDrop<=ZEROINT16

                        DualFeasible=true;
                        x=Opt(ONEINT16:n);
                    else

                        status=status+ONE;
                        if status>MaxWSiter

                            [nA,iA,iC]=ResetToColdStart(m,meq,mmax);
                            ColdReset=true;
                        else

                            lambda(iC(kDrop))=ZERO;
                            [iA,nA,iC]=DropConstraint(kDrop,iA,nA,iC);
                        end
                    end
                end
            end
            if nA<=ZEROINT16


                lambda=zeros(mmax,ONEINT16,'like',b);
                x=Unconstrained(Hinv,f,x,n);
            end
        else

            x=Unconstrained(Hinv,f,x,n);
        end


        Xnorm0=norm(x);












        while status<=maxiter
            if ForceDualStop











                phi=.5*x'*H0*x+f'*x;


                if phi>=V0
                    iters=status;
                    status=-3*ONE;
                    return
                end
            end


            cMin=-FeasTol;
            kNext=ZEROINT16;
            for i=ONEINT16:(m-meq)
                if~cTolComputed

                    cTol(i)=max(cTol(i),max(abs(Ac(i,:).*x')));
                end
                if iA(i)==ZEROINT16

                    cVal=(Ac(i,:)*x-b(i))/cTol(i);
                    if cVal<cMin
                        cMin=cVal;
                        kNext=i;
                    end
                end
            end
            cTolComputed=true;
            if kNext<=ZEROINT16

                iters=status;
                return
            end
            if status==maxiter

                iters=status;
                status=ZERO;
                return
            end
            while kNext>ZEROINT16&&status<=maxiter




                AcRow=Ac(kNext,:);
                if nA==ZEROINT16
                    z=Hinv*AcRow';
                else
                    [RLinv,D,H,Stat]=KWIKfactor(Ac,iC,nA,Linv,RLinv,D,H,n);
                    if Stat<=ZERO

                        iters=status;
                        status=-2*ONE;
                        return
                    end
                    z=-H*AcRow';
                    for i=ONEINT16:nA
                        r(i)=AcRow*D(:,i);
                    end
                end

                kDrop=ZEROINT16;
                t1=ZERO;
                isT1Inf=true;


                tempOK=true;
                if nA>meq
                    for ct=ONEINT16:nA-meq
                        if r(ct)>=LamTol
                            tempOK=false;
                            break;
                        end
                    end
                end


                if~((nA==meq)||tempOK)


                    for i=ONEINT16:(nA-meq)
                        if r(i)>LamTol

                            rVal=lambda(iC(i))/r(i);
                            if kDrop==ZEROINT16||rVal<rMin
                                rMin=rVal;
                                kDrop=i;
                            end
                        end
                    end
                    if kDrop>ZEROINT16
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

                    iters=status;
                    status=-1*ONE;
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

                for i=ONEINT16:nA
                    k=iC(i);

                    lambda(k)=lambda(k)-t*r(i);


                    if k<=(m-meq)&&lambda(k)<ZERO
                        lambda(k)=ZERO;
                    end
                end

                lambda(kNext)=lambda(kNext)+t;
                if t==t1

                    [iA,nA,iC]=DropConstraint(kDrop,iA,nA,iC);
                end
                if~isT2Inf

                    x=x+t*z;
                    if t==t2

                        if nA==n


                            iters=status;
                            status=-1*ONE;
                            return
                        end


                        nA=nA+ONEINT16;
                        iC(nA)=kNext;

                        for i=nA:-ONEINT16:ONEINT16*2
                            if iC(i)>iC(i-ONEINT16)
                                break
                            else
                                iSave=iC(i);
                                iC(i)=iC(i-ONEINT16);
                                iC(i-ONEINT16)=iSave;
                            end
                        end
                        iA(kNext)=ONEINT16;
                        kNext=ZEROINT16;
                    end
                end
                status=status+ONE;
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
            ONEINT16=ones('int16');
            Status=ONE;
            RLinv(:,:)=ZERO;
            FactorizationSingularityTolerance=ONE*1e-12;

            if nA>n

                Status=-2*ONE;
                return
            end

            for i=ONEINT16:nA
                RLinv(:,i)=Linv*Ac(iC(i),:)';
            end
            [QQ,RR]=qr(RLinv);



            for i=ONEINT16:nA
                if abs(RR(i,i))<FactorizationSingularityTolerance


                    Status=-2*ONE;
                    return
                end
            end
            for i=ONEINT16:n
                for j=ONEINT16:n
                    TL(i,j)=Linv(:,i)'*QQ(:,j);
                end
            end

            RLinv(:,:)=ZERO;
            for j=nA:-ONEINT16:ONEINT16
                RLinv(j,j)=ONE;
                for k=j:nA
                    RLinv(j,k)=RLinv(j,k)/RR(j,j);
                end
                if j>ONEINT16
                    for i=ONEINT16:j-ONEINT16
                        for k=j:nA
                            RLinv(i,k)=RLinv(i,k)-RR(i,j)*RLinv(j,k);
                        end
                    end
                end
            end



            for i=ONEINT16:n
                for j=i:n
                    H(i,j)=ZERO;
                    for k=nA+ONEINT16:n
                        H(i,j)=H(i,j)-TL(i,k)*TL(j,k);
                    end
                    H(j,i)=H(i,j);
                end
            end
            for j=ONEINT16:nA
                for i=ONEINT16:n
                    D(i,j)=ZERO;

                    for k=j:nA
                        D(i,j)=D(i,j)+TL(i,k)*RLinv(j,k);
                    end
                end
            end

            function[iA,nA,iC]=DropConstraint(kDrop,iA,nA,iC)




%#codegen
                ZEROINT16=zeros('int16');
                ONEINT16=ones('int16');
                iA(iC(kDrop))=ZEROINT16;
                if kDrop<nA
                    for i=kDrop:nA-ONEINT16
                        iC(i)=iC(i+ONEINT16);
                    end
                end
                iC(nA)=ZEROINT16;
                nA=nA-ONEINT16;

                function[nA,iA,iC]=ResetToColdStart(m,meq,mmax)


%#codegen
                    ONEINT16=ones('int16');
                    nA=meq;
                    iA=zeros(mmax,ONEINT16,'int16');
                    iC=iA;
                    if meq>0
                        for i=ONEINT16:meq
                            ix=m-meq+i;
                            iA(ix)=ONEINT16;
                            iC(i)=ix;
                        end
                    end

                    function x=Unconstrained(Hinv,f,x,n)


%#codegen
                        ONEINT16=ones('int16');
                        for i=ONEINT16:n
                            x(i)=-Hinv(i,:)*f;
                        end


