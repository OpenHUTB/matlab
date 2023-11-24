function[J1,J2]=perturb(aircraft,state,stateName,output,RelativePerturbation,DifferentialMethod)

    baseValue=state.getState(stateName);
    perturbX=RelativePerturbation+1e-3*RelativePerturbation*abs(baseValue);

    switch DifferentialMethod
    case "Forward"
        forwardState=state.setState(stateName,baseValue+perturbX);
        backwardState=state;

        dx=perturbX;
    case "Backward"
        forwardState=state;
        backwardState=state.setState(stateName,baseValue-perturbX);

        dx=perturbX;
    case "Central"
        forwardState=state.setState(stateName,baseValue+perturbX);
        backwardState=state.setState(stateName,baseValue-perturbX);

        dx=2*perturbX;
    end

    forwardy=forwardState.getState(output);
    forwardState.AlphaDot=getAlphaDot(aircraft,forwardState);
    forwarddx=aircraft.nonlinearDynamics(forwardState);

    backwardy=backwardState.getState(output);
    backwardState.AlphaDot=getAlphaDot(aircraft,backwardState);
    backwarddx=aircraft.nonlinearDynamics(backwardState);

    J1=(forwarddx-backwarddx)./dx;
    J2=(forwardy-backwardy)./dx;

end

function alphadot=getAlphaDot(Aircraft,State)







    dydt=nonlinearDynamics(Aircraft,State);
    uwSquare=State.U^2+State.W^2;
    switch Aircraft.DegreesOfFreedom
    case{"3DOF","PM4"}
        uDot=dydt(3);
        wDot=dydt(4);
    case{"6DOF","PM6"}
        uDot=dydt(4);
        wDot=dydt(6);
    end
    alphadot=(State.U*wDot-State.W*uDot)/uwSquare;
end
