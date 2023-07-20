function[AngL,AngR,SpdL,SpdR,TrqIn]=automlvdynStrgParaArm(AngIn,SpdIn,Tr,w,l,TrqL,TrqR)

    coder.allowpcode('plain');
    coder.extrinsic('atan','acos','cos','sin');
    thetaL=-2*atan(((cos(AngIn)+1)*(cos(AngIn/2)*(-((Tr^2-2*cos(AngIn)*Tr*w+w^2)*(Tr^2-2*cos(AngIn)*Tr*w-4*l^2+w^2))/cos(AngIn/2)^4)^(1/2)+4*l*w*sin(AngIn/2)))/(2*cos(AngIn/2)*(Tr^2-2*cos(AngIn)*Tr*w+2*l*Tr+w^2-2*l*cos(AngIn)*w)));
    thetaR=-2*atan(((cos(AngIn)+1)*(cos(AngIn/2)*(-((Tr^2-2*cos(AngIn)*Tr*w+w^2)*(Tr^2-2*cos(AngIn)*Tr*w-4*l^2+w^2))/cos(AngIn/2)^4)^(1/2)-4*l*w*sin(AngIn/2)))/(2*cos(AngIn/2)*(Tr^2-2*cos(AngIn)*Tr*w+2*l*Tr+w^2-2*l*cos(AngIn)*w)));
    if~isreal(thetaL)

    end
    theta0=acos((Tr-w)/2/l);
    AngR=thetaL+theta0;
    AngL=-thetaR-theta0;
    omegaR=(SpdIn*w*(cos(AngIn)*sin(thetaL)-sin(AngIn)*cos(thetaL)))/(l*(cos(thetaL)*sin(thetaR)+cos(thetaR)*sin(thetaL)));
    omegaL=(SpdIn*w*(cos(AngIn)*sin(thetaR)+sin(AngIn)*cos(thetaR)))/(l*(cos(thetaL)*sin(thetaR)+cos(thetaR)*sin(thetaL)));
    SpdL=-omegaR;
    SpdR=-omegaL;
    T1=(TrqR*w*(cos(AngIn)*sin(thetaL)-sin(AngIn)*cos(thetaL)))/(l*(cos(thetaL)*sin(thetaR)+cos(thetaR)*sin(thetaL)));
    T2=(TrqL*w*(cos(AngIn)*sin(thetaR)+sin(AngIn)*cos(thetaR)))/(l*(cos(thetaL)*sin(thetaR)+cos(thetaR)*sin(thetaL)));
    TrqIn=T1+T2;
end