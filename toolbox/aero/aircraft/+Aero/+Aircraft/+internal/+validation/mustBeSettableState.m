function mustBeSettableState(stateName,ACState)





    mainProps=string(properties(ACState));


    envProps=string(properties(ACState.Environment));


    ctrlNames=ACState.SettableControlStateNames;

    validStates=vertcat(mainProps(:),envProps(:),ctrlNames(:));

    Aero.Aircraft.internal.validation.mustBeKnownState(stateName,validStates);

end
