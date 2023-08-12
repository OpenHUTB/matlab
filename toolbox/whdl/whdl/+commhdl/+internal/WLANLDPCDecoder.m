classdef ( StrictDefaults )WLANLDPCDecoder < matlab.System








%#codegen


properties ( Nontunable )


Standard = 'IEEE 802.11 n/ac/ax'


Algorithm = 'Min-sum';


ScalingFactor = 0.75;


Termination = 'Max';


SpecifyInputs = 'Property'


NumIterations = 8;


MaxNumIterations = 8;


ParityCheckStatus( 1, 1 )logical = false;
end 

properties ( Constant, Hidden )
StandardSet = matlab.system.StringSet( { 'IEEE 802.11 n/ac/ax', 'IEEE 802.11 ad' } );
SpecifyInputsSet = matlab.system.StringSet( { 'Input port', 'Property' } );
AlgorithmSet = matlab.system.StringSet( { 'Min-sum', 'Normalized min-sum' } );
TerminationSet = matlab.system.StringSet( { 'Max', 'Early' } );
end 

properties ( Access = private, Nontunable )
scalarFlag;
SF;
alphaWL;
alphaFL;
betaWL;
minWL;
betadecmpWL;
dataRound;
end 


properties ( Access = private )


codeParameters;
ldpcDecoderCore;


dataCP;
validCP;
frameValidCP;
maxCount;
countData;
frameValid;
invalidBlockLength;
invalidLength, 
maxCountLUT;
lengthLUT;
lengthVal;
blockLen;
codeRate;
refIter;
ctrlOutReg1;


dataOut;
ctrlOut;
iterOut;
parCheck;
nextFrame;

dataOutReg;
ctrlOutReg;
iterOutReg;
parCheckReg;
end 

methods 


function obj = WLANLDPCDecoder( varargin )
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

function set.ScalingFactor( obj, val )
NMSVec = [ 1, 0.5, 0.5625, 0.625, 0.6875, 0.75, 0.8125, 0.875, 0.9375 ];
validateattributes( val, { 'double' }, { 'scalar' }, 'WLANLDPCDecoder', 'Scaling factor' );
coder.internal.errorIf( ~( any( val == NMSVec ) ),  ...
'whdl:WLANLDPCDecoder:InvalidScalingFactor' );
obj.ScalingFactor = val;
end 

function set.NumIterations( obj, val )
validateattributes( val, { 'double' }, { 'scalar', 'integer' }, 'WLANLDPCDecoder', 'Number of Iterations' );
coder.internal.errorIf( ~( val >= 1 && val <= 63 ),  ...
'whdl:WLANLDPCDecoder:InvalidNumIterations' );
obj.NumIterations = val;
end 

function set.MaxNumIterations( obj, val )
validateattributes( val, { 'double' }, { 'scalar', 'integer' }, 'WLANLDPCDecoder', 'Number of Iterations' );
coder.internal.errorIf( ~( val >= 1 && val <= 63 ),  ...
'whdl:WLANLDPCDecoder:InvalidMaxNumIterations' );
obj.MaxNumIterations = val;
end 

end 

methods ( Static, Access = protected )

function header = getHeaderImpl
text = [  ...
'Decode low-density parity-check (LDPC) code using layered belief ' ...
, 'propagation with min-sum or normalized min-sum approximation algorithm.' ...
, newline ...
, newline ...
, 'The block supports scalar inputs and vector inputs of size 8.'
 ];

header = matlab.system.display.Header( 'commhdl.internal.WLANLDPCDecoder',  ...
'Title', 'WLAN LDPC Decoder',  ...
'Text', text,  ...
'ShowSourceLink', false );
end 

function groups = getPropertyGroupsImpl
struc = matlab.system.display.Section(  ...
'Title', 'Parameters',  ...
'PropertyList', { 'Standard', 'Algorithm', 'ScalingFactor', 'Termination', 'SpecifyInputs', 'NumIterations', 'MaxNumIterations', 'ParityCheckStatus' } );

main = matlab.system.display.SectionGroup(  ...
'TitleSource', 'Auto',  ...
'Sections', struc );

groups = main;
end 


function isVisible = showSimulateUsingImpl
isVisible = false;
end 

end 

methods ( Access = protected )

function icon = getIconImpl( ~ )
icon = sprintf( 'WLAN LDPC Decoder' );
end 

function supported = supportsMultipleInstanceImpl( ~ )

supported = true;
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function resetImpl( obj )

reset( obj.codeParameters );
reset( obj.ldpcDecoderCore );

if obj.scalarFlag
obj.dataOutReg( : ) = zeros( 1, 1 );
else 
obj.dataOutReg( : ) = zeros( 8, 1 );
end 

obj.parCheckReg( : ) = false;
obj.nextFrame( : ) = true;
obj.ctrlOutReg( : ) = struct( 'start', false, 'end', false, 'valid', false );
obj.iterOutReg( : ) = uint8( 0 );
end 

function setupImpl( obj, varargin )

if isa( varargin{ 1 }, 'int8' )
WL = 8;
FL = 0;
elseif isa( varargin{ 1 }, 'int16' )
WL = 16;
FL = 0;
elseif isa( varargin{ 1 }, 'embedded.fi' )
WL = varargin{ 1 }.WordLength;
FL = varargin{ 1 }.FractionLength;
else 
WL = 4;
FL = 0;
end 

if ( strcmpi( obj.Algorithm, 'Min-sum' ) )
obj.SF = 1;
else 
obj.SF = obj.ScalingFactor;
end 

intwl = WL - FL;

if obj.SF == 1
obj.alphaFL = FL;
else 
obj.alphaFL = FL + 4;
end 
obj.alphaWL = intwl + 2 + obj.alphaFL;
obj.betaWL = intwl + obj.alphaFL;
obj.minWL = intwl - 1 + obj.alphaFL;

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
obj.betadecmpWL = 28;
else 
obj.betadecmpWL = 22;
end 

obj.scalarFlag = isscalar( varargin{ 1 } );



obj.codeParameters = commhdl.internal.WLANLDPCCodeParameters( 'Standard', obj.Standard, 'Termination', obj.Termination,  ...
'SpecifyInputs', obj.SpecifyInputs, 'NumIterations', obj.NumIterations, 'MaxNumIterations', obj.MaxNumIterations );


obj.ldpcDecoderCore = commhdl.internal.WLANLDPCDecoderCore( 'Standard', obj.Standard, 'Termination', obj.Termination,  ...
'ScalingFactor', obj.SF, 'alphaWL', obj.alphaWL, 'alphaFL', obj.alphaFL,  ...
'betaWL', obj.betaWL, 'minWL', obj.minWL, 'betadecmpWL', obj.betadecmpWL, 'ParityCheckStatus', obj.ParityCheckStatus );

if obj.scalarFlag
obj.dataCP = cast( 0, 'like', varargin{ 1 } );
obj.dataOut = zeros( 1, 1 ) > 0;
obj.dataOutReg = zeros( 1, 1 ) > 0;
obj.dataRound = cast( 0, 'like', fi( 0, 1, obj.alphaWL, obj.alphaFL ) );
obj.countData = fi( 0, 0, 11, 0, hdlfimath );
obj.maxCount = fi( 0, 0, 11, 0, hdlfimath );
else 
obj.dataCP = cast( zeros( 8, 1 ), 'like', varargin{ 1 } );
obj.dataOut = zeros( 8, 1 ) > 0;
obj.dataOutReg = zeros( 8, 1 ) > 0;
obj.dataRound = cast( zeros( 8, 1 ), 'like', fi( 0, 1, obj.alphaWL, obj.alphaFL ) );
obj.countData = fi( 0, 0, 8, 0, hdlfimath );
obj.maxCount = fi( 0, 0, 8, 0, hdlfimath );
end 

obj.validCP = false;
obj.frameValidCP = false;

obj.frameValid = false;
obj.invalidLength = false;
obj.invalidBlockLength = false;
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
if obj.scalarFlag
obj.maxCountLUT = fi( [ 648, 1296, 1944, 648 ], 0, 11, 0 );
else 
obj.maxCountLUT = fi( [ 81, 162, 243, 81 ], 0, 8, 0 );
end 
obj.lengthLUT = fi( [ 648, 1296, 1944, 648 ], 0, 11, 0 );
obj.lengthVal = fi( 648, 0, 11, 0 );
else 
obj.lengthLUT = fi( 672, 0, 11, 0 );
obj.lengthVal = fi( 672, 0, 11, 0 );
if obj.scalarFlag
obj.maxCountLUT = fi( 672, 0, 11, 0 );
else 
obj.maxCountLUT = fi( 84, 0, 8, 0 );
end 
end 
obj.blockLen = fi( 0, 0, 2, 0 );
obj.codeRate = fi( 0, 0, 2, 0 );
obj.refIter = uint8( 8 );
obj.ctrlOutReg1 = struct( 'start', false, 'end', false, 'valid', false );


obj.parCheck = false;
obj.nextFrame = true;
obj.ctrlOut = struct( 'start', false, 'end', false, 'valid', false );
obj.iterOut = uint8( 0 );

obj.parCheckReg = false;
obj.ctrlOutReg = struct( 'start', false, 'end', false, 'valid', false );
obj.iterOutReg = uint8( 0 );
end 

function varargout = outputImpl( obj, varargin )
varargout{ 1 } = obj.dataOutReg;
varargout{ 2 } = obj.ctrlOutReg;

if strcmpi( obj.Termination, 'Early' )
varargout{ 3 } = obj.iterOutReg;
if obj.ParityCheckStatus
varargout{ 4 } = obj.parCheckReg;
varargout{ 5 } = obj.nextFrame;
else 
varargout{ 4 } = obj.nextFrame;
end 
else 
if obj.ParityCheckStatus
varargout{ 3 } = obj.parCheckReg;
varargout{ 4 } = obj.nextFrame;
else 
varargout{ 3 } = obj.nextFrame;
end 
end 
end 

function updateImpl( obj, varargin )

datain = varargin{ 1 };
ctrlin = varargin{ 2 };


if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
blocklen = varargin{ 3 };
rate = varargin{ 4 };
if ctrlin.start && ctrlin.valid
obj.blockLen( : ) = blocklen;
obj.codeRate( : ) = rate;
end 
if ( strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' ) )
iterin = varargin{ 5 };
if ctrlin.start && ctrlin.valid
obj.refIter( : ) = iterin;
end 
[ data_cp, valid_cp, framevalid_cp, reset, endind,  ...
smdone, niter ] = obj.codeParameters( datain, ctrlin, obj.blockLen, obj.codeRate, obj.refIter );
else 
[ data_cp, valid_cp, framevalid_cp, reset, endind,  ...
smdone, niter ] = obj.codeParameters( datain, ctrlin, obj.blockLen, obj.codeRate );
end 

if ctrlin.start && ctrlin.valid
obj.maxCount( : ) = obj.maxCountLUT( obj.blockLen + 1 );
obj.lengthVal( : ) = obj.lengthLUT( obj.blockLen + 1 );
if obj.blockLen == fi( 3, 0, 2, 0 )
obj.invalidBlockLength = true;
obj.blockLen( : ) = 0;
if isempty( coder.target ) || ~coder.internal.isAmbiguousTypes
coder.internal.warning( 'whdl:WLANLDPCDecoder:InvalidBlockLength' );
end 
else 
obj.invalidBlockLength = false;
end 
end 
else 
rate = varargin{ 3 };
if ctrlin.start && ctrlin.valid
obj.codeRate( : ) = rate;
end 
if ( strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' ) )
iterin = varargin{ 4 };
if ctrlin.start && ctrlin.valid
obj.refIter( : ) = iterin;
end 
[ data_cp, valid_cp, framevalid_cp, reset, endind,  ...
smdone, niter ] = obj.codeParameters( datain, ctrlin, obj.codeRate, obj.refIter );
else 
[ data_cp, valid_cp, framevalid_cp, reset, endind,  ...
smdone, niter ] = obj.codeParameters( datain, ctrlin, obj.codeRate );
end 

if ctrlin.start && ctrlin.valid
obj.maxCount( : ) = obj.maxCountLUT;
obj.lengthVal( : ) = obj.lengthLUT;
end 
end 

endValid = ctrlin.end && ctrlin.valid && obj.frameValid;

if ctrlin.start && ctrlin.valid
obj.frameValid( : ) = true;
obj.countData( : ) = 0;
obj.invalidLength( : ) = false;
elseif endValid
obj.frameValid( : ) = false;
end 

if endValid && ~obj.nextFrame
if obj.countData ~= cast( obj.maxCount - 1, 'like', obj.maxCount )
obj.invalidLength = true;
if ( ~obj.invalidBlockLength )
if isempty( coder.target ) || ~coder.internal.isAmbiguousTypes
coder.internal.warning( 'whdl:WLANLDPCDecoder:InvalidInputLength', double( obj.lengthVal ), double( obj.blockLen ) );
end 
end 
else 
obj.invalidLength = false;
end 
end 

validframe = ( obj.frameValid && ctrlin.valid );

if ( validframe )
obj.countData( : ) = obj.countData + fi( 1, 0, 1, 0, hdlfimath );
end 

if obj.scalarFlag
datao = cast( obj.dataCP, 'like', obj.dataRound );
valido = obj.validCP;
framevalid = obj.frameValidCP;

obj.dataCP( : ) = data_cp;
obj.validCP( : ) = valid_cp;
obj.frameValidCP( : ) = framevalid_cp;
else 
datao = cast( data_cp, 'like', obj.dataRound );
valido = valid_cp;
framevalid = framevalid_cp;
end 

obj.iterOutReg( : ) = obj.iterOut;

if strcmpi( obj.Termination, 'Early' )
[ data_out, ctrl_out, iter_out, parcheck_out ] = obj.ldpcDecoderCore( reset, datao, valido,  ...
framevalid, obj.blockLen, obj.codeRate, endind, smdone, niter );
obj.iterOut( : ) = iter_out;
else 
[ data_out, ctrl_out, parcheck_out ] = obj.ldpcDecoderCore( reset, datao, valido,  ...
framevalid, obj.blockLen, obj.codeRate, endind, smdone, niter );
end 

obj.ctrlOutReg( : ) = obj.ctrlOut;
obj.dataOutReg( : ) = obj.dataOut;

obj.parCheckReg( : ) = obj.parCheck;

if obj.nextFrame || obj.frameValid
if obj.scalarFlag
obj.dataOut( : ) = zeros( 1, 1 );
else 
obj.dataOut( : ) = zeros( 8, 1 );
end 

obj.ctrlOut( : ) = struct( 'start', false, 'end', false, 'valid', false );
obj.iterOut( : ) = uint8( 0 );
obj.parCheck( : ) = false;
else 
obj.dataOut( : ) = data_out;
obj.ctrlOut( : ) = ctrl_out;
obj.parCheck( : ) = parcheck_out;
end 

if ctrlin.start && ctrlin.valid
obj.nextFrame( : ) = false;
elseif ( ( obj.ctrlOutReg1.end && obj.ctrlOutReg1.valid ) ||  ...
( ( obj.invalidBlockLength || obj.invalidLength ) && ( ctrlin.end && ctrlin.valid ) ) )
obj.nextFrame( : ) = true;
end 

obj.ctrlOutReg1( : ) = obj.ctrlOutReg;
end 

function num = getNumInputsImpl( obj )

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
num = 4;
else 
num = 3;
end 

if ( strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' ) )
num = num + 1;
end 

end 

function num = getNumOutputsImpl( obj )
if strcmpi( obj.Termination, 'Early' )
num = 4;
else 
num = 3;
end 

if obj.ParityCheckStatus
num = num + 1;
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'data';
varargout{ 2 } = 'ctrl';
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
varargout{ 3 } = 'blkLenIdx';
varargout{ 4 } = 'codeRateIdx';
if ( strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' ) )
varargout{ 5 } = 'iter';
end 
else 
varargout{ 3 } = 'codeRateIdx';
if ( strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' ) )
varargout{ 4 } = 'iter';
end 
end 
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'data';
varargout{ 2 } = 'ctrl';
if ( strcmpi( obj.Termination, 'Early' ) )
varargout{ 3 } = 'actIter';
if obj.ParityCheckStatus
varargout{ 4 } = 'parityCheck';
varargout{ 5 } = 'nextFrame';
else 
varargout{ 4 } = 'nextFrame';
end 
else 
if obj.ParityCheckStatus
varargout{ 3 } = 'parityCheck';
varargout{ 4 } = 'nextFrame';
else 
varargout{ 3 } = 'nextFrame';
end 
end 
end 

function validateInputsImpl( obj, varargin )
if isempty( coder.target ) || ~coder.internal.isAmbiguousTypes
datain = varargin{ 1 };
if isscalar( datain )
validateattributes( datain, { 'embedded.fi', 'int8', 'int16' }, { 'scalar', 'real' }, 'WLANLDPCDecoder', 'data' );
else 
if ( length( datain ) ~= 8 )
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidVecLength' );
end 
validateattributes( datain, { 'embedded.fi', 'int8', 'int16' }, { 'vector', 'real' }, 'WLANLDPCDecoder', 'data' );
end 


if isa( datain, 'embedded.fi' )
if ~( issigned( datain ) )
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidSignedType' );
end 
maxWordLength = 16;
minWordLength = 4;
coder.internal.errorIf(  ...
( ( datain.WordLength > maxWordLength ) || ( datain.WordLength < minWordLength ) ),  ...
'whdl:WLANLDPCDecoder:InvalidInputWordLength' );

end 
ctrlIn = varargin{ 2 };
if ~isstruct( ctrlIn )
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidSampleCtrlBus' );
end 

ctrlNames = fieldnames( ctrlIn );
if ~isequal( numel( ctrlNames ), 3 )
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidSampleCtrlBus' );
end 

if isfield( ctrlIn, ctrlNames{ 1 } ) && strcmp( ctrlNames{ 1 }, 'start' )
validateattributes( ctrlIn.start, { 'logical' },  ...
{ 'scalar' }, 'WLANLDPCDecoder', 'start' );
else 
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidSampleCtrlBus' );
end 

if isfield( ctrlIn, ctrlNames{ 2 } ) && strcmp( ctrlNames{ 2 }, 'end' )
validateattributes( ctrlIn.end, { 'logical' },  ...
{ 'scalar' }, 'WLANLDPCDecoder', 'end' );
else 
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidSampleCtrlBus' );
end 

if isfield( ctrlIn, ctrlNames{ 3 } ) && strcmp( ctrlNames{ 3 }, 'valid' )
validateattributes( ctrlIn.valid, { 'logical' },  ...
{ 'scalar' }, 'WLANLDPCDecoder', 'valid' );
else 
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidSampleCtrlBus' );
end 

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
blocklen = varargin{ 3 };
rate = varargin{ 4 };
validateattributes( blocklen, { 'embedded.fi' }, { 'scalar', 'real' }, 'WLANLDPCDecoder', 'blkLenIdx' );
if isa( blocklen, 'embedded.fi' )
if ( issigned( blocklen ) )
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidBlkLenUnsignedType' );
end 
coder.internal.errorIf(  ...
~( ( blocklen.WordLength == 2 ) && ( blocklen.FractionLength == 0 ) ),  ...
'whdl:WLANLDPCDecoder:InvalidBlockLengthType' );

end 
if strcmpi( obj.SpecifyInputs, 'Input port' ) && ( strcmpi( obj.Termination, 'Max' ) )
niter = varargin{ 5 };
validateattributes( niter, { 'uint8' }, { 'scalar', 'real' }, 'WLANLDPCDecoder', 'Number of iterations' );
end 
else 
rate = varargin{ 3 };
if strcmpi( obj.SpecifyInputs, 'Input port' ) && ( strcmpi( obj.Termination, 'Max' ) )
niter = varargin{ 4 };
validateattributes( niter, { 'uint8' }, { 'scalar', 'real' }, 'WLANLDPCDecoder', 'Number of iterations' );
end 
end 


validateattributes( rate, { 'embedded.fi' }, { 'scalar', 'real' }, 'WLANLDPCDecoder', 'codeRateIdx' );
if isa( rate, 'embedded.fi' )
if ( issigned( rate ) )
coder.internal.error( 'whdl:WLANLDPCDecoder:InvalidCodeRateUnsignedType' );
end 
coder.internal.errorIf(  ...
~( ( rate.WordLength == 2 ) && ( rate.FractionLength == 0 ) ),  ...
'whdl:WLANLDPCDecoder:InvalidCodeRateType' );
end 
end 
end 

function flag = isInactivePropertyImpl( obj, prop )
props = {  };
if strcmpi( obj.Termination, 'Max' )
props = [ props,  ...
{ 'MaxNumIterations' } ];
switch obj.SpecifyInputs
case 'Input port'
props = [ props,  ...
{ 'NumIterations' } ];
end 
end 
switch obj.Algorithm
case 'Min-sum'
props = [ props,  ...
{ 'ScalingFactor' } ];
end 
switch obj.Termination
case 'Early'
props = [ props,  ...
{ 'SpecifyInputs' } ];
props = [ props,  ...
{ 'NumIterations' } ];
end 
flag = ismember( prop, props );
end 





function varargout = getOutputDataTypeImpl( obj, varargin )
if strcmpi( obj.Termination, 'Early' )
varargout = { 'logical', samplecontrolbustype, numerictype( 0, 8, 0 ), 'logical', 'logical' };
else 
varargout = { 'logical', samplecontrolbustype, 'logical', 'logical' };
end 
end 



function varargout = isOutputComplexImpl( obj )
if strcmpi( obj.Termination, 'Early' )
varargout = { false, false, false, false, false, false, false, false };
else 
varargout = { false, false, false, false, false, false, false };
end 
end 



function [ sz1, sz2, sz3, sz4, sz5, sz6 ] = getOutputSizeImpl( obj )
sz1 = propagatedInputSize( obj, 1 );sz2 = [ 1, 1 ];sz3 = [ 1, 1 ];sz4 = [ 1, 1 ];sz5 = [ 1, 1 ];sz6 = [ 1, 1 ];
end 



function varargout = isOutputFixedSizeImpl( obj )
if strcmpi( obj.Termination, 'Early' )
varargout = { true, true, true, true, true, true, true, true };
else 
varargout = { true, true, true, true, true, true, true };
end 
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked

s.codeParameters = obj.codeParameters;
s.ldpcDecoderCore = obj.ldpcDecoderCore;
s.Termination = obj.Termination;
s.SpecifyInputs = obj.SpecifyInputs;


s.dataCP = obj.dataCP;
s.validCP = obj.validCP;
s.frameValidCP = obj.frameValidCP;
s.maxCount = obj.maxCount;
s.countData = obj.countData;
s.frameValid = obj.frameValid;
s.invalidBlockLength = obj.invalidBlockLength;
s.invalidLength = obj.invalidLength;
s.maxCountLUT = obj.maxCountLUT;
s.lengthLUT = obj.lengthLUT;
s.lengthVal = obj.lengthVal;
s.blockLen = obj.blockLen;
s.codeRate = obj.codeRate;
s.refIter = obj.refIter;
s.ctrlOutReg1 = obj.ctrlOutReg1;
s.scalarFlag = obj.scalarFlag;
s.dataRound = obj.dataRound;


s.dataOut = obj.dataOut;
s.ctrlOut = obj.ctrlOut;
s.iterOut = obj.iterOut;
s.parCheck = obj.parCheck;
s.nextFrame = obj.nextFrame;
s.dataOutReg = obj.dataOutReg;
s.ctrlOutReg = obj.ctrlOutReg;
s.iterOutReg = obj.iterOutReg;
s.parCheckReg = obj.parCheckReg;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1n37On.p.
% Please follow local copyright laws when handling this file.

