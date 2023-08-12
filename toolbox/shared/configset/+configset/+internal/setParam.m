function setParam( cs, param, value, options )










R36
cs
param
value
options.Apply( 1, 1 )matlab.lang.OnOffSwitchState = "on"
end 

isCsRef = isa( cs, 'Simulink.ConfigSetRef' );
overridden = isCsRef && cs.isParameterOverridden( param );

if isCsRef && ~overridden
csSource = cs.getRefConfigSet;
else 
csSource = cs;
end 


set_param( csSource, param, value );

if isCsRef
if ~isempty( cs.LocalConfigSet )

cs.refresh( 'LocalConfigSet' );
end 
if ~overridden && cs.SourceResolvedInBaseWorkspace == "off" &&  ...
options.Apply == "on"

dd = Simulink.dd.open( cs.DDName );
oldCS = dd.getEntry( [ 'Configurations.', csSource.Name ] );
if ~isequal( oldCS, csSource )
dd.setEntry( [ 'Configurations.', csSource.Name ], csSource );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpR4Fell.p.
% Please follow local copyright laws when handling this file.

