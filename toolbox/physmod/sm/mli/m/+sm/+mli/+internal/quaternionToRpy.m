function rpy=quaternionToRpy(quat)









    tol=1e-6;

    w=quat(1);
    x=quat(2);
    y=quat(3);
    z=quat(4);

    t2=2.0*(w*y-z*x);
    t2=min(1.0,t2);
    t2=max(-1.0,t2);
    if abs(t2)<tol
        t2=0;
    end
    p=asin(t2);

    t0=2.0*(w*x+y*z);
    t1=1.0-2.0*(x*x+y*y);
    if abs(t0)<tol
        t0=0;
    end
    if abs(t1)<tol
        t1=0;
    end

    t3=2.0*(w*z+x*y);
    t4=1.0-2.0*(y*y+z*z);
    if abs(t3)<sqrt(eps)
        t3=0;
    end
    if abs(t4)<sqrt(eps)
        t4=0;
    end

    if abs(t1)<tol&&abs(t0)<tol

        r=2*atan2(x,w);
        if r>pi
            r=r-2*pi;
        end
        if r<-pi
            r=r+2*pi;
        end
        y=0;
    else

        r=atan2(t0,t1);
        y=atan2(t3,t4);
    end

    rpy=[r,p,y];