classdef ( Abstract )State < Aero.Aircraft.internal.Common & Aero.Aircraft.internal.Units










properties 
Mass( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;
Inertia( 3, 3 ){ Aero.Aircraft.internal.validation.mustBeInertia( Inertia ) } = table( [ 1;0;0 ], [ 0;1;0 ], [ 0;0;1 ], 'VariableNames', [ "X", "Y", "Z" ], 'RowNames', [ "X", "Y", "Z" ] );
CenterOfGravity( 1, 3 ) = [ 0, 0, 0 ];
CenterOfPressure( 1, 3 ) = [ 0, 0, 0 ];

AltitudeMSL( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;
GroundHeight( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;

XN = 0
XE = 0
end 

properties ( Dependent )
XD
end 

properties 
U( 1, 1 ){ mustBeNumeric, mustBeReal } = 50
V( 1, 1 ){ mustBeNumeric, mustBeReal } = 0
W( 1, 1 ){ mustBeNumeric, mustBeReal } = 0


Phi( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;
Theta( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;
Psi( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;


P( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;
Q( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;
R( 1, 1 ){ mustBeNumeric, mustBeReal } = 0;
end 

properties ( Dependent, SetAccess = private )
Weight

AltitudeAGL

Airspeed
GroundSpeed

MachNumber

BodyVelocity
GroundVelocity

Ur
Vr
Wr

FlightPathAngle
CourseAngle
end 

properties ( Dependent, SetAccess = private )
InertialToBodyMatrix
BodyToInertialMatrix
BodyToWindMatrix
WindToBodyMatrix
BodyToStabilityMatrix
StabilityToBodyMatrix

DynamicPressure
end 

properties 
Environment( 1, 1 )Aero.Aircraft.Environment
end 

properties ( Dependent, Hidden )
SettableControlStateNames
ControlStateNames
end 

properties ( SetAccess = private )
ControlStates( 1, : )Aero.Aircraft.ControlState
end 

properties ( Dependent )
OutOfRangeAction( 1, 1 )Aero.Aircraft.internal.datatype.RangeAction
DiagnosticAction( 1, 1 )Aero.internal.datatype.Action
end 

properties ( Constant, Hidden )
Zero = 1;
end 

properties ( Hidden )
OutOfRangeActionInternal = "Limit"
DiagnosticActionInternal = "Warning"
end 


methods 
function obj = State( n, NameValues )
R36( Repeating )
n{ mustBeInteger, mustBeGreaterThanOrEqual( n, 0 ) }
end 
R36
NameValues.?Aero.FixedWing.State
end 

obj = Aero.internal.namevalues.applyNameValuesAndCopyObject( obj, NameValues, n );
end 
end 

methods 
function obj = set.Inertia( obj, value )
if istable( value )
obj.Inertia.Variables = value.Variables;
else 
obj.Inertia.Variables = value;
end 
end 

function obj = set.OutOfRangeAction( obj, value )
obj.OutOfRangeActionInternal = string( value );
value = repmat( { value }, 1, numel( obj.ControlStates ) );
[ obj.ControlStates.OutOfRangeAction ] = value{ : };
end 
function value = get.OutOfRangeAction( obj )
value = obj.OutOfRangeActionInternal;
end 
function obj = set.DiagnosticAction( obj, value )
obj.DiagnosticActionInternal = string( value );
value = repmat( { value }, 1, numel( obj.ControlStates ) );
[ obj.ControlStates.DiagnosticAction ] = value{ : };
end 
function value = get.DiagnosticAction( obj )
value = obj.DiagnosticActionInternal;
end 
end 


methods 
function value = get.InertialToBodyMatrix( obj )
phi = convang( obj.Phi, obj.AngleConvertString_I, 'rad' );
theta = convang( obj.Theta, obj.AngleConvertString_I, 'rad' );
psi = convang( obj.Psi, obj.AngleConvertString_I, 'rad' );

value = angle2dcm( phi, theta, psi, 'XYZ' );
end 
function value = get.BodyToInertialMatrix( obj )
value = obj.InertialToBodyMatrix';
end 
function Rbw = get.BodyToWindMatrix( obj )
alpha = convang( obj.Alpha, obj.AngleConvertString_I, 'rad' );
beta = convang( obj.Beta, obj.AngleConvertString_I, 'rad' );

Rbw = dcmbody2wind( alpha, beta );
end 
function Rwb = get.WindToBodyMatrix( obj )
Rwb = obj.BodyToWindMatrix';
end 
function Rbs = get.BodyToStabilityMatrix( obj )
alpha = convang( obj.Alpha, obj.AngleConvertString_I, 'rad' );

Rbs = dcmbody2stability( alpha );
end 
function Rsb = get.StabilityToBodyMatrix( obj )
Rsb = obj.BodyToStabilityMatrix';
end 

function value = get.Weight( obj )
value = obj.Mass * obj.Environment.Gravity;
end 

function value = get.AltitudeAGL( obj )
value = obj.AltitudeMSL - obj.GroundHeight;
end 

function value = get.MachNumber( obj )
value = machnumber( obj.BodyVelocity, obj.Environment.SpeedOfSound );
end 

function value = get.BodyVelocity( obj )
value = obj.GroundVelocity - ( obj.InertialToBodyMatrix * obj.Environment.WindVelocity' )';
end 

function value = get.Ur( obj )
value = obj.BodyVelocity( 1 );
end 
function value = get.Vr( obj )
value = obj.BodyVelocity( 2 );
end 
function value = get.Wr( obj )
value = obj.BodyVelocity( 3 );
end 

function value = get.GroundVelocity( obj )
value = [ obj.U, obj.V, obj.W ];
end 

function value = get.Airspeed( obj )
value = airspeed( obj.BodyVelocity );
end 

function value = get.GroundSpeed( obj )
value = airspeed( obj.GroundVelocity );
end 

function value = get.DynamicPressure( obj )
if obj.UnitSystem == "English (kts)"
v = convvel( obj.BodyVelocity, "kts", "ft/s" );
else 
v = obj.BodyVelocity;
end 

value = dpressure( v, obj.Environment.Density );
end 

function value = get.FlightPathAngle( obj )
value = obj.atan2( obj.W, obj.U );
end 
function value = get.CourseAngle( obj )
value = obj.atan2( obj.V, obj.U );
end 

function value = get.XD( obj )
value =  - obj.AltitudeMSL;
end 
function obj = set.XD( obj, value )
obj.AltitudeMSL =  - value;
end 

function ctrlNames = get.ControlStateNames( obj )
if isempty( obj.ControlStates )
ctrlNames = [  ];
else 
ctrlProps = [ obj.ControlStates.Properties ];
ctrlNames = [ ctrlProps.Name ];
end 
end 
function ctrlNames = get.SettableControlStateNames( obj )

ctrlNames = obj.ControlStateNames;
if ~isempty( ctrlNames )
ctrlNames( ~[ obj.ControlStates.Settable ] ) = [  ];
end 
end 
end 


methods ( Hidden )
function state = setupControlStatesInternal( state, controlStates )
[ state.ControlStates ] = deal( controlStates );
end 

function state = setControlStatesInternal( state, location, value )
state.ControlStates( location ).Position = value;
end 

function value = sin( obj, a )
switch obj.AngleSystem
case "Degrees"
trigFun = @sind;
case "Radians"
trigFun = @sin;
end 
value = trigFun( a );
end 
function value = cos( obj, a )
switch obj.AngleSystem
case "Degrees"
trigFun = @cosd;
case "Radians"
trigFun = @cos;
end 
value = trigFun( a );
end 
function value = acos( obj, a )
switch obj.AngleSystem
case "Degrees"
trigFun = @acosd;
case "Radians"
trigFun = @acos;
end 
value = trigFun( a );
end 
function value = asin( obj, a )
switch obj.AngleSystem
case "Degrees"
trigFun = @asind;
case "Radians"
trigFun = @asin;
end 
value = trigFun( a );
end 
function value = atan2( obj, a, b )
switch obj.AngleSystem
case "Degrees"
trigFun = @atan2d;
case "Radians"
trigFun = @atan2;
end 
value = trigFun( a, b );
end 
function value = tan( obj, a )
switch obj.AngleSystem
case "Degrees"
trigFun = @tand;
case "Radians"
trigFun = @tan;
end 
value = trigFun( a );
end 
function value = sec( obj, a )
switch obj.AngleSystem
case "Degrees"
trigFun = @secd;
case "Radians"
trigFun = @sec;
end 
value = trigFun( a );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpmJ3ADW.p.
% Please follow local copyright laws when handling this file.

