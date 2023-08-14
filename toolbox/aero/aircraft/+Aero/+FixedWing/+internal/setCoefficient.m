function obj=setCoefficient(obj,stateOutput,stateVariable,value,NameValues)




    if~NameValues.AddVariable
        Aero.Aircraft.internal.validation.mustBeStateVariable(obj,stateOutput,stateVariable,NameValues.Component);
    end

    if~iscell(value)
        value=num2cell(value);
    end

    for i=1:numel(stateOutput)
        obj=setCoefficientInternal(obj,stateOutput(i),stateVariable(i),value{i},NameValues.Component,NameValues.AddVariable);
    end
end

function obj=setCoefficientInternal(obj,stateOutput,stateVariable,value,component,addVariable)
    switch class(obj)
    case "Aero.FixedWing.Coefficient"
        if~ismember(stateVariable,obj.StateVariables)
            if addVariable
                obj.StateVariables=[obj.StateVariables,stateVariable];
            else
                return
            end
        end

        obj.Values{obj.StateOutput==stateOutput,obj.StateVariables==stateVariable}=value;

    case "Aero.FixedWing.Thrust"
        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            obj.Coefficients=setCoefficientInternal(obj.Coefficients,stateOutput,stateVariable,value,component,addVariable);
        end

    case "Aero.FixedWing.Surface"
        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            obj.Coefficients=setCoefficientInternal(obj.Coefficients,stateOutput,stateVariable,value,component,addVariable);
        else
            for i=1:numel(obj.Surfaces)
                obj.Surfaces(i)=setCoefficientInternal(obj.Surfaces(i),stateOutput,stateVariable,value,component,addVariable);
            end
        end

    case "Aero.FixedWing"

        surfValidNames=Aero.Aircraft.internal.validation.getValidComponentNames(obj.Surfaces);
        thrustValidNames=Aero.Aircraft.internal.validation.getValidComponentNames(obj.Thrusts);

        if(component==obj.Properties.Name)

            obj.Coefficients=setCoefficientInternal(obj.Coefficients,stateOutput,stateVariable,value,component,addVariable);
        elseif any(component==surfValidNames)
            for i=1:numel(obj.Surfaces)
                obj.Surfaces(i)=setCoefficientInternal(obj.Surfaces(i),stateOutput,stateVariable,value,component,addVariable);
            end

        elseif any(component==thrustValidNames)
            for i=1:numel(obj.Thrusts)
                obj.Thrusts(i)=setCoefficientInternal(obj.Thrusts(i),stateOutput,stateVariable,value,component,addVariable);
            end
        end
    end
end