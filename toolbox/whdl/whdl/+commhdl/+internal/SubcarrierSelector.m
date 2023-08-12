classdef ( StrictDefaults )SubcarrierSelector < matlab.System




%#codegen
%#ok<*EMCLS>
properties ( Nontunable )


OFDMParamSrc = 'Property';



FFTSize = 64;



maxFFTSize = 64;



NumLGsC = 6;



NumRGsC = 5;
end 

properties ( Constant, Hidden )
OFDMParamSrcSet = matlab.system.StringSet( {  ...
'Property', 'Input port' } );
end 

properties ( Nontunable )

removeDCSubcarrier( 1, 1 )logical = true;

resetPort( 1, 1 )logical = false;
end 

properties ( DiscreteState )

end 


properties ( Nontunable, Access = private )
vecLength;
end 


properties ( Access = private )
dataIn;
validIn;
dataOut;
validOut;
FFTLength;
FFTLength1;
numLGSC;
numRGSC;
numLGPlusVL;
FFTLenBy2;
vecStepCount;
vSCInCurrVec;
residueElem;
buffVec1;
buffVec1Valid;
countVecElem;
bufferVec2;
intermedBuff;
countIntermedBuffElem;
resetSig;
DCCount;
FFTLenBy2PlusVecLen;
FFTMinusRG;
FFTMinusRGPlusVec;
nextSamplesStart;
nextSamplesEnd;
outStartPos;
outEndPos;
idx;
end 

methods 
function obj = SubcarrierSelector( varargin )
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
end 

methods ( Access = protected )

function numInpPorts = getNumInputsImpl( obj )
numInpPorts = 2;
if ( ~strcmpi( obj.OFDMParamSrc, 'Property' ) )
numInpPorts = numInpPorts + 3;
end 
if obj.resetPort
numInpPorts = numInpPorts + 1;
end 
end 

function numOutPorts = getNumOutputsImpl( ~ )
numOutPorts = 2;
end 

function flag = isInactivePropertyImpl( obj, prop )
props = {  };
if ( ~strcmpi( obj.OFDMParamSrc, 'Property' ) )
props = [ props, { 'FFTSize', 'NumLGsC', 'NumRGsC' } ];
end 
flag = ismember( prop, props );
end 

function obj = fillVectorBuff1( obj, varargin )
indx = fi( 0, 0, 8, 0, hdlfimath );
if ( obj.vecLength == obj.FFTLength )
obj.DCCount( : ) = obj.FFTLenBy2 + fi( 1, 0, 1, 0, hdlfimath );
for count = 1:obj.vecLength
if count > obj.numLGSC && count <= ( obj.vecLength - obj.numRGSC )
if count == obj.DCCount
if ~obj.removeDCSubcarrier
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
else 
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
end 
end 
obj.buffVec1Valid = obj.validIn;
else 
countGreaterThanLG = ( obj.vecStepCount > obj.numLGSC );
countLessThanLGPlusVec = ( obj.vecStepCount < obj.numLGPlusVL );
countLTorEqFFTMinRG = ( obj.vecStepCount <= obj.FFTMinusRG );
countLTorEqFFTby2 = ( obj.vecStepCount <= obj.FFTLenBy2 );
countEqFFTby2PlusVL = ( obj.vecStepCount == obj.FFTLenBy2PlusVecLen );
countLTFFTMinRGPlusVL = obj.vecStepCount < obj.FFTMinusRGPlusVec;
countGTFFTBy2PlusVL = ( obj.vecStepCount > obj.FFTLenBy2PlusVecLen );
cond1 = ( ~countLessThanLGPlusVec && countLTorEqFFTby2 );
cond2 = ( countGTFFTBy2PlusVL && countLTorEqFFTMinRG );
cond3 = cond1 || cond2;
if ( countGreaterThanLG &&  ...
countLessThanLGPlusVec )
for count = 1:obj.vecLength
if count > obj.outStartPos
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
end 
obj.buffVec1Valid = obj.validIn;
else 
if cond3
for count = 1:obj.vecLength
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
obj.buffVec1Valid = obj.validIn;
else 
if ( countEqFFTby2PlusVL && countLTorEqFFTMinRG )
for count = 1:obj.vecLength
if count == 1
if ~obj.removeDCSubcarrier
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
else 
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
end 
obj.buffVec1Valid = obj.validIn;
else 
if ( countEqFFTby2PlusVL && ~countLTorEqFFTMinRG )
for count = 1:obj.vecLength
if count == 1
if ~obj.removeDCSubcarrier
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
else 
if count <= obj.outEndPos
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
end 
end 
obj.buffVec1Valid = obj.validIn;
else 
if ( ~countLTorEqFFTMinRG && countLTFFTMinRGPlusVL )
for count = 1:obj.vecLength
if count <= ( obj.outEndPos )
obj.buffVec1( indx + 1 ) = obj.dataIn( count );
indx( : ) = indx + 1;
end 
end 
obj.buffVec1Valid = obj.validIn;
else 
obj.buffVec1( : ) = 0;
obj.buffVec1Valid = false;
end 
end 
end 
end 
end 
end 

obj.vSCInCurrVec( : ) = indx;

end 


function obj = copyBuff1ToBuff2( obj )
for count = 1:obj.vecLength
if ( count <= obj.countIntermedBuffElem )

obj.bufferVec2( obj.countVecElem + count ) = obj.intermedBuff( count );
else 
if ( count <= obj.countIntermedBuffElem + obj.vSCInCurrVec )
if ( obj.countVecElem + count <= obj.vecLength )

obj.bufferVec2( obj.countVecElem + count ) = obj.buffVec1( count - obj.countIntermedBuffElem );
end 
end 
end 
end 

if obj.vSCInCurrVec ~= 0
if obj.countIntermedBuffElem == 0
if obj.vecLength > ( obj.vSCInCurrVec + obj.countVecElem )
obj.countVecElem( : ) = obj.vSCInCurrVec + obj.countVecElem;
else 
obj.idx( : ) = obj.vecLength - obj.countVecElem;
obj.countVecElem( : ) = obj.vecLength;
end 
else 
if obj.vecLength > ( obj.vSCInCurrVec + obj.countIntermedBuffElem )
obj.countVecElem( : ) = obj.vSCInCurrVec + obj.countIntermedBuffElem;
else 
obj.idx( : ) = obj.vecLength - obj.countIntermedBuffElem;
obj.countVecElem( : ) = obj.vecLength;
end 
end 
else 
if obj.countIntermedBuffElem ~= 0
obj.countVecElem( : ) = obj.countIntermedBuffElem;
end 
end 

obj.countIntermedBuffElem( : ) = 0;
obj.intermedBuff( : ) = 0;
indx = fi( 0, 0, 8, 0, hdlfimath );
for count = 1:obj.vecLength
if ( count <= obj.vSCInCurrVec ) && count > ( obj.idx )
if ( obj.countVecElem == obj.vecLength )

obj.intermedBuff( indx + 1 ) = obj.buffVec1( count );
indx( : ) = indx + 1;
end 
end 
end 

if ( obj.countVecElem == obj.vecLength )
obj.countIntermedBuffElem( : ) = indx;
end 

obj.vSCInCurrVec( : ) = 0;
obj.buffVec1( : ) = 0;
end 

function setupImpl( obj, varargin )

VL = length( varargin{ 1 } );
bitWidth = 17;
obj.vecLength = fi( VL, 0, bitWidth, 0, hdlfimath );
obj.dataIn = cast( zeros( VL, 1 ), 'like', varargin{ 1 } );
obj.validIn = false;
obj.dataOut = cast( zeros( VL, 1 ), 'like', varargin{ 1 } );
obj.validOut = false;
obj.FFTLength = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTLength1 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.numLGSC = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRGSC = fi( 5, 0, bitWidth, 0, hdlfimath );
obj.numLGPlusVL = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2 = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.vecStepCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.vSCInCurrVec = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.buffVec1 = cast( zeros( VL, 1 ), 'like', varargin{ 1 } );
obj.buffVec1Valid = false;
obj.countVecElem = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.bufferVec2 = cast( zeros( VL, 1 ), 'like', varargin{ 1 } );
obj.intermedBuff = cast( zeros( VL, 1 ), 'like', varargin{ 1 } );
obj.countIntermedBuffElem = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.resetSig = false;
obj.DCCount = fi( 33, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2PlusVecLen = fi( 33, 0, bitWidth, 0, hdlfimath );
obj.FFTMinusRG = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTMinusRGPlusVec = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.nextSamplesStart = fi( VL, 0, bitWidth, 0, hdlfimath );
obj.nextSamplesEnd = fi( VL, 0, bitWidth, 0, hdlfimath );
obj.outStartPos = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.outEndPos = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idx = fi( 0, 0, bitWidth, 0, hdlfimath );
end 

function resetImpl( obj )

VL = length( obj.dataIn );
obj.dataIn( : ) = 0;
obj.validIn = false;
obj.dataOut( : ) = 0;
obj.validOut = false;
obj.FFTLength( : ) = 64;
obj.FFTLength1( : ) = 64;
obj.numLGSC( : ) = 6;
obj.numRGSC( : ) = 5;
obj.numLGPlusVL( : ) = 6;
obj.FFTLenBy2( : ) = 1;
obj.vecStepCount( : ) = 0;
obj.vSCInCurrVec( : ) = 0;
obj.buffVec1( : ) = 0;
obj.buffVec1Valid( : ) = false;
obj.countVecElem( : ) = 0;
obj.bufferVec2( : ) = 0;
obj.intermedBuff( : ) = 0;
obj.countIntermedBuffElem( : ) = 0;
obj.DCCount( : ) = 33;
obj.FFTLenBy2PlusVecLen( : ) = 33;
obj.FFTMinusRG( : ) = 64;
obj.FFTMinusRGPlusVec( : ) = 64;
obj.nextSamplesStart( : ) = VL;
obj.nextSamplesEnd( : ) = VL;
obj.outStartPos( : ) = 0;
obj.outEndPos( : ) = 0;
obj.idx( : ) = 0;
end 

function varargout = outputImpl( obj, varargin )
varargout{ 1 } = obj.dataOut;
varargout{ 2 } = obj.validOut;
end 


function updateImpl( obj, varargin )

if obj.buffVec1Valid
copyBuff1ToBuff2( obj );

end 

if obj.validIn
if obj.vecLength == 1
if ( obj.vecStepCount > obj.numLGSC ) && ( obj.vecStepCount <= obj.FFTMinusRG )

if ( obj.vecStepCount == obj.FFTLenBy2PlusVecLen && obj.removeDCSubcarrier )
obj.dataOut( : ) = 0;
obj.validOut = false;
else 
obj.dataOut( : ) = obj.dataIn;
obj.validOut = true;
end 

else 
obj.dataOut( : ) = 0;
obj.validOut = false;
end 
else 
fillVectorBuff1( obj, varargin );



end 

if ( obj.vecStepCount == obj.FFTLength )
obj.vecStepCount( : ) = 0;
end 
else 
obj.dataOut( : ) = 0;
obj.validOut = false;
end 

if obj.vecLength ~= 1
if obj.countVecElem == obj.vecLength
obj.dataOut( : ) = obj.bufferVec2( : );
obj.validOut = true;
obj.countVecElem( : ) = 0;
obj.bufferVec2( : ) = 0;
else 
obj.dataOut( : ) = 0;
obj.validOut = false;
end 
end 


obj.dataIn = varargin{ 1 };
obj.validIn = varargin{ 2 };
obj.FFTLength1( : ) = obj.FFTLength;
if ( ~strcmpi( obj.OFDMParamSrc, 'Property' ) )
obj.FFTLength( : ) = varargin{ 3 };
obj.numLGSC( : ) = varargin{ 4 };
obj.numRGSC( : ) = varargin{ 5 };
if obj.resetPort
obj.resetSig = varargin{ 6 };
end 
else 
obj.FFTLength( : ) = obj.FFTSize;
obj.numLGSC( : ) = obj.NumLGsC;
obj.numRGSC( : ) = obj.NumRGsC;
if obj.resetPort
obj.resetSig = varargin{ 3 };
end 
end 


if obj.validIn
if obj.vecStepCount == 0
obj.FFTLenBy2( : ) = bitsrl( obj.FFTLength, fi( 1, 0, 1, 0, hdlfimath ) );
obj.FFTLenBy2PlusVecLen( : ) = obj.FFTLenBy2 + obj.vecLength;
obj.FFTMinusRG( : ) = obj.FFTLength - obj.numRGSC;
obj.FFTMinusRGPlusVec( : ) = obj.FFTMinusRG + obj.vecLength;
obj.numLGPlusVL( : ) = obj.numLGSC + obj.vecLength;
end 
obj.vecStepCount( : ) = obj.vecStepCount + obj.vecLength;
end 

obj.nextSamplesStart( : ) = obj.vecStepCount - obj.numLGSC;
obj.nextSamplesEnd( : ) = obj.vecStepCount - obj.numRGSC;

if obj.nextSamplesStart < obj.vecLength
obj.outStartPos( : ) = obj.vecLength - obj.nextSamplesStart;
end 
if obj.nextSamplesEnd < obj.vecLength
obj.outEndPos( : ) = obj.nextSamplesEnd;
end 

ifResetTrue( obj );
end 

function ifResetTrue( obj )
if obj.resetSig
resetImpl( obj );
end 
end 

function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.dataIn = obj.dataIn;
s.validIn = obj.validIn;
s.dataOut = obj.dataOut;
s.validOut = obj.validOut;
s.FFTLength = obj.FFTLength;
s.FFTLength1 = obj.FFTLength1;
s.numLGSC = obj.numLGSC;
s.numRGSC = obj.numRGSC;
s.numLGPlusVL = obj.numLGPlusVL;
s.FFTLenBy2 = obj.FFTLenBy2;

s.vSCInCurrVec = obj.vSCInCurrVec;
s.buffVec1 = obj.buffVec1;
s.buffVec1Valid = obj.buffVec1Valid;
s.countVecElem = obj.countVecElem;
s.bufferVec2 = obj.bufferVec2;
s.intermedBuff = obj.intermedBuff;
s.countIntermedBuffElem = obj.countIntermedBuffElem;
s.DCCount = obj.DCCount;
s.FFTLenBy2PlusVecLen = obj.FFTLenBy2PlusVecLen;
s.nextSamplesStart = obj.nextSamplesStart;
s.nextSamplesEnd = obj.nextSamplesEnd;
s.outStartPos = obj.outStartPos;
s.outEndPos = obj.outEndPos;
s.vecLength = obj.vecLength;
s.idx = obj.idx;
end 
end 

function loadObjectImpl( obj, s, ~ )
fn = fieldnames( s );
for ii = 1:numel( fn )
obj.( fn{ ii } ) = s.( fn{ ii } );
end 
end 

function flag = isInputComplexityMutableImpl( ~, ~ )

flag = true;
end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVkZz74.p.
% Please follow local copyright laws when handling this file.

