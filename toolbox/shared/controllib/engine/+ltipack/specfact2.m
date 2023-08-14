function[aG,bG,cG,dG,eG,S]=specfact2(a,b,c,d,e0,Ts,R0)















    nx=size(a,1);
    [ny,nu]=size(d);
    RealFlag=isreal(a)&&isreal(b)&&isreal(c)&&isreal(d)&&isreal(e0)&&isreal(R0);
    if isempty(R0)
        R=eye(ny);
    else
        R=R0;
    end
    if isempty(e0)
        e=eye(nx);
    else
        e=e0;
    end
    hw=ctrlMsgUtils.SuspendWarnings;%#ok<NASGU>


    if Ts==0
        Href=d'*R*d;
        if nx>0&&rcond(Href)<eps
            error(message('Control:transformation:SpectralFact9C'))
        end
    else
        F1=d+c*((e-a)\b);
        Href=F1'*R*F1;
        if nx>0&&(hasInfNaN(F1)||rcond(Href)<eps)

            error(message('Control:transformation:SpectralFact9D'))
        end
    end


    dG=eye(nu);
    eG=e0;
    if nx>0


        sF=sqrt(norm(Href,1));
        d=d/sF;b=b/sF;


        [~,W1,W2]=ltipack.getSectorData(R,[]);
        nw1=size(W1,2);nw2=size(W2,2);
        W12=[W1,W2];
        c12=W12'*c;
        d12=W12'*d;
        DELTA=[-ones(nw1,1);ones(nw2,1)];
        RSCALE=max(1,norm(d12,1));


        bnorm=norm(b,1);
        cnorm=norm(c12,1);
        tau=sqrt(cnorm/bnorm);
        b=tau*b;
        c12=c12/tau;



        BX=[b,zeros(nx,ny)];
        SX=[zeros(nx,nu),c12'];
        RX=[zeros(nu),d12';d12,diag(DELTA)];
        if Ts==0
            tau=localScaleFactor(norm(a,1),RSCALE);
            [~,K,~,XINFO]=icare(a,tau*BX,0,tau^2*RX,tau*SX,e0,'noscaling');
            if XINFO.Report==3
                error(message('Control:transformation:SpectralFact9C'))
            end
        else
            tau=localScaleFactor(max(norm(a,1),norm(e,1)),RSCALE);
            [~,K,~,XINFO]=idare(a,tau*BX,0,tau^2*RX,tau*SX,e0,'noscaling');
            if XINFO.Report==3
                error(message('Control:transformation:SpectralFact9D'))
            end
        end
        if XINFO.Report==2

            error(message('Control:transformation:SpectralFact8'))
        end
        K=tau*K(1:nu,:);




        if isempty(e0)
            pF=eig(a);
        else
            pF=eig(a,e0);
        end
        if(Ts==0&&all(real(pF)<0))||(Ts~=0&&all(abs(pF)<1))
            aG=a;
            bG=b;
            cG=K;
        else
            BY=[K',zeros(nx,nu+ny)];
            RY=[zeros(nu),eye(nu),zeros(nu,ny);...
            eye(nu),zeros(nu),d12';...
            zeros(ny,nu),d12,diag(DELTA)];
            if Ts==0

                [~,L,~,YINFO]=icare(a',tau*BY,0,tau^2*RY,0,e0','noscaling');
                if YINFO.Report==3
                    error(message('Control:transformation:SpectralFact9C'))
                end
            else



                [Q,COS,SIN]=localGetRicFactors(XINFO.U,XINFO.V,e0,RealFlag);
                qbx=sqrt(SIN).*(Q*b);
                tau=localScaleFactor(max(norm(a,1),norm(e,1)),max(RSCALE,norm(qbx,1)));
                BY=[BY,zeros(nx)];
                aux=[zeros(nx,nu),qbx,zeros(nx,ny)];
                RY=[RY,aux';aux,diag(-COS)];
                [~,L,~,YINFO]=idare(a',tau*BY,0,tau^2*RY,0,e0','noscaling');
                if YINFO.Report==3
                    error(message('Control:transformation:SpectralFact9D'))
                end
            end
            if YINFO.Report==2

                error(message('Control:transformation:SpectralFact8'))
            end
            L=tau*L(1:nu,:)';


            aG=a-L*K;
            bG=b-L;
            cG=K;
        end
    else

        sF=1;
        aG=[];
        bG=zeros(0,nu);
        cG=zeros(nu,0);
    end


    if isempty(R0)

        if Ts==0
            M=sF*d;
        else
            G1=dG+cG*((e-aG)\bG);
            M=F1/G1;
        end
        if ny>nu
            [~,M]=qr(M,0);
        end
        dG=M;
        cG=M*cG;
        S=[];
    else
        if Ts==0
            S=Href;
        else
            G1=dG+cG*((e-aG)\bG);
            X1=F1/G1;
            S=X1'*R*X1;
        end
        S=(S+S')/2;
    end



    function[Q,C,S]=localGetRicFactors(U,V,E,RealFlag)




        nx=size(U,1);
        if~isempty(E)
            [Q,~]=qr([E*U;V],0);
            U=Q(1:nx,:);V=Q(nx+1:2*nx,:);
        end
        if RealFlag
            [C,S,Q,~]=qz(U,V,'real');
        else
            [C,S,Q,~]=qz(U,V,'complex');
        end
        C=diag(C);S=diag(S);

        ix=find(S<0);
        C(ix)=-C(ix);S(ix)=-S(ix);


        function tau=localScaleFactor(a,b)

            tau=sqrt(a/b);
            if tau==0
                tau=1;
            end

