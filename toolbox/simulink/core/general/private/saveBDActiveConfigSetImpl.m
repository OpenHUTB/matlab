function saveBDActiveConfigSetImpl( model, filename )















if nargin < 2
throw( MSLException( [  ], message( 'Simulink:ConfigSet:MissingInpArgs' ) ) );
end 

if isempty( model )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:FirstInpArgMustBeValidModel' ) ) );
end 
cs = getActiveConfigSet( model );

if ~isa( cs, 'Simulink.ConfigSet' )
throw( MSLException( [  ], message( 'Simulink:ConfigSet:saveAsOnlyConfigSet', get_param( model, 'Name' ) ) ) );
end 
configset.internal.util.save( cs, filename );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpIL8tC4.p.
% Please follow local copyright laws when handling this file.

