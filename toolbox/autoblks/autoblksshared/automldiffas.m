function[y,xdot]=automldiffas(u,bw1,bd,bw2,Ndiff,Nl,Nr,shaftSwitch,Jd,Jw1,Jw2,Jgc,x)%#codegen



    coder.allowpcode('plain')

    NbdTerm=Ndiff.^2.*bd./4;
    Aprime=-[bw1+NbdTerm,NbdTerm;NbdTerm,NbdTerm+bw2];
    if shaftSwitch~=0
        diffDir=-1;
    else
        diffDir=1;
    end
    Jd=Jd+Jgc;
    Bprime=[diffDir./2.*Ndiff,-1,0,Nl/2,-Nr/2;diffDir./2.*Ndiff,0,-1,-1+Nl/2,1+Nr/2];
    C=[diffDir./2.*Ndiff,diffDir./2.*Ndiff;-1,0;0,-1;-Nl/2,1-Nl/2;Nr/2,-1+Nr/2];
    D=zeros(5,5);
    term1=Ndiff.^2.*Jd;
    term2=(term1*Jw1+4*Jw1*Jw2+Jw2*term1);
    invJ=[(Jw2.*4+term1)./term2,-term1./term2;-term1./term2,(Jw1.*4+term1)./term2];
    xdot=invJ*Bprime*u+invJ*Aprime*x;
    y=C*x+D*u;