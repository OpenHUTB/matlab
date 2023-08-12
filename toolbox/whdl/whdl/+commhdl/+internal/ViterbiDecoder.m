classdef ( StrictDefaults )ViterbiDecoder < matlab.System














%#codegen




properties ( Nontunable )


ConstraintLength = 7;


CodeGenerator = [ 171, 133 ];

Tbd = 32;


TerminationMethod = 'Continuous';


ErasureInputPort( 1, 1 )logical = false;

ResetInputPort( 1, 1 )logical = false;
end 

properties ( Nontunable, Access = private )
nsDec;
frameSignal;
terminationMode;
counterWordLen;
latency;
dataType;
end 

properties ( Constant, Hidden )
TerminationMethodSet = matlab.system.StringSet( {  ...
'Continuous', 'Terminated', 'Truncated' } );
end 


properties ( Access = private )

frameControllerObj;
metricCalculatorObj;
RAMTraceBackUnitObj;


delayDataBalance;
delayErasBalance;
delayCtrlBalance;
delayValBalance;
delayRstBalance;


validCount;
state;


decodedBit;
validReg;
ctrlOut;
end 





methods 

function obj = ViterbiDecoder( varargin )
coder.allowpcode( 'plain' );
if coder.target( 'MATLAB' )
if ~( builtin( 'license', 'checkout', 'LTE_HDL_Toolbox' ) )
error( message( 'whdl:whdl:NoLicenseAvailable' ) );
end 
else 
coder.license( 'checkout', 'LTE_HDL_Toolbox' );
end 


setProperties( obj, nargin, varargin{ : } );
end 

function set.ConstraintLength( obj, val )
validateattributes( val, { 'numeric' }, { 'integer',  ...
'scalar', '>', 2, '<', 10 }, 'ViterbiDecoder', 'Constraint Length' );
obj.ConstraintLength = val;
end 

function set.CodeGenerator( obj, val )
coder.extrinsic( 'commprivate' );
coder.extrinsic( 'boolean' );
CGLength = numel( val );
validateattributes( val, { 'numeric' }, { 'integer',  ...
'row' }, 'ViterbiDecoder', 'Code Generator' );
coder.internal.errorIf( ~boolean( commprivate( 'isoctal', val ) ),  ...
'whdl:ViterbiDecoder:InvalidCGType' );
coder.internal.errorIf( ~( CGLength >= 2 && CGLength <= 7 ),  ...
'whdl:ViterbiDecoder:InvalidRate' );
obj.CodeGenerator = val;
end 

function set.Tbd( obj, val )
TBD = val;
validateattributes( TBD, { 'numeric' }, { 'integer', 'scalar', '>', 2, '<', 129 }, 'ViterbiDecoder', 'Traceback depth' );
obj.Tbd = TBD;
end 
end 

methods ( Static, Access = protected )
function header = getHeaderImpl
text = [  ...
'Decodes convolutionally encoded data using a RAM-based Viterbi algorithm. ', newline, newline ...
, 'To represent signed soft decisions, use sfix input with a word length from 2 to 16 bits and fraction length 0. ', newline ...
, 'To represent unsigned soft decisions, use ufix input with a word length from 1 to 16 bits and fraction length 0. ', newline ...
, 'To represent unquantized decisions use double/single. This input type is supported for simulation but not for HDL code generation. ', newline, newline ...
, 'For HDL code generation, the recommended word length is 8 or fewer bits. Fraction length must be 0.'
 ];

header = matlab.system.display.Header( 'commhdl.internal.ViterbiDecoder',  ...
'Title', 'Viterbi Decoder',  ...
'Text', text,  ...
'ShowSourceLink', false );
end 

function groups = getPropertyGroupsImpl

trellisStruc = matlab.system.display.Section(  ...
'Title', 'Encoded data parameters',  ...
'PropertyList', { 'ConstraintLength', 'CodeGenerator',  ...
'ErasureInputPort' } );

tbParam = matlab.system.display.Section(  ...
'Title', 'Traceback decoding parameters',  ...
'PropertyList', { 'Tbd', 'TerminationMethod', 'ResetInputPort' } );

main = matlab.system.display.SectionGroup(  ...
'Title', 'Main',  ...
'Sections', [ trellisStruc, tbParam ] );

groups = main;
end 

function isVisible = showSimulateUsingImpl
isVisible = false;
end 
end 



methods ( Access = protected )
function icon = getIconImpl( ~ )
icon = 'Viterbi Decoder';
end 

function supported = supportsMultipleInstanceImpl( ~ )

supported = true;
end 

function resetImpl( obj )

reset( obj.frameControllerObj );
reset( obj.metricCalculatorObj );
reset( obj.RAMTraceBackUnitObj );
reset( obj.delayDataBalance );
reset( obj.delayErasBalance );
reset( obj.delayCtrlBalance );
reset( obj.delayValBalance );
reset( obj.delayRstBalance );

resetparams( obj );
end 

function setupImpl( obj, varargin )

obj.frameSignal = ~strcmpi( obj.TerminationMethod, 'Continuous' );
obj.terminationMode = strcmpi( obj.TerminationMethod, 'Terminated' );
softBitsDT = varargin{ 1 };

if ( isa( softBitsDT, 'embedded.fi' ) && isfixed( softBitsDT ) )
obj.nsDec = softBitsDT.WordLength;
obj.dataType = cast( 0, 'like', softBitsDT );
elseif ( isa( softBitsDT, 'logical' ) )
obj.nsDec = 1;
obj.dataType = fi( 0, 0, 1, 0 );
elseif ( isa( softBitsDT, 'uint8' ) ) && isnumeric( softBitsDT )
obj.nsDec = 8;
obj.dataType = fi( 0, 0, 8, 0 );
elseif ( isa( softBitsDT, 'uint16' ) ) && isnumeric( softBitsDT )
obj.nsDec = 16;
obj.dataType = fi( 0, 0, 16, 0 );
elseif ( isa( softBitsDT, 'int8' ) ) && isnumeric( softBitsDT )
obj.nsDec = 8;
obj.dataType = fi( 0, 1, 8, 0 );
elseif ( isa( softBitsDT, 'int16' ) ) && isnumeric( softBitsDT )
obj.nsDec = 16;
obj.dataType = fi( 0, 1, 16, 0 );
else 
obj.dataType = cast( 0, 'like', softBitsDT );
obj.nsDec = 16;
end 

obj.frameControllerObj = commhdl.internal.ViterbiDecoderFrameController( 'tbd', obj.Tbd );

obj.metricCalculatorObj = commhdl.internal.ViterbiDecoderMetricCalculator( 'K', obj.ConstraintLength,  ...
'G', obj.CodeGenerator, 'nsDec', obj.nsDec, 'enbErasure',  ...
obj.ErasureInputPort, 'frameSignal', obj.frameSignal,  ...
'continuousModeReset', obj.ResetInputPort && ~obj.frameSignal,  ...
'terminationMode', obj.terminationMode );

obj.RAMTraceBackUnitObj = commhdl.internal.ViterbiDecoderRAMTracebackUnit( 'tbd', obj.Tbd, 'K',  ...
obj.ConstraintLength, 'continuousModeReset', obj.ResetInputPort && ~obj.frameSignal );

obj.delayDataBalance = dsp.Delay( 1 );
obj.delayErasBalance = dsp.Delay( 1 );
obj.delayCtrlBalance = dsp.Delay( 7 );
obj.decodedBit = fi( 0, 0, 1, 0 );
obj.delayValBalance = dsp.Delay( 1 );
obj.delayRstBalance = dsp.Delay( 1 );

countermax = obj.ConstraintLength + 12;

obj.counterWordLen = ceil( log2( countermax ) );
obj.latency = fi( countermax, 0, obj.counterWordLen + 1, 0, hdlfimath );
obj.state = fi( 0, 0, 1, 0 );
resetparams( obj )
end 

function resetparams( obj )

obj.validCount = fi( 0, 0, obj.counterWordLen, 0, hdlfimath );

obj.decodedBit = fi( 0, 0, 1, 0 );
obj.validReg = false;
obj.ctrlOut = struct( 'start', false, 'end', false, 'valid', false );
end 

function flag = getExecutionSemanticsImpl( ~ )

flag = { 'Classic', 'Synchronous' };
end 

function [ data, valid ] = outputImpl( obj, varargin )


if ( ~obj.frameSignal )
valid = obj.validReg;
data = ( obj.decodedBit( : ) == 1 ) && obj.validReg;
else 
data = ( obj.decodedBit( : ) == 1 ) && obj.ctrlOut.valid;
valid = obj.ctrlOut;
end 
end 

function updateImpl( obj, varargin )


if ( isa( obj.dataType, 'double' ) || isa( obj.dataType, 'single' ) )
softValues = cast(  - varargin{ 1 }, 'like', obj.dataType );
else 
softValues = cast( varargin{ 1 }, 'like', obj.dataType );
end 
softValuesd = obj.delayDataBalance( softValues( : )' );
if ( obj.frameSignal )
ctrlIn = varargin{ 2 };

[ startOut0, endOut0, validOut0, startInFlag,  ...
frameGapValid, enbProcess ] =  ...
obj.frameControllerObj( ctrlIn.start, ctrlIn.end, ctrlIn.valid );
ctrlout = [ startOut0, endOut0, validOut0 ];

if ( obj.ErasureInputPort )
erasure = varargin{ 3 };
erasured = obj.delayErasBalance( erasure( : )' );

if ( obj.ConstraintLength == 9 )
[ minStateIndx, metvalidOut, datainfiL, datainfiH, ctrlSignals ] =  ...
obj.metricCalculatorObj( softValuesd, enbProcess,  ...
frameGapValid, startInFlag, erasured, ctrlout );
else 
[ minStateIndx, metvalidOut, datainfi, ctrlSignals ] =  ...
obj.metricCalculatorObj( softValuesd, enbProcess,  ...
frameGapValid, startInFlag, erasured, ctrlout );
end 
else 

if ( obj.ConstraintLength == 9 )
[ minStateIndx, metvalidOut, datainfiL, datainfiH, ctrlSignals ] ...
 = obj.metricCalculatorObj( softValuesd, enbProcess,  ...
frameGapValid, startInFlag, ctrlout );
else 
[ minStateIndx, metvalidOut, datainfi, ctrlSignals ] =  ...
obj.metricCalculatorObj( softValuesd, enbProcess,  ...
frameGapValid, startInFlag, ctrlout );
end 
end 

if ( obj.ConstraintLength == 9 )
[ obj.decodedBit, ~ ] = obj.RAMTraceBackUnitObj( datainfiL,  ...
datainfiH, metvalidOut, minStateIndx );
else 
[ obj.decodedBit, ~ ] = obj.RAMTraceBackUnitObj( datainfi,  ...
metvalidOut, minStateIndx );
end 
ctrlOutVec = obj.delayCtrlBalance( ctrlSignals( : )' );

obj.ctrlOut.start = ctrlOutVec( 1 );
obj.ctrlOut.end = ctrlOutVec( 2 );
obj.ctrlOut.valid = ctrlOutVec( 3 );
else 
validd = obj.delayValBalance( varargin{ 2 } );

if ( obj.ErasureInputPort )
erasure = varargin{ 3 }';
erasured = obj.delayErasBalance( erasure( : )' );

if ( obj.ResetInputPort )
continuousModeReset = varargin{ 4 };
continuousModeResetd = obj.delayRstBalance( continuousModeReset );
if ( obj.ConstraintLength == 9 )
[ minStateIndx, metvalidOut,  ...
datainfiL, datainfiH, continousResetOut ] =  ...
obj.metricCalculatorObj( softValuesd, validd,  ...
erasured, continuousModeResetd );
else 
[ minStateIndx, metvalidOut,  ...
datainfi, continousResetOut ] =  ...
obj.metricCalculatorObj( softValuesd, validd,  ...
erasured, continuousModeResetd );
end 
else 

if ( obj.ConstraintLength == 9 )
[ minStateIndx, metvalidOut, datainfiL, datainfiH ] =  ...
obj.metricCalculatorObj( softValuesd, validd,  ...
erasured );
else 
[ minStateIndx, metvalidOut,  ...
datainfi ] = obj.metricCalculatorObj( softValuesd,  ...
validd, erasured );
end 
end 
else 

if ( obj.ResetInputPort )
continuousModeReset = varargin{ 3 };
continuousModeResetd = obj.delayRstBalance( continuousModeReset );
if ( obj.ConstraintLength == 9 )
[ minStateIndx, metvalidOut,  ...
datainfiL, datainfiH, continousResetOut ] =  ...
obj.metricCalculatorObj( softValuesd, validd,  ...
continuousModeResetd );
else 
[ minStateIndx, metvalidOut, datainfi, continousResetOut ] =  ...
obj.metricCalculatorObj( softValuesd, validd,  ...
continuousModeResetd );
end 
else 
if ( obj.ConstraintLength == 9 )
[ minStateIndx, metvalidOut, datainfiL, datainfiH ] =  ...
obj.metricCalculatorObj( softValuesd, validd );
else 
[ minStateIndx, metvalidOut, datainfi ] =  ...
obj.metricCalculatorObj( softValuesd, validd );
end 
end 
end 

if ( obj.ResetInputPort )

if ( obj.ConstraintLength == 9 )
[ decodedBitLifo, validLifo ] =  ...
obj.RAMTraceBackUnitObj( datainfiL, datainfiH,  ...
metvalidOut, minStateIndx, continousResetOut );
else 
[ decodedBitLifo, validLifo ] =  ...
obj.RAMTraceBackUnitObj( datainfi, metvalidOut,  ...
minStateIndx, continousResetOut );
end 

validgenerationWithReset( obj, continuousModeReset, varargin{ 2 },  ...
validLifo, decodedBitLifo );
else 
if ( obj.ConstraintLength == 9 )
[ obj.decodedBit, obj.validReg ] =  ...
obj.RAMTraceBackUnitObj( datainfiL, datainfiH, metvalidOut,  ...
minStateIndx );
else 
[ obj.decodedBit, obj.validReg ] =  ...
obj.RAMTraceBackUnitObj( datainfi, metvalidOut,  ...
minStateIndx );
end 
end 

end 
end 


function validgenerationWithReset( obj, contModeReset, enb, validLifo, dataBit )

if ( contModeReset )
obj.validCount( : ) = 0;
obj.validReg( : ) = 0;
obj.decodedBit( : ) = 0;
obj.state( : ) = 0;
else 
switch ( uint32( obj.state ) )
case uint32( 0 )
obj.validReg( : ) = 0;
obj.decodedBit( : ) = 0;
if ( obj.validCount( : ) == obj.latency - 1 )
obj.state( : ) = 1;
end 
case uint32( 1 )
obj.validReg( : ) = validLifo;
if ( validLifo )
obj.decodedBit( : ) = dataBit;
else 
obj.decodedBit( : ) = 0;
end 
end 
if ( enb )
if ( obj.validCount( : ) == obj.latency - 1 )
obj.validCount( : ) = 0;
else 
obj.validCount( : ) = obj.validCount + 1;
end 
end 

end 
end 

function num = getNumInputsImpl( obj )
num = 2;
if ( obj.ErasureInputPort )
num = num + 1;
end 
if ( strcmpi( obj.TerminationMethod, 'Continuous' ) )
if ( obj.ResetInputPort )
num = num + 1;
end 
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'data';

if ( ~strcmpi( obj.TerminationMethod, 'Continuous' ) )
varargout{ 2 } = 'ctrl';
if ( obj.ErasureInputPort )
varargout{ 3 } = 'erasure';
end 
else 
varargout{ 2 } = 'valid';
if ( obj.ErasureInputPort )
varargout{ 3 } = 'erasure';
if ( obj.ResetInputPort )
varargout{ 4 } = 'reset';
end 
else 
if ( obj.ResetInputPort )
varargout{ 3 } = 'reset';
end 
end 
end 

end 

function num = getNumOutputsImpl( ~ )
num = 2;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'data';
if ( ~strcmpi( obj.TerminationMethod, 'Continuous' ) )
varargout{ 2 } = 'ctrl';
else 
varargout{ 2 } = 'valid';
end 

end 


function flag = isInactivePropertyImpl( obj, prop )
props = {  };
if ~strcmpi( obj.TerminationMethod, 'Continuous' )
props = [ props,  ...
{ 'ResetInputPort' } ];
end 
flag = ismember( prop, props );
end 


function validateInputsImpl( obj, varargin )

coder.extrinsic( 'tostringInternalSlName' );

if isempty( coder.target ) || ~coder.internal.isAmbiguousTypes
validateattributes( varargin{ 1 },  ...
{ 'single', 'double', 'logical', 'embedded.fi', 'uint8',  ...
'int8', 'uint16', 'int16' }, { 'size', [ length( obj.CodeGenerator ), 1 ], 'real' },  ...
'ViterbiDecoder', 'data' );


if isa( varargin{ 1 }, 'embedded.fi' )
maxWordLength = 16;
coder.internal.errorIf( varargin{ 1 }.FractionLength ~= 0,  ...
'whdl:ViterbiDecoder:InvalidInputFractionlength',  ...
tostringInternalSlName( varargin{ 1 }.numerictype ) );

if ( varargin{ 1 }.WordLength ~= 1 )
coder.internal.errorIf(  ...
( varargin{ 1 }.WordLength > maxWordLength ),  ...
'whdl:ViterbiDecoder:InvalidInputWordLength',  ...
tostringInternalSlName( varargin{ 1 }.numerictype ),  ...
maxWordLength );
if ( varargin{ 1 }.WordLength > 8 )
coder.internal.warning( 'whdl:ViterbiDecoder:InvalidHDLInputWordLength' );
end 
end 
end 
if strcmpi( obj.TerminationMethod, 'Continuous' )
validateattributes( varargin{ 2 }, { 'logical' }, { 'scalar' },  ...
'ViterbiDecoder', 'valid' );
if ( obj.ErasureInputPort )
validateattributes( varargin{ 3 }, { 'logical' }, { 'numel',  ...
length( obj.CodeGenerator ) }, 'ViterbiDecoder', 'erasure' );
if ( obj.ResetInputPort )
validateattributes( varargin{ 4 }, { 'logical' },  ...
{ 'scalar' }, 'ViterbiDecoder', 'reset' );
end 
else 
if ( obj.ResetInputPort )
validateattributes( varargin{ 3 }, { 'logical' },  ...
{ 'scalar' }, 'ViterbiDecoder', 'reset' );
end 
end 
else 
if ( obj.ErasureInputPort )
validateattributes( varargin{ 3 }, { 'logical' },  ...
{ 'numel', length( obj.CodeGenerator ) },  ...
'ViterbiDecoder', 'erasure' );
end 

validateattributes( varargin{ 2 }.start, { 'logical' },  ...
{ 'scalar' }, 'ViterbiDecoder', 'start' );
validateattributes( varargin{ 2 }.end, { 'logical' },  ...
{ 'scalar' }, 'ViterbiDecoder', 'end' );
validateattributes( varargin{ 2 }.valid, { 'logical' },  ...
{ 'scalar' }, 'ViterbiDecoder', 'valid' );
end 
if ( ( isa( varargin{ 1 }, 'int16' ) ) || ( isa( varargin{ 1 }, 'uint16' ) ) )
coder.internal.warning( 'whdl:ViterbiDecoder:InvalidHDLInputWordLength' );
end 
end 
end 

function validatePropertiesImpl( obj )

CodeGenMatrix = dec2bin( oct2dec( double( obj.CodeGenerator ) ) ) - '0';
if ( ( size( CodeGenMatrix, 2 ) ~= double( obj.ConstraintLength ) ) ||  ...
sum( CodeGenMatrix( :, 1 ) ) == 0 )
coder.internal.error( 'whdl:ViterbiDecoder:CGNotMatch' );
end 
end 





function varargout = getOutputDataTypeImpl( obj, varargin )
if strcmpi( obj.TerminationMethod, 'Continuous' )
varargout = { 'logical', 'logical' };
else 
varargout = { 'logical', samplecontrolbustype };
end 
end 


function varargout = isOutputComplexImpl( ~ )
varargout = { false, false };
end 



function [ sz1, sz2 ] = getOutputSizeImpl( ~ )
sz1 = [ 1, 1 ];
sz2 = [ 1, 1 ];
end 



function varargout = isOutputFixedSizeImpl( obj )
if strcmpi( obj.TerminationMethod, 'Continuous' )
varargout = { true, true };
else 
varargout = { true, true, true, true };
end 
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.frameControllerObj = obj.frameControllerObj;
s.metricCalculatorObj = obj.metricCalculatorObj;
s.RAMTraceBackUnitObj = obj.RAMTraceBackUnitObj;
s.delayDataBalance = obj.delayDataBalance;
s.delayErasBalance = obj.delayErasBalance;
s.delayCtrlBalance = obj.delayCtrlBalance;
s.delayValBalance = obj.delayValBalance;
s.delayRstBalance = obj.delayRstBalance;
s.validCount = obj.validCount;
s.state = obj.state;
s.decodedBit = obj.decodedBit;
s.validReg = obj.validReg;
s.ctrlOut = obj.ctrlOut;
s.nsDec = obj.nsDec;
s.frameSignal = obj.frameSignal;
s.terminationMode = obj.terminationMode;
s.counterWordLen = obj.counterWordLen;
s.latency = obj.latency;
s.dataType = obj.dataType;
end 
end 



function loadObjectImpl( obj, s, ~ )
fn = fieldnames( s );
for ii = 1:numel( fn )
obj.( fn{ ii } ) = s.( fn{ ii } );
end 
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5Qt4Wr.p.
% Please follow local copyright laws when handling this file.

