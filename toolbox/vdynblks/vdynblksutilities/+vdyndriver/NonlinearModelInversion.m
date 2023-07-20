function[gamma,delta,FxrDes]=NonlinearModelInversion(phiDotDes,rDotDes,r,Vx,Vy,beta,vparams,~)
%#codegen
    coder.allowpcode('plain');










    a=vparams(1);
    b=vparams(2);
    m=vparams(3);
    Iz=vparams(4);
    muFrctn=vparams(5);
    Calpha=vparams(6);
    mFront=b/(a+b)*m;
    mRear=a/(a+b)*m;




    V=sqrt(Vx^2+Vy^2);
    vx=V*cos(beta);
    vy=V*sin(beta);
    deltaThreshold1=0.85*atan((vy+r*a)/vx)+0.18*exp(min(beta,-0.01));
    deltaThreshold2=1.15*atan((vy+r*a)/vx)-0.18*exp(min(beta,-0.01));

    deltaVec=linspace(deltaThreshold2,deltaThreshold1,101);


    g=9.81;
    Fzr=mRear*g;


    Fzf=mFront*g;


    Fyf=vdyndriver.Fiala(deltaVec,vx,vy,r,Fzf,muFrctn,Calpha,a);


    Fyr=1/b*(a.*Fyf.*cos(deltaVec)-rDotDes.*Iz);

    Fxr=sqrt(max(muFrctn^2*Fzr.^2-Fyr.^2,0));

    gammaVec=atan2(Fyr,Fxr);



    [~,phiDot,~]=vdyndriver.BicycleStateDerivatives(V,beta,deltaVec,Fyf,Fxr,Fyr,a,b,m,Iz);


    ErrOfPhiDot=(phiDot-phiDotDes).^2;
    [~,indMin]=min(ErrOfPhiDot(:));
    delta=deltaVec(indMin);
    gamma=gammaVec(indMin);
    FxrDes=Fxr(indMin);

end

