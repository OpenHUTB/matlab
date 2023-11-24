function mustBeStateVariable(obj,stateOutput,stateVariable,component)
    validStateVariables=getValidStateVariables(obj,component);

    try

        for iStateVar=1:numel(stateVariable)
            checkStateVariablesAndThrowError(stateOutput(1),stateVariable(iStateVar),validStateVariables,component);
        end
    catch ERR
        throwAsCaller(ERR)
    end

end

function stateVariables=getValidStateVariables(obj,component)
    stateVariables=[];
    switch class(obj)
    case "Aero.FixedWing.Coefficient"
        stateVariables=obj.StateVariables;

    case "Aero.FixedWing.Thrust"
        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            stateVariables=getValidStateVariables(obj.Coefficients,component);
        end

    case "Aero.FixedWing.Surface"
        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            stateVariables=getValidStateVariables(obj.Coefficients,component);
        else
            for s=obj.Surfaces
                stateVariables=getValidStateVariables(s,component);
                if~isempty(stateVariables)
                    break
                end
            end
        end

    case "Aero.FixedWing"
        if(component==obj.Properties.Name)
            stateVariables=getValidStateVariables(obj.Coefficients,component);
        elseif any(component==Aero.Aircraft.internal.validation.getValidComponentNames(obj.Surfaces))
            for s=obj.Surfaces
                stateVariables=getValidStateVariables(s,component);
                if~isempty(stateVariables)
                    break
                end
            end
        elseif any(component==Aero.Aircraft.internal.validation.getValidComponentNames(obj.Thrusts))
            for t=obj.Thrusts
                stateVariables=getValidStateVariables(t,component);
                if~isempty(stateVariables)
                    break
                end
            end
        end
    end

end

function checkStateVariablesAndThrowError(stateOutput,stateVariable,validStateVariables,component)
    if~ismember(stateVariable,validStateVariables)
        error(message("aero:FixedWing:UnknownStateVariable",stateVariable,component,sprintf("\n\t'%s'",validStateVariables)))
    end
    if numel(find(validStateVariables==stateVariable))~=1


        error(message("aero:FixedWing:CoefficientMultipleMatches",stateOutput+"_"+stateVariable))
    end
end
