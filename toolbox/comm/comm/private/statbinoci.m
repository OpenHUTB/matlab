function pci=statbinoci(x,n,alpha)





    nu1=2*x;
    nu2=2*(n-x+1);
    F=finv(alpha/2,nu1,nu2);
    lb=(nu1.*F)./(nu2+nu1.*F);


    xeq0=find(x==0);
    if~isempty(xeq0)
        lb(xeq0)=0;
    end


    nu1=2*(x+1);
    nu2=2*(n-x);
    F=finv(1-alpha/2,nu1,nu2);
    ub=(nu1.*F)./(nu2+nu1.*F);


    xeqn=find(x==n);
    if~isempty(xeqn)
        ub(xeqn)=1;
    end

    pci=[lb(:),ub(:)];
