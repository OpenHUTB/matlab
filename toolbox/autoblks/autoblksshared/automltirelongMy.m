function My=automltirelongMy(Fx,Fz,Omega,Vx,press,FNOMIN,NOMPRES,QSY1,QSY2,...
    QSY3,QSY4,QSY5,QSY6,QSY7,QSY8,gamma,lam_My,UNLOADED_RADIUS,FZMAX,PRESMIN,PRESMAX)
%#codegen

    coder.allowpcode('plain')
    tempInds=press<PRESMIN;
    press(tempInds)=PRESMIN;
    tempInds=press>PRESMAX;
    press(tempInds)=PRESMAX;
    FZMIN=0;
    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN;
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX;

    LONGVL=16.7;
    My=tanh(Omega).*Fz.*UNLOADED_RADIUS.*(QSY1+QSY2.*Fx./FNOMIN+QSY3.*abs(Vx./LONGVL)+QSY4.*(Vx./LONGVL).^4+(QSY5+QSY6.*Fz./FNOMIN).*gamma.^2).*...
    ((Fz./FNOMIN).^QSY7.*(press./NOMPRES).^QSY8).*lam_My;
end
