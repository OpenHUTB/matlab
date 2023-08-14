function[XClothoid,YClothoid,eC,sC,kappaC,thetaC,refPoseC,clothoidState,dk1OfChoice,dk2OfChoice]=clothoidRefGenV3_noForLoop(X0,Y0,Phi0,V0,r0,vehX,vehY,hrzX,hrzY,hrzPhiRef,hrzKappa,dk1opPrev,dk2opPrev)
%#codegen
    coder.allowpcode('plain');





    x0=X0;
    y0=Y0;


    XClothoid=zeros(1,10);
    YClothoid=zeros(1,10);


    clothoidLengths=zeros(1,10);



    p=[-0.0041,0.4597,2.8441];
    kappa0=sign(r0)*2*p(1)/(-p(2)+sqrt(p(2)^2-4*p(1)*(p(3)-V0)));
    theta0=Phi0;

    Rcirc=1/abs(hrzKappa);
    L1=pi/2*Rcirc/2;
    L2=pi/2*Rcirc/2;
    dk1OfChoice=dk1opPrev;
    dk2OfChoice=dk2opPrev;
    CL1=vdynpath.ClothoidCurve(x0,y0,theta0,kappa0,dk1OfChoice,L1);
    x1=CL1.xEnd();
    y1=CL1.yEnd();
    theta1=CL1.thetaEnd();
    kappa1=CL1.kappaEnd();
    CL2=vdynpath.ClothoidCurve(x1,y1,theta1,kappa1,dk2OfChoice,L2);



    [~,~,sCL1,~]=CL1.closestPoint(vehX,vehY);
    if sCL1<L1-1e-5
        clothoidState=1;
        Lc=CL1.L;

        clothoidLengths=linspace(0,Lc,10);

        [XClothoid,YClothoid,~,~]=CL1.evaluate(clothoidLengths);
    else
        [~,~,sCL2,~]=CL2.closestPoint(vehX,vehY);
        if sCL2<L2-1e-5
            clothoidState=2;
            Lc=CL2.L;

            clothoidLengths=linspace(0,Lc,10);

            [XClothoid,YClothoid,~,~]=CL2.evaluate(clothoidLengths);
        else
            clothoidState=3;
            Lc=CL2.L;

            clothoidLengths=linspace(0,Lc,10);

            [XClothoid,YClothoid,~,~]=CL2.evaluate(clothoidLengths);
        end
    end

    thetaC=0;
    kappaC=0;
    Xc=0;
    Yc=0;
    sC=0;
    dC=0;

    switch clothoidState
    case 1
        [Xc,Yc,sC,dC]=CL1.closestPoint(vehX,vehY);
        [~,~,thetaC,kappaC]=CL1.evaluate(sC);
    case 2
        [Xc,Yc,sC,dC]=CL2.closestPoint(vehX,vehY);
        [~,~,thetaC,kappaC]=CL2.evaluate(sC);
    case 3
        [Xc,Yc,sC,dC]=CL2.closestPoint(vehX,vehY);
        [~,~,thetaC,kappaC]=CL2.evaluate(sC);
    end


    eSign=cos(thetaC)*(vehY-Yc)-sin(thetaC)*(vehX-Xc);
    eC=dC*eSign;



    refPoseC=[Xc,Yc]';

end