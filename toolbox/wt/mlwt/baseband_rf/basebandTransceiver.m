classdef basebandTransceiver < handle & matlab.mixin.SetGet
























































properties ( Dependent )



TransmitRadioGain double{ mustBeFinite, mustBeVector }



TransmitCenterFrequency double{ mustBeFinite, mustBePositive, mustBeVector }






TransmitAntennas( 1, 1 ){ mustBeText }




CaptureRadioGain double{ mustBeFinite, mustBeVector }



CaptureCenterFrequency double{ mustBeFinite, mustBePositive, mustBeVector }






CaptureAntennas( 1, 1 ){ mustBeText }





CaptureDataType{ mustBeTextScalar }



DroppedSamplesAction{ mustBeTextScalar }








SampleRate( 1, 1 )double{ mustBeFinite, mustBePositive }
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

function set.TransmitRadioGain( obj, val )
obj.propHelper.applyVectorTunable( "TransmitGain", val, length( obj.CaptureAntennas ), canRelease( obj ), obj.nonTunableErrorMessage( "TransmitGain" ) )
end 
function val = get.TransmitRadioGain( obj )
val = obj.sysObj.TransmitGain;
end 
function set.TransmitCenterFrequency( obj, val )
obj.propHelper.applyVectorTunable( "TransmitCenterFrequency", val, length( obj.CaptureAntennas ), canRelease( obj ), obj.nonTunableErrorMessage( "TransmitCenterFrequency" ) )
end 
function val = get.TransmitCenterFrequency( obj )
val = obj.sysObj.TransmitCenterFrequency;
end 

function set.TransmitAntennas( obj, val )
mustBeMember( val, obj.sysObj.AvailableTransmitAntennas );
val = convertCharsToStrings( val );
obj.propHelper.setNontunable( "TransmitAntennas", val, canRelease( obj ), obj.nonTunableErrorMessage( "TransmitAntennas" ) );
end 
function val = get.TransmitAntennas( obj )
val = obj.sysObj.TransmitAntennas;
end 
function set.TransmitDataType( obj, val )
obj.propHelper.setNontunable( "TransmitDataType", val, canRelease( obj ), obj.nonTunableErrorMessage( "TransmitDataType" ) );
end 
function val = get.TransmitDataType( obj )
val = obj.sysObj.TransmitDataType;
end 


function set.CaptureDataType( obj, val )
val = validatestring( val, [ "int16", "double", "single" ], "", "CaptureDataType" );
obj.propHelper.setNontunable( "CaptureDataType", val, canRelease( obj ), obj.nonTunableErrorMessage( "CaptureDataType" ) );
end 
function val = get.CaptureDataType( obj )
val = obj.sysObj.CaptureDataType;
end 
function set.DroppedSamplesAction( obj, val )
val = validatestring( val, [ "error", "warning", "none" ], "", "DroppedSamplesAction" );
obj.sysObj.DroppedSamplesAction = val;
end 
function val = get.DroppedSamplesAction( obj )
val = obj.sysObj.DroppedSamplesAction;
end 
function set.CaptureRadioGain( obj, val )
obj.propHelper.applyVectorTunable( "ReceiveGain", val, length( obj.CaptureAntennas ), canRelease( obj ), obj.nonTunableErrorMessage( "CaptureGain" ) )
end 
function val = get.CaptureRadioGain( obj )
val = obj.sysObj.ReceiveGain;
end 
function set.CaptureCenterFrequency( obj, val )
obj.propHelper.applyVectorTunable( "ReceiveCenterFrequency", val, length( obj.CaptureAntennas ), canRelease( obj ), obj.nonTunableErrorMessage( "CaptureCenterFrequency" ) )
end 
function val = get.CaptureCenterFrequency( obj )
val = obj.sysObj.ReceiveCenterFrequency;
end 

function set.CaptureAntennas( obj, val )
mustBeMember( val, obj.sysObj.AvailableReceiveAntennas );
val = convertCharsToStrings( val );
obj.propHelper.setNontunable( "ReceiveAntennas", val, canRelease( obj ), obj.nonTunableErrorMessage( "CaptureAntennas" ) );
end 
function val = get.CaptureAntennas( obj )
val = obj.sysObj.ReceiveAntennas;
end 


function set.SampleRate( obj, val )
obj.propHelper.setNontunable( "SampleRate", val, canRelease( obj ), obj.nonTunableErrorMessage( "SampleRate" ) );
end 
function val = get.SampleRate( obj )
val = obj.sysObj.SampleRate;
end 
end 

methods 
function obj = basebandTransceiver( radioID, varargin )
radioID = convertCharsToStrings( radioID );
obj.sysObj = wt.internal.basebandTransceiver( radioID );
obj.propHelper = wt.internal.app.PropertyHelper( obj.sysObj );


obj.sysObj.TransmitAntennas = obj.sysObj.TransmitAntennas( 1 );
obj.sysObj.ReceiveAntennas = obj.sysObj.ReceiveAntennas( 1 );


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

function [ data, timestamp, droppedSamples ] = capture( obj, length )

























[ data, timestamp, droppedSamples ] = capture( obj.sysObj, length, 1 );
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmppQ4r6T.p.
% Please follow local copyright laws when handling this file.

