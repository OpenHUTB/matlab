classdef ( StrictDefaults )WLANLDPCCodeParameters < matlab.System





%#codegen

properties ( Nontunable )
Standard = 'IEEE 802.11 n/ac/ax'
Termination = 'Max';
SpecifyInputs = 'Property';
NumIterations = 8;
MaxNumIterations = 8;
end 


properties ( Access = private )

dataMemory;
delayBalancer1;
delayBalancer2;

endReg;
validReg;
frameValid;
rdValid;
rdValidReg;
eValid;
count;
countMax;
wrData;
wrAddr;
wrEnb;
rdAddr;
rdAddrD;
rdValidReg1;
rdEnb;
aIdx;
smDone;
endInd;
rdAddrDReg;
aIdxReg;
rdEnbReg;
smDoneReg;
smDoneReg1;
smDoneOutReg;

dataOut;
dataReg;
ctrlOut;
validOut;
frameValidOut;
resetOut;
subMatrixSize;
codeRate;
blockLen;
endIndOut;
smDoneOut;
numIterOut;
end 

properties ( Nontunable, Access = private )
expFactorSet;
vectorSize;
end 
properties ( Constant, Hidden )
StandardSet = matlab.system.StringSet( { 'IEEE 802.11 n/ac/ax', 'IEEE 802.11 ad' } );
TerminationSet = matlab.system.StringSet( { 'Max', 'Early' } );
SpecifyInputsSet = matlab.system.StringSet( { 'Input port', 'Property' } );
end 

methods 


function obj = WLANLDPCCodeParameters( varargin )
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

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function resetImpl( obj )

reset( obj.dataMemory );
reset( obj.delayBalancer1 );
reset( obj.delayBalancer2 );

obj.dataOut( : ) = zeros( obj.vectorSize, 1 );
obj.dataReg( : ) = zeros( obj.vectorSize, 1 );
obj.ctrlOut = struct( 'start', false, 'end', false, 'valid', false );
obj.validOut = false;
obj.frameValidOut = false;
obj.resetOut = false;
obj.subMatrixSize = fi( 27, 0, 7, 0 );
obj.codeRate = fi( 0, 0, 2, 0 );
obj.blockLen = fi( 0, 0, 2, 0 );
obj.endIndOut = false;
obj.smDoneOut = false;
obj.numIterOut = fi( 8, 0, 8, 0 );

obj.endReg = false;
obj.validReg = false;
obj.frameValid = false;
obj.rdValid = false;
obj.rdValidReg = false;
obj.eValid = false;
obj.count = fi( 0, 0, 5, 0, hdlfimath );
obj.countMax = fi( 0, 0, 5, 0, hdlfimath );
obj.wrData( : ) = zeros( obj.vectorSize, 1 );
obj.wrEnb = zeros( 8, 1 ) > 0;
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
aWL = 8;aIWL = 5;
else 
aWL = 7;aIWL = 4;
end 
obj.wrAddr = fi( 1, 0, aWL, 0, hdlfimath );
obj.rdAddr = fi( 1, 0, aWL, 0, hdlfimath );
obj.rdAddrD = fi( 1, 0, aWL, 0, hdlfimath );
obj.aIdx = fi( 1, 0, aIWL, 0 );

obj.rdValidReg1 = false;
obj.rdEnb = true;
obj.smDone = false;
obj.endInd = false;

obj.rdAddrDReg = fi( 1, 0, aWL, 0, hdlfimath );
obj.aIdxReg = fi( 1, 0, aIWL, 0 );
obj.rdEnbReg = true;
obj.smDoneReg = false;
obj.smDoneReg1 = false;
obj.smDoneOutReg = false;

obj.expFactorSet = fi( [ 27, 54, 81, 81 ], 0, 7, 0 );
end 

function setupImpl( obj, varargin )

obj.vectorSize = size( varargin{ 1 }, 1 );



obj.dataMemory = hdl.RAM( 'RAMType', 'Simple dual port' );
obj.delayBalancer1 = dsp.Delay( 3 );
obj.delayBalancer2 = dsp.Delay( 2 );

obj.dataOut = cast( zeros( obj.vectorSize, 1 ), 'like', varargin{ 1 } );
obj.dataReg = cast( zeros( obj.vectorSize, 1 ), 'like', varargin{ 1 } );
obj.ctrlOut = struct( 'start', false, 'end', false, 'valid', false );
obj.validOut = false;
obj.frameValidOut = false;
obj.resetOut = false;
obj.subMatrixSize = fi( 27, 0, 7, 0 );
obj.codeRate = fi( 0, 0, 2, 0 );
obj.blockLen = fi( 0, 0, 2, 0 );
obj.endIndOut = false;
obj.smDoneOut = false;
obj.numIterOut = fi( 8, 0, 8, 0 );

obj.endReg = false;
obj.validReg = false;
obj.frameValid = false;
obj.rdValid = false;
obj.rdValidReg = false;
obj.eValid = false;
obj.count = fi( 0, 0, 5, 0, hdlfimath );
obj.countMax = fi( 0, 0, 5, 0, hdlfimath );
obj.wrData = cast( zeros( obj.vectorSize, 1 ), 'like', varargin{ 1 } );
obj.wrEnb = zeros( 8, 1 ) > 0;
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
aWL = 8;aIWL = 5;
else 
aWL = 7;aIWL = 4;
end 
obj.wrAddr = fi( 1, 0, aWL, 0, hdlfimath );
obj.rdAddr = fi( 1, 0, aWL, 0, hdlfimath );
obj.rdAddrD = fi( 1, 0, aWL, 0, hdlfimath );
obj.aIdx = fi( 1, 0, aIWL, 0 );

obj.rdValidReg1 = false;
obj.rdEnb = true;
obj.smDone = false;
obj.endInd = false;

obj.rdAddrDReg = fi( 1, 0, aWL, 0, hdlfimath );
obj.aIdxReg = fi( 1, 0, aIWL, 0 );
obj.rdEnbReg = true;
obj.smDoneReg = false;
obj.smDoneReg1 = false;
obj.smDoneOutReg = false;

obj.expFactorSet = fi( [ 27, 54, 81, 81 ], 0, 7, 0 );

end 

function varargout = outputImpl( obj, varargin )

varargout{ 1 } = obj.dataOut;
varargout{ 2 } = obj.validOut;
varargout{ 3 } = obj.frameValidOut;
varargout{ 4 } = obj.resetOut;
varargout{ 5 } = obj.endIndOut;
varargout{ 6 } = obj.smDoneOut;
varargout{ 7 } = obj.numIterOut;
end 

function updateImpl( obj, varargin )

dataIn = varargin{ 1 };
ctrlIn.start = varargin{ 2 }.start;
ctrlIn.end = varargin{ 2 }.end;
ctrlIn.valid = varargin{ 2 }.valid;

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
blklen = varargin{ 3 };
rateidx = varargin{ 4 };
if strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' )
niter = varargin{ 5 };
end 
else 
blklen = 0;
rateidx = varargin{ 3 };
if strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' )
niter = varargin{ 4 };
end 
end 


obj.blockLen( : ) = blklen;
obj.codeRate( : ) = rateidx;
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
obj.subMatrixSize( : ) = obj.expFactorSet( blklen + 1 );
else 
obj.subMatrixSize( : ) = 42;
end 

[ reset, wrvalid, rdvalid, frame_valid, endind ] = frameController( obj, ctrlIn.start, ctrlIn.end, ctrlIn.valid, obj.subMatrixSize );

if obj.vectorSize == 8
[ wr_data, wr_addr, wr_en, rd_addr, rd_valid, smdone ] = writeController( obj, dataIn, reset, wrvalid, rdvalid, obj.subMatrixSize );

wr_addrD = wr_addr * uint8( ones( obj.vectorSize, 1 ) );
rd_addrD = rd_addr * uint8( ones( obj.vectorSize, 1 ) );


obj.dataOut( : ) = obj.dataMemory( wr_data, wr_addrD, wr_en, rd_addrD );
obj.validOut( : ) = rd_valid;
obj.frameValidOut( : ) = obj.delayBalancer1( frame_valid ) || obj.validOut;

else 
obj.dataOut( : ) = dataIn;
obj.validOut( : ) = rdvalid;
obj.frameValidOut( : ) = frame_valid;
smdone = false;
end 

obj.endIndOut( : ) = obj.delayBalancer2( endind );

obj.resetOut( : ) = reset;
obj.smDoneOut( : ) = obj.smDoneOutReg;
obj.smDoneOutReg( : ) = smdone;


if strcmpi( obj.SpecifyInputs, 'Input port' ) && strcmpi( obj.Termination, 'Max' )
if ( obj.resetOut )
if ( niter > 63 ) || ( niter < 1 )
obj.numIterOut( : ) = 8;
if isempty( coder.target ) || ~coder.internal.isAmbiguousTypes
coder.internal.warning( 'whdl:WLANLDPCDecoder:InvalidNumIter' );
end 
else 
obj.numIterOut( : ) = niter;
end 
end 
elseif strcmpi( obj.Termination, 'Early' )
obj.numIterOut( : ) = obj.MaxNumIterations;
else 
obj.numIterOut( : ) = obj.NumIterations;
end 

end 

function [ reset, wr_valid, rd_valid, frame_valid, endind ] = frameController( obj, starti, endi, validi, smsize )

reset = starti && validi;

if starti && validi
obj.frameValid = true;
elseif obj.endReg && obj.validReg
obj.frameValid = false;
end 

if obj.vectorSize == 8
frame_valid = obj.frameValid;
wr_valid = obj.frameValid && validi;
rd_valid = obj.rdValidReg || obj.eValid;

if reset
obj.rdValid( : ) = false;
else 
obj.rdValid( : ) = wr_valid;
end 
obj.rdValidReg( : ) = obj.rdValid;

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
if smsize == fi( 27, 0, 8, 0 )
obj.countMax( : ) = 22;
elseif smsize == fi( 54, 0, 8, 0 )
obj.countMax( : ) = 19;
elseif smsize == fi( 81, 0, 8, 0 )
obj.countMax( : ) = 22;
else 
obj.countMax( : ) = 22;
end 
else 
obj.countMax( : ) = 13;
end 

if reset
obj.eValid( : ) = false;
obj.endInd( : ) = false;
obj.count( : ) = 0;
elseif ( obj.frameValid && endi && validi )
obj.eValid( : ) = true;
elseif obj.eValid
if obj.count == obj.countMax
obj.eValid( : ) = false;
obj.endInd( : ) = true;
obj.count( : ) = 0;
else 
obj.eValid = true;
obj.endInd( : ) = false;
obj.count( : ) = obj.count + 1;
end 
end 
else 
wr_valid = false;
rd_valid = obj.frameValid && validi;
frame_valid = obj.frameValid;
if starti && validi
obj.endInd( : ) = false;
elseif obj.endReg && obj.validReg
obj.endInd( : ) = true;
end 
end 

endind = obj.endInd;
obj.endReg( : ) = endi;
obj.validReg( : ) = validi;

end 

function [ wr_data, wr_addr, wr_en, rd_addr, rd_valid, smdone ] = writeController( obj, data, reset, wrvalid, rdvalid, smsize )


addrLUT11ac = fi( [ 4;7;11;14;17;21;24;31;34;38;41;44;48;51;58;61;65;68;71;75;78;0;0;0;0;0;0;0;0;0;0;0;
7;14;21;34;41;48;61;68;75;88;95;102;115;122;129;142;149;156;7;7;7;7;7;7;7;7;7;7;7;7;7;7;
11;21;31;41;51;61;71;92;102;112;122;132;142;152;173;183;193;203;213;223;233;11;zeros( 42, 1 ) ], 0, 8, 0 );

rdAddrLUT11ac = fi( [ 4;7;11;14;17;21;24;27;31;34;38;41;44;48;51;54;58;61;65;68;71;75;78;81;0;0;0;0;0;0;0;0;
7;14;21;27;34;41;48;54;61;68;75;81;88;95;102;108;115;122;129;135;142;149;156;162;7;7;7;7;7;7;7;7;
11;21;31;41;51;61;71;81;92;102;112;122;132;142;152;162;173;183;193;203;213;223;233;243;11;
11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11;11; ], 0, 8, 0 );
addrLUT11ad = fi( [ 6;11;16;27;32;37;48;53;58;69;74;79;0;0;0;0 ], 0, 7, 0 );

rdAddrLUT11ad = fi( [ 6;11;16;21;27;32;37;42;48;53;58;63;69;74;79;84;6 ], 0, 7, 0 );

wr_data = obj.wrData;
wr_addr = obj.wrAddr;
wr_en = obj.wrEnb;
rd_addr = obj.rdAddr;
if obj.rdValidReg1 %#ok<*ALIGN> 
smdone = obj.smDoneReg;
else 
smdone = obj.smDoneReg1;
end 

if reset
obj.wrAddr( : ) = 1;
elseif wrvalid
obj.wrAddr( : ) = obj.wrAddr + 1;
end 
obj.wrData( : ) = data;

if wrvalid
obj.wrEnb( : ) = ones( 8, 1 );
else 
obj.wrEnb( : ) = zeros( 8, 1 );
end 

if smsize == fi( 27, 0, 8, 0 )
rdIdx = fi( 0, 0, 2, 0 );
elseif smsize == fi( 54, 0, 8, 0 )
rdIdx = fi( 1, 0, 2, 0 );
elseif smsize == fi( 81, 0, 8, 0 )
rdIdx = fi( 2, 0, 2, 0 );
else 
rdIdx = fi( 0, 0, 2, 0 );
end 

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
rdaddr = addrLUT11ac( fi( bitconcat( rdIdx, obj.aIdx ), 0, 7, 0 ) );
rdaddr_reg = rdAddrLUT11ac( fi( bitconcat( rdIdx, obj.aIdxReg ), 0, 7, 0 ) );
else 
rdaddr = addrLUT11ad( obj.aIdx );
rdaddr_reg = rdAddrLUT11ad( obj.aIdxReg );
end 


if reset
obj.rdEnbReg( : ) = true;
elseif rdvalid
if ( obj.rdAddr == obj.rdAddrDReg )
if ( ~obj.rdEnbReg )
obj.rdEnbReg( : ) = true;
else 
obj.rdEnbReg( : ) = false;
end 
else 
obj.rdEnbReg( : ) = true;
end 
else 
obj.rdEnbReg( : ) = true;
end 


if reset
obj.rdAddr( : ) = 1;
obj.rdEnb( : ) = true;
elseif rdvalid
if ( obj.rdAddr == obj.rdAddrD )
if ( ~obj.rdEnb )
obj.rdAddr( : ) = obj.rdAddr + 1;
obj.rdEnb( : ) = true;
else 
obj.rdEnb( : ) = false;
end 
else 
obj.rdEnb( : ) = true;
obj.rdAddr( : ) = obj.rdAddr + 1;
end 
else 
obj.rdEnb( : ) = true;
end 


obj.rdAddrD( : ) = rdaddr;
obj.rdAddrDReg( : ) = rdaddr_reg;

if reset
obj.smDoneReg1( : ) = 0;
else 
if obj.rdValidReg1
obj.smDoneReg1( : ) = obj.smDoneReg;
end 
end 

obj.smDone( : ) = ~obj.rdEnb;
obj.smDoneReg( : ) = ~obj.rdEnbReg;

if reset
obj.aIdx( : ) = 1;
elseif obj.smDone
obj.aIdx( : ) = obj.aIdx + 1;
end 

if reset
obj.aIdxReg( : ) = 1;
elseif obj.smDoneReg
obj.aIdxReg( : ) = obj.aIdxReg + 1;
end 

rd_valid = obj.rdValidReg1;
if reset
obj.rdValidReg1( : ) = false;
else 
obj.rdValidReg1( : ) = rdvalid;
end 


end 

function num = getNumInputsImpl( obj )
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
num = 4;
else 
num = 3;
end 
if strcmpi( obj.Termination, 'Max' ) && strcmpi( obj.SpecifyInputs, 'Input port' )
num = num + 1;
end 
end 

function num = getNumOutputsImpl( ~ )
num = 7;
end 






























function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.dataMemory = obj.dataMemory;
s.delayBalancer1 = obj.delayBalancer1;
s.delayBalancer2 = obj.delayBalancer2;
s.endReg = obj.endReg;
s.validReg = obj.validReg;
s.frameValid = obj.frameValid;
s.rdValid = obj.rdValid;
s.rdValidReg = obj.rdValidReg;
s.eValid = obj.eValid;
s.count = obj.count;
s.countMax = obj.countMax;
s.wrData = obj.wrData;
s.wrAddr = obj.wrAddr;
s.wrEnb = obj.wrEnb;
s.rdAddr = obj.rdAddr;
s.rdAddrD = obj.rdAddrD;
s.rdValidReg1 = obj.rdValidReg1;
s.rdEnb = obj.rdEnb;
s.aIdx = obj.aIdx;
s.smDone = obj.smDone;
s.endInd = obj.endInd;
s.rdAddrDReg = obj.rdAddrDReg;
s.aIdxReg = obj.aIdxReg;
s.rdEnbReg = obj.rdEnbReg;
s.smDoneReg = obj.smDoneReg;
s.smDoneOutReg = obj.smDoneOutReg;
s.dataOut = obj.dataOut;
s.dataReg = obj.dataReg;
s.ctrlOut = obj.ctrlOut;
s.validOut = obj.validOut;
s.frameValidOut = obj.frameValidOut;
s.resetOut = obj.resetOut;
s.subMatrixSize = obj.subMatrixSize;
s.codeRate = obj.codeRate;
s.blockLen = obj.blockLen;
s.endIndOut = obj.endIndOut;
s.numIterOut = obj.numIterOut;
s.smDoneOut = obj.smDoneOut;
s.expFactorSet = obj.expFactorSet;
s.smDoneReg1 = obj.smDoneReg1;
s.vectorSize = obj.vectorSize;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6HXyNY.p.
% Please follow local copyright laws when handling this file.

