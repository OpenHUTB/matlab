function y=TRBDF3(M,C,K,B,F,G,D,u,t,x0,tau)
















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



    b=0.338;
    alpha=2*b;beta=2*alpha-1;
    g1=1-11/(4*b)+5/(4*b^2)-1/(8*b^3);
    g2=-b+3-3/(2*b)+1/(6*b^2);
    g3=-2+9/(2*b)-7/(4*b^2)+1/(6*b^3);
    g4=1-(g1+g3);
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

                aux=SOLVER(M*dq1-Kd*q1+Bd1);
                q2=q1+(2*bh)*aux;
                dq2=2*aux-dq1;

                aux=g1*q2+g2h*dq2+g3*q1+g4*qk;
                dqk=SOLVER(M*(g1*dq2+g3*dq1+g4*dqk)-...
                K*(g2h*q2+bh*aux)-C*(g2h*dq2)+Bd2);
                qk=aux+bh*dqk;
                y(:,k)=F*qk+G*dqk+D;
            end
        else

            Bd1=(bh/2)*B;
            uk=u(:,1);ukp1=u(:,min(2,Ns));
            y(:,1)=F*q0+G*dq0+D*uk;
            for k=2:Ns

                ukm1=uk;uk=ukp1;ukp1=u(:,min(k+1,Ns));
                u1=(1-alpha)*ukm1+alpha*uk;
                u2=(1-beta)*uk+beta*ukp1;

                aux=SOLVER(M*dqk-Kd*qk+Bd1*(ukm1+u1));
                q1=qk+(2*bh)*aux;
                dq1=2*aux-dqk;

                aux=SOLVER(M*dq1-Kd*q1+Bd1*(u1+u2));
                q2=q1+(2*bh)*aux;
                dq2=2*aux-dq1;

                aux=g1*q2+g2h*dq2+g3*q1+g4*qk;
                dqk=SOLVER(M*(g1*dq2+g3*dq1+g4*dqk)-...
                K*(g2h*q2+bh*aux)-C*(g2h*dq2)+B*(g2h*u2+bh*uk));
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
        z2buf=zeros(nfd,idmax);

        ioffset=(1:nfd)';
        Bd1=(bh/2)*B;
        y=zeros(ny,Ns);
        qk=q0;dqk=dq0;
        uk=u(:,1);ukp1=u(:,min(2,Ns));
        uwk=[uk;zeros(nfd,1)];
        y(:,1)=F1*q0+G1*dq0+D1*uwk;
        zbuf(:,1)=F2*q0+G2*dq0+D2*uwk;

        h2=beta*h;delta=h2/2;nu=size(u,1);
        u2=(1-beta)*uk+beta*ukp1;
        aux=B(:,1:nu)*(delta*(uk+u2));
        if any(q0)||any(dq0)||any(aux,'all')

            dq2=(M+delta*C+delta^2*K)\...
            (M*dq0-delta*(C*dq0)-K*(h2*q0+delta^2*dq0)+aux);
            q2=q0+delta*(dq0+dq2);
            z2buf(:,1)=F2*q2+G2*dq2+D2(:,1:nu)*u2;
        end

        for k=2:Ns
            ukm1=uk;uwkm1=uwk;uk=ukp1;
            ukp1=u(:,min(k+1,Ns));

            ix=ioffset+mod(k-id-1,idmax)*nfd;
            uwk=[uk;zbuf(ix)];
            uw1=[(1-alpha)*ukm1+alpha*uk;z1buf(ix)];
            uw2=[(1-beta)*uk+beta*ukp1;z2buf(ix)];

            aux=SOLVER(M*dqk-Kd*qk+Bd1*(uwkm1+uw1));
            q1=qk+(2*bh)*aux;
            dq1=2*aux-dqk;
            jz=mod(k-1,idmax)+1;
            z1buf(:,jz)=F2*q1+G2*dq1+D2*uw1;

            aux=SOLVER(M*dq1-Kd*q1+Bd1*(uw1+uw2));
            q2=q1+(2*bh)*aux;
            dq2=2*aux-dq1;
            z2buf(:,jz)=F2*q2+G2*dq2+D2*uw2;

            aux=g1*q2+g2h*dq2+g3*q1+g4*qk;
            dqk=SOLVER(M*(g1*dq2+g3*dq1+g4*dqk)-...
            K*(g2h*q2+bh*aux)-C*(g2h*dq2)+B*(g2h*uw2+bh*uwk));
            qk=aux+bh*dqk;
            zbuf(:,jz)=F2*qk+G2*dqk+D2*uwk;
            y(:,k)=F1*qk+G1*dqk+D1*uwk;
        end
    end
