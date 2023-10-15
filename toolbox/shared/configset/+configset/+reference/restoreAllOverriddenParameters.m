function restoreAllOverriddenParameters( model )

arguments
    model
end

configset.internal.reference.OverrideManager( model ).restoreAll;

