function h = getActiveConfigSet( mdl )





if isempty( mdl )
h = [  ];
return ;
end 

mdl = configset.internal.util.getModelObject( mdl );
h = mdl.getActiveConfigSet;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeX9eNG.p.
% Please follow local copyright laws when handling this file.

