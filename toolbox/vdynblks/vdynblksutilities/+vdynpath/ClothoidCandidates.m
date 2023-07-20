function[XClothoid,YClothoid,eC,sC,kappaC,thetaC,refPoseC,clothoidState,dk1OfChoice,dk2OfChoice]=clothoidRefGenV3(X0,Y0,Phi0,V0,r0,vehX,vehY,hrzX,hrzY,hrzPhiRef,hrzKappa)
%#codegen
    coder.allowpcode('plain');






    XClothoid=zeros(1,10);
    YClothoid=zeros(1,10);


    allowedAngleRange=pi/2;
    thetaArc0=hrzPhiRef;
    Rcirc=1/abs(hrzKappa);
    circArc=vdynpath.ClothoidCurve(hrzX,hrzY,thetaArc0,hrzKappa,0,allowedAngleRange/abs(hrzKappa));



    dk1Range=-0.005:0.0001:0.005;

    x0=X0;
    y0=Y0;


    p=[-0.0041,0.4597,2.8441];
    kappa0=sign(r0)*2*p(1)/(-p(2)+sqrt(p(2)^2-4*p(1)*(p(3)-V0)));
    kappaf=hrzKappa;
    theta0=Phi0;

    L1=pi/2*Rcirc/2;
    L2=pi/2*Rcirc/2;
    d2Circle=zeros(numel(dk1Range),1);
    for i=1:numel(dk1Range)
        dk1=dk1Range(i);
        dk2=(kappaf-kappa0-dk1*L1)/L2;
        CL1=vdynpath.ClothoidCurve(x0,y0,theta0,kappa0,dk1,L1);
        x1=CL1.xEnd();
        y1=CL1.yEnd();
        theta1=CL1.thetaEnd();
        kappa1=CL1.kappaEnd();
        CL2=vdynpath.ClothoidCurve(x1,y1,theta1,kappa1,dk2,L2);
        x2=CL2.xEnd();
        y2=CL2.yEnd();

        [~,~,~,d2Circle(i)]=circArc.closestPoint(x2,y2);


    end



    [~,minIndex]=min(abs(d2Circle));
    dk1OfChoice=dk1Range(minIndex);
    dk2OfChoice=(kappaf-kappa0-dk1OfChoice*L1)/L2;

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
        interval=Lc/9-eps;
        size(0:interval:Lc)
        [XClothoid,YClothoid,~,~]=CL1.evaluate(linspace(0,Lc,10));
    else
        [~,~,sCL2,~]=CL2.closestPoint(vehX,vehY);
        if sCL2<L2-1e-5
            clothoidState=2;
            Lc=CL2.L;
            interval=Lc/9-eps;
            size(0:interval:Lc)
            [XClothoid,YClothoid,~,~]=CL2.evaluate(linspace(0,Lc,10));
        else
            clothoidState=3;
            Lc=CL2.L;
            interval=Lc/9-eps;
            size(0:interval:Lc)
            [XClothoid,YClothoid,~,~]=CL2.evaluate(linspace(0,Lc,10));
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