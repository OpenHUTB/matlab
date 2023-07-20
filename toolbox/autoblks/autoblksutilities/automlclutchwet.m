
function[Tc,q,hdot]=automlclutchwet(Papp,wrel,muf,mui,Ared,h,phi,phif,phifs,...
    Ndisks,ri,ro,d,E,ho,beta,...
    rho_a,sigmaf,sigmas,Kperm)%#codegen
    coder.allowpcode('plain')
    Kperm=Kperm.*9.869233e-13;
    sigma=sqrt(sigmaf.^2+sigmas.^2);
    sigmahat=sigma./ho;

    x=h./sigma;
    Fl=(2^(1/2).*(exp(-x.^2./2)+(2^(1/2).*x.*pi^(1/2)*(erf((2.^(1/2).*x)./2)-1))./2))./(2*pi^(1/2));

    Adisk=pi.*(ro.^2-ri.^2);
    An=Adisk.*Ared;

    Ar=An.*pi.*rho_a.*beta.*sigma.*Fl;


    Pa=E.*Ar./An;



    Q=ro.^4./16-ri.^4./16-(((ri.^2.*(log(ri./ro)-1/2))./2+ro.^2./4).*(ri-ro).^2)./(4.*log(ri./ro));


    Fhatapp=(ro.^2-ri.^2)./(2.*ro^2);
    gamma=Fhatapp.*Papp.*ho.^2./12./mui./ro.^2./Q;



    hhat=h./ho;
    g=1/2.*(1+erf(hhat./sqrt(2)./sigmahat));

    chi=0.2;
    eta=1./(1+chi.*h./sqrt(Kperm));



    dhat=d./ho;
    Khatperm=Kperm./ho.^2;

    delta=(hhat.^3.*(1+eta)+12.*Khatperm.*dhat)./hhat.^3;
    zeta=(Papp-Pa)./Papp;
    hhatdot=(-phi.*zeta.*delta./g./Ared.*gamma.*hhat.^3);
    hdot=hhatdot.*ho;

    Th=mui.*Ndisks.*(phif+phifs).*2.*pi.*(wrel*(ro.^4-ri.^4))./(4.*h);
    Ta=muf.*Ndisks.*2.*pi.*(Pa.*(ro.^3-ri.^3))./3.*tanh(4.*wrel);

    Tc=Ta+Th;

    q=abs(Tc.*wrel);