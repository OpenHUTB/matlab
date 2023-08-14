function[ns,m,no,x0]=mblkdel(tau,y0,ts)







    if(isempty(y0))
        y0=0;
    end
    y0=y0(:);
    no=size(y0,1);
    h=ts(1);
    if(h==-1)
        nh=floor(tau)+1;
    else
        nh=tau/h;
    end
    ns=floor(nh);
    m=nh-floor(nh);
    x0=y0(:,ones(1,ns+1));
    x0=x0(:);
    return


