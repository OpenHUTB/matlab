function My=automltirelongMyMapped(omega,Fz,Vx,VxMy,FzMy,MyMap,FZMAX)
%#codegen

    coder.allowpcode('plain')


    FZMIN=0;
    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);

    My=tanh(omega).*interp2(VxMy,FzMy,MyMap',Vx,Fz,'linear',0);

end
