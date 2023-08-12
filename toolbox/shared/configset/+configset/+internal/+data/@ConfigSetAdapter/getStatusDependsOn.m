function out = getStatusDependsOn( obj, name, paramData )

















R36
obj
name( 1, 1 )string
paramData( 1, 1 )configset.internal.data.ParamStaticData =  ...
getParam( configset.internal.getConfigSetStaticData, name )
end 

if nargin == 3

assert( paramData.Name == name );
end 


list = paramData.getStatusDependsOn;



out = list( cellfun( @( x )obj.getParamStatus( x ) < 3, list ) );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpRh6hl2.p.
% Please follow local copyright laws when handling this file.

