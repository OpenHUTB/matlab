function[heigs,w_acc]=HamConicTest(a,b,c,d,e,Ts,M0,W1,W2,sgn,r)



























    nx=size(a,1);
    nu=size(d,2);
    ncw1=size(W1,2);
    ncw2=size(W2,2);
    ncw=ncw1+ncw2;
    UseM0=(~isempty(M0));


    W12=[W1,r*W2];
    Z1=W12'*c;
    Z2=W12'*d;
    if UseM0

        aux=[c,d];
        M0=aux'*M0*aux;
        M0=(M0+M0')/2;
    end


    nZ2=norm(Z2,1);
    if nZ2>0
        Z2=Z2/nZ2;Z1=Z1/nZ2;M0=M0/nZ2^2;
    end


    aux=norm(Z1,1);
    if UseM0
        aux=max([aux,sqrt(norm(M0(1:nx,1:nx),1)),norm(M0(nx+1:nx+nu,1:nx),1)]);
    end
    tau=sqrt(aux/norm(b,1));
    b=tau*b;Z1=Z1/tau;


    if isempty(e)
        e=eye(nx);
    end
    if UseM0
        Q1=M0(1:nx,1:nx);
        S1=M0(1:nx,nx+1:nx+nu);
        R1=M0(nx+1:nx+nu,nx+1:nx+nu);
    else
        Q1=zeros(nx);S1=zeros(nx,nu);R1=zeros(nu);
    end
    R=[R1,Z2';Z2,diag(-[ones(1,ncw1),sgn*ones(1,ncw2)])];

    if Ts==0


        t=ltipack.scalePencil(norm(a,1),norm(b,1),1);
        if UseM0
            aux=t/tau;Q1=(aux^2)*Q1;S1=aux*S1;
        end
        [alpha,beta,w_acc]=ltipack.eigSHH(t^2*a,t^2*e,zeros(nx),Q1,R,...
        [t*b,zeros(nx,ncw)],[S1,t*Z1']);
        idx=find(beta~=0);
        heigs=alpha(idx)./beta(idx);
    else

        t=ltipack.scalePencil(norm(a,1)+norm(e,1),norm(b,1),1);
        if UseM0
            aux=t/tau;Q1=(aux^2)*Q1;S1=aux*S1;
        end
        BF=[t*b,zeros(nx,ncw)];
        [alpha,beta,w_acc]=ltipack.eigSHH(t^2*(a-e),t^2*(a+e),zeros(nx),...
        Q1,R,BF,[S1,t*Z1'],BF);





        Ts=abs(Ts);
        idx=find(abs(beta)>100*eps*abs(alpha)&beta+alpha~=0&beta-alpha~=0);
        heigs=(log(beta(idx)+alpha(idx))-log(beta(idx)-alpha(idx)))/Ts;
        w_acc=ltipack.getAccLims(w_acc,Ts);
    end
