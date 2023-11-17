function[F,M]=coefficientForcesAndMoments(coeff,state,S,b,c)

    qbarS=state.DynamicPressure*S;
    qbarSb=qbarS*b;
    qbarSc=qbarS*c;

    try
        coefficientValues=cell2mat(coeff.Values);

    catch
        numelStateVariables=numel(coeff.StateVariables);
        stateOutputs=repmat(coeff.StateOutput,numelStateVariables,1);
        stateVariables=repelem(coeff.StateVariables,1,6)';

        coeff1=coeff.getCoefficient(stateOutputs,stateVariables,"State",state);
        coefficientValues=reshape(coeff1,6,numelStateVariables);
    end


    if coeff.MultiplyStateVariables
        stateValues=state.getState(coeff.StateVariables).';
    else
        stateValues=ones(size(coefficientValues,2),1);
    end

    if numel(coeff.StateVariables)==9&&coeff.NonDimensional


        Vair=state.Airspeed;
        nonDimStateValues=[1,1/Vair,1,c/(2*Vair),c/(2*Vair),1,b/(2*Vair),b/(2*Vair),b/(2*Vair)]'.*stateValues;
    else
        nonDimStateValues=stateValues;
    end
    nonDimValues=coefficientValues*nonDimStateValues;

    if coeff.NonDimensional
        FM=[qbarS;qbarS;qbarS;qbarSb;qbarSc;qbarSb].*nonDimValues;
    else
        FM=nonDimValues;
    end



    switch coeff.ReferenceFrame
    case Aero.Aircraft.internal.datatype.ReferenceFrame.Body
        F=FM(1:3);
        M=FM(4:6);
    case Aero.Aircraft.internal.datatype.ReferenceFrame.Wind
        DCMb2w=state.BodyToWindMatrix;
        DCMw2b=state.WindToBodyMatrix;

        Fw=FM(1:3).*[-1;-1;-1];
        Mw=FM(4:6)+cross(Fw,DCMb2w*(state.CenterOfGravity-state.CenterOfPressure)');

        F=DCMw2b*Fw;
        M=DCMw2b*Mw;
    case Aero.Aircraft.internal.datatype.ReferenceFrame.Stability
        DCMb2s=state.BodyToStabilityMatrix;
        DCMs2b=state.StabilityToBodyMatrix;

        Fs=FM(1:3).*[-1;1;-1];
        Ms=FM(4:6)+cross(Fs,DCMb2s*(state.CenterOfGravity-state.CenterOfPressure)');

        F=DCMs2b*Fs;
        M=DCMs2b*Ms;
    end
end