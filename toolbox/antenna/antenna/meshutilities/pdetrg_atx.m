function[ar,g1x,g1y,g2x,g2y,g3x,g3y]=pdetrg_atx(p,t)















    a1=t(1,:);
    a2=t(2,:);
    a3=t(3,:);


    r23x=p(1,a3)-p(1,a2);
    r23y=p(2,a3)-p(2,a2);
    r31x=p(1,a1)-p(1,a3);
    r31y=p(2,a1)-p(2,a3);
    r12x=p(1,a2)-p(1,a1);
    r12y=p(2,a2)-p(2,a1);


    ar=abs(r31x.*r23y-r31y.*r23x)/2;

    if nargout==4
        a1=(r12x.*r31x+r12y.*r31y);
        a2=(r23x.*r12x+r23y.*r12y);
        a3=(r31x.*r23x+r31y.*r23y);
        g1x=0.25*a1./ar;
        g1y=0.25*a2./ar;
        g2x=0.25*a3./ar;
    else
        g1x=-0.5*r23y./ar;
        g1y=0.5*r23x./ar;
        g2x=-0.5*r31y./ar;
        g2y=0.5*r31x./ar;
        g3x=-0.5*r12y./ar;
        g3y=0.5*r12x./ar;
    end

