function[Re,Fz]=automltireFzmagic(rhoz,omega,press,NOMPRES,PRESMIN,PRESMAX,gamma,Fxnew,Fynew,VERTICAL_STIFFNESS,UNLOADED_RADIUS,LONGVL,FNOMIN,...
    Q_V1,Q_V2,Q_FCX,Q_FCY,Q_FZ1,Q_FZ2,Q_FZ3,PFZ1,lam_Fzo)%#codegen
    coder.allowpcode('plain')





    Re=UNLOADED_RADIUS+rhoz+Q_V1.*abs(omega);
    tempInds=Re<1e-3;
    Re(tempInds)=1e-3;
    press(tempInds)=PRESMIN(tempInds);
    tempInds=press>PRESMAX;
    press(tempInds)=PRESMAX(tempInds);
    dpi=(press-NOMPRES)./NOMPRES;

    Fzo_prime=lam_Fzo.*FNOMIN;
    Fz=VERTICAL_STIFFNESS.*Fzo_prime.*(1+Q_V2.*abs(omega).*UNLOADED_RADIUS./LONGVL-(Q_FCX.*Fxnew./FNOMIN).^2-(Q_FCY.*Fynew./FNOMIN).^2).*...
    ((Q_FZ1+Q_FZ3.*gamma.^2).*rhoz./UNLOADED_RADIUS+Q_FZ2.*(rhoz./UNLOADED_RADIUS).^2).*(1+PFZ1.*dpi);
end