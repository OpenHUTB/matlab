function pp=pdearcl_atx(p,xy,s,s0,s1)























    np=length(p);

    dal=sqrt((xy(1,2:np)-xy(1,1:np-1)).^2+...
    (xy(2,2:np)-xy(2,1:np-1)).^2);
    al=[0,cumsum(dal)];
    tl=al(np);
    s=s(:);
    sal=tl*(s-s0)/(s1-s0);
    pp=interp1(al,p,sal)';

