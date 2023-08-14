function mustBeComponentName(obj,component)





    validComponentNames=Aero.Aircraft.internal.validation.getValidComponentNames(obj);

    mustBeMember(component,validComponentNames)

    if sum(validComponentNames==component)>1
        error(message("aero:FixedWing:ComponentMultipleMatches",component))
    end

end
