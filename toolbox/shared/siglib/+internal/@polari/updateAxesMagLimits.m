function updateAxesMagLimits( p )







auto_lim = strcmpi( p.MagnitudeLimMode, 'auto' );
if auto_lim




mlim = findMagLimits( p );
else 

mlim = p.pMagnitudeLim;
end 
if any( isinf( mlim ) )


mlim = [ 0, 1 ];
end 



mlim = constrainMagnitudeLim( p, mlim );



auto_tick = strcmpi( p.MagnitudeTickMode, 'auto' );
if auto_tick


rescaleLimits = strcmpi( p.MagnitudeLimMode, 'auto' );
[ mlim_scaled, ticks_scaled, scale, units ] = findMagTicks_Auto( mlim, rescaleLimits );
else 
[ mlim_scaled, ticks_scaled, scale, units ] = findMagTicks_Manual( mlim, p.MagnitudeTick );
end 

if auto_lim




p.pMagnitudeLim = mlim_scaled ./ scale;
end 
p.pMagnitudeLim_Scaled = mlim_scaled;

if auto_tick


p.pMagnitudeTick = ticks_scaled ./ scale;
end 



ticks_scaled( ticks_scaled < mlim_scaled( 1 ) ) = [  ];
ticks_scaled( ticks_scaled > mlim_scaled( 2 ) ) = [  ];

p.pMagnitudeTick_Scaled = ticks_scaled;

p.pMagnitudeCircleRadii = determineCircleRadii( mlim_scaled, ticks_scaled );
p.pMagnitudeScale = scale;
p.pMagnitudeUnits = units;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcXRQrq.p.
% Please follow local copyright laws when handling this file.

