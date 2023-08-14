function q=pdetriq_atx(p,t)




















    [ar,tmp1,tmp2,tmp3]=pdetrg_atx(p,t);

    h3sq=(p(1,t(1,:))-p(1,t(2,:))).^2+(p(2,t(1,:))-p(2,t(2,:))).^2;
    h1sq=(p(1,t(2,:))-p(1,t(3,:))).^2+(p(2,t(2,:))-p(2,t(3,:))).^2;
    h2sq=(p(1,t(3,:))-p(1,t(1,:))).^2+(p(2,t(3,:))-p(2,t(1,:))).^2;

    q=4*sqrt(3)*ar./(h1sq+h2sq+h3sq);

