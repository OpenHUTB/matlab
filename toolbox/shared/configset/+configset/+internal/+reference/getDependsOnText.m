function out = getDependsOnText( ref, paramData, fromDialog )




R36
ref
paramData( 1, 1 )configset.ParameterInfo
fromDialog( 1, 1 )logical = false
end 

adapter = configset.internal.getConfigSetAdapter( ref );
dependsOn = adapter.getStatusDependsOn( paramData.Name, paramData.ParamInfo );
if fromDialog

description = cellfun( @( x )configset.internal.reference.getParameterInfo( ref, x ).Description,  ...
dependsOn, 'UniformOutput', false );
out = [ '<ul>', sprintf( '<li>%s</li>', description{ : } ), '</ul>' ];
else 

out = sprintf( '\n    %s', dependsOn{ : } );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpybNupQ.p.
% Please follow local copyright laws when handling this file.

