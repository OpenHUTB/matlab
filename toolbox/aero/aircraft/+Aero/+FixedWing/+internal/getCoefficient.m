function value=getCoefficient(obj,stateOutput,stateVariable,NameValues)

    value=arrayfun(@(r,c)getCoefficientInternal(obj,r,c,NameValues.State,NameValues.Component),stateOutput,stateVariable,'UniformOutput',~isempty(NameValues.State));
    if iscell(value)&&(all(cellfun(@isnumeric,value),'all')||all(cellfun(@(x)isa(x,"Simulink.LookupTable"),value),'all'))
        value=[value{:}];
    end
end

function coeff=getCoefficientInternal(obj,stateOutput,stateVariable,state,component)
    coeff=[];

    switch class(obj)
    case "Aero.FixedWing.Coefficient"

        coeff=Aero.FixedWing.internal.getCoefficientFromCoefficientObject(obj,stateOutput,stateVariable,state);

    case "Aero.FixedWing.Thrust"

        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            coeff=getCoefficientInternal(obj.Coefficients,stateOutput,stateVariable,state,component);
        end

    case "Aero.FixedWing.Surface"
        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            coeff=getCoefficientInternal(obj.Coefficients,stateOutput,stateVariable,state,component);
        else
            for s=obj.Surfaces
                coeff=getCoefficientInternal(s,stateOutput,stateVariable,state,component);
                if~isempty(coeff)
                    return
                end
            end
        end

    case "Aero.FixedWing"


        if(component==obj.Properties.Name)
            coeff=getCoefficientInternal(obj.Coefficients,stateOutput,stateVariable,state,component);
            return
        end




        surfValidNames=Aero.Aircraft.internal.validation.getValidComponentNames(obj.Surfaces);
        if any(component==surfValidNames)
            for s=obj.Surfaces
                coeff=getCoefficientInternal(s,stateOutput,stateVariable,state,component);
                if~isempty(coeff)
                    return
                end
            end
        end


        for t=obj.Thrusts
            coeff=getCoefficientInternal(t.Coefficients,stateOutput,stateVariable,state,component);
            if~isempty(coeff)
                return
            end
        end
    end
end