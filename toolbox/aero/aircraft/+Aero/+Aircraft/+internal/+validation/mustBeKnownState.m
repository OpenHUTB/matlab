function mustBeKnownState(stateName,validStates)

    idx=~ismember(stateName,validStates);
    if any(idx)
        error(message("aero_aircraft:State:UnknownState",sprintf("\n\t'%s'",stateName(idx))))
    end

end