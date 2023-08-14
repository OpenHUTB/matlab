function p=makeBoundingCircle(r,loc)

    N=500;
    del_phi=360/N;
    phi_start=0;
    phi_end=360-del_phi;
    phi=unique([linspace(phi_start,phi_end,N),90,270]);
    p=em.internal.makecircle(r,phi);
    p=em.internal.translateshape(p,[loc(1),loc(2),0]);