function[Fx,My,kappa]=automltirelong(Re,Fz,omega,Vx,lam_mux,...
    D,C,B,E,FZMAX,VXLOW,kappamax,press,FNOMIN,NOMPRES,QSY1,QSY2,...
    QSY3,QSY4,QSY5,QSY6,QSY7,QSY8,gamma,lam_My,UNLOADED_RADIUS,PRESMIN,PRESMAX)
%#codegen

    coder.allowpcode('plain')

    Dx=D(1,:);
    Cx=C(1,:);
    Bx=B(1,:);
    Ex=E(1,:);







    [~,Vxpabs]=div0protect(Vx,VXLOW);
    FZMIN=0;
    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);
    tempInds=Re<1e-3;
    Re(tempInds)=1e-3;
    tempInds=press<PRESMIN;
    press(tempInds)=PRESMIN(tempInds);
    tempInds=press>PRESMAX;
    press(tempInds)=PRESMAX(tempInds);




    kappa=(Re.*omega-Vx)./Vxpabs;
    kappa(kappa<-kappamax)=-kappamax;
    kappa(kappa>kappamax)=kappamax;


    Fxo=Fz.*lam_mux.*magicsin(Dx,Cx,Bx,Ex,kappa);

    Gxalpha=1;
    Fx=Fxo.*Gxalpha;


    My=tanh(omega).*rollingMoment(Fx,Vx,Fz,press,UNLOADED_RADIUS,FNOMIN,NOMPRES,QSY1,QSY2,QSY3,QSY4,QSY5,QSY6,gamma,QSY7,QSY8,lam_My);

end


function y=magicsin(D,C,B,E,u)
%#codegen
    y=D.*sin(C.*atan(B.*u-E.*(B.*u-atan(B.*u))));
end





function My=rollingMoment(Fx,Vx,Fz,press,UNLOADED_RADIUS,FNOMIN,NOMPRES,QSY1,QSY2,QSY3,QSY4,QSY5,QSY6,gamma,QSY7,QSY8,lam_My)

    LONGVL=16.7;
    My=Fz.*UNLOADED_RADIUS*(QSY1+QSY2.*Fx./FNOMIN+QSY3.*abs(Vx./LONGVL)+QSY4.*(Vx./LONGVL).^4+(QSY5+QSY6.*Fz./FNOMIN).*gamma.^2).*...
    ((Fz./FNOMIN).^QSY7.*(press./NOMPRES).^QSY8).*lam_My;
end

function[y,yabs]=div0protect(u,tol)
%#codegen
    yabs=abs(u);
    ytolinds=yabs<tol;
    yabs(ytolinds)=2.*tol(ytolinds)./(3-(yabs(ytolinds)./tol(ytolinds)).^2);
    yneginds=u<0;
    y=yabs;
    y(yneginds)=-yabs(yneginds);
end