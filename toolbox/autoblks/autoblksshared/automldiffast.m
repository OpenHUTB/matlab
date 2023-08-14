function[y,xdot]=automldiffast(u,bw1,bd,bw2,Ndiff,Nl,Nr,shaftSwitch,Jd,Jw1,Jw2,Js1,Js2,Jc1,Jc2,Jr1,Jr2,x)%#codegen



    coder.allowpcode('plain')
    NbdTerm=Ndiff.^2.*bd./4;
    Aprime=-[bw1+NbdTerm,NbdTerm;NbdTerm,NbdTerm+bw2];

    if shaftSwitch~=0
        diffDir=-1;
    else
        diffDir=1;
    end
    Jd=Jd+Js1+Js2;
    Jw1=Jw1+Jr1;
    Jw2=Jw2+Jr2;
    H11=Nl./(2.*(Nl-1));
    H12=(2-Nl)./(2.*(Nl-1));
    H21=Nr./(2.*(Nr-1));
    H22=(2-Nr)./(2.*(Nr-1));
    Bprime=[diffDir./2.*Ndiff,-1,0,H12,-H21;diffDir./2.*Ndiff,0,-1,-H11,H22];
    C=[diffDir./2.*Ndiff,diffDir./2.*Ndiff;-1,0;0,-1;-H12,H11;H21,-H22];
    D=zeros(5,5);
    term1=(4*Jw1*Jw2+4*H11^2*Jc1*Jw1+4*H12^2*Jc1*Jw2+4*H21^2*Jc2*Jw2+4*H22^2*Jc2*Jw1+Jd*Jw1*Ndiff^2+...
    Jd*Jw2*Ndiff^2+4*H11^2*H21^2*Jc1*Jc2+4*H12^2*H22^2*Jc1*Jc2+H11^2*Jc1*Jd*Ndiff^2+H12^2*Jc1*Jd*Ndiff^2+...
    H21^2*Jc2*Jd*Ndiff^2+H22^2*Jc2*Jd*Ndiff^2+2*H11*H12*Jc1*Jd*Ndiff^2+2*H21*H22*Jc2*Jd*Ndiff^2-8*H11*H12*H21*H22*Jc1*Jc2);
    term2=(-Jd*Ndiff^2+4*H11*H12*Jc1+4*H21*H22*Jc2)/term1;
    invJ=[(4*Jc1*H11^2+4*Jc2*H22^2+Jd*Ndiff^2+4*Jw2)./term1,term2;...
    term1,(4*Jc1*H12^2+4*Jc2*H21^2+Jd*Ndiff^2+4*Jw1)./term1];
    xdot=invJ*Bprime*u+invJ*Aprime*x;
    y=C*x+D*u;

