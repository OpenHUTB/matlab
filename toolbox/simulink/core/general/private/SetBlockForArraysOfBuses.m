function SetBlockForArraysOfBuses( block, h )








model = get_param( block, 'parent' );
usingBO = get_param( block, 'UseBusObject' );
dims = str2double( get_param( block, 'PortDimensions' ) );
nvbus = get_param( block, 'BusOutputAsStruct' );

width = prod( dims );


if strcmp( usingBO, 'on' ) && width ~=  - 1 && width ~= 1
if strcmp( nvbus, 'off' )

if askToReplace( h, block )
funcSet = uSafeSetParam( h, block, 'PortDimensions', '1' );
appendTransaction( h, block, DAStudio.message( 'Simulink:Bus:SlUpdateArraysOfBusesReason' ),  ...
{ funcSet } );
end 
elseif get_param( model, 'VersionLoaded' ) < 7.5001

if askToReplace( h, block )
funcSet = uSafeSetParam( h, block, 'PortDimensions', '1' );
appendTransaction( h, block, DAStudio.message( 'Simulink:Bus:SlUpdateArraysOfBusesReason' ),  ...
{ funcSet } );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpSx1Tsq.p.
% Please follow local copyright laws when handling this file.

