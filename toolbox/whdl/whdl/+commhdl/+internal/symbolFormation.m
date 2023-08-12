classdef ( StrictDefaults )symbolFormation < matlab.System
%#codegen




properties ( Nontunable )

OFDMParametersSource = 'Property';


FFTLength = 64;


MaxFFTLength = 1024;


CPLength = 16;


numLgSc = 6;


numRgSc = 5;


WinLength = 4;


MaxWinLength = 8;
end 

properties ( Constant, Hidden )
OFDMParametersSourceSet = matlab.system.StringSet( {  ...
'Property', 'Input port' } );
end 

properties ( Nontunable )

InsertDCNull( 1, 1 )logical = false;


ResetInputPort( 1, 1 )logical = false;


Windowing( 1, 1 )logical = false;
end 

properties ( Nontunable, Access = private )
vecLen;
vecLength;
loopRange;
VLBits;
addrBitWidth;
end 


properties ( Access = private )

dataOut
validOut
FFTLenOut
CPLenOut
numLgScOut
numRgScOut


dataOutReg
validOutReg
FFTLenOutReg2
FFTLenOutReg1
CPLenOutReg2
CPLenOutReg1
numLgScOutReg2
numLgScOutReg1
numRgScOutReg2
numRgScOutReg1


hRAM1
hRAM2
dataOutRAM
dataOutRAM1
dataOutRAM2
selectRAM
selectRAMReg
selectRAMReg1
selectRAMReg2
RAM2ReadSelect
startReadFromRAM
startRead
startReadReg
readAddr
writeAddrRAM1
writeAddrRAM2
sym1Done
sym2Done
writeEnbRAM1
writeEnbRAM2
RAM2WriteSelect



FFTLenMinusVecLenReg
FFTLenMinusVecLenReg1
FFTLenMinusVecLenReg2
FFTSampledReg
CPSampledReg
numLgScSampledReg
numRgScSampledReg
numDataScReg
numDataScMinusVecLenReg
numLgScCountReg
FFTLenBy2Reg
FFTLenBy2Reg1
FFTLenBy2Reg2

FFTLenMinusVecLen
FFTSampled
CPSampled
numLgScSampled
numRgScSampled
numDataSc
numDataScMinusVecLen
numLgScCount
FFTLenBy2
sumLgRg
sumLgRgDC
numDataScPlusNumLgSc
numDataScPlusNumLgScReg
numDataScPlusNumLgScReg1
numDataScPlusNumLgScReg2
FFTLenMinusNumRgScReg
maxLimitForDataReg
maxLimitForDataReg1
maxLimitForDataReg2


prevVecData
numPrevVecSamples
idxPos
index1
index2
startSymbForm
startSymbFormReg
startSymbFormReg1


outCount
outCountReg1
outCountReg
readCount
numLgScCountReg2
numLgScCountReg1
inCount
inCountReg


dataInReg
validInReg
dataInRegDelay1
validInRegDelay1
dataInRegDelay2
validInRegDelay2
dataInReg1
insertDC
FFTLenReg
CPLenReg
numLgScReg
numRgScReg
FFTLenRegDelay1
CPLenRegDelay1
numLgScRegDelay1
numRgScRegDelay1
FFTLenRegDelay2
CPLenRegDelay2
numLgScRegDelay2
numRgScRegDelay2
resetReg
enbDataRead
enbDataPlacing
numSampLeft


dataOutRAMReg
sendOutput
dataVecidx1
dataVecidx2
sendDC
dataVec1Samples
dataVec1
dataVec2
startSymbFormReg2
FFTLenOutReg4
FFTLenOutReg3
outCountReg2
numLgScOutReg3
numLgScCountReg3
prevVecSamples
FFTLenBy2Reg4
FFTLenBy2Reg3
FFTLenMinusVecLenReg3
numDataScPlusNumLgScReg3
maxLimitForDataReg3

winLenReg
winLenRegDelay1
winLenRegDelay2
winLenSampled
winLenSampledReg
winLenOutReg1
winLenOutReg2
winLenOut
end 

methods 

function obj = symbolFormation( varargin )
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
props = [ props, { 'FFTLength' }, { 'CPLength' }, { 'numLgSc' }, { 'numRgSc' } ];
if obj.Windowing
props = [ props, { 'WinLength' } ];
else 
props = [ props, { 'MaxWinLength' }, { 'WinLength' } ];
end 
else 
props = [ props, { 'MaxFFTLength' } ];
if obj.Windowing
props = [ props, { 'MaxWinLength' } ];
else 
props = [ props, { 'MaxWinLength' }, { 'WinLength' } ];
end 
end 
flag = ismember( prop, props );
end 


function num = getNumInputsImpl( obj )
num = 2;
if strcmpi( obj.OFDMParametersSource, 'Input port' )
num = num + 4;
if obj.Windowing
num = num + 1;
end 
end 
if obj.ResetInputPort
num = num + 1;
end 
end 


function num = getNumOutputsImpl( obj )
num = 2;
if strcmpi( obj.OFDMParametersSource, 'Input port' )
num = num + 4;
if obj.Windowing
num = num + 1;
end 
end 
end 


function setupImpl( obj, varargin )
if strcmpi( obj.OFDMParametersSource, 'Input port' )
bitWidth = log2( obj.MaxFFTLength ) + 1;
else 
bitWidth = log2( obj.FFTLength ) + 1;
end 
obj.vecLength = length( varargin{ 1 } );
VL = log2( obj.vecLength ) + 1;
obj.VLBits = log2( obj.vecLength );
obj.vecLen = fi( obj.vecLength, 0, VL, 0, hdlfimath );

obj.addrBitWidth = bitWidth - obj.VLBits + 1;

obj.dataOut = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.validOut = false;
obj.FFTLenOut = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPLenOut = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.numLgScOut = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRgScOut = fi( 5, 0, bitWidth, 0, hdlfimath );

obj.dataOutReg = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.validOutReg = false;
obj.FFTLenOutReg2 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTLenOutReg1 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPLenOutReg2 = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.CPLenOutReg1 = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.numLgScOutReg2 = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numLgScOutReg1 = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRgScOutReg2 = fi( 5, 0, bitWidth, 0, hdlfimath );
obj.numRgScOutReg1 = fi( 5, 0, bitWidth, 0, hdlfimath );


obj.hRAM1 = hdl.RAM( 'RAMType', 'Simple Dual Port' );
obj.hRAM2 = hdl.RAM( 'RAMType', 'Simple Dual Port' );
obj.dataOutRAM = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.dataOutRAM1 = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.dataOutRAM2 = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.selectRAM = false;
obj.selectRAMReg = false;
obj.selectRAMReg1 = false;
obj.selectRAMReg2 = false;
obj.RAM2ReadSelect = false;
obj.startReadFromRAM = false;
obj.startRead = false;
obj.startReadReg = false;
obj.readAddr = fi( 0, 0, obj.addrBitWidth, 0, hdlfimath );
obj.writeAddrRAM1 = fi( 0, 0, obj.addrBitWidth, 0, hdlfimath );
obj.writeAddrRAM2 = fi( 0, 0, obj.addrBitWidth, 0, hdlfimath );
obj.sym1Done = false;
obj.sym2Done = false;
obj.writeEnbRAM1 = false;
obj.writeEnbRAM2 = false;
obj.RAM2WriteSelect = false;



obj.FFTLenMinusVecLenReg = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTSampledReg = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPSampledReg = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.numLgScSampledReg = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRgScSampledReg = fi( 5, 0, bitWidth, 0, hdlfimath );
obj.numDataScReg = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.numDataScMinusVecLenReg = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.numLgScCountReg = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2Reg = fi( 32, 0, bitWidth, 0, hdlfimath );

obj.FFTLenMinusVecLen = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTLenMinusVecLenReg1 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTLenMinusVecLenReg2 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTSampled = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPSampled = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.numLgScSampled = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRgScSampled = fi( 5, 0, bitWidth, 0, hdlfimath );
obj.numDataSc = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.numDataScMinusVecLen = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.numLgScCount = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2 = fi( 32, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2Reg1 = fi( 32, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2Reg2 = fi( 32, 0, bitWidth, 0, hdlfimath );
obj.sumLgRg = fi( 11, 0, bitWidth, 0, hdlfimath );
obj.sumLgRgDC = fi( 11, 0, bitWidth, 0, hdlfimath );
obj.numDataScPlusNumLgSc = fi( 53, 0, bitWidth, 0, hdlfimath );
obj.numDataScPlusNumLgScReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.numDataScPlusNumLgScReg1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.numDataScPlusNumLgScReg2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTLenMinusNumRgScReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.maxLimitForDataReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.maxLimitForDataReg1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.maxLimitForDataReg2 = fi( 0, 0, bitWidth, 0, hdlfimath );

obj.prevVecData = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.numPrevVecSamples = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.numSampLeft = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.idxPos = fi( 0, 0, VL, 0, hdlfimath );
obj.index1 = fi( 0, 0, VL, 0, hdlfimath );
obj.index2 = fi( 0, 0, VL, 0, hdlfimath );
obj.startSymbForm = false;
obj.startSymbFormReg = false;
obj.startSymbFormReg1 = false;


obj.outCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.outCountReg1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.outCountReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.readCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.numLgScCountReg2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.numLgScCountReg1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.numLgScCountReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.inCount = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.inCountReg = fi( 0, 0, bitWidth, 0, hdlfimath );


obj.dataInReg = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.validInReg = false;
obj.dataInRegDelay1 = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.validInRegDelay1 = false;
obj.dataInRegDelay2 = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.validInRegDelay2 = false;
obj.dataInReg1 = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.insertDC = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTLenReg = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPLenReg = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.numLgScReg = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRgScReg = fi( 5, 0, bitWidth, 0, hdlfimath );

obj.FFTLenRegDelay1 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPLenRegDelay1 = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.numLgScRegDelay1 = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRgScRegDelay1 = fi( 5, 0, bitWidth, 0, hdlfimath );

obj.FFTLenRegDelay2 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.CPLenRegDelay2 = fi( 16, 0, bitWidth, 0, hdlfimath );
obj.numLgScRegDelay2 = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numRgScRegDelay2 = fi( 5, 0, bitWidth, 0, hdlfimath );

obj.resetReg = false;
obj.loopRange = fi( 0:obj.vecLen - 1, 0, VL, 0, hdlfimath );
obj.enbDataRead = false;
obj.enbDataPlacing = false;


obj.dataOutRAMReg = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.sendOutput = false;
obj.dataVecidx1 = fi( 0, 0, VL, 0, hdlfimath );
obj.dataVecidx2 = fi( 0, 0, VL, 0, hdlfimath );
obj.sendDC = false;
obj.dataVec1Samples = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.dataVec1 = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.dataVec2 = cast( zeros( obj.vecLength, 1 ), 'like', varargin{ 1 } );
obj.startSymbFormReg2 = false;
obj.FFTLenOutReg4 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.FFTLenOutReg3 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.outCountReg2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.numLgScOutReg3 = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.numLgScCountReg3 = fi( 6, 0, bitWidth, 0, hdlfimath );
obj.prevVecSamples = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2Reg4 = fi( 32, 0, bitWidth, 0, hdlfimath );
obj.FFTLenBy2Reg3 = fi( 32, 0, bitWidth, 0, hdlfimath );
obj.FFTLenMinusVecLenReg3 = fi( 64, 0, bitWidth, 0, hdlfimath );
obj.numDataScPlusNumLgScReg3 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.maxLimitForDataReg3 = fi( 0, 0, bitWidth, 0, hdlfimath );
if obj.Windowing
obj.winLenReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winLenRegDelay1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winLenRegDelay2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winLenSampled = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winLenSampledReg = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winLenOutReg1 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winLenOutReg2 = fi( 0, 0, bitWidth, 0, hdlfimath );
obj.winLenOut = fi( 0, 0, bitWidth, 0, hdlfimath );
end 
end 


function resetImpl( obj )

obj.dataOut( : ) = 0;
obj.validOut = false;
obj.FFTLenOut( : ) = 64;
obj.CPLenOut( : ) = 16;
obj.numLgScOut( : ) = 6;
obj.numRgScOut( : ) = 5;

obj.dataOutReg( : ) = 0;
obj.validOutReg = false;
obj.FFTLenOutReg2( : ) = 64;
obj.FFTLenOutReg1( : ) = 64;
obj.CPLenOutReg2( : ) = 16;
obj.CPLenOutReg1( : ) = 16;
obj.numLgScOutReg2( : ) = 6;
obj.numLgScOutReg1( : ) = 6;
obj.numRgScOutReg2( : ) = 5;
obj.numRgScOutReg1( : ) = 5;


obj.dataOutRAM( : ) = 0;
obj.dataOutRAM1( : ) = 0;
obj.dataOutRAM2( : ) = 0;
obj.selectRAM = false;
obj.selectRAMReg = false;
obj.selectRAMReg1 = false;
obj.selectRAMReg2 = false;
obj.RAM2ReadSelect = false;
obj.startReadFromRAM = false;
obj.startRead = false;
obj.startReadReg = false;
obj.readAddr( : ) = 0;
obj.writeAddrRAM1( : ) = 0;
obj.writeAddrRAM2( : ) = 0;
obj.sym1Done = false;
obj.sym2Done = false;
obj.writeEnbRAM1 = false;
obj.writeEnbRAM2 = false;
obj.RAM2WriteSelect = false;



obj.FFTLenMinusVecLenReg( : ) = 64;
obj.FFTLenMinusVecLenReg1( : ) = 64;
obj.FFTLenMinusVecLenReg2( : ) = 64;
obj.FFTSampledReg( : ) = 64;
obj.CPSampledReg( : ) = 16;
obj.numLgScSampledReg( : ) = 6;
obj.numRgScSampledReg( : ) = 5;
obj.numDataScReg( : ) = 64;
obj.numDataScMinusVecLenReg( : ) = 64;
obj.numLgScCountReg( : ) = 6;
obj.FFTLenBy2Reg( : ) = 32;
obj.FFTLenBy2Reg1( : ) = 32;
obj.FFTLenBy2Reg2( : ) = 32;

obj.FFTLenMinusVecLen( : ) = 64;
obj.FFTSampled( : ) = 64;
obj.CPSampled( : ) = 16;
obj.numLgScSampled( : ) = 6;
obj.numRgScSampled( : ) = 5;
obj.numDataSc( : ) = 64;
obj.numDataScMinusVecLen( : ) = 64;
obj.numLgScCount( : ) = 6;
obj.FFTLenBy2( : ) = 32;
obj.sumLgRg( : ) = 11;
obj.sumLgRgDC( : ) = 11;
obj.numDataScPlusNumLgSc( : ) = 53;
obj.numDataScPlusNumLgScReg( : ) = 0;
obj.numDataScPlusNumLgScReg1( : ) = 0;
obj.numDataScPlusNumLgScReg2( : ) = 0;
obj.FFTLenMinusNumRgScReg( : ) = 0;
obj.maxLimitForDataReg( : ) = 0;
obj.maxLimitForDataReg1( : ) = 0;
obj.maxLimitForDataReg2( : ) = 0;

obj.prevVecData( : ) = 0;
obj.numPrevVecSamples( : ) = 0;
obj.numSampLeft( : ) = 0;
obj.idxPos( : ) = 0;
obj.index1( : ) = 0;
obj.index2( : ) = 0;
obj.startSymbForm = false;
obj.startSymbFormReg = false;
obj.startSymbFormReg1 = false;


obj.outCount( : ) = 0;
obj.outCountReg1( : ) = 0;
obj.outCountReg( : ) = 0;
obj.readCount( : ) = 0;
obj.numLgScCountReg2( : ) = 0;
obj.numLgScCountReg1( : ) = 0;
obj.numLgScCountReg( : ) = 0;
obj.inCount( : ) = 0;
obj.inCountReg( : ) = 0;


obj.dataInReg( : ) = 0;
obj.validInReg( : ) = false;
obj.dataInRegDelay1( : ) = 0;
obj.validInRegDelay1( : ) = false;
obj.dataInRegDelay2( : ) = 0;
obj.validInRegDelay2( : ) = false;
obj.dataInReg1( : ) = 0;
obj.insertDC( : ) = 0;
obj.FFTLenReg( : ) = 64;
obj.CPLenReg( : ) = 16;
obj.numLgScReg( : ) = 6;
obj.numRgScReg( : ) = 5;

obj.FFTLenRegDelay1( : ) = 64;
obj.CPLenRegDelay1( : ) = 16;
obj.numLgScRegDelay1( : ) = 6;
obj.numRgScRegDelay1( : ) = 5;

obj.FFTLenRegDelay2( : ) = 64;
obj.CPLenRegDelay2( : ) = 16;
obj.numLgScRegDelay2( : ) = 6;
obj.numRgScRegDelay2( : ) = 5;
obj.resetReg( : ) = false;
obj.enbDataRead( : ) = false;
obj.enbDataPlacing( : ) = false;

obj.dataOutRAMReg( : ) = 0;
obj.sendOutput = false;
obj.dataVecidx1( : ) = 0;
obj.dataVecidx2( : ) = 0;
obj.sendDC = false;
obj.dataVec1Samples( : ) = 0;
obj.dataVec1( : ) = 0;
obj.dataVec2( : ) = 0;
obj.startSymbFormReg2 = false;
obj.FFTLenOutReg4( : ) = 64;
obj.FFTLenOutReg3( : ) = 64;
obj.outCountReg2( : ) = 0;
obj.numLgScOutReg3( : ) = 6;
obj.numLgScCountReg3( : ) = 6;
obj.prevVecSamples( : ) = 0;
obj.FFTLenBy2Reg4( : ) = 0;
obj.FFTLenBy2Reg3( : ) = 0;
obj.FFTLenMinusVecLenReg3( : ) = 64;
obj.numDataScPlusNumLgScReg3( : ) = 0;
obj.maxLimitForDataReg3( : ) = 0;
if obj.Windowing
obj.winLenReg( : ) = 0;
obj.winLenRegDelay1( : ) = 0;
obj.winLenRegDelay2( : ) = 0;
obj.winLenSampled( : ) = 0;
obj.winLenSampledReg( : ) = 0;
obj.winLenOutReg1( : ) = 0;
obj.winLenOutReg2( : ) = 0;
obj.winLenOut( : ) = 0;
end 
end 


function varargout = outputImpl( obj, varargin )
varargout{ 1 } = obj.dataOut;
varargout{ 2 } = obj.validOut;
if strcmpi( obj.OFDMParametersSource, 'Input port' )
varargout{ 3 } = cast( obj.FFTLenOut, 'like', varargin{ 3 } );
varargout{ 4 } = cast( obj.CPLenOut, 'like', varargin{ 4 } );
varargout{ 5 } = cast( obj.numLgScOut, 'like', varargin{ 5 } );
varargout{ 6 } = cast( obj.numRgScOut, 'like', varargin{ 6 } );
if obj.Windowing
varargout{ 7 } = cast( obj.winLenOut, 'like', varargin{ 7 } );
end 
end 
end 


function updateImpl( obj, varargin )

obj.dataOut( : ) = obj.dataOutReg;
obj.validOut = obj.validOutReg;
obj.FFTLenOut( : ) = obj.FFTLenOutReg2;
obj.CPLenOut( : ) = obj.CPLenOutReg2;
obj.numLgScOut( : ) = obj.numLgScOutReg2;
obj.numRgScOut( : ) = obj.numRgScOutReg2;
if obj.Windowing
obj.winLenOut( : ) = obj.winLenOutReg2;
end 

obj.dataOutRAM1( : ) = obj.hRAM1( obj.dataInReg1, obj.writeAddrRAM1, obj.writeEnbRAM1, obj.readAddr );
obj.dataOutRAM2( : ) = obj.hRAM2( obj.dataInReg1, obj.writeAddrRAM2, obj.writeEnbRAM2, obj.readAddr );


if obj.outCount == 0
obj.numDataScReg( : ) = obj.numDataSc;
obj.numDataScMinusVecLenReg( : ) = obj.numDataScMinusVecLen;
obj.FFTLenMinusVecLenReg( : ) = obj.FFTLenMinusVecLen;
obj.FFTSampledReg( : ) = obj.FFTSampled;
obj.CPSampledReg( : ) = obj.CPSampled;
obj.numLgScSampledReg( : ) = obj.numLgScSampled;
obj.numRgScSampledReg( : ) = obj.numRgScSampled;
obj.numLgScCountReg( : ) = obj.numLgScCount;
obj.numDataScPlusNumLgScReg( : ) = obj.numDataSc + obj.numLgScSampled;
obj.FFTLenMinusNumRgScReg( : ) = obj.FFTSampled - obj.numRgScSampled;
obj.FFTLenBy2Reg( : ) = obj.FFTLenBy2;
if obj.Windowing
obj.winLenSampledReg( : ) = obj.winLenSampled;
end 
end 

obj.dataOutRAMReg( : ) = obj.dataOutRAM;

if obj.startReadFromRAM
if ~obj.RAM2ReadSelect
obj.dataOutRAM( : ) = obj.dataOutRAM1;
else 
obj.dataOutRAM( : ) = obj.dataOutRAM2;
end 
end 
if obj.sendOutput
obj.dataVecidx1( : ) = obj.index1;
obj.dataVecidx2( : ) = obj.index2;

















if obj.sendDC
for ii = 0:( obj.vecLen - 1 )
if ii == 0
obj.dataOutReg( ii + 1 ) = cast( 0, 'like', obj.dataOutReg );
elseif ii <= obj.dataVec1Samples
obj.dataVecidx1( : ) = obj.index1 + cast( ii, 'like', obj.dataVecidx1 );
obj.dataOutReg( ii + 1 ) = obj.dataVec1( obj.dataVecidx1 );
else 
obj.dataOutReg( ii + 1 ) = obj.dataVec2( obj.dataVecidx2 + 1 );
obj.dataVecidx2( : ) = obj.dataVecidx2 + 1;
end 
end 
else 
for ii = 0:( obj.vecLen - 1 )
if ii < obj.dataVec1Samples
obj.dataVecidx1( : ) = obj.index1 + cast( ii, 'like', obj.dataVecidx1 );
obj.dataOutReg( ii + 1 ) = obj.dataVec1( obj.dataVecidx1 + 1 );
else 
obj.dataOutReg( ii + 1 ) = obj.dataVec2( obj.dataVecidx2 + 1 );
obj.dataVecidx2( : ) = obj.dataVecidx2 + 1;
end 
end 
end 

obj.validOutReg = true;
else 
obj.dataOutReg( : ) = zeros( obj.vecLength, 1 );
obj.validOutReg = false;
end 


if obj.startSymbFormReg2













if obj.outCountReg2 < obj.numLgScOutReg3
if obj.numLgScCountReg3 < obj.vecLen
obj.dataVec1( : ) = zeros( obj.vecLength, 1 );
obj.dataVec1Samples( : ) = obj.numLgScCountReg3;
obj.index1( : ) = 0;
obj.dataVec2( : ) = obj.dataOutRAMReg;
obj.index2( : ) = 0;
obj.idxPos( : ) = obj.vecLen - obj.numLgScCountReg3;
obj.prevVecData( : ) = obj.dataOutRAMReg;
obj.prevVecSamples( : ) = obj.numLgScCountReg3;
else 
if obj.numLgScCountReg3 == obj.vecLen
obj.dataVec1( : ) = zeros( obj.vecLength, 1 );
obj.dataVec1Samples( : ) = 0;
obj.index1( : ) = 0;
obj.dataVec2( : ) = zeros( obj.vecLength, 1 );
obj.index2( : ) = 0;
else 
obj.dataVec1( : ) = zeros( obj.vecLength, 1 );
obj.dataVec1Samples( : ) = 0;
obj.index1( : ) = 0;
obj.dataVec2( : ) = zeros( obj.vecLength, 1 );
obj.index2( : ) = 0;
end 
obj.idxPos( : ) = 0;
obj.prevVecData( : ) = zeros( obj.vecLength, 1 );
obj.prevVecSamples( : ) = 0;
end 
obj.sendDC = false;
else 
if obj.enbDataPlacing
if obj.outCountReg2 == obj.FFTLenBy2Reg3 && obj.insertDC
obj.dataVec1( : ) = obj.prevVecData;
obj.dataVec1Samples( : ) = obj.prevVecSamples;
obj.index1( : ) = obj.idxPos;
obj.dataVec2( : ) = obj.dataOutRAMReg;
obj.index2( : ) = 0;
if obj.vecLen == 1
obj.idxPos( : ) = 0;
obj.prevVecData( : ) = obj.dataOutRAMReg;
obj.prevVecSamples( : ) = 1;
else 
if obj.prevVecSamples == obj.vecLen - 1
obj.idxPos( : ) = 0;
obj.prevVecData( : ) = obj.dataOutRAMReg;
obj.prevVecSamples( : ) = 0;
elseif obj.prevVecSamples == 0
obj.idxPos( : ) = obj.vecLen - 1;
obj.prevVecData( : ) = obj.dataOutRAMReg;
obj.prevVecSamples( : ) = 1;
else 
obj.idxPos( : ) = obj.idxPos - 1;
obj.prevVecData( : ) = obj.dataOutRAMReg;
obj.prevVecSamples( : ) = obj.prevVecSamples + 1;
end 
end 
obj.sendDC = true;
else 
obj.dataVec1( : ) = obj.prevVecData;
obj.dataVec1Samples( : ) = obj.prevVecSamples;
obj.index1( : ) = obj.idxPos;
obj.dataVec2( : ) = obj.dataOutRAMReg;
obj.index2( : ) = 0;
obj.idxPos( : ) = obj.idxPos;
obj.prevVecData( : ) = obj.dataOutRAMReg;
obj.sendDC = false;
end 
else 
obj.dataVec1( : ) = obj.prevVecData;
obj.dataVec1Samples( : ) = obj.prevVecSamples;
obj.index1( : ) = obj.idxPos;
obj.dataVec2( : ) = zeros( obj.vecLength, 1 );
obj.index2( : ) = 0;
obj.idxPos( : ) = 0;
obj.prevVecData( : ) = zeros( obj.vecLength, 1 );
obj.prevVecSamples( : ) = 0;
obj.sendDC = false;
end 
end 

obj.sendOutput = true;
if obj.outCountReg2 == obj.FFTLenMinusVecLenReg3
obj.prevVecSamples( : ) = 0;
obj.startSymbFormReg2 = false;
end 
else 
obj.sendOutput = false;
end 
obj.enbDataPlacing( : ) = obj.outCountReg1 < obj.numDataScPlusNumLgScReg2 && obj.outCountReg1 < obj.maxLimitForDataReg2;

obj.outCountReg2( : ) = obj.outCountReg1;
obj.outCountReg1( : ) = obj.outCountReg;
obj.outCountReg( : ) = obj.outCount;

obj.numLgScCountReg3( : ) = obj.numLgScCountReg2;
obj.numLgScCountReg2( : ) = obj.numLgScCountReg1;
obj.numLgScCountReg1( : ) = obj.numLgScCountReg;

obj.FFTLenOutReg4( : ) = obj.FFTLenOutReg3;
obj.FFTLenOutReg3( : ) = obj.FFTLenOutReg2;
obj.FFTLenOutReg2( : ) = obj.FFTLenOutReg1;
obj.FFTLenOutReg1( : ) = obj.FFTSampledReg;

obj.CPLenOutReg2( : ) = obj.CPLenOutReg1;
obj.CPLenOutReg1( : ) = obj.CPSampledReg;

if obj.Windowing
obj.winLenOutReg2( : ) = obj.winLenOutReg1;
obj.winLenOutReg1( : ) = obj.winLenSampledReg;
end 

obj.numLgScOutReg3( : ) = obj.numLgScOutReg2;
obj.numLgScOutReg2( : ) = obj.numLgScOutReg1;
obj.numLgScOutReg1( : ) = obj.numLgScSampledReg;

obj.numRgScOutReg2( : ) = obj.numRgScOutReg1;
obj.numRgScOutReg1( : ) = obj.numRgScSampledReg;

obj.numDataScPlusNumLgScReg3 = obj.numDataScPlusNumLgScReg2;
obj.numDataScPlusNumLgScReg2 = obj.numDataScPlusNumLgScReg1;
obj.numDataScPlusNumLgScReg1( : ) = obj.numDataScPlusNumLgScReg;

obj.FFTLenBy2Reg4( : ) = obj.FFTLenBy2Reg3;
obj.FFTLenBy2Reg3( : ) = obj.FFTLenBy2Reg2;
obj.FFTLenBy2Reg2( : ) = obj.FFTLenBy2Reg1;
obj.FFTLenBy2Reg1( : ) = obj.FFTLenBy2Reg;

obj.FFTLenMinusVecLenReg3( : ) = obj.FFTLenMinusVecLenReg2;
obj.FFTLenMinusVecLenReg2( : ) = obj.FFTLenMinusVecLenReg1;
obj.FFTLenMinusVecLenReg1( : ) = obj.FFTLenMinusVecLenReg;

obj.startReadReg = obj.startRead;

obj.selectRAMReg2 = obj.selectRAMReg1;
obj.selectRAMReg1 = obj.selectRAMReg;
obj.selectRAMReg = obj.selectRAM;


if obj.CPSampledReg == 0
obj.RAM2ReadSelect = obj.selectRAMReg1;
else 
obj.RAM2ReadSelect = obj.selectRAMReg2;
end 





obj.startReadFromRAM = obj.startReadReg;



if obj.startRead && obj.startSymbFormReg
if obj.readCount >= obj.numDataScMinusVecLenReg
obj.readAddr( : ) = 0;
obj.readCount( : ) = 0;
else 
obj.readAddr( : ) = obj.readAddr + 1;
obj.readCount( : ) = obj.readCount + obj.vecLen;
end 
end 


obj.startSymbFormReg2 = obj.startSymbFormReg1;
obj.startSymbFormReg1 = obj.startSymbFormReg;
obj.startSymbFormReg = obj.startSymbForm;

obj.maxLimitForDataReg3( : ) = obj.maxLimitForDataReg2;
obj.maxLimitForDataReg2( : ) = obj.maxLimitForDataReg1;
obj.maxLimitForDataReg1( : ) = obj.maxLimitForDataReg;

obj.enbDataRead( : ) = obj.outCount < obj.numDataScPlusNumLgScReg && obj.outCount < obj.maxLimitForDataReg;



if obj.startSymbForm
if obj.outCount < obj.numLgScSampledReg
if obj.numLgScCountReg < obj.vecLen
if obj.insertDC
obj.numSampLeft( : ) = obj.numLgScCountReg + 1;
else 
obj.numSampLeft( : ) = obj.numLgScCountReg;
end 
obj.numLgScCountReg( : ) = 0;
obj.startRead = true;
else 
if obj.numLgScCountReg == obj.vecLen
obj.numSampLeft( : ) = 0;
obj.numLgScCountReg( : ) = 0;
obj.startRead = false;
else 
obj.numSampLeft( : ) = 0;
obj.numLgScCountReg( : ) = obj.numLgScCountReg - obj.vecLen;
obj.startRead = false;
end 
end 
else 
if obj.enbDataRead
obj.startRead = true;
else 
obj.startRead = false;
end 
end 
if obj.outCount == obj.FFTLenMinusVecLenReg
obj.outCount( : ) = 0;
obj.selectRAM = ~obj.selectRAM;
obj.startSymbForm = false;
else 
obj.outCount( : ) = obj.outCount + obj.vecLen;
end 
end 

obj.maxLimitForDataReg( : ) = obj.FFTLenMinusNumRgScReg - obj.numSampLeft;


if ( obj.sym2Done || obj.sym1Done ) && ~obj.startSymbForm
obj.startSymbForm = true;
if obj.sym1Done
obj.sym1Done = false;
elseif obj.sym2Done
obj.sym2Done = false;
end 
end 


if obj.writeEnbRAM1
if obj.inCountReg >= obj.numDataScMinusVecLen
obj.writeAddrRAM1( : ) = 0;
obj.sym1Done = true;
else 
obj.writeAddrRAM1( : ) = obj.writeAddrRAM1 + 1;
end 
elseif obj.writeEnbRAM2
if obj.inCountReg >= obj.numDataScMinusVecLen
obj.writeAddrRAM2( : ) = 0;
obj.sym2Done = true;
else 
obj.writeAddrRAM2( : ) = obj.writeAddrRAM2 + 1;
end 
end 


obj.inCountReg( : ) = obj.inCount;


obj.writeEnbRAM1 = obj.validInReg && ~obj.RAM2WriteSelect;
obj.writeEnbRAM2 = obj.validInReg && obj.RAM2WriteSelect;

obj.numLgScCount( : ) = obj.numLgScSampled;
obj.FFTLenBy2( : ) = bitsra( obj.FFTSampled, 1 );

if obj.validInReg
if obj.inCount == 0
obj.numDataScMinusVecLen( : ) = obj.numDataSc - obj.vecLen;
obj.FFTLenMinusVecLen( : ) = obj.FFTLenReg - obj.vecLen;
obj.FFTSampled( : ) = obj.FFTLenReg;
obj.CPSampled( : ) = obj.CPLenReg;
obj.numLgScSampled( : ) = obj.numLgScReg;
obj.numRgScSampled( : ) = obj.numRgScReg;
if obj.Windowing
obj.winLenSampled( : ) = obj.winLenReg;
end 
end 
end 


if obj.validInReg
if obj.inCount >= obj.numDataScMinusVecLen
obj.inCount( : ) = 0;
obj.RAM2WriteSelect = ~obj.RAM2WriteSelect;
else 
obj.inCount( : ) = obj.inCount + obj.vecLen;
end 
end 


obj.dataInReg1( : ) = obj.dataInReg;


obj.dataInReg( : ) = obj.dataInRegDelay1;
obj.validInReg( : ) = obj.validInRegDelay1;
obj.FFTLenReg( : ) = obj.FFTLenRegDelay1;
obj.CPLenReg( : ) = obj.CPLenRegDelay1;
obj.numLgScReg( : ) = obj.numLgScRegDelay1;
obj.numRgScReg( : ) = obj.numRgScRegDelay1;

obj.dataInRegDelay1( : ) = obj.dataInRegDelay2;
obj.validInRegDelay1( : ) = obj.validInRegDelay2;
obj.FFTLenRegDelay1( : ) = obj.FFTLenRegDelay2;
obj.CPLenRegDelay1( : ) = obj.CPLenRegDelay2;
obj.numLgScRegDelay1( : ) = obj.numLgScRegDelay2;
obj.numRgScRegDelay1( : ) = obj.numRgScRegDelay2;
if obj.Windowing
obj.winLenReg( : ) = obj.winLenRegDelay1;
obj.winLenRegDelay1( : ) = obj.winLenRegDelay2;
end 


obj.dataInRegDelay2( : ) = varargin{ 1 };
obj.validInRegDelay2( : ) = varargin{ 2 };
obj.insertDC( : ) = obj.InsertDCNull;
if strcmp( obj.OFDMParametersSource, 'Input port' )
obj.FFTLenRegDelay2( : ) = varargin{ 3 };
obj.CPLenRegDelay2( : ) = varargin{ 4 };
obj.numLgScRegDelay2( : ) = varargin{ 5 };
obj.numRgScRegDelay2( : ) = varargin{ 6 };
if obj.Windowing
obj.winLenRegDelay2( : ) = varargin{ 7 };
if obj.ResetInputPort
obj.resetReg = varargin{ 8 };
end 
else 
if obj.ResetInputPort
obj.resetReg = varargin{ 7 };
end 
end 
else 
obj.FFTLenRegDelay2( : ) = obj.FFTLength;
obj.CPLenRegDelay2( : ) = obj.CPLength;
obj.numLgScRegDelay2( : ) = obj.numLgSc;
obj.numRgScRegDelay2( : ) = obj.numRgSc;
if obj.Windowing
obj.winLenRegDelay2( : ) = obj.WinLength;
end 
if obj.ResetInputPort
obj.resetReg = varargin{ 3 };
end 
end 
obj.numDataSc( : ) = obj.FFTLenReg - obj.sumLgRgDC;
obj.sumLgRgDC( : ) = obj.sumLgRg + obj.insertDC;
obj.sumLgRg( : ) = obj.numLgScRegDelay2 + obj.numRgScRegDelay2;

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
s.vecLen = obj.vecLen;
s.vecLength = obj.vecLength;
s.loopRange = obj.loopRange;
s.VLBits = obj.VLBits;
s.addrBitWidth = obj.addrBitWidth;
s.dataOut = obj.dataOut;
s.validOut = obj.validOut;
s.FFTLenOut = obj.FFTLenOut;
s.CPLenOut = obj.CPLenOut;
s.numLgScOut = obj.numLgScOut;
s.numRgScOut = obj.numRgScOut;
s.dataOutReg = obj.dataOutReg;
s.validOutReg = obj.validOutReg;
s.FFTLenOutReg2 = obj.FFTLenOutReg2;
s.FFTLenOutReg1 = obj.FFTLenOutReg1;
s.CPLenOutReg2 = obj.CPLenOutReg2;
s.CPLenOutReg1 = obj.CPLenOutReg1;
s.numLgScOutReg2 = obj.numLgScOutReg2;
s.numLgScOutReg1 = obj.numLgScOutReg1;
s.numRgScOutReg2 = obj.numRgScOutReg2;
s.numRgScOutReg1 = obj.numRgScOutReg1;
s.hRAM1 = obj.hRAM1;
s.hRAM2 = obj.hRAM2;
s.dataOutRAM = obj.dataOutRAM;
s.dataOutRAM1 = obj.dataOutRAM1;
s.dataOutRAM2 = obj.dataOutRAM2;
s.selectRAM = obj.selectRAM;
s.selectRAMReg = obj.selectRAMReg;
s.selectRAMReg1 = obj.selectRAMReg1;
s.selectRAMReg2 = obj.selectRAMReg2;
s.RAM2ReadSelect = obj.RAM2ReadSelect;
s.startReadFromRAM = obj.startReadFromRAM;
s.startRead = obj.startRead;
s.startReadReg = obj.startReadReg;
s.readAddr = obj.readAddr;
s.writeAddrRAM1 = obj.writeAddrRAM1;
s.writeAddrRAM2 = obj.writeAddrRAM2;
s.sym1Done = obj.sym1Done;
s.sym2Done = obj.sym2Done;
s.writeEnbRAM1 = obj.writeEnbRAM1;
s.writeEnbRAM2 = obj.writeEnbRAM2;
s.RAM2WriteSelect = obj.RAM2WriteSelect;
s.FFTLenMinusVecLenReg = obj.FFTLenMinusVecLenReg;
s.FFTLenMinusVecLenReg1 = obj.FFTLenMinusVecLenReg1;
s.FFTLenMinusVecLenReg2 = obj.FFTLenMinusVecLenReg2;
s.FFTSampledReg = obj.FFTSampledReg;
s.CPSampledReg = obj.CPSampledReg;
s.numLgScSampledReg = obj.numLgScSampledReg;
s.numRgScSampledReg = obj.numRgScSampledReg;
s.numDataScReg = obj.numDataScReg;
s.numDataScMinusVecLenReg = obj.numDataScMinusVecLenReg;
s.numLgScCountReg = obj.numLgScCountReg;
s.FFTLenBy2Reg = obj.FFTLenBy2Reg;
s.FFTLenBy2Reg1 = obj.FFTLenBy2Reg1;
s.FFTLenBy2Reg2 = obj.FFTLenBy2Reg2;
s.FFTLenMinusVecLen = obj.FFTLenMinusVecLen;
s.FFTSampled = obj.FFTSampled;
s.CPSampled = obj.CPSampled;
s.numLgScSampled = obj.numLgScSampled;
s.numRgScSampled = obj.numRgScSampled;
s.numDataSc = obj.numDataSc;
s.numDataScMinusVecLen = obj.numDataScMinusVecLen;
s.numLgScCount = obj.numLgScCount;
s.FFTLenBy2 = obj.FFTLenBy2;
s.sumLgRg = obj.sumLgRg;
s.sumLgRgDC = obj.sumLgRgDC;
s.numDataScPlusNumLgSc = obj.numDataScPlusNumLgSc;
s.numDataScPlusNumLgScReg = obj.numDataScPlusNumLgScReg;
s.numDataScPlusNumLgScReg1 = obj.numDataScPlusNumLgScReg1;
s.numDataScPlusNumLgScReg2 = obj.numDataScPlusNumLgScReg2;
s.FFTLenMinusNumRgScReg = obj.FFTLenMinusNumRgScReg;
s.maxLimitForDataReg = obj.maxLimitForDataReg;
s.maxLimitForDataReg1 = obj.maxLimitForDataReg1;
s.maxLimitForDataReg2 = obj.maxLimitForDataReg2;
s.numPrevVecSamples = obj.numPrevVecSamples;
s.idxPos = obj.idxPos;
s.index1 = obj.index1;
s.index2 = obj.index2;
s.startSymbForm = obj.startSymbForm;
s.startSymbFormReg = obj.startSymbFormReg;
s.startSymbFormReg1 = obj.startSymbFormReg1;
s.outCount = obj.outCount;
s.outCountReg1 = obj.outCountReg1;
s.outCountReg = obj.outCountReg;
s.readCount = obj.readCount;
s.numLgScCountReg2 = obj.numLgScCountReg2;
s.numLgScCountReg1 = obj.numLgScCountReg1;
s.inCount = obj.inCount;
s.inCountReg = obj.inCountReg;
s.dataInReg = obj.dataInReg;
s.validInReg = obj.validInReg;
s.dataInReg1 = obj.dataInReg1;
s.insertDC = obj.insertDC;
s.FFTLenReg = obj.FFTLenReg;
s.CPLenReg = obj.CPLenReg;
s.numLgScReg = obj.numLgScReg;
s.numRgScReg = obj.numRgScReg;
s.resetReg = obj.resetReg;
s.enbDataRead = obj.enbDataRead;
s.enbDataPlacing = obj.enbDataPlacing;
s.numSampLeft = obj.numSampLeft;
s.dataOutRAMReg = obj.dataOutRAMReg;
s.sendOutput = obj.sendOutput;
s.dataVecidx1 = obj.dataVecidx1;
s.dataVecidx2 = obj.dataVecidx2;
s.sendDC = obj.sendDC;
s.dataVec1Samples = obj.dataVec1Samples;
s.dataVec1 = obj.dataVec1;
s.dataVec2 = obj.dataVec2;
s.startSymbFormReg2 = obj.startSymbFormReg2;
s.FFTLenOutReg4 = obj.FFTLenOutReg4;
s.FFTLenOutReg3 = obj.FFTLenOutReg3;
s.outCountReg2 = obj.outCountReg2;
s.numLgScOutReg3 = obj.numLgScOutReg3;
s.numLgScCountReg3 = obj.numLgScCountReg3;
s.prevVecSamples = obj.prevVecSamples;
s.FFTLenBy2Reg4 = obj.FFTLenBy2Reg4;
s.FFTLenBy2Reg3 = obj.FFTLenBy2Reg3;
s.FFTLenMinusVecLenReg3 = obj.FFTLenMinusVecLenReg3;
s.numDataScPlusNumLgScReg3 = obj.numDataScPlusNumLgScReg3;
s.maxLimitForDataReg3 = obj.maxLimitForDataReg3;
s.winLenReg = obj.winLenReg;
s.winLenSampled = obj.winLenSampled;
s.winLenSampledReg = obj.winLenSampledReg;
s.winLenOutReg1 = obj.winLenOutReg1;
s.winLenOutReg2 = obj.winLenOutReg2;
s.winLenOut = obj.winLenOut;
s.dataInRegDelay1 = obj.dataInRegDelay1;
s.dataInRegDelay2 = obj.dataInRegDelay2;
s.validInRegDelay1 = obj.validInRegDelay1;
s.validInRegDelay2 = obj.validInRegDelay2;
s.FFTLenRegDelay1 = obj.FFTLenRegDelay1;
s.FFTLenRegDelay2 = obj.FFTLenRegDelay2;
s.CPLenRegDelay1 = obj.CPLenRegDelay1;
s.CPLenRegDelay2 = obj.CPLenRegDelay2;
s.numLgScRegDelay1 = obj.numLgScRegDelay1;
s.numLgScRegDelay2 = obj.numLgScRegDelay2;
s.numRgScRegDelay1 = obj.numRgScRegDelay1;
s.numRgScRegDelay2 = obj.numRgScRegDelay2;
s.winLenRegDelay1 = obj.winLenRegDelay1;
s.winLenRegDelay2 = obj.winLenRegDelay2;

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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqGbfS7.p.
% Please follow local copyright laws when handling this file.

