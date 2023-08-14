function y=TRBDF2(M,C,K,B,F,G,D,u,t,x0,tau)
















    h=t(2)-t(1);
    Ns=numel(t);
    nq=size(K,1);
    if isempty(x0)
        q0=zeros(nq,1);dq0=q0;
    else
        q0=x0(1:nq,:);dq0=x0(nq+1:2*nq);
    end
    if isempty(M)
        M=speye(nq);
    else

        if isempty(u)
            Bu=B(:,1);
        else
            Bu=B(:,1:size(u,1))*u(:,1);
        end
        hCIC=min(h/10,1e-4*(t(end)-t(1)));
        [~,q0,dq0]=findCIC(M,C,K,Bu,F,G,q0,dq0,hCIC);
    end










    b=0.252;
    alpha=2*b;
    g1=-1+1.5/b-0.25/b^2;
    g2=b-2+0.5/b;
    g3=1-g1;
    bh=b*h;
    g2h=g2*h;
    Md=M+bh*C+bh^2*K;
    Kd=bh*K;


    SOLVER=ltipack.spssdata.linearSolver(Md);

    if isempty(tau)

        y=zeros(size(D,1),Ns);
        qk=q0;dqk=dq0;
        if isempty(u)

            Bd1=bh*B;Bd2=(bh+g2h)*B;
            y(:,1)=F*q0+G*dq0+D;
            for k=2:Ns

                aux=SOLVER(M*dqk-Kd*qk+Bd1);
                q1=qk+(2*bh)*aux;
                dq1=2*aux-dqk;

                aux=g1*q1+g2h*dq1+g3*qk;
                dqk=SOLVER(M*(g1*dq1+g3*dqk)-K*(g2h*q1+bh*aux)-C*(g2h*dq1)+Bd2);
                qk=aux+bh*dqk;
                y(:,k)=F*qk+G*dqk+D;
            end
        else

            Bd1=(bh/2)*B;
            uk=u(:,1);
            y(:,1)=F*q0+G*dq0+D*uk;
            for k=2:Ns
                ukm1=uk;uk=u(:,k);
                u1=(1-alpha)*ukm1+alpha*uk;

                aux=SOLVER(M*dqk-Kd*qk+Bd1*(ukm1+u1));
                q1=qk+(2*bh)*aux;
                dq1=2*aux-dqk;

                aux=g1*q1+g2h*dq1+g3*qk;
                dqk=SOLVER(M*(g1*dq1+g3*dqk)-...
                K*(g2h*q1+bh*aux)-C*(g2h*dq1)+B*(g2h*u1+bh*uk));
                qk=aux+bh*dqk;
                y(:,k)=F*qk+G*dqk+D*uk;
            end
        end
    else



        if isempty(u)
            u=ones(1,Ns);
        end
        nfd=numel(tau);
        ny=size(D,1)-nfd;
        F1=F(1:ny,:);G1=G(1:ny,:);D1=D(1:ny,:);
        F2=F(ny+1:ny+nfd,:);G2=G(ny+1:ny+nfd,:);D2=D(ny+1:ny+nfd,:);


        id=round(tau/h);
        idmax=max(id);
        zbuf=zeros(nfd,idmax);
        z1buf=zeros(nfd,idmax);

        ioffset=(1:nfd)';
        Bd1=(bh/2)*B;
        y=zeros(ny,Ns);
        qk=q0;dqk=dq0;
        uk=u(:,1);
        uwk=[uk;zeros(nfd,1)];
        y(:,1)=F1*q0+G1*dq0+D1*uwk;
        zbuf(:,1)=F2*q0+G2*dq0+D2*uwk;
        for k=2:Ns
            ukm1=uk;uwkm1=uwk;
            uk=u(:,k);

            ix=ioffset+mod(k-id-1,idmax)*nfd;
            uwk=[uk;zbuf(ix)];
            uw1=[(1-alpha)*ukm1+alpha*uk;z1buf(ix)];

            aux=SOLVER(M*dqk-Kd*qk+Bd1*(uwkm1+uw1));
            q1=qk+(2*bh)*aux;
            dq1=2*aux-dqk;
            jz=mod(k-1,idmax)+1;
            z1buf(:,jz)=F2*q1+G2*dq1+D2*uw1;

            aux=g1*q1+g2h*dq1+g3*qk;
            dqk=SOLVER(M*(g1*dq1+g3*dqk)-K*(g2h*q1+bh*aux)-...
            C*(g2h*dq1)+B*(g2h*uw1+bh*uwk));
            qk=aux+bh*dqk;
            zbuf(:,jz)=F2*qk+G2*dqk+D2*uwk;
            y(:,k)=F1*qk+G1*dqk+D1*uwk;
        end
    end
