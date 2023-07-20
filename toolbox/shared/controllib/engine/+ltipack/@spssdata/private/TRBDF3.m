function y=TRBDF3(A,B,C,D,E,u,t,x0,tau)
















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



    b=0.338;
    alpha=2*b;beta=2*alpha-1;
    g1=1-11/(4*b)+5/(4*b^2)-1/(8*b^3);
    g2=-b+3-3/(2*b)+1/(6*b^2);
    g3=-2+9/(2*b)-7/(4*b^2)+1/(6*b^3);
    g4=1-(g1+g3);
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
                x2=SOLVER(Ad1*x1+Bd1);
                xk=SOLVER(Ad2*x2+E*(g3*x1+g4*xk)+Bd2);
                y(:,k)=C*xk+D;
            end
        else

            Bd1=bh*B;
            uk=u(:,1);ukp1=u(:,min(2,Ns));
            y(:,1)=C*xk+D*uk;
            for k=2:Ns

                ukm1=uk;uk=ukp1;ukp1=u(:,min(k+1,Ns));
                u1=(1-alpha)*ukm1+alpha*uk;
                u2=(1-beta)*uk+beta*ukp1;
                x1=SOLVER(Ad1*xk+Bd1*(ukm1+u1));
                x2=SOLVER(Ad1*x1+Bd1*(u1+u2));
                xk=SOLVER(Ad2*x2+E*(g3*x1+g4*xk)+B*(g2h*u2+bh*uk));
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
        z2buf=zeros(nfd,idmax);

        ioffset=(1:nfd)';
        Bd1=bh*B;
        y=zeros(ny,Ns);
        xk=x0;
        uk=u(:,1);ukp1=u(:,min(2,Ns));
        uwk=[uk;zeros(nfd,1)];
        y(:,1)=C1*xk+D1*uwk;
        zbuf(:,1)=C2*xk+D2*uwk;

        delta=beta*h/2;nu=size(u,1);
        u2=(1-beta)*uk+beta*ukp1;
        aux=B(:,1:nu)*(delta*(uk+u2));
        if any(x0)||any(aux,'all')
            x2=(E-delta*A)\((E+delta*A)*x0+aux);
            z2buf(:,1)=C2*x2+D2(:,1:nu)*u2;
        end

        for k=2:Ns
            ukm1=uk;uwkm1=uwk;uk=ukp1;
            ukp1=u(:,min(k+1,Ns));

            ix=ioffset+mod(k-id-1,idmax)*nfd;
            uwk=[uk;zbuf(ix)];
            uw1=[(1-alpha)*ukm1+alpha*uk;z1buf(ix)];
            uw2=[(1-beta)*uk+beta*ukp1;z2buf(ix)];

            x1=SOLVER(Ad1*xk+Bd1*(uwkm1+uw1));
            jz=mod(k-1,idmax)+1;
            z1buf(:,jz)=C2*x1+D2*uw1;

            x2=SOLVER(Ad1*x1+Bd1*(uw1+uw2));
            z2buf(:,jz)=C2*x2+D2*uw2;

            xk=SOLVER(Ad2*x2+E*(g3*x1+g4*xk)+B*(g2h*uw2+bh*uwk));
            zbuf(:,jz)=C2*xk+D2*uwk;
            y(:,k)=C1*xk+D1*uwk;
        end
    end