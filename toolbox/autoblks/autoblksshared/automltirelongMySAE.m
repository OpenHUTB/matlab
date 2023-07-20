function My=automltirelongMySAE(Fz,omega,Vx,press,QSY1,QSY2,...
    QSY3,QSY7,QSY8,UNLOADED_RADIUS,FZMIN,FZMAX,PRESMIN,PRESMAX)%#codegen

    coder.allowpcode('plain')

    tempInds=press<PRESMIN;
    press(tempInds)=PRESMIN(tempInds);
    tempInds=press>PRESMAX;
    press(tempInds)=PRESMAX(tempInds);
    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);

    My=tanh(omega).*UNLOADED_RADIUS.*(QSY1+QSY2.*abs(Vx)+QSY3.*(Vx).^2).*...
    ((Fz).^QSY7.*(press).^QSY8);
end
