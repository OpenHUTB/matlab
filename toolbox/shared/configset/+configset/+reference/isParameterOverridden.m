function out = isParameterOverridden( model, parameter )


arguments
    model
    parameter( 1, 1 )string
end

out = configset.internal.reference.OverrideManager( model ).isParameterOverridden( parameter );

