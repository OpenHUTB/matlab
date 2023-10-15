function restoreOverriddenParameter( model, parameter )

arguments
    model
    parameter( 1, 1 )string
end

configset.internal.reference.OverrideManager( model ).restore( parameter );

