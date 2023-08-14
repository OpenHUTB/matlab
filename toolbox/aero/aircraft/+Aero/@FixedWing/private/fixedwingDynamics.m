function dydt=fixedwingDynamics(aircraft,state)




    [F,M]=aircraft.forcesAndMoments(state);

    sinPhi=state.sin(state.Phi);
    cosPhi=state.cos(state.Phi);
    tanTheta=state.tan(state.Theta);
    secTheta=state.sec(state.Theta);

    pqr=[state.P;state.Q;state.R];

    if aircraft.AngleSystem=="Degrees"
        pqr=deg2rad(pqr);
    end

    if aircraft.UnitSystem=="English (kts)"
        uvw=convvel(state.GroundVelocity',"kts","ft/s");
    else
        uvw=state.GroundVelocity';
    end

    phithetapsiDot=[
    1,sinPhi*tanTheta,cosPhi*tanTheta;
    0,cosPhi,-sinPhi;
    0,sinPhi*secTheta,cosPhi*secTheta]*pqr;

    pqrMat=[
    0,pqr(3),-pqr(2);
    -pqr(3),0,pqr(1);
    pqr(2),-pqr(1),0];


    inertia=state.Inertia.Variables;
    pqrDot=inertia\(pqrMat*inertia*pqr+M);

    uvwDot=cross(-pqr,uvw)+(1/state.Mass)*F;

    PnedDot=state.BodyToInertialMatrix*uvw;

    if aircraft.AngleSystem=="Degrees"
        pqrDot=rad2deg(pqrDot);
        phithetapsiDot=rad2deg(phithetapsiDot);
    end

    if aircraft.UnitSystem=="English (kts)"
        uvwDot=convvel(uvwDot,"ft/s","kts");
    end


    switch aircraft.DegreesOfFreedom
    case "PM4"
        dydt=zeros(4,1);
        dydt(1)=PnedDot(1);
        dydt(2)=PnedDot(3);
        dydt(3)=uvwDot(1);
        dydt(4)=uvwDot(3);
    case "PM6"
        dydt=zeros(6,1);
        dydt(1:3)=PnedDot;
        dydt(4:6)=uvwDot;
    case "3DOF"
        dydt=zeros(6,1);
        dydt(1)=PnedDot(1);
        dydt(2)=PnedDot(3);
        dydt(3)=uvwDot(1);
        dydt(4)=uvwDot(3);
        dydt(5)=pqrDot(2);
        dydt(6)=phithetapsiDot(2);
    case "6DOF"
        dydt=zeros(12,1);
        dydt(1:3)=PnedDot;
        dydt(4:6)=uvwDot;
        dydt(7:9)=pqrDot;
        dydt(10:12)=phithetapsiDot;
    end


end