function[tMax,fMax]=specmax(A,E,B,S,R,K,L,M,D,Ts,AbsTol,RelTol)





































    n=size(A,1);
    if n==0
        aux=D-M'*(R\M);
        tMax=max(eig(aux+aux'))/2;fMax=0;return
    end
    NULL=zeros(n);
    if isempty(E)
        E=eye(n);
    end
    m=size(R,1);
    p=size(D,1);
    KLM=[K;L;M];
    RealFlag=isreal(A)&&isreal(E)&&isreal(B)&&isreal(S)&&isreal(R)&&isreal(KLM);
    Ts=abs(Ts);
    tMax=-Inf;


    if Ts==0
        AA=[NULL,A,B;A',NULL,S;B',S',R];
        EE=blkdiag([NULL,E;-E',NULL],zeros(m));
    else
        AA=[NULL,A,B;-E',NULL,S;zeros(m,n),S',R];
        EE=[NULL,E,zeros(n,m);-A',zeros(n,n+m);-B',zeros(m,n+m)];
    end
    e=eig(AA,EE);
    if Ts>0
        e=log(e)/Ts;
    end
    fTest=abs(e(isfinite(e)));
    if Ts>0
        nf=pi/Ts;
        fTest=[fTest(fTest<nf);nf];
    end
    fBand=[0,Inf];
    if RealFlag
        fTest=unique([0;fTest]);
    else
        fTest=unique([-fTest;0;fTest]);
    end


    if Ts==0
        BB=KLM;CC=KLM';
    else
        AA=blkdiag(eye(n),AA);
        EE=blkdiag(zeros(n),EE);
        EE(1:n,n+1:2*n)=eye(n);
        BB=[zeros(n,p);KLM];
        CC=[K',zeros(p,n),L',M'];
    end
    [AA,EE,Q,Z]=hess(AA,EE);
    BB=Q*BB;
    CC=CC*Z;


    s=complex(0,fTest);
    if Ts==0
        h=ssfresp(AA,BB,CC,D,EE,s);
        fTest=[fTest;Inf];
        h=cat(3,h,D-M'*(R\M));
    else
        h=ssfresp(AA,BB,CC,D,EE,exp(Ts*s));
    end
    for ct=1:numel(fTest)
        hw=h(:,:,ct);
        tw=max(eig(hw+hw'))/2;
        if tw>tMax
            tMax=tw;fMax=fTest(ct);
        end
    end


    for iter=1:30

        tMax0=tMax;
        dt=max(RelTol*abs(tMax),AbsTol);
        t=tMax+dt;


        [heigs,w_acc]=localTCut(A,E,[B,K],[S,L],[R,M;M',D-t*eye(p)],Ts);
        if RealFlag

            heigs=heigs(imag(heigs)>=0);
        end


        ws=pickTestFreqs(heigs,w_acc,fBand,fMax);
        if isempty(ws)
            break
        end


        s=complex(0,ws);
        if Ts>0
            s=exp(Ts*s);
        end
        h=ssfresp(AA,BB,CC,D,EE,s);
        for ct=1:numel(ws)
            hw=h(:,:,ct);
            tw=max(eig(hw+hw'))/2;
            if tw>tMax
                tMax=tw;fMax=ws(ct);
            end
        end



        if tMax<tMax0+dt/10
            break
        end
    end


    function[heigs,w_acc]=localTCut(A,E,B,S,R,Ts)














        n=size(A,1);
        NULL=zeros(n);
        nrmA=norm(A,1);
        [~,B,S]=ltipack.scaleBC(B,S,1+nrmA);
        if Ts==0
            [ta,td]=ltipack.scalePencil(nrmA,norm(B,1),norm(R,1));
            [alpha,beta,w_acc]=ltipack.eigSHH(ta^2*A,ta^2*E,NULL,NULL,td^2*R,(ta*td)*B,(ta*td)*S);
            idx=find(beta~=0);
            heigs=alpha(idx)./beta(idx);
        else

            [ta,td]=ltipack.scalePencil(nrmA+norm(E,1),norm(B,1),norm(R,1));
            aux=(ta*td)*B;
            [alpha,beta,w_acc]=ltipack.eigSHH(ta^2*(A-E),ta^2*(A+E),NULL,NULL,...
            td^2*R,aux,(ta*td)*S,aux);

            Ts=abs(Ts);
            idx=find(abs(beta)>100*eps*abs(alpha)&beta+alpha~=0&beta-alpha~=0);
            heigs=(log(beta(idx)+alpha(idx))-log(beta(idx)-alpha(idx)))/Ts;
            w_acc=ltipack.getAccLims(w_acc,Ts);
        end

