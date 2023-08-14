function y=TRBDF2(A,B,C,D,E,u,t,x0,tau)
















    h=t(2)-t(1);
    Ns=numel(t);
    nx=size(A,1);
    if isempty(x0)
        x0=zeros(nx,1);
    end
    if isempty(E)
        E=speye(nx);
    else

        if isempty(u)
            Bu=B(:,1);
        else
            Bu=B(:,1:size(u,1))*u(:,1);
        end
        hCIC=min(h/10,1e-4*(t(end)-t(1)));
        [~,x0]=ltipack.util.findCIC(A,E,Bu,x0,hCIC);
    end











    b=0.252;
    alpha=2*b;
    g1=-1+1.5/b-0.25/b^2;
    g2=b-2+0.5/b;
    g3=1-g1;
    bh=b*h;
    g2h=g2*h;
    Ed=E-bh*A;
    Ad1=E+bh*A;
    Ad2=g1*E+g2h*A;


    SOLVER=ltipack.spssdata.linearSolver(Ed);

    if isempty(tau)

        y=zeros(size(D,1),Ns);
        xk=x0;
        if isempty(u)


            Bd1=(2*bh)*B;Bd2=(bh+g2h)*B;
            y(:,1)=C*xk+D;
            for k=2:Ns
                x1=SOLVER(Ad1*xk+Bd1);
                xk=SOLVER(Ad2*x1+g3*(E*xk)+Bd2);
                y(:,k)=C*xk+D;
            end
        else

            Bd1=bh*B;
            uk=u(:,1);
            y(:,1)=C*xk+D*uk;
            for k=2:Ns
                ukm1=uk;uk=u(:,k);
                u1=(1-alpha)*ukm1+alpha*uk;
                x1=SOLVER(Ad1*xk+Bd1*(ukm1+u1));
                xk=SOLVER(Ad2*x1+g3*(E*xk)+B*(g2h*u1+bh*uk));
                y(:,k)=C*xk+D*uk;
            end
        end
    else



        if isempty(u)
            u=ones(1,Ns);
        end
        nfd=numel(tau);
        ny=size(D,1)-nfd;
        C1=C(1:ny,:);D1=D(1:ny,:);
        C2=C(ny+1:ny+nfd,:);D2=D(ny+1:ny+nfd,:);


        id=round(tau/h);
        idmax=max(id);
        zbuf=zeros(nfd,idmax);
        z1buf=zeros(nfd,idmax);

        ioffset=(1:nfd)';
        Bd1=bh*B;
        y=zeros(ny,Ns);
        xk=x0;
        uk=u(:,1);
        uwk=[uk;zeros(nfd,1)];
        y(:,1)=C1*xk+D1*uwk;
        zbuf(:,1)=C2*xk+D2*uwk;
        for k=2:Ns
            ukm1=uk;uwkm1=uwk;
            uk=u(:,k);

            ix=ioffset+mod(k-id-1,idmax)*nfd;
            uwk=[uk;zbuf(ix)];
            uw1=[(1-alpha)*ukm1+alpha*uk;z1buf(ix)];

            x1=SOLVER(Ad1*xk+Bd1*(uwkm1+uw1));
            jz=mod(k-1,idmax)+1;
            z1buf(:,jz)=C2*x1+D2*uw1;

            xk=SOLVER(Ad2*x1+g3*(E*xk)+B*(g2h*uw1+bh*uwk));
            zbuf(:,jz)=C2*xk+D2*uwk;
            y(:,k)=C1*xk+D1*uwk;
        end
    end