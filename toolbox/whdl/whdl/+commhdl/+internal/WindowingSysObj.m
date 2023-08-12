classdef ( StrictDefaults )WindowingSysObj < matlab.System



%#codegen
%#ok<*EMCLS>



properties ( Nontunable )
OFDMParametersSource = 'Property';
MaxFFTLength = 64;
FFTLength = 64;
CPLength = 16;
WinLength = 4;
MaxWinLength = 8;
end 

properties ( Constant, Hidden )
OFDMParametersSourceSet = matlab.system.StringSet( { 'Property', 'Input port' } );
end 

properties ( Nontunable )
ResetInputPort( 1, 1 )logical = false;
end 

properties ( Nontunable, Access = private )
winLen
maxWinLen
lutIndex11
lutIndex12
repLutIndex1
lutIndex21
lutIndex22
repLutIndex2
vecLen
winTailSize
end 

properties ( Access = private )

dataOut
validOut
dataOut1
validOut1
dataOutReg
validOutReg
dataOutReg1
validOutReg1

winTailForOverlapAdd
correspondingWinCoeff

outCount
outCountReg
outCountReg1
outCountReg2
outCountReg3

FFTSampledAtIn
CPSampledAtIn
CPSampledAtIn1
WinLenSampledAtIn
WinLenSampledAtIn1
WinLenSampledAtIn2
WinLenSampledAtIn3
WinLenSampledAtIn4
WinLenSampledAtIn5
WinLenSampledAtInMinusOne
WinLenSampledAtInMinusOne1
WinLenSampledAtInMinusOne2
WinLenSampledAtInMinusOne3
WinLenSampledAtInMinusOne4
WinLenSampledAtInMinusOne5
FFTPlusCPSampledAtIn
FFTPlusCPSampledMinusVecLen
FFTPlusCPSampledMinusVecLen1
FFTPlusCPSampledMinusVecLen2
FFTPlusCPSampledMinusVecLen3
FFTPlusCPSampledMinusVecLen4
FFTPlusCPSampledMinusVecLen5
FFTPlusCPSampledMinusOne
FFTPlusCPSampledMinusOne1
FFTPlusCPSampledMinusOne2
FFTPlusCPSampledMinusOne3
FFTPlusCPSampledMinusOne4
FFTPlusCPSampledMinusOne5
CPPlusWinLen
CPPlusWinLen1

winTailIn
winTailCoeff
winTailInReg
winTailInReg1
winTailInReg2
winTailInReg3
winHeadCount
winTailCount
winTailCountReadReg
FFTPlusCPCount
FFTPlusCPCount2
FFTPlusCPCountAtOutput


dataInReg
validInReg
dataInReg1
validInReg1
dataInReg2
validInReg2
dataInReg3
validInReg3
dataInReg4
validInReg4
dataInReg5
validInReg5
FFTLenInReg
CPLenInReg
WinLenInReg
resetReg

windowCoeffInvStartIndex
windowCoeffInvStartIndex1
windowCoeffInvStartIndex2
windowCoeffInvStartIndex3
windowCoeff
windowCoeffInv
windowCoeff1
windowCoeffInv1
windowCoeffInv2
windowCoeffInv3
windowCoeffRAM
windowCoeffInvRAM
sampCount
sampCountReg
idxPos
idxPosReg
idxPosReg1
idxPosReg2
idxPosReg3
idxPosReg4
sampCountLessThanVecLen
end 


methods 

function obj = WindowingSysObj( varargin )
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

function flag = isInactivePropertyImpl( obj, prop )


props = {  };
if ~strcmpi( obj.OFDMParametersSource, 'Property' )
props = [ props, { 'FFTLength' }, { 'CPLength' } ];
else 
props = [ props, { 'MaxFFTLength' } ];
end 
flag = ismember( prop, props );
end 


function num = getNumInputsImpl( obj )
if obj.ResetInputPort
rPort = 1;
else 
rPort = 0;
end 
if strcmpi( obj.OFDMParametersSource, 'Input port' )
oPort = 3;
else 
oPort = 0;
end 
num = 2 + rPort + oPort;
end 


function num = getNumOutputsImpl( ~ )
num = 2;
end 


function setupImpl( obj, varargin )
A = varargin{ 1 };
obj.vecLen = length( varargin{ 1 } );
if strcmpi( obj.OFDMParametersSource, 'Input port' )
bitWidth = log2( obj.MaxFFTLength ) + 3;
else 
bitWidth = log2( obj.FFTLength ) + 3;
end 

obj.maxWinLen = double( obj.MaxWinLength );
obj.winLen = double( obj.WinLength );


obj.dataOut = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', varargin{ 1 } );
obj.validOut = false;
obj.dataOut1 = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', varargin{ 1 } );
obj.validOut1 = false;

obj.validOutReg = false;

obj.validOutReg1 = false;


obj.outCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.outCountReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.outCountReg1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.outCountReg2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.outCountReg3 = fi( 0, 0, bitWidth, 0, hdlfimath );

obj.FFTPlusCPCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPCount2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPCountAtOutput = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.sampCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.sampCountReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idxPos = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idxPosReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idxPosReg1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idxPosReg2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idxPosReg3 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idxPosReg4 = fi( 0, 0, bitWidth, 0, hdlfimath );

obj.FFTSampledAtIn = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPSampledAtIn = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.CPSampledAtIn1 = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtIn = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtIn1 = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtIn2 = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtIn3 = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtIn4 = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtIn5 = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledAtIn = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtInMinusOne = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtInMinusOne1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtInMinusOne2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtInMinusOne3 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtInMinusOne4 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.WinLenSampledAtInMinusOne5 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusVecLen = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusVecLen1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusVecLen2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusVecLen3 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusVecLen4 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusVecLen5 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusOne = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusOne1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusOne2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusOne3 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusOne4 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTPlusCPSampledMinusOne5 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.CPPlusWinLen = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.CPPlusWinLen1 = fi( 0, 0, bitWidth, 0, hdlfimath );

obj.winHeadCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winTailCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winTailCountReadReg = fi( 0, 0, bitWidth, 0, hdlfimath );


obj.dataInReg = cast( zeros( obj.vecLen, 1 ), 'like', varargin{ 1 } );
obj.validInReg = false;
obj.dataInReg1 = cast( zeros( obj.vecLen, 1 ), 'like', varargin{ 1 } );
obj.validInReg1 = false;
obj.dataInReg2 = cast( zeros( obj.vecLen, 1 ), 'like', varargin{ 1 } );
obj.validInReg2 = false;
obj.dataInReg3 = cast( zeros( obj.vecLen, 1 ), 'like', varargin{ 1 } );
obj.validInReg3 = false;
obj.dataInReg4 = cast( zeros( obj.vecLen, 1 ), 'like', varargin{ 1 } );
obj.validInReg4 = false;
obj.validInReg5 = false;

obj.FFTLenInReg = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPLenInReg = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.WinLenInReg = fi( 1, 0, bitWidth, 0, hdlfimath );
obj.resetReg = false;


if strcmpi( obj.OFDMParametersSource, 'Input port' )
offset = 0.5;
idx1 = offset + ( 0:obj.maxWinLen - 1 );
idx2 = offset + ( obj.maxWinLen - 1: - 1:0 );
if isfloat( A )
obj.windowCoeffRAM = cast( complex( ones( obj.maxWinLen + 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInvRAM = cast( complex( ones( obj.maxWinLen + 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );

obj.windowCoeff = cast( complex( ones( 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv = cast( complex( ones( 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );
obj.windowCoeff1 = cast( complex( ones( 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv1 = cast( complex( ones( 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv2 = cast( complex( ones( 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv3 = cast( complex( ones( 1, obj.maxWinLen ) ), 'like', varargin{ 1 } );
else 
obj.windowCoeffRAM = fi( complex( ones( obj.maxWinLen + 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInvRAM = fi( complex( ones( obj.maxWinLen + 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );

obj.windowCoeff = fi( complex( ones( 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv = fi( complex( ones( 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeff1 = fi( complex( ones( 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv1 = fi( complex( ones( 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv2 = fi( complex( ones( 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv3 = fi( complex( ones( 1, obj.maxWinLen ) ), 0, 16, 14, hdlfimath );
end 
obj.lutIndex11 = ( 1:obj.maxWinLen ).';
obj.lutIndex12 = pi ./ obj.lutIndex11;
obj.repLutIndex1 = [ zeros( 1, obj.maxWinLen );repmat( obj.lutIndex12, 1, obj.maxWinLen ) ];
cosIdx1 = [ zeros( 1, obj.maxWinLen );repmat( idx1, obj.maxWinLen, 1 ) ];
cosIndices1 = obj.repLutIndex1 .* cosIdx1;

cosVal1 = ones( obj.maxWinLen + 1, obj.maxWinLen );
coder.unroll
for jj = 1:numel( cosVal1 )
cosVal1( jj ) = cos( cosIndices1( jj ) );
end 
obj.windowCoeffRAM( : ) = 0.5 * ( 1 + cosVal1 );
obj.lutIndex21 = ( 1:obj.maxWinLen ).';
obj.lutIndex22 = pi ./ obj.lutIndex21;
obj.repLutIndex2 = [ zeros( 1, obj.maxWinLen );repmat( obj.lutIndex22, 1, obj.maxWinLen ) ];

cosIdx2 = [ zeros( 1, obj.maxWinLen );repmat( idx2, obj.maxWinLen, 1 ) ];
cosIndices2 = obj.repLutIndex2 .* cosIdx2;

cosVal2 = ones( obj.maxWinLen + 1, obj.maxWinLen );
coder.unroll
for jj = 1:numel( cosVal2 )
cosVal2( jj ) = cos( cosIndices2( jj ) );
end 
obj.windowCoeffInvRAM( : ) = 0.5 * ( 1 + cosVal2 );
obj.winTailSize = obj.maxWinLen;
else 
if isfloat( A )
obj.windowCoeffRAM = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInvRAM = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
obj.windowCoeff = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
obj.windowCoeff1 = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv1 = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv2 = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
obj.windowCoeffInv3 = cast( complex( ones( 1, obj.winLen ) ), 'like', varargin{ 1 } );
else 
obj.windowCoeffRAM = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInvRAM = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeff = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeff1 = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv1 = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv2 = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
obj.windowCoeffInv3 = fi( complex( ones( 1, obj.winLen ) ), 0, 16, 14, hdlfimath );
end 
offset = 0.5;
obj.windowCoeffRAM( : ) = 0.5 * ( 1 + cos( pi * ( offset:obj.winLen - offset ) / obj.winLen ) );
obj.windowCoeffInvRAM( : ) = 0.5 * ( 1 + cos( pi * ( offset + ( obj.winLen - 1: - 1:0 ) ) / obj.winLen ) );
obj.winTailSize = obj.winLen;
end 

obj.windowCoeffInvStartIndex = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.windowCoeffInvStartIndex1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.windowCoeffInvStartIndex2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.windowCoeffInvStartIndex3 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.sampCountLessThanVecLen = false;
if ~isfloat( A )
if isa( A, 'int8' )
obj.dataInReg5 = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 9, 0, hdlfimath );
obj.dataOutReg = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 9, 0, hdlfimath );
obj.dataOutReg1 = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 9, 0, hdlfimath );
obj.winTailIn = fi( complex( zeros( obj.winTailSize, 1 ) ), 1, 9, 0, hdlfimath );
obj.winTailInReg = fi( complex( zeros( obj.winTailSize, 1 ) ), 1, 9, 0, hdlfimath );
elseif isa( A, 'int16' )
obj.dataInReg5 = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 17, 0, hdlfimath );
obj.dataOutReg = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 17, 0, hdlfimath );
obj.dataOutReg1 = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 17, 0, hdlfimath );
obj.winTailIn = fi( complex( zeros( obj.winTailSize, 1 ) ), 1, 17, 0, hdlfimath );
obj.winTailInReg = fi( complex( zeros( obj.winTailSize, 1 ) ), 1, 17, 0, hdlfimath );
elseif isa( A, 'int32' )
obj.dataInReg5 = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 33, 0, hdlfimath );
obj.dataOutReg = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 33, 0, hdlfimath );
obj.dataOutReg1 = fi( complex( zeros( obj.vecLen, 1 ) ), 1, 33, 0, hdlfimath );
obj.winTailIn = fi( complex( zeros( obj.winTailSize, 1 ) ), 1, 33, 0, hdlfimath );
obj.winTailInReg = fi( complex( zeros( obj.winTailSize, 1 ) ), 1, 33, 0, hdlfimath );
elseif isa( A, 'embedded.fi' )
obj.dataInReg5 = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.dataInReg );
obj.dataOutReg = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.dataInReg );
obj.dataOutReg1 = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.dataInReg );
obj.winTailIn = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.dataInReg );
obj.winTailInReg = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.dataInReg );
end 
else 
obj.dataInReg5 = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.dataInReg );
obj.dataOutReg = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.dataInReg );
obj.dataOutReg1 = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.dataInReg );
obj.winTailIn = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.dataInReg );
obj.winTailInReg = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.dataInReg );
end 
obj.winTailInReg1 = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.winTailInReg );
obj.winTailInReg2 = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.winTailInReg );
obj.winTailInReg3 = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.winTailInReg );
obj.winTailCoeff = cast( complex( zeros( obj.winTailSize, 1 ) ), 'like', obj.windowCoeff );
obj.correspondingWinCoeff = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.windowCoeff );
obj.winTailForOverlapAdd = cast( complex( zeros( obj.vecLen, 1 ) ), 'like', obj.winTailInReg );

end 


function resetImpl( obj )
obj.maxWinLen = double( obj.MaxWinLength );
obj.winLen = double( obj.WinLength );


obj.dataOut( : ) = 0;
obj.validOut = false;
obj.dataOut1( : ) = 0;
obj.validOut1 = false;
obj.dataOutReg( : ) = 0;
obj.validOutReg = false;
obj.dataOutReg1( : ) = 0;
obj.validOutReg1 = false;


obj.outCount( : ) = 0;
obj.outCountReg( : ) = 0;
obj.outCountReg1( : ) = 0;
obj.outCountReg2( : ) = 0;
obj.outCountReg3( : ) = 0;

obj.FFTPlusCPCount( : ) = 0;
obj.FFTPlusCPCount2( : ) = 0;
obj.FFTPlusCPCountAtOutput( : ) = 0;
obj.sampCount( : ) = 0;
obj.sampCountReg( : ) = 0;
obj.idxPos( : ) = 0;
obj.idxPosReg( : ) = 0;
obj.idxPosReg1( : ) = 0;
obj.idxPosReg2( : ) = 0;
obj.idxPosReg3( : ) = 0;
obj.idxPosReg4( : ) = 0;

obj.FFTSampledAtIn( : ) = 64;
obj.CPSampledAtIn( : ) = 16;
obj.CPSampledAtIn1( : ) = 16;
obj.WinLenSampledAtIn( : ) = 1;
obj.WinLenSampledAtIn1( : ) = 1;
obj.WinLenSampledAtIn2( : ) = 1;
obj.WinLenSampledAtIn3( : ) = 1;
obj.WinLenSampledAtIn4( : ) = 1;
obj.WinLenSampledAtIn5( : ) = 1;
obj.FFTPlusCPSampledAtIn( : ) = 0;
obj.WinLenSampledAtInMinusOne( : ) = 0;
obj.WinLenSampledAtInMinusOne1( : ) = 0;
obj.WinLenSampledAtInMinusOne2( : ) = 0;
obj.WinLenSampledAtInMinusOne3( : ) = 0;
obj.WinLenSampledAtInMinusOne4( : ) = 0;
obj.WinLenSampledAtInMinusOne5( : ) = 0;
obj.FFTPlusCPSampledMinusVecLen( : ) = 0;
obj.FFTPlusCPSampledMinusVecLen1( : ) = 0;
obj.FFTPlusCPSampledMinusVecLen2( : ) = 0;
obj.FFTPlusCPSampledMinusVecLen3( : ) = 0;
obj.FFTPlusCPSampledMinusVecLen4( : ) = 0;
obj.FFTPlusCPSampledMinusVecLen5( : ) = 0;
obj.FFTPlusCPSampledMinusOne( : ) = 0;
obj.FFTPlusCPSampledMinusOne1( : ) = 0;
obj.FFTPlusCPSampledMinusOne2( : ) = 0;
obj.FFTPlusCPSampledMinusOne3( : ) = 0;
obj.FFTPlusCPSampledMinusOne4( : ) = 0;
obj.FFTPlusCPSampledMinusOne5( : ) = 0;
obj.CPPlusWinLen( : ) = 0;
obj.CPPlusWinLen1( : ) = 0;

obj.winHeadCount( : ) = 0;
obj.winTailCount( : ) = 0;
obj.winTailCountReadReg( : ) = 0;


obj.dataInReg( : ) = 0;
obj.validInReg = false;
obj.dataInReg1( : ) = 0;
obj.validInReg1 = false;
obj.dataInReg2( : ) = 0;
obj.validInReg2 = false;
obj.dataInReg3( : ) = 0;
obj.validInReg3 = false;
obj.dataInReg4( : ) = 0;
obj.validInReg4 = false;
obj.dataInReg5( : ) = 0;
obj.validInReg5 = false;

obj.FFTLenInReg( : ) = 64;
obj.CPLenInReg( : ) = 16;
obj.WinLenInReg( : ) = 1;
obj.resetReg = false;


if strcmpi( obj.OFDMParametersSource, 'Input port' )
offset = 0.5;
idx1 = offset + ( 0:obj.maxWinLen - 1 );
idx2 = offset + ( obj.maxWinLen - 1: - 1:0 );

obj.windowCoeffRAM( : ) = ones( obj.maxWinLen + 1, obj.maxWinLen );
obj.windowCoeffInvRAM( : ) = ones( obj.maxWinLen + 1, obj.maxWinLen );

obj.windowCoeff( : ) = ones( 1, obj.maxWinLen );
obj.windowCoeffInv( : ) = ones( 1, obj.maxWinLen );
obj.windowCoeff1( : ) = ones( 1, obj.maxWinLen );
obj.windowCoeffInv1( : ) = ones( 1, obj.maxWinLen );
obj.windowCoeffInv2( : ) = ones( 1, obj.maxWinLen );
obj.windowCoeffInv3( : ) = ones( 1, obj.maxWinLen );

obj.lutIndex11 = ( 1:obj.maxWinLen ).';
obj.lutIndex12 = pi ./ obj.lutIndex11;
obj.repLutIndex1 = [ zeros( 1, obj.maxWinLen );repmat( obj.lutIndex12, 1, obj.maxWinLen ) ];
cosIdx1 = [ zeros( 1, obj.maxWinLen );repmat( idx1, obj.maxWinLen, 1 ) ];
cosIndices1 = obj.repLutIndex1 .* cosIdx1;

cosVal1 = ones( obj.maxWinLen + 1, obj.maxWinLen );
coder.unroll
for jj = 1:numel( cosVal1 )
cosVal1( jj ) = cos( cosIndices1( jj ) );
end 
obj.windowCoeffRAM( : ) = 0.5 * ( 1 + cosVal1 );
obj.lutIndex21 = ( 1:obj.maxWinLen ).';
obj.lutIndex22 = pi ./ obj.lutIndex21;
obj.repLutIndex2 = [ zeros( 1, obj.maxWinLen );repmat( obj.lutIndex22, 1, obj.maxWinLen ) ];

cosIdx2 = [ zeros( 1, obj.maxWinLen );repmat( idx2, obj.maxWinLen, 1 ) ];
cosIndices2 = obj.repLutIndex2 .* cosIdx2;

cosVal2 = ones( obj.maxWinLen + 1, obj.maxWinLen );
coder.unroll
for jj = 1:numel( cosVal2 )
cosVal2( jj ) = cos( cosIndices2( jj ) );
end 
obj.windowCoeffInvRAM( : ) = 0.5 * ( 1 + cosVal2 );

obj.winTailIn( : ) = 0;
obj.winTailCoeff( : ) = 0;
obj.winTailInReg( : ) = 0;
obj.winTailInReg1( : ) = 0;
obj.winTailInReg2( : ) = 0;
obj.winTailInReg3( : ) = 0;
else 

obj.windowCoeffRAM( : ) = ones( 1, obj.winLen );
obj.windowCoeffInvRAM( : ) = ones( 1, obj.winLen );
obj.windowCoeff( : ) = ones( 1, obj.winLen );
obj.windowCoeffInv( : ) = ones( 1, obj.winLen );
obj.windowCoeff1( : ) = ones( 1, obj.winLen );
obj.windowCoeffInv1( : ) = ones( 1, obj.winLen );
obj.windowCoeffInv2( : ) = ones( 1, obj.winLen );
obj.windowCoeffInv3( : ) = ones( 1, obj.winLen );

offset = 0.5;
obj.windowCoeffRAM( : ) = 0.5 * ( 1 + cos( pi * ( offset:obj.winLen - offset ) / obj.winLen ) );
obj.windowCoeffInvRAM( : ) = 0.5 * ( 1 + cos( pi * ( offset + ( obj.winLen - 1: - 1:0 ) ) / obj.winLen ) );

obj.winTailIn( : ) = 0;
obj.winTailCoeff( : ) = 0;
obj.winTailInReg( : ) = 0;
obj.winTailInReg1( : ) = 0;
obj.winTailInReg2( : ) = 0;
obj.winTailInReg3( : ) = 0;
end 
obj.winTailForOverlapAdd( : ) = 0;
obj.correspondingWinCoeff( : ) = 0;
obj.windowCoeffInvStartIndex( : ) = 0;
obj.windowCoeffInvStartIndex1( : ) = 0;
obj.windowCoeffInvStartIndex2( : ) = 0;
obj.windowCoeffInvStartIndex3( : ) = 0;
obj.sampCountLessThanVecLen = false;
end 


function varargout = outputImpl( obj, varargin )
varargout{ 1 } = obj.dataOut;
varargout{ 2 } = obj.validOut;
end 


function updateImpl( obj, varargin )

obj.dataOut( : ) = obj.dataOut1;
obj.validOut( : ) = obj.validOut1;


obj.dataOut1( : ) = obj.dataOutReg1 + obj.winTailForOverlapAdd;
obj.validOut1 = obj.validOutReg1;


obj.dataOutReg1( : ) = obj.dataOutReg;
obj.validOutReg1 = obj.validOutReg;




if obj.validOutReg
if obj.outCountReg3 >= obj.FFTPlusCPSampledMinusVecLen5
for index = fi( 0:obj.vecLen - 1, 0, 8, 0, hdlfimath )
if index >= obj.idxPosReg4
if obj.FFTPlusCPCountAtOutput < obj.WinLenSampledAtIn4
obj.winTailForOverlapAdd( index + 1 ) = cast( obj.winTailInReg3( obj.winTailCountReadReg + 1 ), 'like', obj.winTailForOverlapAdd );
if obj.winTailCountReadReg == obj.WinLenSampledAtInMinusOne4
obj.winTailCountReadReg( : ) = 0;
else 
obj.winTailCountReadReg( : ) = obj.winTailCountReadReg + 1;
end 
else 
obj.winTailForOverlapAdd( index + 1 ) = cast( 0, 'like', obj.winTailForOverlapAdd );
end 
if obj.FFTPlusCPCountAtOutput == obj.FFTPlusCPSampledMinusOne4
obj.FFTPlusCPCountAtOutput( : ) = 0;
else 
obj.FFTPlusCPCountAtOutput( : ) = obj.FFTPlusCPCountAtOutput + 1;
end 
else 
if obj.FFTPlusCPCountAtOutput < obj.WinLenSampledAtIn5
obj.winTailForOverlapAdd( index + 1 ) = cast( obj.winTailInReg3( obj.winTailCountReadReg + 1 ), 'like', obj.winTailForOverlapAdd );
if obj.winTailCountReadReg == obj.WinLenSampledAtInMinusOne5
obj.winTailCountReadReg( : ) = 0;
else 
obj.winTailCountReadReg( : ) = obj.winTailCountReadReg + 1;
end 
else 
obj.winTailForOverlapAdd( index + 1 ) = cast( 0, 'like', obj.winTailForOverlapAdd );
end 
if obj.FFTPlusCPCountAtOutput == obj.FFTPlusCPSampledMinusOne5
obj.FFTPlusCPCountAtOutput( : ) = 0;
else 
obj.FFTPlusCPCountAtOutput( : ) = obj.FFTPlusCPCountAtOutput + 1;
end 
end 
end 
else 
for index = fi( 0:obj.vecLen - 1, 0, 8, 0, hdlfimath )
if obj.FFTPlusCPCountAtOutput < obj.WinLenSampledAtIn5
obj.winTailForOverlapAdd( index + 1 ) = cast( obj.winTailInReg3( obj.winTailCountReadReg + 1 ), 'like', obj.winTailForOverlapAdd );
if obj.winTailCountReadReg == obj.WinLenSampledAtInMinusOne5
obj.winTailCountReadReg( : ) = 0;
else 
obj.winTailCountReadReg( : ) = obj.winTailCountReadReg + 1;
end 
else 
obj.winTailForOverlapAdd( index + 1 ) = cast( 0, 'like', obj.winTailForOverlapAdd );
end 
if obj.FFTPlusCPCountAtOutput == obj.FFTPlusCPSampledMinusOne5
obj.FFTPlusCPCountAtOutput( : ) = 0;
else 
obj.FFTPlusCPCountAtOutput( : ) = obj.FFTPlusCPCountAtOutput + 1;
end 
end 
end 
end 


obj.dataOutReg( : ) = obj.dataInReg5 .* obj.correspondingWinCoeff;
obj.validOutReg = obj.validInReg5;

obj.outCountReg3( : ) = obj.outCountReg2;
obj.idxPosReg4( : ) = obj.idxPosReg3;
obj.WinLenSampledAtIn5( : ) = obj.WinLenSampledAtIn4;
obj.FFTPlusCPSampledMinusVecLen5( : ) = obj.FFTPlusCPSampledMinusVecLen4;
obj.FFTPlusCPSampledMinusOne5( : ) = obj.FFTPlusCPSampledMinusOne4;
obj.WinLenSampledAtInMinusOne5( : ) = obj.WinLenSampledAtInMinusOne4;



obj.winTailInReg3( : ) = obj.winTailInReg2;


obj.dataInReg5( : ) = obj.dataInReg4;
obj.validInReg5 = obj.validInReg4;

obj.outCountReg2( : ) = obj.outCountReg1;
obj.idxPosReg3( : ) = obj.idxPosReg2;
obj.WinLenSampledAtIn4( : ) = obj.WinLenSampledAtIn3;
obj.FFTPlusCPSampledMinusVecLen4( : ) = obj.FFTPlusCPSampledMinusVecLen3;
obj.FFTPlusCPSampledMinusOne4( : ) = obj.FFTPlusCPSampledMinusOne3;
obj.WinLenSampledAtInMinusOne4( : ) = obj.WinLenSampledAtInMinusOne3;




if obj.validInReg4
if obj.outCountReg1 >= obj.FFTPlusCPSampledMinusVecLen3
for index = fi( 0:obj.vecLen - 1, 0, 8, 0, hdlfimath )
if index >= obj.idxPosReg2
if obj.FFTPlusCPCount2 < obj.WinLenSampledAtIn2
obj.correspondingWinCoeff( index + 1 ) = cast( obj.windowCoeffInv2( obj.windowCoeffInvStartIndex2 + obj.winHeadCount + 1 ), 'like', obj.correspondingWinCoeff );
if obj.winHeadCount == obj.WinLenSampledAtInMinusOne2
obj.winHeadCount( : ) = 0;
else 
obj.winHeadCount( : ) = obj.winHeadCount + 1;
end 
else 
obj.correspondingWinCoeff( index + 1 ) = cast( 1, 'like', obj.correspondingWinCoeff );
end 
if obj.FFTPlusCPCount2 == obj.FFTPlusCPSampledMinusOne2
obj.winTailInReg2( : ) = obj.winTailInReg1;
obj.FFTPlusCPCount2( : ) = 0;
else 
obj.FFTPlusCPCount2( : ) = obj.FFTPlusCPCount2 + 1;
end 
else 
if obj.FFTPlusCPCount2 < obj.WinLenSampledAtIn3
obj.correspondingWinCoeff( index + 1 ) = cast( obj.windowCoeffInv3( obj.windowCoeffInvStartIndex3 + obj.winHeadCount + 1 ), 'like', obj.correspondingWinCoeff );
if obj.winHeadCount == obj.WinLenSampledAtInMinusOne3
obj.winHeadCount( : ) = 0;
else 
obj.winHeadCount( : ) = obj.winHeadCount + 1;
end 
else 
obj.correspondingWinCoeff( index + 1 ) = cast( 1, 'like', obj.correspondingWinCoeff );
end 
if obj.FFTPlusCPCount2 == obj.FFTPlusCPSampledMinusOne3
obj.winTailInReg2( : ) = obj.winTailInReg1;
obj.FFTPlusCPCount2( : ) = 0;
else 
obj.FFTPlusCPCount2( : ) = obj.FFTPlusCPCount2 + 1;
end 
end 
end 
else 
for index = fi( 0:obj.vecLen - 1, 0, 8, 0, hdlfimath )
if obj.FFTPlusCPCount2 < obj.WinLenSampledAtIn3
obj.correspondingWinCoeff( index + 1 ) = cast( obj.windowCoeffInv3( obj.windowCoeffInvStartIndex3 + obj.winHeadCount + 1 ), 'like', obj.correspondingWinCoeff );
if obj.winHeadCount == obj.WinLenSampledAtInMinusOne3
obj.winHeadCount( : ) = 0;
else 
obj.winHeadCount( : ) = obj.winHeadCount + 1;
end 
else 
obj.correspondingWinCoeff( index + 1 ) = cast( 1, 'like', obj.correspondingWinCoeff );
end 
if obj.FFTPlusCPCount2 == obj.FFTPlusCPSampledMinusOne3
obj.winTailInReg2( : ) = obj.winTailInReg1;
obj.FFTPlusCPCount2( : ) = 0;
else 
obj.FFTPlusCPCount2( : ) = obj.FFTPlusCPCount2 + 1;
end 
end 
end 
end 


obj.dataInReg4( : ) = obj.dataInReg3;
obj.validInReg4 = obj.validInReg3;

obj.outCountReg1( : ) = obj.outCountReg;
obj.idxPosReg2( : ) = obj.idxPosReg1;
obj.WinLenSampledAtIn3( : ) = obj.WinLenSampledAtIn2;
obj.FFTPlusCPSampledMinusVecLen3( : ) = obj.FFTPlusCPSampledMinusVecLen2;
obj.FFTPlusCPSampledMinusOne3( : ) = obj.FFTPlusCPSampledMinusOne2;
obj.WinLenSampledAtInMinusOne3( : ) = obj.WinLenSampledAtInMinusOne2;
obj.windowCoeffInv3( : ) = obj.windowCoeffInv2;
obj.windowCoeffInvStartIndex3( : ) = obj.windowCoeffInvStartIndex2;

obj.dataInReg3( : ) = obj.dataInReg2;
obj.validInReg3 = obj.validInReg2;

obj.outCountReg( : ) = obj.outCount;
obj.idxPosReg1( : ) = obj.idxPosReg;
obj.WinLenSampledAtIn2( : ) = obj.WinLenSampledAtIn1;
obj.FFTPlusCPSampledMinusVecLen2( : ) = obj.FFTPlusCPSampledMinusVecLen1;
obj.FFTPlusCPSampledMinusOne2( : ) = obj.FFTPlusCPSampledMinusOne1;
obj.WinLenSampledAtInMinusOne2( : ) = obj.WinLenSampledAtInMinusOne1;
obj.windowCoeffInv2( : ) = obj.windowCoeffInv1;
obj.windowCoeffInvStartIndex2( : ) = obj.windowCoeffInvStartIndex1;


obj.winTailInReg1( : ) = obj.winTailInReg;
obj.winTailInReg( : ) = obj.winTailIn .* obj.winTailCoeff;




if obj.validInReg2
if obj.outCount >= obj.FFTPlusCPSampledMinusVecLen1
for index = fi( 0:obj.vecLen - 1, 0, 8, 0, hdlfimath )
if index >= obj.idxPosReg
if obj.FFTPlusCPCount >= obj.CPSampledAtIn && obj.FFTPlusCPCount < obj.CPPlusWinLen
obj.winTailCoeff( obj.winTailCount + 1 ) = cast( obj.windowCoeff( obj.winTailCount + 1 ), 'like', obj.winTailCoeff );
obj.winTailIn( obj.winTailCount + 1 ) = cast( obj.dataInReg2( index + 1 ), 'like', obj.winTailIn );
if obj.winTailCount == obj.WinLenSampledAtInMinusOne
obj.winTailCount( : ) = 0;
else 
obj.winTailCount( : ) = obj.winTailCount + 1;
end 
end 
if obj.FFTPlusCPCount == obj.FFTPlusCPSampledMinusOne
obj.FFTPlusCPCount( : ) = 0;
else 
obj.FFTPlusCPCount( : ) = obj.FFTPlusCPCount + 1;
end 
else 
if obj.FFTPlusCPCount >= obj.CPSampledAtIn1 && obj.FFTPlusCPCount < obj.CPPlusWinLen1
obj.winTailCoeff( obj.winTailCount + 1 ) = cast( obj.windowCoeff1( obj.winTailCount + 1 ), 'like', obj.winTailCoeff );
obj.winTailIn( obj.winTailCount + 1 ) = cast( obj.dataInReg2( index + 1 ), 'like', obj.winTailIn );
if obj.winTailCount == obj.WinLenSampledAtInMinusOne1
obj.winTailCount( : ) = 0;
else 
obj.winTailCount( : ) = obj.winTailCount + 1;
end 
end 
if obj.FFTPlusCPCount == obj.FFTPlusCPSampledMinusOne1
obj.FFTPlusCPCount( : ) = 0;
else 
obj.FFTPlusCPCount( : ) = obj.FFTPlusCPCount + 1;
end 
end 
end 
else 
for index = fi( 0:obj.vecLen - 1, 0, 8, 0, hdlfimath )
if obj.FFTPlusCPCount >= obj.CPSampledAtIn1 && obj.FFTPlusCPCount < obj.CPPlusWinLen1
obj.winTailCoeff( obj.winTailCount + 1 ) = cast( obj.windowCoeff1( obj.winTailCount + 1 ), 'like', obj.winTailCoeff );
obj.winTailIn( obj.winTailCount + 1 ) = cast( obj.dataInReg2( index + 1 ), 'like', obj.winTailIn );
if obj.winTailCount == obj.WinLenSampledAtInMinusOne1
obj.winTailCount( : ) = 0;
else 
obj.winTailCount( : ) = obj.winTailCount + 1;
end 
end 
if obj.FFTPlusCPCount == obj.FFTPlusCPSampledMinusOne1
obj.FFTPlusCPCount( : ) = 0;
else 
obj.FFTPlusCPCount( : ) = obj.FFTPlusCPCount + 1;
end 
end 
end 
if obj.outCount >= obj.FFTPlusCPSampledMinusVecLen1
obj.outCount( : ) = obj.sampCountReg;
else 
obj.outCount( : ) = obj.outCount + obj.vecLen;
end 
end 


obj.dataInReg2( : ) = obj.dataInReg1;
obj.validInReg2( : ) = obj.validInReg1;

obj.idxPosReg( : ) = obj.idxPos;
obj.sampCountReg( : ) = obj.sampCount;
obj.CPSampledAtIn1( : ) = obj.CPSampledAtIn;
obj.WinLenSampledAtIn1( : ) = obj.WinLenSampledAtIn;
obj.FFTPlusCPSampledMinusVecLen1( : ) = obj.FFTPlusCPSampledMinusVecLen;
obj.FFTPlusCPSampledMinusOne1( : ) = obj.FFTPlusCPSampledMinusOne;
obj.CPPlusWinLen1( : ) = obj.CPPlusWinLen;
obj.WinLenSampledAtInMinusOne1( : ) = obj.WinLenSampledAtInMinusOne;
obj.windowCoeff1( : ) = obj.windowCoeff;
obj.windowCoeffInv1( : ) = obj.windowCoeffInv;
obj.windowCoeffInvStartIndex1( : ) = obj.windowCoeffInvStartIndex;

obj.dataInReg1( : ) = obj.dataInReg;
obj.validInReg1( : ) = obj.validInReg;



obj.idxPos( : ) = obj.FFTPlusCPSampledAtIn - obj.sampCount;

obj.sampCountLessThanVecLen = obj.sampCount < obj.vecLen;



if obj.sampCountLessThanVecLen
if obj.validInReg
obj.FFTSampledAtIn( : ) = obj.FFTLenInReg;
obj.CPSampledAtIn( : ) = obj.CPLenInReg;
obj.WinLenSampledAtIn( : ) = obj.WinLenInReg;

obj.FFTPlusCPSampledAtIn( : ) = obj.FFTLenInReg + obj.CPLenInReg;
obj.FFTPlusCPSampledMinusVecLen( : ) = obj.FFTPlusCPSampledAtIn - obj.vecLen;
obj.FFTPlusCPSampledMinusOne( : ) = obj.FFTPlusCPSampledAtIn - 1;

obj.CPPlusWinLen( : ) = obj.CPLenInReg + obj.WinLenInReg;

if obj.WinLenInReg ~= 0
obj.WinLenSampledAtInMinusOne( : ) = obj.WinLenInReg - 1;
else 
obj.WinLenSampledAtInMinusOne( : ) = 0;
end 

if strcmpi( obj.OFDMParametersSource, 'Input port' )
obj.windowCoeff( : ) = obj.windowCoeffRAM( obj.WinLenInReg + 1, 1:obj.MaxWinLength );
obj.windowCoeffInv( : ) = obj.windowCoeffInvRAM( obj.WinLenInReg + 1, 1:obj.MaxWinLength );
if obj.WinLenInReg ~= 0
obj.windowCoeffInvStartIndex( : ) = obj.MaxWinLength - obj.WinLenInReg;


else 
obj.windowCoeffInvStartIndex( : ) = 0;
end 
else 
obj.windowCoeff( : ) = obj.windowCoeffRAM;
obj.windowCoeffInv( : ) = obj.windowCoeffInvRAM;
obj.windowCoeffInvStartIndex( : ) = 0;
end 
end 
end 


if obj.validInReg
if obj.sampCount >= obj.FFTPlusCPSampledMinusVecLen
if obj.sampCount == obj.FFTPlusCPSampledMinusVecLen
obj.sampCount( : ) = 0;
else 
obj.sampCount( : ) = obj.vecLen - obj.idxPos;
end 
else 
obj.sampCount( : ) = obj.sampCount + obj.vecLen;
end 
end 


obj.dataInReg( : ) = varargin{ 1 };
obj.validInReg( : ) = varargin{ 2 };
if strcmpi( obj.OFDMParametersSource, 'Input port' )
obj.FFTLenInReg( : ) = varargin{ 3 };
obj.CPLenInReg( : ) = varargin{ 4 };
obj.WinLenInReg( : ) = varargin{ 5 };
else 
obj.FFTLenInReg( : ) = obj.FFTLength;
obj.CPLenInReg( : ) = obj.CPLength;
obj.WinLenInReg( : ) = obj.WinLength;
end 
if obj.ResetInputPort
if strcmpi( obj.OFDMParametersSource, 'Input port' )
obj.resetReg = varargin{ 6 };
else 
obj.resetReg = varargin{ 3 };
end 
end 
if obj.ResetInputPort
ifResetTrue( obj );
end 
end 


function ifResetTrue( obj )
if obj.resetReg
resetImpl( obj );
end 
end 


function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.dataOut = obj.dataOut;
s.validOut = obj.validOut;
s.dataOut1 = obj.dataOut1;
s.validOut1 = obj.validOut1;
s.dataOutReg = obj.dataOutReg;
s.validOutReg = obj.validOutReg;
s.dataOutReg1 = obj.dataOutReg1;
s.validOutReg1 = obj.validOutReg1;
s.winTailForOverlapAdd = obj.winTailForOverlapAdd;
s.correspondingWinCoeff = obj.correspondingWinCoeff;
s.outCount = obj.outCount;
s.outCountReg = obj.outCountReg;
s.outCountReg1 = obj.outCountReg1;
s.outCountReg2 = obj.outCountReg2;
s.outCountReg3 = obj.outCountReg3;
s.FFTSampledAtIn = obj.FFTSampledAtIn;
s.CPSampledAtIn = obj.CPSampledAtIn;
s.CPSampledAtIn1 = obj.CPSampledAtIn1;
s.WinLenSampledAtIn = obj.WinLenSampledAtIn;
s.WinLenSampledAtIn1 = obj.WinLenSampledAtIn1;
s.WinLenSampledAtIn2 = obj.WinLenSampledAtIn2;
s.WinLenSampledAtIn3 = obj.WinLenSampledAtIn3;
s.WinLenSampledAtIn4 = obj.WinLenSampledAtIn4;
s.WinLenSampledAtIn5 = obj.WinLenSampledAtIn5;
s.WinLenSampledAtInMinusOne = obj.WinLenSampledAtInMinusOne;
s.WinLenSampledAtInMinusOne1 = obj.WinLenSampledAtInMinusOne1;
s.WinLenSampledAtInMinusOne2 = obj.WinLenSampledAtInMinusOne2;
s.WinLenSampledAtInMinusOne3 = obj.WinLenSampledAtInMinusOne3;
s.WinLenSampledAtInMinusOne4 = obj.WinLenSampledAtInMinusOne4;
s.WinLenSampledAtInMinusOne5 = obj.WinLenSampledAtInMinusOne5;
s.FFTPlusCPSampledAtIn = obj.FFTPlusCPSampledAtIn;
s.FFTPlusCPSampledMinusVecLen = obj.FFTPlusCPSampledMinusVecLen;
s.FFTPlusCPSampledMinusVecLen1 = obj.FFTPlusCPSampledMinusVecLen1;
s.FFTPlusCPSampledMinusVecLen2 = obj.FFTPlusCPSampledMinusVecLen2;
s.FFTPlusCPSampledMinusVecLen3 = obj.FFTPlusCPSampledMinusVecLen3;
s.FFTPlusCPSampledMinusVecLen4 = obj.FFTPlusCPSampledMinusVecLen4;
s.FFTPlusCPSampledMinusVecLen5 = obj.FFTPlusCPSampledMinusVecLen5;
s.FFTPlusCPSampledMinusOne = obj.FFTPlusCPSampledMinusOne;
s.FFTPlusCPSampledMinusOne1 = obj.FFTPlusCPSampledMinusOne1;
s.FFTPlusCPSampledMinusOne2 = obj.FFTPlusCPSampledMinusOne2;
s.FFTPlusCPSampledMinusOne3 = obj.FFTPlusCPSampledMinusOne3;
s.FFTPlusCPSampledMinusOne4 = obj.FFTPlusCPSampledMinusOne4;
s.FFTPlusCPSampledMinusOne5 = obj.FFTPlusCPSampledMinusOne5;
s.CPPlusWinLen = obj.CPPlusWinLen;
s.CPPlusWinLen1 = obj.CPPlusWinLen1;
s.winTailIn = obj.winTailIn;
s.winTailCoeff = obj.winTailCoeff;
s.winTailInReg = obj.winTailInReg;
s.winTailInReg1 = obj.winTailInReg1;
s.winTailInReg2 = obj.winTailInReg2;
s.winTailInReg3 = obj.winTailInReg3;
s.winHeadCount = obj.winHeadCount;
s.winTailCount = obj.winTailCount;
s.winTailCountReadReg = obj.winTailCountReadReg;
s.FFTPlusCPCount = obj.FFTPlusCPCount;
s.FFTPlusCPCount2 = obj.FFTPlusCPCount2;
s.FFTPlusCPCountAtOutput = obj.FFTPlusCPCountAtOutput;
s.dataInReg = obj.dataInReg;
s.validInReg = obj.validInReg;
s.dataInReg1 = obj.dataInReg1;
s.validInReg1 = obj.validInReg1;
s.dataInReg2 = obj.dataInReg2;
s.validInReg2 = obj.validInReg2;
s.dataInReg3 = obj.dataInReg3;
s.validInReg3 = obj.validInReg3;
s.dataInReg4 = obj.dataInReg4;
s.validInReg4 = obj.validInReg4;
s.dataInReg5 = obj.dataInReg5;
s.validInReg5 = obj.validInReg5;
s.FFTLenInReg = obj.FFTLenInReg;
s.CPLenInReg = obj.CPLenInReg;
s.WinLenInReg = obj.WinLenInReg;
s.resetReg = obj.resetReg;
s.windowCoeffInvStartIndex = obj.windowCoeffInvStartIndex;
s.windowCoeffInvStartIndex1 = obj.windowCoeffInvStartIndex1;
s.windowCoeffInvStartIndex2 = obj.windowCoeffInvStartIndex2;
s.windowCoeffInvStartIndex3 = obj.windowCoeffInvStartIndex3;
s.windowCoeff = obj.windowCoeff;
s.windowCoeffInv = obj.windowCoeffInv;
s.windowCoeff1 = obj.windowCoeff1;
s.windowCoeffInv1 = obj.windowCoeffInv1;
s.windowCoeffInv2 = obj.windowCoeffInv2;
s.windowCoeffInv3 = obj.windowCoeffInv3;
s.windowCoeffRAM = obj.windowCoeffRAM;
s.windowCoeffInvRAM = obj.windowCoeffInvRAM;
s.sampCount = obj.sampCount;
s.sampCountReg = obj.sampCountReg;
s.idxPos = obj.idxPos;
s.idxPosReg = obj.idxPosReg;
s.idxPosReg1 = obj.idxPosReg1;
s.idxPosReg2 = obj.idxPosReg2;
s.idxPosReg3 = obj.idxPosReg3;
s.idxPosReg4 = obj.idxPosReg4;
s.sampCountLessThanVecLen = obj.sampCountLessThanVecLen;

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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpYSlahU.p.
% Please follow local copyright laws when handling this file.

