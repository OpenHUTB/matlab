function out = hasOverriddenParameters( model )

arguments
    model
end

out = ~isempty( configset.reference.getOverriddenParameters( model ) );
