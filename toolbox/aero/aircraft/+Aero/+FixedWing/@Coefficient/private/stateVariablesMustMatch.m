function stateVariablesMustMatch(obj)

    if size(obj.StateVariables,2)~=size(obj.Values,2)
        error(message("aero:FixedWing:StateVariableDimsMustMatchValues"));
    end
end
