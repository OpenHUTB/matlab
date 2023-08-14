function[Fx]=automltirelongFx(kappa,Fz,...
    D,C,B,E,lam_mux,FZMIN,FZMAX)
%#codegen

    coder.allowpcode('plain')

    Dx=D(1,:);
    Cx=C(1,:);
    Bx=B(1,:);
    Ex=E(1,:);

    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);


    Fxo=Fz.*lam_mux.*magicsin(Dx,Cx,Bx,Ex,kappa);

    Gxalpha=1;
    Fx=Fxo.*Gxalpha;

end


function y=magicsin(D,C,B,E,u)
%#codegen
    y=D.*sin(C.*atan(B.*u-E.*(B.*u-atan(B.*u))));
end