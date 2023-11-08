function[heigs,w_acc]=HamGainTest(a,b,c,d,e,Ts,gam,UseExplicit)

    nx=size(a,1);
    [ny,nu]=size(d);
    if nargin<8
        UseExplicit=false;
    end

    if UseExplicit&&Ts==0&&isempty(e)









        if isinf(gam)
            J=zeros(2*nx);
        else
            J=[zeros(nx,ny),b;c',zeros(nx,nu)]*...
            ([gam*eye(ny),d;d',gam*eye(nu)]\[c,zeros(ny,nx);zeros(nu,nx),-b']);
        end
        [heigs,hnorm]=HamEig(a-J(1:nx,1:nx),-J(1:nx,nx+1:2*nx),-J(nx+1:2*nx,1:nx));
        rtol=sqrt(eps);
        w_acc=hnorm*[rtol,1/rtol];

    else

        sqrt_gam=sqrt(gam);
        if isempty(e)
            e=eye(nx);
        end
        aux=d/gam;
        R=[eye(nu),aux';aux,eye(ny)];
        GQ=zeros(nx);

        if Ts==0


            t=ltipack.scalePencil(norm(a,1),norm(b,1)/sqrt_gam,1);
            tg=t/sqrt_gam;


            [alpha,beta,w_acc]=ltipack.eigSHH(t^2*a,t^2*e,GQ,GQ,...
            R,[tg*b,zeros(nx,ny)],[zeros(nx,nu),tg*c']);


            idx=find(beta~=0);
            heigs=alpha(idx)./beta(idx);
        else


            t=ltipack.scalePencil(norm(a,1)+norm(e,1),norm(b,1)/sqrt_gam,1);
            tg=t/sqrt_gam;


            BF=[tg*b,zeros(nx,ny)];
            [alpha,beta,w_acc]=ltipack.eigSHH(t^2*(a-e),t^2*(a+e),GQ,GQ,...
            R,BF,[zeros(nx,nu),tg*c'],BF);





            Ts=abs(Ts);
            idx=find(abs(beta)>100*eps*abs(alpha)&beta+alpha~=0&beta-alpha~=0);
            heigs=(log(beta(idx)+alpha(idx))-log(beta(idx)-alpha(idx)))/Ts;
            w_acc=ltipack.getAccLims(w_acc,Ts);
        end
    end
