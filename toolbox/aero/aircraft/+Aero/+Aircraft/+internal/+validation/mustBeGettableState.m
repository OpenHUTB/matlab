function mustBeGettableState(stateName,ACState)





    stateName(stateName=="Zero")=[];


    mainProps=string(properties(ACState));


    envProps=string(properties(ACState.Environment));


    ctrlProps=[ACState.ControlStates.Properties];

    if~isempty(ctrlProps)
        ctrlProps=[ctrlProps.Name];
    end

    validStates=vertcat(mainProps(:),envProps(:),ctrlProps(:));

    Aero.Aircraft.internal.validation.mustBeKnownState(stateName,validStates);

end
