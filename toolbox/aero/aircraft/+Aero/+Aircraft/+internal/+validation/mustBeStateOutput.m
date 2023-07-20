function mustBeStateOutput(obj,stateOutput,component)





    validStateOutputs=getValidStateOutputs(obj,component);
    stateOutput=string(stateOutput);
    try

        for iStateOut=1:numel(stateOutput)
            checkStateOutputsAndThrowError(stateOutput(iStateOut),validStateOutputs,component);
        end
    catch ERR
        throwAsCaller(ERR)
    end


end

function stateOutputs=getValidStateOutputs(obj,component)
    stateOutputs=[];
    switch class(obj)
    case "Aero.FixedWing.Coefficient"
        stateOutputs=obj.StateOutput;

    case "Aero.FixedWing.Thrust"
        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            stateOutputs=getValidStateOutputs(obj.Coefficients,component);
        end

    case "Aero.FixedWing.Surface"
        if((component==obj.Properties.Name)||(component==obj.Coefficients.Properties.Name))
            stateOutputs=getValidStateOutputs(obj.Coefficients,component);
        else
            for s=obj.Surfaces
                stateOutputs=getValidStateOutputs(s,component);
                if~isempty(stateOutputs)
                    break
                end
            end
        end

    case "Aero.FixedWing"
        if(component==obj.Properties.Name)
            stateOutputs=getValidStateOutputs(obj.Coefficients,component);
        elseif any(component==Aero.Aircraft.internal.validation.getValidComponentNames(obj.Surfaces))
            for s=obj.Surfaces
                stateOutputs=getValidStateOutputs(s,component);
                if~isempty(stateOutputs)
                    break
                end
            end
        elseif any(component==Aero.Aircraft.internal.validation.getValidComponentNames(obj.Thrusts))
            for t=obj.Thrusts
                stateOutputs=getValidStateOutputs(t,component);
                if~isempty(stateOutputs)
                    break
                end
            end
        end
    end

end

function checkStateOutputsAndThrowError(stateOutput,validStateOutputs,component)
    if~ismember(stateOutput,validStateOutputs)
        error(message("aero:FixedWing:UnknownStateOutput",stateOutput,component,sprintf("\n\t'%s'",validStateOutputs)))
    end

end

