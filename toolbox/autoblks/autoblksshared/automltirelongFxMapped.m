function[Fx]=automltirelongFxMapped(kappa,Fz,kappaFx,FzFx,FxMap,FZMIN,FZMAX,lam_mux)
%#codegen

    coder.allowpcode('plain')

    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);
    Fx=interp2(kappaFx,FzFx,FxMap',kappa,Fz,'linear',0).*lam_mux;
end