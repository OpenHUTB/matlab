

function[bin,H,Hx,G,Gx]=evalHermiteBases(x,n,t,m,extrapMethod)

    H=zeros(m,2);
    Hx=zeros(m,2);
    G=zeros(m,2);
    Gx=zeros(m,2);



    [~,~,bin]=histcounts(t,x);


    indInterp=bin~=0;
    binInterp=bin(indInterp);


    x_lb=x(binInterp);
    Dx=x(binInterp+1)-x_lb;
    s=(t(indInterp)-x_lb)./Dx;


    s_sq=s.^2;
    s_cu=s_sq.*s;
    ss=2*s_cu-3*s_sq;
    H(indInterp,:)=[(ss+1),-ss];
    Hx(indInterp,:)=[(s_cu-2*s_sq+s).*Dx,(s_cu-s_sq).*Dx];



    if nargout>3
        sss=6*(s_sq-s)./Dx;
        G(indInterp,:)=[sss,-sss];
        Gx(indInterp,:)=[(3*s_sq-4*s+1),(3*s_sq-2*s)];
    end


    indExtrapL=t<x(1);
    bin(indExtrapL)=1;



    H(indExtrapL,1)=1;
    Hx(indExtrapL,1)=(t(indExtrapL)-x(1))*extrapMethod;



    if nargout>3
        Gx(indExtrapL,1)=extrapMethod;
    end


    indExtrapU=t>x(n);
    bin(indExtrapU)=n-1;



    H(indExtrapU,2)=1;
    Hx(indExtrapU,2)=(t(indExtrapU)-x(n))*extrapMethod;



    if nargout>3
        Gx(indExtrapU,2)=extrapMethod;
    end

end