function My=automltirelongMyISO(Fz,omega,Tamb,Fpl,Cr,Kt,Tmeas,Re,FZMIN,FZMAX,TMIN,TMAX)%#codegen



    coder.allowpcode('plain')

    tempInds=Tamb<TMIN;
    Tamb(tempInds)=TMIN(tempInds);
    tempInds=Tamb>TMAX;
    Tamb(tempInds)=TMAX(tempInds);
    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);

    My=-tanh(omega).*Re.*(Fpl+Fz.*Cr.*1e-3./(1+Kt.*(Tamb-Tmeas)));
end
