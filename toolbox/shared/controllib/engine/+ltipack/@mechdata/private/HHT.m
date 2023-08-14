function y=HHT(M,C,K,B,F,G,D,u,t,x0,tau)
















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
        d2q0=B-C*dq0-K*q0;
    else

        if isempty(u)
            Bu=B(:,1);
        else
            Bu=B(:,1:size(u,1))*u(:,1);
        end
        hCIC=min(h/10,1e-4*(t(end)-t(1)));
        [~,q0,dq0,d2q0]=findCIC(M,C,K,Bu,F,G,q0,dq0,hCIC);
    end



    alpha=0.05;
    gamma=1/2+alpha;
    beta=(1+alpha)^2/4;
    c1=(1-alpha)*gamma*h;
    c2=(1-alpha)*beta*h^2;
    c3=(1-alpha)*(1-gamma)*h;
    c4=(1-alpha)*h;
    c5=(1-alpha)*(0.5-beta)*h^2;
    c6=(0.5-beta)*h^2;
    c7=beta*h^2;
    c8=(1-gamma)*h;
    c9=gamma*h;



    Md=M+c1*C+c2*K;
    SOLVER=ltipack.spssdata.linearSolver(Md);

    if isempty(tau)

        y=zeros(size(D,1),Ns);
        qk=q0;dqk=dq0;d2qk=d2q0;
        if isempty(u)

            y(:,1)=F*q0+G*dq0+D;
            for k=2:Ns

                d2q_new=SOLVER(B-C*(dqk+c3*d2qk)-K*(qk+c4*dqk+c5*d2qk));

                qk=qk+h*dqk+c6*d2qk+c7*d2q_new;
                dqk=dqk+c8*d2qk+c9*d2q_new;
                d2qk=d2q_new;
                y(:,k)=F*qk+G*dqk+D;
            end
        else

            ukp1=u(:,min(1,Ns));
            y(:,1)=F*q0+G*dq0+D*u(:,1);
            for k=2:Ns
                uk=ukp1;ukp1=u(:,min(k+1,Ns));

                d2q_new=SOLVER(B*(alpha*uk+(1-alpha)*ukp1)-...
                C*(dqk+c3*d2qk)-K*(qk+c4*dqk+c5*d2qk));

                qk=qk+h*dqk+c6*d2qk+c7*d2q_new;
                dqk=dqk+c8*d2qk+c9*d2q_new;
                d2qk=d2q_new;
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

        ioffset=(1:nfd)';
        y=zeros(ny,Ns);
        qk=q0;dqk=dq0;d2qk=d2q0;
        uwk=[u(:,1);zeros(nfd,1)];
        y(:,1)=F1*q0+G1*dq0+D1*uwk;
        zbuf(:,1)=F2*q0+G2*dq0+D2*uwk;
        ix=ioffset+mod(1-id,idmax)*nfd;
        uwkp1=[u(:,min(2,Ns));zbuf(ix)];
        for k=2:Ns
            uwk=uwkp1;

            ix=ioffset+mod(k-id,idmax)*nfd;
            uwkp1=[u(:,min(k+1,Ns));zbuf(ix)];

            d2q_new=SOLVER(B*(alpha*uwk+(1-alpha)*uwkp1)-...
            C*(dqk+c3*d2qk)-K*(qk+c4*dqk+c5*d2qk));

            qk=qk+h*dqk+c6*d2qk+c7*d2q_new;
            dqk=dqk+c8*d2qk+c9*d2q_new;
            d2qk=d2q_new;
            y(:,k)=F1*qk+G1*dqk+D1*uwk;
            jz=mod(k-1,idmax)+1;
            zbuf(:,jz)=F2*qk+G2*dqk+D2*uwk;
        end
    end


