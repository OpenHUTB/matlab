function[R,Xint]=skin(f,Rdc,ur,Rext,Rint,SkinEffect)

















    if Rext<=Rint
        Erreur.identifier='SpecializedPowerSystems:PowerLineParam:InvalidSkinResistance';
        Erreur.message=sprintf('Rint (%g) must be smaller than Rext (%g)',Rint,Rext);
        psberror(Erreur);
    end
    u=4*pi*1e-7*ur;
    w=2*pi*f;
    r=Rext;q=Rint;
    if q==0,q=0.001*r;end
    switch SkinEffect
    case{0,'no','No','NO'}

        Ldc=2e-7*(q^4/(r^2-q^2)^2*log(r/q)-(3*q^2-r^2)/4/(r^2-q^2));
        R=Rdc;
        Xint=w*Ldc;
    case{1,'yes','Yes','YES'}

        rho=Rdc*(pi*Rext^2-pi*Rint^2);
        m=sqrt(j*w*u/rho);

        D=besseli(1,m*r)*besselk(1,m*q)-besseli(1,m*q)*besselk(1,m*r);
        Z=rho*m/(2*pi*r*D)*(besseli(0,m*r)*besselk(1,m*q)+besselk(0,m*r)*besseli(1,m*q));
        R=real(Z);
        Xint=imag(Z);
    end