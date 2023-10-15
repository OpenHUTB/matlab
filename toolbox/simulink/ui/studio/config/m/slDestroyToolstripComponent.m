function slDestroyToolstripComponent( comp, options )

arguments
    comp{ mustBeTextScalar, mustBeNonempty };
    options.RemoveFromPath{ mustBeNumericOrLogical } = true;
end


dig.config.destroyComponent( 'sl_toolstrip_plugins', comp,  ...
    RemoveFromPath = options.RemoveFromPath );
end
