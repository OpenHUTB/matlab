function[VDot,phiDot,rDot]=BicycleStateDerivatives(V,beta,delta,Fyf,Fxr,Fyr,a,b,m,Iz)
%#codegen
    coder.allowpcode('plain');








    phiDot=(Fyf.*cos(delta-beta)+Fyr.*cos(beta)-Fxr.*sin(beta))./(m.*V);

    rDot=(a.*Fyf.*cos(delta)-b.*Fyr)./Iz;

    VDot=(-Fyf.*sin(delta-beta)+Fyr.*sin(beta)+Fxr.*cos(beta))./m;

end