function[dF,dM]=perturbFM(aircraft,state,stateName,nvpStruct)

    baseValue=state.getState(stateName);
    perturbX=nvpStruct.RelativePerturbation+1e-3*nvpStruct.RelativePerturbation*abs(baseValue);

    switch nvpStruct.DifferentialMethod
    case Aero.Aircraft.internal.datatype.DifferentialMethod.Forward
        forwardState=state.setState(stateName,baseValue+perturbX);
        backwardState=state;

        dx=perturbX;
    case Aero.Aircraft.internal.datatype.DifferentialMethod.Backward
        forwardState=state;
        backwardState=state.setState(stateName,baseValue-perturbX);

        dx=perturbX;
    case Aero.Aircraft.internal.datatype.DifferentialMethod.Central
        forwardState=state.setState(stateName,baseValue+perturbX);
        backwardState=state.setState(stateName,baseValue-perturbX);

        dx=2*perturbX;
    end

    [forwardF,forwardM]=aircraft.forcesAndMoments(forwardState);

    [backwardF,backwardM]=aircraft.forcesAndMoments(backwardState);

    dF=(forwardF-backwardF)./dx;
    dM=(forwardM-backwardM)./dx;

end
