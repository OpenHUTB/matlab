function[ad,bd,cd,dd]=mblkczp(g,xz,wz,xp,wp,ts)






    narginchk(5,6);
    if(nargin<6)
        ts=[];
    end
    if(isempty(ts))
        ts=0;
    end
    if(isempty(wz))
        k=g*prod(wp.^2);
    else
        k=g*prod(wp.^2)/prod(wz.^2);
    end
    xz=xz(:);wz=wz(:);
    xp=xp(:);wp=wp(:);
    imZ=sqrt(xz.^2-1);
    Z=[(-xz+imZ).*wz;(-xz-imZ).*wz];
    imP=sqrt(xp.^2-1);
    P=[(-xp+imP).*wp;(-xp-imP).*wp];
    [a,b,c,d]=zp2ss(Z,P,k);
    if(ts==0)
        ad=a;
        bd=b;
        cd=c;
        dd=d;
    else
        [nx,~]=size(a);
        I=eye(nx);
        P=(I-a.*ts/2);
        ad=(I+a.*ts/2)/P;
        bd=P\b;
        cd=ts*c/P;
        dd=cd*b/2+d;
    end
    return
