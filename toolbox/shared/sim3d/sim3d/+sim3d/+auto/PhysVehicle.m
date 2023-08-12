classdef PhysVehicle < sim3d.auto.WheeledVehicle

properties ( SetAccess = 'private', GetAccess = 'public' )

LightModule = {  };


PhysVehicleType;

end 

properties ( Access = private )
PhysVehicleConfigPublisher = [  ];
PhysVehicleChassisFeedbackSubscriber = [  ];
PhysVehicleDrivelineFeedbackSubscriber = [  ];
PhysVehicleTireFeedbackSubscriber = [  ];
PhysVehicleControlsPublisher = [  ];
TraceStart_cache;
TraceEnd_cache;
PhysVehicleProperties;
end 

properties ( Access = private, Constant = true )
SuffixChassisFeedbackIn = '/PhysVehicleChassisFeedback_IN';
SuffixDrivelineFeedbackIn = '/PhysVehicleDrivelineFeedback_IN';
SuffixTireFeedbackIn = '/PhysVehicleTireFeedback_IN';
SuffixConfigOut = '/PhysVehicleConfiguration_OUT';
SuffixControlsOut = '/PhysVehicleControls_OUT';
end 

methods 
function self = PhysVehicle( actorName, PhysVehicleType, vehicleProperties, varargin )
narginchk( 2, inf );
r = sim3d.auto.PhysVehicle.parseInputs( varargin{ : } );
numberOfParts = uint32( 1 );


mesh = '';
self@sim3d.auto.WheeledVehicle( actorName, r.ActorID, r.Translation, r.Rotation, r.Scale, numberOfParts, mesh );
if ( self.DebugRayTrace )
self.RayEnd( :, 2 ) = 1;
end 
self.PhysVehicleType = self.getVehType( PhysVehicleType );
switch PhysVehicleType
case 'Custom'
self.Mesh = r.Mesh;
otherwise 
self.Mesh = sim3d.auto.PhysVehicle.getBlueprintPath( self.PhysVehicleType );
end 
self.Animation = self.getAnimation(  );
self.Color = self.getColor( r.Color );
self.Translation = single( r.Translation );
self.Rotation = single( r.Rotation );
self.Scale = single( r.Scale );
self.ActorID = r.ActorID;
self.RayStart = [ 0, 0,  - 0.35;0, 0,  - 0.35 ];
self.RayEnd = [ 1, 0, 5;1, 0, 5 ];

self.PhysVehicleProperties = vehicleProperties;
switch PhysVehicleType
case 'MuscleCar'
self.PhysVehicleProperties.TrackWidth = 1.9;
self.PhysVehicleProperties.WheelBase = 3.02;
self.PhysVehicleProperties.FrntWhlRadius = 0.369;
self.PhysVehicleProperties.RearWhlRadius = 0.369;
self.PhysVehicleProperties.CgOffset = self.PhysVehicleProperties.CgOffset + [ .125, .125, 0 ];
case 'Sedan'
self.PhysVehicleProperties.TrackWidth = 1.9;
self.PhysVehicleProperties.WheelBase = 2.82;
self.PhysVehicleProperties.FrntWhlRadius = 0.350;
self.PhysVehicleProperties.RearWhlRadius = 0.350;
self.PhysVehicleProperties.CgOffset = self.PhysVehicleProperties.CgOffset + [ .125,  - .0075, 0 ];
case 'SportUtilityVehicle'
self.PhysVehicleProperties.TrackWidth = 1.9;
self.PhysVehicleProperties.WheelBase = 2.90;
self.PhysVehicleProperties.FrntWhlRadius = 0.401;
self.PhysVehicleProperties.RearWhlRadius = 0.401;
self.PhysVehicleProperties.CgOffset = self.PhysVehicleProperties.CgOffset + [ .125,  - .0175, 0 ];
case 'SmallPickupTruck'
self.PhysVehicleProperties.TrackWidth = 1.9;
self.PhysVehicleProperties.WheelBase = 3.69;
self.PhysVehicleProperties.FrntWhlRadius = 0.446;
self.PhysVehicleProperties.RearWhlRadius = 0.446;
self.PhysVehicleProperties.CgOffset = self.PhysVehicleProperties.CgOffset + [ 0.25,  - .2725, 0 ];
case 'Hatchback'
self.PhysVehicleProperties.TrackWidth = 1.9;
self.PhysVehicleProperties.WheelBase = 2.45;
self.PhysVehicleProperties.FrntWhlRadius = 0.306;
self.PhysVehicleProperties.RearWhlRadius = 0.306;
self.PhysVehicleProperties.CgOffset = self.PhysVehicleProperties.CgOffset + [ .05,  - .04, 0 ];
case 'BoxTruck'
self.PhysVehicleProperties.TrackWidth = 1.38;
self.PhysVehicleProperties.WheelBase = 5.5;
self.PhysVehicleProperties.FrntWhlRadius = 0.5715;
self.PhysVehicleProperties.RearWhlRadius = 0.5715;
self.PhysVehicleProperties.CgOffset = self.PhysVehicleProperties.CgOffset + [ .25, 0, 0 ];
otherwise 

self.PhysVehicleProperties.TrackWidth = vehicleProperties.TrackWidth;
self.PhysVehicleProperties.WheelBase = vehicleProperties.WheelBase;
self.PhysVehicleProperties.FrntWhlRadius = vehicleProperties.FrntWhlRadius;
self.PhysVehicleProperties.RearWhlRadius = vehicleProperties.RearWhlRadius;
end 

self.PhysVehicleProperties.DrivetrainType = vehicleProperties.DrivetrainType;
self.PhysVehicleProperties.DiffType = vehicleProperties.DiffType;
self.PhysVehicleProperties.DlType = getDlType( self );



self.LightModule = sim3d.vehicle.VehicleLightingModule( r.LightConfiguration );

self.Config.MeshPath = self.Mesh;
self.Config.AnimationPath = self.Animation;
self.Config.ColorPath = self.Color;
self.Config.AdditionalOptions = self.LightModule.generateInitMessageString(  );












end 
function setup( self )
setup@sim3d.auto.WheeledVehicle( self );
self.PhysVehicleConfigPublisher = sim3d.io.Publisher( [ self.getTag(  ), sim3d.auto.PhysVehicle.SuffixConfigOut ] );
self.PhysVehicleControlsPublisher = sim3d.io.Publisher( [ self.getTag(  ), sim3d.auto.PhysVehicle.SuffixControlsOut ] );
self.PhysVehicleChassisFeedbackSubscriber = sim3d.io.Subscriber( [ self.getTag(  ), sim3d.auto.PhysVehicle.SuffixChassisFeedbackIn ] );
self.PhysVehicleDrivelineFeedbackSubscriber = sim3d.io.Subscriber( [ self.getTag(  ), sim3d.auto.PhysVehicle.SuffixDrivelineFeedbackIn ] );
self.PhysVehicleTireFeedbackSubscriber = sim3d.io.Subscriber( [ self.getTag(  ), sim3d.auto.PhysVehicle.SuffixTireFeedbackIn ] );
end 
function reset( self )
reset@sim3d.auto.WheeledVehicle( self );
self.PhysVehicleConfigPublisher.publish( self.PhysVehicleProperties );
end 
function write( self, steerCmd, acclCmd, decelCmd, gearCmd, hndbrkCmd )
PhysVehicleControls = struct(  ...
'steerCmd', single( steerCmd ),  ...
'acclCmd', single( acclCmd ),  ...
'decelCmd', single( decelCmd ),  ...
'gearCmd', single( gearCmd ),  ...
'hndbrkCmd', boolean( hndbrkCmd ) );
self.PhysVehicleControlsPublisher.publish( PhysVehicleControls );


self.Config.AdditionalOptions = self.LightModule.generateStepMessageString(  );

self.ConfigWriter.send( self.Config );
end 

function [ translation, rotation, scale ] = readTransform( self )
[ translation, rotation, scale ] = readTransform@sim3d.auto.WheeledVehicle( self );
end 
function [ inertVel, bodyVel, bodyAccel, bodyAngVel, bodyAngAcc, COMLoc ] = readChassis( self )
if self.PhysVehicleChassisFeedbackSubscriber.has_message(  )
chassisFeedback = self.PhysVehicleChassisFeedbackSubscriber.take(  );
bodyVel = chassisFeedback.BodyLinearVel;
bodyAccel = chassisFeedback.BodyLinearAccel;
bodyAngVel = chassisFeedback.BodyAngularVel;
bodyAngAcc = chassisFeedback.BodyAngularAccel;
inertVel = chassisFeedback.InertialLinearVel;
COMLoc = chassisFeedback.COMLoc;
end 
end 
function [ EngSpd, TransGear ] = readDriveline( self )
if self.PhysVehicleDrivelineFeedbackSubscriber.has_message(  )
drivelineFeedback = self.PhysVehicleDrivelineFeedbackSubscriber.take(  );
EngSpd = drivelineFeedback.EngSpd;
TransGear = drivelineFeedback.TransGear;
end 
end 
function [ TireForce, WheelTorque, TireSlip ] = readTires( self )
if self.PhysVehicleTireFeedbackSubscriber.has_message(  )
tireFeedback = self.PhysVehicleTireFeedbackSubscriber.take(  );
TireForce = tireFeedback.WheelForce;
TireSlip = tireFeedback.WheelSlip;
WheelTorque = tireFeedback.WheelTorque;
end 
end 

function ret = getMesh( self )
ret = self.Mesh;
end 
function ret = getAnimation( self )
switch self.PhysVehicleType
case sim3d.auto.VehicleTypes.BoxTruck
ret = '/MathWorksAutomotiveContent/Vehicles/PhysVehicle/Blueprints/Anim_PhysVehicleBoxTruck.Anim_PhysVehicleBoxTruck_C';
otherwise 
ret = '/MathWorksAutomotiveContent/Vehicles/PhysVehicle/Blueprints/Anim_PhysVehicle.Anim_PhysVehicle_C';
end 
end 
function ret = getColor( ~, color )
switch color
case 'black'
ret = sim3d.utils.ActorColors.Black;
case 'red'
ret = sim3d.utils.ActorColors.Red;
case 'orange'
ret = sim3d.utils.ActorColors.Orange;
case 'yellow'
ret = sim3d.utils.ActorColors.Yellow;
case 'green'
ret = sim3d.utils.ActorColors.Green;
case 'blue'
ret = sim3d.utils.ActorColors.Blue;
case 'white'
ret = sim3d.utils.ActorColors.White;
case 'whitepearl'
ret = sim3d.utils.ActorColors.WhitePearl;
case 'grey'
ret = sim3d.utils.ActorColors.Grey;
case 'darkgrey'
ret = sim3d.utils.ActorColors.DarkGrey;
case 'silver'
ret = sim3d.utils.ActorColors.Silver;
case 'bluesilver'
ret = sim3d.utils.ActorColors.BlueSilver;
case 'darkredblack'
ret = sim3d.utils.ActorColors.DarkRedBlack;
case 'redblack'
ret = sim3d.utils.ActorColors.RedBlack;
otherwise 
error( 'sim3d:invalidVehicleColor', 'Invalid Vehicle Color. Please check help and select a valid Vehicle Color.' );
end 
end 

function ret = getVehType( ~, VType )
switch VType
case 'MuscleCar'
ret = sim3d.auto.VehicleTypes.MuscleCar;
case 'Sedan'
ret = sim3d.auto.VehicleTypes.Sedan;
case 'SportUtilityVehicle'
ret = sim3d.auto.VehicleTypes.SportUtilityVehicle;
case 'SmallPickupTruck'
ret = sim3d.auto.VehicleTypes.SmallPickupTruck;
case 'Hatchback'
ret = sim3d.auto.VehicleTypes.Hatchback;
case 'BoxTruck'
ret = sim3d.auto.VehicleTypes.BoxTruck;
case 'Custom'
ret = '';
otherwise 
error( 'sim3d:invalidVehicleType', 'Invalid Vehicle Type. Please check help and select a valid Vehicle Type' );
end 
end 
function ret = getDlType( self )


switch self.PhysVehicleProperties.DrivetrainType
case "Rear Wheel Drive"
if self.PhysVehicleProperties.DiffType == "Open"
ret = int32( 5 );
else 
ret = int32( 2 );
end 
case "Front Wheel Drive"
if self.PhysVehicleProperties.DiffType == "Open"
ret = int32( 4 );
else 
ret = int32( 1 );
end 
otherwise 
if self.PhysVehicleProperties.DiffType == "Open"
ret = int32( 3 );
else 
ret = int32( 0 );
end 
end 
end 
function copy( self, other, CopyChildren, UseSourcePosition )
R36
self( 1, 1 )sim3d.auto.PhysVehicle
other( 1, 1 )sim3d.auto.PhysVehicle
CopyChildren( 1, 1 )logical = true
UseSourcePosition( 1, 1 )logical = false
end 


self.PhysVehicleType = other.PhysVehicleType;


copy@sim3d.auto.WheeledVehicle( self, other, CopyChildren, UseSourcePosition );

end 

function actorS = getAttributes( self )
actorS = getAttributes@sim3d.auto.WheeledVehicle( self );
actorS.PhysVehicleType = self.PhysVehicleType;
end 

function setAttributes( self, actorS )
setAttributes@sim3d.auto.WheeledVehicle( self, actorS );
self.PhysVehicleType = actorS.PhysVehicleType;
end 

end 
methods ( Access = public, Hidden = true )
function actorType = getActorType( ~ )
actorType = sim3d.utils.ActorTypes.PhysVehicle;
end 
function numberOfParts = getNumberOfParts( self )
numberOfParts = self.NumberOfParts;
end 
function tagName = getTagName( ~ )
tagName = 'PhysVehicle';
end 
end 
methods ( Access = private, Static )
function ret = getBlueprintPath( PassengerVehicleType )
switch PassengerVehicleType
case sim3d.auto.VehicleTypes.MuscleCar
ret = '/MathWorksAutomotiveContent/Vehicles/Muscle/Meshes/SK_MuscleCar.SK_MuscleCar';
case sim3d.auto.VehicleTypes.Sedan
ret = '/MathWorksAutomotiveContent/Vehicles/Sedan/Meshes/SK_SedanCar.SK_SedanCar';
case sim3d.auto.VehicleTypes.SportUtilityVehicle
ret = '/MathWorksAutomotiveContent/Vehicles/SUV/Meshes/SK_SUVCar.SK_SUVCar';
case sim3d.auto.VehicleTypes.SmallPickupTruck
ret = '/MathWorksAutomotiveContent/Vehicles/PickupTruck/Meshes/SK_PickupTruck.SK_PickupTruck';
case sim3d.auto.VehicleTypes.Hatchback
ret = '/MathWorksAutomotiveContent/Vehicles/Hatchback/Meshes/SK_Hatchback.SK_Hatchback';
case sim3d.auto.VehicleTypes.BoxTruck
ret = '/MathWorksAutomotiveContent/Vehicles/Boxtruck/Meshes/SK_BoxTruck.SK_BoxTruck';
otherwise 
ret = '';
end 
end 
function r = parseInputs( varargin )

defaultParams = struct(  ...
'Color', 'red',  ...
'Mesh', 'MeshText',  ...
'Animation', 'AnimationText',  ...
'Translation', single( zeros( 1, 3 ) ),  ...
'Rotation', single( zeros( 1, 3 ) ),  ...
'Scale', single( ones( 1, 3 ) ),  ...
'ActorID', sim3d.utils.SemanticType.Vehicle,  ...
'DebugRayTrace', false );


parser = inputParser;
parser.addParameter( 'Color', defaultParams.Color );
parser.addParameter( 'Mesh', defaultParams.Mesh );
parser.addParameter( 'Animation', defaultParams.Animation );
parser.addParameter( 'Translation', defaultParams.Translation );
parser.addParameter( 'Rotation', defaultParams.Rotation );
parser.addParameter( 'Scale', defaultParams.Scale );
parser.addParameter( 'ActorID', defaultParams.ActorID );
parser.addParameter( 'LightConfiguration', {  } );

parser.parse( varargin{ : } );
r = parser.Results;
end 
end 
methods ( Access = public, Hidden = true, Static )
function dynvehicleProperties = getPhysVehicleProperties(  )



dynvehicleProperties = struct(  ...
'Mass', 1501,  ...
'Cd', 0.3,  ...
'TrackWidth', 1.80,  ...
'ChassisHeight', 1.5,  ...
'WheelBase', 1.4,  ...
'IvehScale', [ 1, 1, 1 ],  ...
'CgOffset', [ 0, 0, 0 ],  ...
'TrqCrv', [ 0, 300, 400, 0 ],  ...
'SpdCrv', [ 0, 1000, 5500, 8000 ],  ...
'MaxRPM', 8000,  ...
'Jmot', 1,  ...
'bEngMax', 0.15,  ...
'bEngMin', 2,  ...
'bEngN', 0.35,  ...
'DrivetrainType', "Rear Wheel Drive",  ...
'DiffType', "Limited Slip",  ...
'DlType', int32( 2 ),  ...
'AutoTrans', true,  ...
'FrontRearSplit', 0.5,  ...
'ClutchGain', 10,  ...
'tShift', 0.5,  ...
'tMinShift', 2.0,  ...
'G', int32( [  - 1, 0, 1, 2, 3, 4, 5 ] ),  ...
'UpShiftPts', [ 0.15, 0.65, 0.65, 0.65, 0.65 ],  ...
'DownShiftPts', [ 0.15, 0.5, 0.5, 0.5, 0.5 ],  ...
'N', [  - 4, 4, 2, 1.5, 1.1, 1.0, 0.75 ],  ...
'NDiff', 4.0,  ...
'EnableFrontSteer', true,  ...
'EnableRearSteer', false,  ...
'PctAck', 100.0,  ...
'SteerCrv', [ 1, 0.8, 0.7 ],  ...
'SteerSpdCrv', [ 0, 60, 120 ],  ...
'FrntWhlRadius', 0.30,  ...
'FrntWhlMass', 20,  ...
'FrntWhlDamping', 0.25,  ...
'FrntWhlMaxSteer', 70,  ...
'FrntTireMaxLatLoadFactor', 2.0,  ...
'FrntTireLatStiff', 17,  ...
'FrntTireLongStiff', 1000,  ...
'RearWhlRadius', 0.30,  ...
'RearWhlMass', 20,  ...
'RearWhlDamping', 0.25,  ...
'RearWhlMaxSteer', 70,  ...
'RearTireMaxLatLoadFactor', 2.0,  ...
'RearTireLatStiff', 17,  ...
'RearTireLongStiff', 1000,  ...
'FrntWhlHndBrkEnable', true,  ...
'RearWhlHndBrkEnable', true,  ...
'FrntWhlMaxTrq', 1500,  ...
'RearWhlMaxTrq', 1500,  ...
'FrntWhlMaxHndBrkTrq', 3000,  ...
'RearWhlMaxHndBrkTrq', 1500,  ...
'lambda_mu', 1.0,  ...
'FrntSuspFOffset', 0,  ...
'FrntSuspMaxComp', .01,  ...
'FrntSuspMaxExt', .01,  ...
'FrntSuspNatFreq', 7,  ...
'FrntSuspDamping', 1,  ...
'RearSuspFOffset', 0,  ...
'RearSuspMaxComp', .01,  ...
'RearSuspMaxExt', .01,  ...
'RearSuspNatFreq', 7,  ...
'RearSuspDamping', 1,  ...
'EnableLightControls', false,  ...
'LeftHeadlightOrientation', [ 0, 0 ],  ...
'LeftHeadlightLocation', [ 50, 0, 0 ],  ...
'RightHeadlightOrientation', [ 0, 0 ],  ...
'RightHeadlightLocation', [ 50, 0, 0 ],  ...
'HeadlightColor', [ 1, 1, 1 ],  ...
'TaillightColor', [ 1, 0, 0 ],  ...
'BrakelightColor', [ 1, 0, 0 ],  ...
'ReverselightColor', [ 1, 0.868, 0.3234 ],  ...
'SignallightColor', [ 1, 0.146, 0 ],  ...
'HighBeamIntensity', 100000,  ...
'LowBeamIntensity', 60000,  ...
'AttenuationRadius', 10000,  ...
'HighBeamRadius', 70,  ...
'LowBeamRadius', 70,  ...
'BrakelightIntensity', 500,  ...
'ReverselightIntensity', 500,  ...
'IndicatorlightIntensity', 500 );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpxaM6bd.p.
% Please follow local copyright laws when handling this file.

