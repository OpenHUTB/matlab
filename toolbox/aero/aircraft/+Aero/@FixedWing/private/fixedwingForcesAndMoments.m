function[F,M]=fixedwingForcesAndMoments(aircraft,state)
    F=state.InertialToBodyMatrix*([0;0;state.Environment.Gravity]*state.Mass);
    M=zeros(3,1);
    [F1,M1]=aircraft.Coefficients.forcesAndMoments(state,aircraft.ReferenceArea,aircraft.ReferenceSpan,aircraft.ReferenceLength);
    F=F+F1;
    M=M+M1;

    for s=aircraft.Surfaces
        [F1,M1]=s.forcesAndMoments(state,aircraft.ReferenceArea,aircraft.ReferenceSpan,aircraft.ReferenceLength);
        F=F+F1;
        M=M+M1;
    end

    for t=aircraft.Thrusts
        [F1,M1]=t.forcesAndMoments(state,aircraft.ReferenceArea,aircraft.ReferenceSpan,aircraft.ReferenceLength);
        F=F+F1;
        M=M+M1;
    end

    switch aircraft.DegreesOfFreedom
    case "PM4"
        F=[F(1);0;M(3)];
        M=[0;0;0];
    case "PM6"
        M=[0;0;0];
    case "3DOF"
        F=[F(1);0;F(3)];
        M=[0;M(2);0];
    case "6DOF"

    end
end