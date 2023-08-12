classdef basebandTransmitter < handle & matlab.mixin.SetGet
































































properties ( Dependent )






RadioGain double{ mustBeFinite, mustBeVector }






CenterFrequency double{ mustBeFinite, mustBePositive, mustBeVector }







SampleRate( 1, 1 )double{ mustBeFinite, mustBePositive }







Antennas{ mustBeText }
end 

properties ( Hidden, Dependent )


TransmitDataType( 1, 1 ){ mustBeMember( TransmitDataType, [ "int16", "double", "single" ] ) }
end 

properties ( Access = protected )

sysObj
propHelper
nonTunableErrorMessage = @( propName )message( "wt:baseband_rf:StopTxThenTune", propName )
currentlyTransmitting = false;
end 

methods 
function set.RadioGain( obj, val )
obj.propHelper.applyVectorTunable( "TransmitGain", val, length( obj.Antennas ), canRelease( obj ), obj.nonTunableErrorMessage( "RadioGain" ) )
end 
function val = get.RadioGain( obj )
val = obj.sysObj.TransmitGain;
end 
function set.CenterFrequency( obj, val )
obj.propHelper.applyVectorTunable( "TransmitCenterFrequency", val, length( obj.Antennas ), canRelease( obj ), obj.nonTunableErrorMessage( "CenterFrequency" ) )
end 
function val = get.CenterFrequency( obj )
val = obj.sysObj.TransmitCenterFrequency;
end 

function set.Antennas( obj, val )
mustBeMember( val, obj.sysObj.AvailableTransmitAntennas );
val = convertCharsToStrings( val );
obj.propHelper.setNontunable( "TransmitAntennas", val, canRelease( obj ), obj.nonTunableErrorMessage( "Antennas" ) );
end 
function val = get.Antennas( obj )
val = obj.sysObj.TransmitAntennas;
end 
function set.SampleRate( obj, val )
obj.propHelper.setNontunable( "SampleRate", val, canRelease( obj ), obj.nonTunableErrorMessage( "SampleRate" ) );
end 
function val = get.SampleRate( obj )
val = obj.sysObj.SampleRate;
end 
function set.TransmitDataType( obj, val )
obj.propHelper.setNontunable( "TransmitDataType", val, canRelease( obj ), obj.nonTunableErrorMessage( "TransmitDataType" ) );
end 
function val = get.TransmitDataType( obj )
val = obj.sysObj.TransmitDataType;
end 
end 

methods 
function obj = basebandTransmitter( radioID, varargin )
radioID = convertCharsToStrings( radioID );
obj.sysObj = wt.internal.basebandTransceiver( radioID );
obj.propHelper = wt.internal.app.PropertyHelper( obj.sysObj );


obj.sysObj.TransmitAntennas = obj.sysObj.TransmitAntennas( 1 );
obj.sysObj.ReceiveAntennas =  - 1;


if ~isempty( varargin )
set( obj, varargin{ : } );
end 
end 

function transmit( obj, waveform, mode )


















R36
obj( 1, 1 )
waveform
mode( 1, 1 )wt.internal.TransmitModes
end 

if obj.currentlyTransmitting
error( message( "wt:baseband_rf:StopTxThenTx" ) )
end 


if ~ismember( class( waveform ), [ "int16", "double", "single" ] )
error( message( "wt:baseband_rf:WrongTxDataType" ) )
end 
obj.TransmitDataType = string( class( waveform ) );

obj.propHelper.applyAllProperties(  )

transmit( obj.sysObj, waveform, mode );


if mode ~= wt.internal.TransmitModes.once
obj.currentlyTransmitting = true;
end 
end 

function stopTransmission( obj )






obj.sysObj.stopTransmitRepeat(  );


obj.currentlyTransmitting = false;
end 
end 

methods ( Access = public, Hidden = true )
function setHardwareSetupCompleted( obj, value )
obj.sysObj.HardwareSetupCompleted = value;
end 
function value = getHardwareSetupCompleted( obj )
value = obj.sysObj.HardwareSetupCompleted;
end 
function setSystemObjectProperty( obj, name, value )
obj.sysObj.( name ) = value;
end 
function value = getSystemObjectProperty( obj, name )
value = obj.sysObj.( name );
end 
end 

methods ( Access = protected )
function releasable = canRelease( obj )
releasable = ~obj.currentlyTransmitting;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpNEsw7u.p.
% Please follow local copyright laws when handling this file.

