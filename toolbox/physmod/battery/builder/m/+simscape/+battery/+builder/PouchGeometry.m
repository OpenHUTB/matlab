classdef PouchGeometry < simscape.battery.builder.internal.Geometry










































properties ( Dependent )



Length( 1, 1 ){ mustBeA( Length, [ "simscape.Value", "double" ] ) }



Thickness( 1, 1 ){ mustBeA( Thickness, [ "simscape.Value", "double" ] ) }


TabLocation string{ mustBeMember( TabLocation, [ "Standard", "Opposed" ] ) }



TabWidth( 1, 1 ){ mustBeA( TabWidth, [ "simscape.Value", "double" ] ) }



TabHeight( 1, 1 ){ mustBeA( TabHeight, [ "simscape.Value", "double" ] ) }
end 

properties ( SetAccess = private, Hidden )



LengthInternal( 1, 1 ){ mustBeA( LengthInternal, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( LengthInternal, "m" ) } = simscape.Value( 0.23, "m" )



ThicknessInternal( 1, 1 ){ mustBeA( ThicknessInternal, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( ThicknessInternal, "m" ) } = simscape.Value( 0.01, "m" )


TabLocationInternal string{ mustBeMember( TabLocationInternal, [ "Standard", "Opposed" ] ) } = "Standard"



TabWidthInternal( 1, 1 ){ mustBeA( TabWidthInternal, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( TabWidthInternal, "m" ) } = simscape.Value( 0.04, "m" )



TabHeightInternal( 1, 1 ){ mustBeA( TabHeightInternal, "simscape.Value" ),  ...
simscape.mustBeCommensurateUnit( TabHeightInternal, "m" ) } = simscape.Value( 0.03, "m" )
end 

methods 
function obj = PouchGeometry( namedArgs )
R36
namedArgs.Length( 1, 1 ){ mustBeA( namedArgs.Length, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.23, "m" )
namedArgs.Thickness( 1, 1 ){ mustBeA( namedArgs.Thickness, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.01, "m" )
namedArgs.Height( 1, 1 ){ mustBeA( namedArgs.Height, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.28, "m" )
namedArgs.TabLocation string{ mustBeMember( namedArgs.TabLocation, [ "Standard", "Opposed" ] ) } = "Standard"
namedArgs.TabWidth( 1, 1 ){ mustBeA( namedArgs.TabWidth, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.04, "m" )
namedArgs.TabHeight( 1, 1 ){ mustBeA( namedArgs.TabHeight, [ "simscape.Value", "double" ] ) } = simscape.Value( 0.03, "m" )
end 

if ~pmsl_checklicense( 'simscape_battery' )
error( message( 'physmod:battery:license:MissingLicense' ) );
end 
obj.Length = namedArgs.Length;
obj.Thickness = namedArgs.Thickness;
obj.Height = namedArgs.Height;
obj.TabWidth = namedArgs.TabWidth;
obj.TabHeight = namedArgs.TabHeight;
obj.TabLocation = namedArgs.TabLocation;
end 

function obj = set.Length( obj, val )
val = obj.doubleToSimscapeValueConversion( val );
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidLength" ) );
assert( value( val, "m" ) < 5, message( "physmod:battery:builder:batteryclasses:LargeLength", "5" ) );
catch me
throwAsCaller( me )
end 
obj.LengthInternal = val;
end 
function value = get.Length( obj )
value = obj.LengthInternal;
end 
function obj = set.Thickness( obj, val )
val = obj.doubleToSimscapeValueConversion( val );
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidThickness" ) );
assert( value( val, "m" ) < 0.5, message( "physmod:battery:builder:batteryclasses:LargeThickness", "0.5" ) );
catch me
throwAsCaller( me )
end 
obj.ThicknessInternal = val;
end 
function value = get.Thickness( obj )
value = obj.ThicknessInternal;
end 
function obj = set.TabLocation( obj, val )
obj.TabLocationInternal = val;
end 
function value = get.TabLocation( obj )
value = obj.TabLocationInternal;
end 
function obj = set.TabWidth( obj, val )
val = obj.doubleToSimscapeValueConversion( val );
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidTabWidth" ) );
assert( value( val, "m" ) < value( obj.Length, "m" ), message( "physmod:battery:builder:batteryclasses:LargeTabWidth", string( value( obj.Length, "m" ) ) ) );
catch me
throwAsCaller( me )
end 
obj.TabWidthInternal = val;
end 
function value = get.TabWidth( obj )
value = obj.TabWidthInternal;
end 
function obj = set.TabHeight( obj, val )
val = obj.doubleToSimscapeValueConversion( val );
simscape.mustBeCommensurateUnit( val, "m" )
try 
assert( value( val, "m" ) > 0, message( "physmod:battery:builder:batteryclasses:InvalidTabHeight" ) );
assert( value( val, "m" ) < value( obj.Height, "m" ), message( "physmod:battery:builder:batteryclasses:LargeTabHeight", string( value( obj.Height, "m" ) ) ) );
catch me
throwAsCaller( me )
end 
obj.TabHeightInternal = val;
end 

function value = get.TabHeight( obj )
value = obj.TabHeightInternal;
end 

function val = doubleToSimscapeValueConversion( ~, val )
if isa( val, "double" )
warning( message( "physmod:battery:builder:batteryclasses:DoubleToSimscapeValueMeters" ) )
val = simscape.Value( val, "m" );
end 
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpbhvTNH.p.
% Please follow local copyright laws when handling this file.

