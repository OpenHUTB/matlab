function[gpeak,fpeak]=peakResidual(A,B1,B2,C1,D11,D12,E,Ts,tol,fTest,RealFlag)



























    Ts=abs(Ts);
    nx=size(A,1);
    nu=size(B2,2);
    [ne,nd]=size(D11);
    if nargin<11
        RealFlag=(isreal(A)&&isreal(B1)&&isreal(B2)&&isreal(C1)&&isreal(D11)&&isreal(D12));
    end
    DescFlag=~isempty(E);
    fBand=[0,pi/Ts];
    gpeak=0;fpeak=fBand(1);


    bnorm=norm([B1,B2],1);
    cnorm=norm(C1,1);
    if nx==0||bnorm==0||cnorm==0
        [Q,~]=qr(D12);
        gpeak=norm(Q(:,nu+1:end)'*D11);
        return
    end
    tau=sqrt(cnorm/bnorm);
    B1=tau*B1;B2=tau*B2;C1=C1/tau;


    if DescFlag

        [AA,EE,q,z]=hess(A,E);
        BB1=q*B1;BB2=q*B2;
        CC1=C1*z;
    else

        [u,AA]=hess(A);
        BB1=u'*B1;BB2=u'*B2;
        CC1=C1*u;
        E=eye(nx);EE=E;
    end


    if Ts==0
        AX=[A,zeros(nx),B2,zeros(nx,ne);zeros(nx),-A',zeros(nx,nu),-C1';...
        zeros(nu,nx),B2',zeros(nu),D12';C1,zeros(ne,nx),D12,-eye(ne)];
        EX=blkdiag(E,E',zeros(nu+ne));
        BX=[B1;zeros(nx+nu,nd);D11];
        CX=[zeros(ne,2*nx+nu),eye(ne)];
    else
        AX=[A,zeros(nx),B2,zeros(nx,ne);...
        zeros(nx),E',zeros(nx,nu),-C1';...
        zeros(nu,2*nx+nu),D12';...
        C1,zeros(ne,nx),D12,-eye(ne)];
        EX=[E,zeros(nx,nx+nu+ne);...
        zeros(nx),A',zeros(nx,nu+ne);...
        zeros(nu,nx),-B2',zeros(nu,nu+ne);...
        zeros(ne,2*nx+nu+ne)];
        BX=[B1;zeros(nx+nu,nd);D11];
        CX=[zeros(ne,2*nx+nu),eye(ne)];
    end


    if RealFlag
        fTest=[fBand(:);fTest(fTest>fBand(1)&fTest<fBand(2))];
    else
        fTest=[fBand(:);-fBand(:);fTest(abs(fTest)>fBand(1)&abs(fTest)<fBand(2))];
    end
    if Ts>0
        s=exp(complex(0,Ts*fTest));
    else
        s=complex(0,fTest);
    end
    [h,gFro]=localFRESP(AA,BB1,BB2,CC1,D11,D12,EE,AX,BX,CX,EX,s);
    [~,is]=sort(gFro,'descend');
    for ct=1:numel(fTest)
        cts=is(ct);

        if gFro(cts)>gpeak
            w=fTest(cts);
            gw=norm(h(:,:,cts));
            if isinf(gw)
                gpeak=Inf;fpeak=w;return;
            elseif gw>gpeak
                gpeak=gw;fpeak=w;
            end
        end
    end
    if gpeak==0


        return
    end


    GQ=zeros(nx);
    aux=[zeros(nd,nu);D12];
    R=[zeros(nu),aux';aux,zeros(nd+ne)];
    for iter=1:30

        gpeak0=gpeak;
        g=(1+tol)*gpeak;


        B=[B2,B1/g,zeros(nx,ne)];
        S=[zeros(nx,nu+nd),C1'];
        aux=D11/g;
        R(nu+1:end,nu+1:end)=[-eye(nd),aux';aux,-eye(ne)];
        if Ts==0
            [alpha,beta,w_acc]=ltipack.eigSHH(A,E,GQ,GQ,R,B,S);


            idx=find(beta~=0);
            heigs=alpha(idx)./beta(idx);
        else
            [alpha,beta,w_acc]=ltipack.eigSHH(A-E,A+E,GQ,GQ,R,B,S,B);
            idx=find(abs(beta)>100*eps*abs(alpha)&beta+alpha~=0&beta-alpha~=0);
            heigs=(log(beta(idx)+alpha(idx))-log(beta(idx)-alpha(idx)))/Ts;
            w_acc=ltipack.getAccLims(w_acc,Ts);
        end
        if RealFlag

            heigs=heigs(imag(heigs)>=0);
        end


        ws=pickTestFreqs(heigs,w_acc,fBand,fpeak);
        if isempty(ws)
            break
        end


        if Ts>0
            s=exp(complex(0,Ts*ws));
        else
            s=complex(0,ws);
        end
        [hws,gFro]=localFRESP(AA,BB1,BB2,CC1,D11,D12,EE,AX,BX,CX,EX,s);
        for ct=1:numel(ws)
            if gFro(ct)>gpeak
                w=ws(ct);
                gw=norm(hws(:,:,ct));
                if isinf(gw)
                    gpeak=Inf;fpeak=w;return;
                elseif gw>gpeak
                    gpeak=gw;fpeak=w;
                end
            end
        end


        if gpeak<gpeak0*(1+tol/10)
            break
        end
    end



    function[h,gFro]=localFRESP(A,B1,B2,C1,D11,D12,E,AX,BX,CX,EX,s)

        [ne,nd]=size(D11);
        nu=size(B2,2);
        nf=numel(s);
        B=[B1,B2];D=[D11,D12];
        Bnrm=norm(B,'fro');

        h=zeros(ne,nd,nf);
        gFro=zeros(nf,1);
        for ct=1:numel(s)
            if isinf(s(ct))
                [Q,~]=qr(D(:,nd+1:nd+nu));
                Q2=Q(:,nu+1:ne);
                hct=Q2*(Q2'*D(:,1:nd));
            else
                M=s(ct)*E-A;
                aux=M\B;
                if norm(aux,'fro')*norm(M,'fro')<1e6*Bnrm

                    H=C1*aux+D;
                    [Q,~]=qr(H(:,nd+1:nd+nu));
                    Q2=Q(:,nu+1:ne);
                    hct=Q2*(Q2'*H(:,1:nd));
                else

                    hct=CX*((s(ct)*EX-AX)\BX);
                    hct(~isfinite(hct))=Inf;
                end
            end
            h(:,:,ct)=hct;
            gFro(ct)=norm(hct,'fro');
        end