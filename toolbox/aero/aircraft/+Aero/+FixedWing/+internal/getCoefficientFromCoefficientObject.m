function coeff=getCoefficientFromCoefficientObject(obj,stateOutput,stateVariable,state)





    coeff=[];
    r=find(obj.StateOutput==stateOutput);
    c=find(obj.StateVariables==stateVariable);

    if isempty(r)||isempty(c)
        return
    end

    tempValue=obj.Values{r,c};


    if isempty(state)||isnumeric(tempValue)
        coeff=tempValue;
    else

        GI=Aero.FixedWing.internal.getGriddedInterpolantFromLT(tempValue);
        query=num2cell(state.getState({tempValue.Breakpoints.FieldName}));
        coeff=GI(query{:});
    end
end
