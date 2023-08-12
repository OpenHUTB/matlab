classdef preambleDetector < handle & matlab.mixin.SetGet

































































































properties ( Dependent )


CenterFrequency( 1, 1 );


RadioGain( 1, 1 );






Antennas;






SampleRate;




CaptureDataType{ mustBeTextScalar };



DroppedSamplesAction{ mustBeTextScalar };
end 

properties ( Dependent )











Preamble;








ThresholdMethod;


FixedThreshold;




AdaptiveThresholdOffset;




AdaptiveThresholdGain;







TriggerOffset;
end 

properties ( Access = private )
pPreamble = zeros( 16, 1 );
end 

properties ( SetAccess = private, GetAccess = public, Hidden, Dependent )
FilterCoefficients
end 

properties ( Access = private, Dependent )


TransmitDataType( 1, 1 ){ mustBeMember( TransmitDataType, [ "int16", "double", "single" ] ) };
end 

properties ( Dependent, Hidden )



AdaptiveThresholdWindowLength;
PacketSize;
end 

properties ( Hidden )
AvailableTransmitAntennas;
AvailableReceiveAntennas;
end 

properties ( Access = private )

pdSysObj;
propHelper;
nonTunableErrorMessage = @( propName )message( "wt:preambledetector:ChangePropWhileTransmitting", propName )
currentlyTransmitting = false;
end 

properties ( Access = private, Dependent )
pTransmitGain;
pTransmitCenterFrequency;
pTransmitAntennas;
end 

methods 

function set.DroppedSamplesAction( obj, val )
val = validatestring( val, [ "error", "warning", "none" ], "", "DroppedSamplesAction" );
obj.pdSysObj.DroppedSamplesAction = val;
end 
function val = get.DroppedSamplesAction( obj )
val = obj.pdSysObj.DroppedSamplesAction;
end 


function set.SampleRate( obj, val )
obj.propHelper.setNontunable( "SampleRate", val, canRelease( obj ), obj.nonTunableErrorMessage( "SampleRate" ) );
end 
function val = get.SampleRate( obj )
val = obj.pdSysObj.SampleRate;
end 

function set.Antennas( obj, val )
rxAntennas = obj.pdSysObj.pAvailableReceiveAntennas;
try 
mustBeMember( val, rxAntennas );
catch 
dq = repmat( """", size( rxAntennas ) );
rxAntennasMessage = strcat( dq, rxAntennas, dq );
error( message( "wt:preambledetector:AntennaNotValid", "Receive", strjoin( rxAntennasMessage, ', ' ) ) );
end 
val = convertCharsToStrings( val );
obj.propHelper.setNontunable( "ReceiveAntennas", val, canRelease( obj ), obj.nonTunableErrorMessage( "Antennas" ) );
end 
function val = get.Antennas( obj )
val = obj.pdSysObj.ReceiveAntennas;
end 

function set.pTransmitAntennas( obj, val )
val = convertCharsToStrings( val );
obj.propHelper.setNontunable( "TransmitAntennas", val, canRelease( obj ), obj.nonTunableErrorMessage( "TransmitAntennas" ) );
end 



function set.CenterFrequency( obj, val )
obj.propHelper.applyTunable( "ReceiveCenterFrequency", val );
end 
function val = get.CenterFrequency( obj )
val = obj.pdSysObj.ReceiveCenterFrequency;
end 

function set.pTransmitCenterFrequency( obj, val )
obj.propHelper.applyTunable( "TransmitCenterFrequency", val );
end 

function set.RadioGain( obj, val )
obj.propHelper.applyTunable( "ReceiveGain", val );
end 
function val = get.RadioGain( obj )
val = obj.pdSysObj.ReceiveGain;
end 

function set.pTransmitGain( obj, val )
obj.propHelper.applyTunable( "TransmitGain", val );
end 

function set.PacketSize( obj, val )
obj.propHelper.applyTunable( "PacketSize", val );
end 
function val = get.PacketSize( obj )
val = obj.pdSysObj.PacketSize;
end 


function set.Preamble( obj, val )
obj.FilterCoefficients = val;
obj.pPreamble = val;
end 

function val = get.Preamble( obj )
val = obj.pPreamble;
end 

function set.FilterCoefficients( obj, val )
if ( length( val ) > 1536 )
error( message( 'wt:preambledetector:FilterTooLong', 1, 1536 ) );
else 
obj.propHelper.setNontunable( "FilterCoefficients", val, canRelease( obj ), obj.nonTunableErrorMessage( "Preamble" ) );
obj.propHelper.setNontunable( "AdaptiveThresholdWindowLength", length( val ), canRelease( obj ), obj.nonTunableErrorMessage( "AdaptiveThresholdWindowLength" ) );
end 
end 

function val = get.FilterCoefficients( obj )
val = obj.pdSysObj.FilterCoefficients;
end 

function set.ThresholdMethod( obj, val )
val = validatestring( val, [ "fixed", "adaptive" ], "", "ThresholdMethod" );
obj.propHelper.setNontunable( "ThresholdMethod", val, canRelease( obj ), obj.nonTunableErrorMessage( "ThresholdMethod" ) );
end 
function val = get.ThresholdMethod( obj )
val = obj.pdSysObj.ThresholdMethod;
end 

function set.AdaptiveThresholdWindowLength( obj, val )
obj.propHelper.setNontunable( "AdaptiveThresholdWindowLength", val, canRelease( obj ), obj.nonTunableErrorMessage( "AdaptiveThresholdWindowLength" ) );
end 
function val = get.AdaptiveThresholdWindowLength( obj )
val = obj.pdSysObj.AdaptiveThresholdWindowLength;
end 

function set.TriggerOffset( obj, val )
obj.propHelper.setNontunable( "TriggerOffset", val, canRelease( obj ), obj.nonTunableErrorMessage( "TriggerOffset" ) );
end 
function val = get.TriggerOffset( obj )
val = obj.pdSysObj.TriggerOffset;
end 

function set.CaptureDataType( obj, val )
val = validatestring( val, [ "int16", "double", "single" ], "", "CaptureDataType" );
obj.propHelper.setNontunable( "CaptureDataType", val, canRelease( obj ), obj.nonTunableErrorMessage( "CaptureDataType" ) );
end 
function val = get.CaptureDataType( obj )
val = obj.pdSysObj.CaptureDataType;
end 

function set.TransmitDataType( obj, val )
obj.propHelper.setNontunable( "TransmitDataType", val, canRelease( obj ), obj.nonTunableErrorMessage( "TransmitDataType" ) );
end 
function val = get.TransmitDataType( obj )
val = obj.pdSysObj.TransmitDataType;
end 


function set.FixedThreshold( obj, val )
obj.propHelper.applyTunable( "FixedThreshold", val );
end 
function val = get.FixedThreshold( obj )
val = obj.pdSysObj.FixedThreshold;
end 

function set.AdaptiveThresholdOffset( obj, val )
obj.propHelper.applyTunable( "AdaptiveThresholdOffset", val );
end 
function val = get.AdaptiveThresholdOffset( obj )
val = obj.pdSysObj.AdaptiveThresholdOffset;
end 

function set.AdaptiveThresholdGain( obj, val )
obj.propHelper.applyTunable( "AdaptiveThresholdGain", val );
end 
function val = get.AdaptiveThresholdGain( obj )
val = obj.pdSysObj.AdaptiveThresholdGain;
end 

function canRelease = canRelease( obj )
canRelease = ~obj.currentlyTransmitting;
end 

end 

methods ( Hidden )
function [ filterOutput, scaledSignalPower, detectionVector, droppedSamplesFlag ] = readCalibrationSignals( obj, recordLength )




































[ filterOutput, scaledSignalPower, detectionVector, droppedSamplesFlag ] = readCalibrationSignals( obj.pdSysObj, recordLength );
end 
end 

methods 
function obj = preambleDetector( radioID, varargin )
radioID = convertCharsToStrings( radioID );
obj.pdSysObj = wt.internal.preambleDetector( radioID );
obj.propHelper = wt.internal.app.PropertyHelper( obj.pdSysObj );
obj.AvailableTransmitAntennas = obj.pdSysObj.pAvailableTransmitAntennas;
obj.AvailableReceiveAntennas = obj.pdSysObj.pAvailableReceiveAntennas;
if ~isempty( varargin ), set( obj, varargin{ : } );end 
end 

function [ data, timestamp, droppedSamples, status ] = capture( obj, length, timeout )






























obj.propHelper.applyAllProperties(  );
[ data, status, timestamp, droppedSamples ] = detect( obj.pdSysObj, length, timeout );
end 

function varargout = plotThreshold( obj, length )





















obj.propHelper.applyAllProperties(  );

[ filterOutput, scaledSignalPower, detectionVector, droppedSamplesFlag ] = readCalibrationSignals( obj.pdSysObj, length );

figure(  );
legend( 'AutoUpdate', 'Off' )
pFO = plot( filterOutput );
hold on
pSP = plot( scaledSignalPower );
if ( strcmp( obj.ThresholdMethod, "adaptive" ) )
pMT = plot( ones( 1, builtin( "length", filterOutput ) ) * obj.AdaptiveThresholdOffset, '--' );
end 

if ( isempty( detectionVector ) )
pDP = plot( 0, filterOutput( 1 ), 'v', 'Color', 'r', 'LineWidth', 2, 'visible', 'off' );
else 
pDP = plot( detectionVector, filterOutput( detectionVector ), 'v', 'Color', 'r', 'LineWidth', 2 );
end 
grid on
if ( strcmp( obj.ThresholdMethod, "adaptive" ) )
legend( [ pFO, pSP, pMT, pDP ], {  ...
message( "wt:preambledetector:FilterOutputPower" ).getString,  ...
message( "wt:preambledetector:ScaledSignalPower" ).getString,  ...
message( "wt:preambledetector:MinimumThreshold" ).getString,  ...
message( "wt:preambledetector:DetectionPoint" ).getString }, "Location", "southoutside" );
else 
legend( [ pFO, pSP, pDP ], {  ...
message( "wt:preambledetector:FilterOutputPower" ).getString,  ...
message( "wt:preambledetector:FixedThreshold" ).getString,  ...
message( "wt:preambledetector:DetectionPoint" ).getString }, "Location", "southoutside" );
end 
xlabel( message( "wt:preambledetector:Samples" ).getString )
ylabel( message( "wt:preambledetector:PowerAmplitude" ).getString )
if ( nargout == 0 )
return ;
else 
varargout{ 1 } = droppedSamplesFlag;
end 
end 

function transmit( obj, waveform, mode, varargin )























R36
obj( 1, 1 )
waveform
mode( 1, 1 )wt.internal.TransmitModes
end 
R36( Repeating )
varargin
end 
if obj.currentlyTransmitting
error( message( "wt:preambledetector:AttemptTransmitWhileTransmitting" ) );
end 
if ( wt.internal.TransmitModes( mode ) ~= wt.internal.TransmitModes( "continuous" ) )
error( message( "wt:preambledetector:WrongTransmitMode" ) );
else 
mode = wt.internal.TransmitModes( "continuous" );%#ok
end 
p = inputParser;
addParameter( p, "TransmitCenterFrequency", obj.CenterFrequency );
addParameter( p, "TransmitGain", 10 );

addParameter( p, "TransmitAntennas", obj.AvailableTransmitAntennas( 1 ) );
parse( p, varargin{ : } );
antennas = convertCharsToStrings( p.Results.TransmitAntennas );

if ( ~ismember( class( waveform ), [ "int16", "double", "single" ] ) )
error( message( "wt:preambledetector:WrongTxDataType" ) )
elseif ( ~iscolumn( waveform ) )
error( message( "wt:preambledetector:NotVector", "The transmit waveform" ) );
end 

obj.TransmitDataType = string( class( waveform ) );
setTransmitProperties( obj, p.Results.TransmitGain, p.Results.TransmitCenterFrequency, antennas );
obj.propHelper.applyAllProperties(  );
transmitRepeat( obj.pdSysObj, waveform );
obj.currentlyTransmitting = true;
end 

function stopTransmission( obj )




obj.propHelper.applyAllProperties(  );
stopTransmission( obj.pdSysObj );
obj.currentlyTransmitting = false;
end 
end 

methods ( Access = public, Hidden = true )
function setHardwareSetupCompleted( obj, value )
obj.pdSysObj.HardwareSetupCompleted = value;
end 
function value = getHardwareSetupCompleted( obj )
value = obj.pdSysObj.HardwareSetupCompleted;
end 
function regs = readbackRegisters( obj )
regs = obj.pdSysObj.readbackRegisters;
end 
function callSysObjSetup( obj )
obj.pdSysObj.setup;
end 
function status = getStatus( obj )
status = obj.pdSysObj.getStatus;
end 
function setSystemObjectProperty( obj, name, value )
obj.pdSysObj.( name ) = value;
end 
function value = getSystemObjectProperty( obj, name )
value = obj.pdSysObj.( name );
end 

end 

methods ( Access = private, Hidden = true )
function setTransmitProperties( obj, gain, centerfrequency, antennas )
txAntennas = obj.pdSysObj.pAvailableTransmitAntennas;
try 
mustBeMember( antennas, txAntennas );
catch 

dq = repmat( """", size( txAntennas ) );
txAntennasMessage = strcat( dq, txAntennas, dq );
error( message( "wt:preambledetector:AntennaNotValid", "Transmit", strjoin( txAntennasMessage, ', ' ) ) );
end 
if ( max( size( antennas ) ) ~= 1 )
error( message( "wt:preambledetector:AntennaNumNotValid" ) );
end 
obj.pTransmitGain = gain;
obj.pTransmitCenterFrequency = centerfrequency;
obj.pTransmitAntennas = antennas;
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ3IUAd.p.
% Please follow local copyright laws when handling this file.

