function out = getOverriddenParameters( model )

arguments
    model
end

out = configset.internal.reference.OverrideManager( model ).getParameterOverrides;

