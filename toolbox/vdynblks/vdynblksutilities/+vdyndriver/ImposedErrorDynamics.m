function[phiDotDesPreSat,rDotDesPreSat]=ImposedErrorDynamics(V,e,kappaRef,phi,phiRef,beta,betaRef,dBetaDs,r,cparams1)

%#codegen
    coder.allowpcode('plain');



    phiDotDes=0;%#ok<NASGU> 
    rDotDes=0;%#ok<NASGU> 
    kRef=kappaRef;
    kp=cparams1(1);
    kd=cparams1(2);

    deltaPhi=phi-phiRef;






    phiDotRef=V*kRef*cos(deltaPhi)/(1-kRef*e);

    phiDotDes=(-kp./V.*e-kd.*deltaPhi)+phiDotRef;

    phiDotDesMin=-2;
    phiDotDesMax=2;
    phiDotDesPreSat=min(phiDotDesMax,max(phiDotDes,phiDotDesMin));


    kp=cparams1(1);
    kd=cparams1(2);
    kr=cparams1(3);
    kBeta=cparams1(4);

    deltaPhi=phi-phiRef;



    eBeta=beta-betaRef;


    dsDt=V.*cos(deltaPhi);

    betaDotRef=dBetaDs.*dsDt;


    rSyn=phiDotDesPreSat+kBeta.*eBeta-betaDotRef;







    rDotRefNull=0;


    rDotSyn=(kd.^2-kp).*deltaPhi+e.*kd.*kp./V-kBeta.^2.*eBeta+rDotRefNull;


    rDotDes=-kr.*(r-rSyn)+rDotSyn;

    rDotDesMin=-3;
    rDotDesMax=3;
    rDotDesPreSat=min(rDotDesMax,max(rDotDes,rDotDesMin));






