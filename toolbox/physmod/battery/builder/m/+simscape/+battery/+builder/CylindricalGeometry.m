classdef CylindricalGeometry < simscape.battery.builder.internal.Geometry


























properties ( Dependent )



Radius( 1, 1 ){ mustBeA( Radius, [ "simscape.Value", "double" ] ) }
end 
properties ( SetAccess = private, Hidden )



RadiusInternal( 1, 1 ){ mustBeA( RadiusInternal, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( RadiusInternal, "m" ) } = simscape.Value( 0.01, "m" )
end 

methods 
function obj = CylindricalGeometry( namedArgs )
R36
namedArgs.Radius( 1, 1 ){ mustBeA( namedArgs.Radius, [ "simscape.Value", "double" ] ) } ...
 = simscape.Value( 0.01, "m" )
namedArgs.Height( 1, 1 ){ mustBeA( namedArgs.Height, [ "simscape.Value", "double" ] ) } ...
 = simscape.Value( 0.07, "m" )
end 

if ~pmsl_checklicense( 'simscape_battery' )
error( message( 'physmod:battery:license:MissingLicense' ) );
end 
obj.Radius = namedArgs.Radius;
obj.Height = namedArgs.Height;
end 

function obj = set.Radius( obj, val )
val = obj.doubleToSimscapeValueConversion( val );
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidRadius" ) );
assert( value( val, "m" ) < 0.5, message( "physmod:battery:builder:batteryclasses:LargeRadius", "0.5" ) );
catch me
throwAsCaller( me )
end 
obj.RadiusInternal = val;
end 
function value = get.Radius( obj )
value = obj.RadiusInternal;
end 
function val = doubleToSimscapeValueConversion( ~, val )
if isa( val, "double" )
warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
val = simscape.Value( val, "m" );
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOkTo_4.p.
% Please follow local copyright laws when handling this file.

