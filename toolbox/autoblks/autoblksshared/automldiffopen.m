function[y,xdot]=automldiffopen(u,bw1,bd,bw2,Ndiff,shaftSwitch,Jd,Jw1,Jw2,x)%#codegen




    coder.allowpcode('plain')
    NbdTerm=Ndiff.^2.*bd./4;
    Aprime=-[bw1+NbdTerm,NbdTerm;NbdTerm,NbdTerm+bw2];
    if shaftSwitch~=0
        diffDir=-1;
    else
        diffDir=1;
    end
    Bprime=[diffDir./2.*Ndiff,-1,0;diffDir./2.*Ndiff,0,-1];
    C=[diffDir./2.*Ndiff,diffDir./2.*Ndiff;-1,0;0,-1];
    D=zeros(3,3);
    term1=Ndiff.^2.*Jd;
    term2=(term1*Jw1+4*Jw1*Jw2+Jw2*term1);
    invJ=[(Jw2.*4+term1)./term2,-term1./term2;-term1./term2,(Jw1.*4+term1)./term2];
    xdot=invJ*Bprime*u+invJ*Aprime*x;
    y=C*x+D*u;