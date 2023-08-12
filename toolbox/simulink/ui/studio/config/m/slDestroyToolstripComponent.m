function slDestroyToolstripComponent( comp, options )


R36
comp{ mustBeTextScalar, mustBeNonempty };
options.RemoveFromPath{ mustBeNumericOrLogical } = true;
end 


dig.config.destroyComponent( 'sl_toolstrip_plugins', comp,  ...
RemoveFromPath = options.RemoveFromPath );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp1Km8NC.p.
% Please follow local copyright laws when handling this file.

