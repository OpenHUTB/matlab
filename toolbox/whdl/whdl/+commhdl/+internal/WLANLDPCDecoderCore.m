classdef ( StrictDefaults )WLANLDPCDecoderCore < matlab.System





%#codegen

properties ( Nontunable )
Standard = 'IEEE 802.11 n/ac/ax';
Termination = 'Max';
ScalingFactor = 1;
alphaWL = 6;
alphaFL = 0;
betaWL = 4;
minWL = 3;
betadecmpWL = 28;

ParityCheckStatus( 1, 1 )logical = false;
end 

properties ( Nontunable, Access = private )
scalarFlag;
memDepth;
memDepth1;
end 


properties ( Access = private )


variableNodeRAM;
checkMatrixLUT;
circularShifter;
functionalUnit;
checkNodeRAM;
finalDecision;
circularShifterOutput;


gammaOut;
gammaValid;
termPass;
gammaValidReg;
endInd;
validCount;
rdValid;
rdValidReg;
rdValidReg1;
betaDecomp1;
betaDecomp2
betaValid;
dataO;
finalShift;
iterDoneReg;


countLayer;
layerDone;
iterCount;
betaRead;
iterInd;
zCount;
wrAddr;
rdAddr;
rdAddrReg;
rdAddrFinal;
wrEnb;
wrData;
wrCount;
vldCount;
rdEnb;
finalEnb;
readValid;
rdCount;
wrLUTAddr;
rdLUTAddr1;
rdLUTAddr2;
noOp;
dataSel;
iterDone;
countIdx;
initCount;
maxCount;
colCount;
rdFinEnb;


startReg;
validReg;
smSize;
dataReg;
dataPad;
dataPad27;
dataPad54;
dataPad81;
dataPad42;
count;
validEnb;
countReg;
countReg1;
startOut;
endOut;
validOut;
dataOutG;
ocountIdx;
outCount;
outWrData;


fPChecks;
fPChecksD;
eColCount;
eLayCount;
eEnb;
eEnbDelay;
checkFailed;
eEnbLayer;
eEnbLayerD;
termPassD;


dataOut;
ctrlOut;
iterOut;
parCheck;


delayBalancer1;
delayBalancer2;
delayBalancer3;
delayBalancer4;
betaDelayBalancer1;
betaDelayBalancer2;
betaDelayBalancer3;

end 

properties ( Constant, Hidden )
StandardSet = matlab.system.StringSet( { 'IEEE 802.11 n/ac/ax', 'IEEE 802.11 ad' } );
TerminationSet = matlab.system.StringSet( { 'Max', 'Early' } );
end 

methods 

function obj = WLANLDPCDecoderCore( varargin )
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


reset( obj.variableNodeRAM );
reset( obj.checkMatrixLUT );
reset( obj.circularShifter );
reset( obj.functionalUnit );
reset( obj.checkNodeRAM );
reset( obj.finalDecision );
reset( obj.circularShifterOutput );

reset( obj.delayBalancer1 );
reset( obj.delayBalancer2 );
reset( obj.delayBalancer3 );
reset( obj.delayBalancer4 );
reset( obj.betaDelayBalancer1 );
reset( obj.betaDelayBalancer2 );
reset( obj.betaDelayBalancer3 );

if obj.scalarFlag
obj.dataOut( : ) = zeros( 1, 1 );
else 
obj.dataOut( : ) = zeros( 8, 1 );
end 

obj.ctrlOut( : ) = struct( 'start', false, 'end', false, 'valid', false );
obj.iterOut( : ) = uint8( 0 );
obj.parCheck( : ) = false;
end 

function setupImpl( obj, varargin )
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
obj.memDepth = 81;
else 
obj.memDepth = 42;
end 

if isscalar( varargin{ 2 } )
obj.scalarFlag = true;
else 
obj.scalarFlag = false;
end 

if obj.scalarFlag
obj.memDepth1 = obj.memDepth;
else 
obj.memDepth1 = obj.memDepth + 8;
end 



obj.variableNodeRAM = hdl.RAM( 'RAMType', 'Simple dual port' );


obj.checkMatrixLUT = commhdl.internal.WLANLDPCCheckMatrixLUT( 'Standard', obj.Standard, 'scalarFlag', obj.scalarFlag );


obj.circularShifter = commhdl.internal.WLANLDPCCyclicShifter( 'memDepth1', obj.memDepth1 );


obj.circularShifterOutput = commhdl.internal.WLANLDPCCyclicShifter( 'memDepth1', obj.memDepth1 );


obj.checkNodeRAM = commhdl.internal.WLANLDPCCheckNodeRAM( 'memDepth', obj.memDepth );


obj.functionalUnit = commhdl.internal.WLANLDPCFunctionalUnit(  ...
'ScalingFactor', obj.ScalingFactor, 'alphaWL', obj.alphaWL, 'alphaFL', obj.alphaFL,  ...
'betaWL', obj.betaWL, 'minWL', obj.minWL, 'betadecmpWL', obj.betadecmpWL, 'memDepth', obj.memDepth );


obj.finalDecision = commhdl.internal.WLANLDPCFinalDecision( 'Standard', obj.Standard, 'scalarFlag', obj.scalarFlag );


obj.gammaOut = cast( zeros( obj.memDepth1, 1 ), 'like', varargin{ 2 } );
obj.gammaValid = false;
obj.termPass = false;
obj.gammaValidReg = false;
obj.endInd = false;
obj.validCount = fi( 1, 0, 5, 0, hdlfimath );
obj.rdValid = false;
obj.rdValidReg = false;
obj.rdValidReg1 = false;
obj.betaDecomp1 = fi( zeros( obj.memDepth, 1 ), 0, obj.betadecmpWL, 0 );
obj.betaDecomp2 = fi( zeros( obj.memDepth, 1 ), 0, 2 * obj.minWL, 0 );
obj.betaValid = false;
obj.dataO = zeros( obj.memDepth1, 1 ) > 0;
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
obj.finalShift = fi( 1, 0, 7, 0, hdlfimath );
aWL = 11;sWL = 7;
else 
obj.finalShift = fi( 1, 0, 6, 0, hdlfimath );
aWL = 8;sWL = 6;
end 
obj.iterDoneReg = false;


obj.countLayer = fi( 1, 0, 4, 0, hdlfimath );
obj.layerDone = false;
obj.iterCount = fi( 0, 0, 8, 0, hdlfimath );
obj.betaRead = false;
obj.iterInd = false;
if obj.scalarFlag
obj.zCount = fi( 0, 0, sWL, 0, hdlfimath );
else 
obj.zCount = fi( 0, 0, 5, 0, hdlfimath );
end 
obj.wrAddr = fi( 0, 0, 5, 0, hdlfimath );
obj.rdAddr = fi( 0, 0, 5, 0, hdlfimath );
obj.rdAddrReg = fi( 0, 0, 5, 0, hdlfimath );
obj.rdAddrFinal = fi( 1, 0, 5, 0, hdlfimath );
obj.wrEnb = zeros( obj.memDepth1, 1 ) > 0;
obj.wrData = cast( zeros( obj.memDepth1, 1 ), 'like', varargin{ 2 } );
obj.wrCount = fi( 1, 0, 8, 0, hdlfimath );
obj.vldCount = fi( 1, 0, 5, 0, hdlfimath );
obj.rdEnb = false;
obj.finalEnb = false;
obj.readValid = false;
obj.rdCount = fi( 1, 0, 8, 0, hdlfimath );
obj.wrLUTAddr = fi( 0, 0, aWL, 0, hdlfimath );
obj.rdLUTAddr1 = fi( 0, 0, aWL, 0, hdlfimath );
obj.rdLUTAddr2 = fi( 0, 0, aWL, 0, hdlfimath );
obj.noOp = false;
obj.dataSel = false;
obj.iterDone = false;
obj.countIdx = fi( 1, 0, 5, 0 );
obj.initCount = fi( 1, 0, aWL, 0, hdlfimath );
obj.maxCount = fi( 12, 0, 5, 0 );
obj.colCount = fi( 1, 0, 8, 0 );
obj.rdFinEnb = false;


obj.fPChecks = zeros( obj.memDepth, 1 ) > 0;
obj.fPChecksD = zeros( obj.memDepth, 1 ) > 0;
obj.eColCount = fi( 0, 0, 5, 0, hdlfimath );
obj.eLayCount = fi( 0, 0, 4, 0, hdlfimath );
obj.eEnb = false;
obj.eEnbDelay = false;
obj.checkFailed = false;
obj.eEnbLayer = false;
obj.eEnbLayerD = false;
obj.termPassD = false;


obj.startReg = false;
obj.validReg = false;
obj.smSize = fi( 27, 0, sWL, 0 );
obj.dataReg = zeros( obj.memDepth, 1 ) > 0;
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
obj.dataPad = zeros( 1624, 1 ) > 0;
else 
obj.dataPad = zeros( 552, 1 ) > 0;
end 
obj.dataPad27 = zeros( 544, 1 ) > 0;
obj.dataPad54 = zeros( 1080, 1 ) > 0;
obj.dataPad81 = zeros( 1624, 1 ) > 0;
obj.dataPad42 = zeros( 552, 1 ) > 0;
obj.count = fi( 1, 0, 5, 0, hdlfimath );
obj.validEnb = false;
obj.countReg = fi( 0, 0, 11, 0, hdlfimath );
obj.countReg1 = fi( 0, 0, 11, 0, hdlfimath );
obj.startOut = false;
obj.endOut = false;
obj.validOut = false;

obj.ocountIdx = fi( 1, 0, sWL, 0, hdlfimath );
obj.outWrData = zeros( 1, 1 ) > 0;
obj.outCount = fi( 1, 0, 11, 0, hdlfimath );


if obj.scalarFlag
obj.dataOut = zeros( 1, 1 ) > 0;
obj.dataOutG = zeros( 1, 1 ) > 0;
else 
obj.dataOut = zeros( 8, 1 ) > 0;
obj.dataOutG = zeros( 8, 1 ) > 0;
end 
obj.ctrlOut = struct( 'start', false, 'end', false, 'valid', false );
obj.iterOut = uint8( 0 );
obj.parCheck = false;


obj.delayBalancer1 = dsp.Delay( obj.memDepth1 * 3 );
obj.delayBalancer2 = dsp.Delay( 3 );
obj.delayBalancer3 = dsp.Delay( 2 );
obj.delayBalancer4 = dsp.Delay( 5 );
obj.betaDelayBalancer1 = dsp.Delay( obj.memDepth * 2 );
obj.betaDelayBalancer2 = dsp.Delay( obj.memDepth * 2 );
obj.betaDelayBalancer3 = dsp.Delay( 2 );

end 

function varargout = outputImpl( obj, varargin )
varargout{ 1 } = obj.dataOut;
varargout{ 2 } = obj.ctrlOut;
if strcmpi( obj.Termination, 'Early' )
varargout{ 3 } = obj.iterOut;
varargout{ 4 } = obj.parCheck;
else 
varargout{ 3 } = obj.parCheck;
end 
end 

function updateImpl( obj, varargin )

reset = varargin{ 1 };
data = varargin{ 2 };
valid = varargin{ 3 };
framevalid = varargin{ 4 };
blocklen = varargin{ 5 };
coderate = varargin{ 6 };
endind = varargin{ 7 };
smdone = varargin{ 8 };
numiter = varargin{ 9 };

data_mc = obj.gammaOut;
valid_mc = obj.gammaValid;

if strcmpi( obj.Termination, 'Early' )
termpass = obj.termPass;
else 
termpass = false;
end 

datasel = ( ~framevalid );

layerdone = ( ~valid_mc ) && obj.gammaValidReg;
obj.gammaValidReg( : ) = obj.gammaValid;

softreset = endind && ( ~obj.endInd );
obj.endInd( : ) = endind;

if obj.scalarFlag
[ wr_data, wr_addr, wr_en, rd_addr, rd_valid, layeridx, countidx, iterind,  ...
validcount, iterdone, betaread, iterout, smsize ] = iterationControllerSerial( obj, data, valid,  ...
datasel, reset, blocklen, coderate, layerdone, softreset, numiter, termpass, data_mc, valid_mc );
else 
[ wr_data, wr_addr, wr_en, rd_addr, rd_valid, layeridx, countidx, iterind,  ...
validcount, iterdone, betaread, iterout, smsize ] = iterationControllerVector( obj, data, valid,  ...
datasel, reset, blocklen, coderate, smdone, layerdone, softreset, numiter, termpass, data_mc, valid_mc );
end 

int_reset = softreset || reset;

wr_addrD = wr_addr * uint8( ones( obj.memDepth1, 1 ) );
rd_addrD = rd_addr * uint8( ones( obj.memDepth1, 1 ) );


coldata = obj.variableNodeRAM( wr_data, wr_addrD, wr_en, rd_addrD );


[ shift, offset, finalshift ] = obj.checkMatrixLUT( blocklen, coderate, layeridx, iterind, obj.validCount );
obj.validCount( : ) = validcount;


[ shiftdata, shiftvalid ] = obj.circularShifter( coldata, smsize, shift, offset, obj.rdValid );


betaenb = ( obj.rdValidReg && ( ~obj.rdValidReg1 ) ) && betaread;
obj.rdValidReg1( : ) = obj.rdValidReg;
obj.rdValidReg( : ) = obj.rdValid;
obj.rdValid( : ) = rd_valid;


betain1 = obj.betaDecomp1;
betain2 = obj.betaDecomp2;
wrenb = obj.betaValid;
[ cnudecomp1, cnudecomp2, cnuvalid ] = obj.checkNodeRAM( betain1, betain2, layeridx, betaenb, wrenb );


[ gamma, gammavalid, betadecomp1, betadecomp2, betavalid ] = obj.functionalUnit( shiftdata( 1:obj.memDepth ),  ...
shiftvalid, countidx, cnudecomp1, cnudecomp2, cnuvalid, int_reset );



if strcmpi( obj.Termination, 'Early' ) || obj.ParityCheckStatus
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
numRowsLUT = fi( [ 12, 8, 6, 4 ], 0, 4, 0 );
numrows = numRowsLUT( fi( coderate + 1, 0, 3, 0 ) );
else 
numRowsLUT = fi( [ 8, 6, 4, 3 ], 0, 4, 0 );
numrows = numRowsLUT( fi( coderate + 1, 0, 3, 0 ) );
end 
obj.termPass( : ) = earlyTermination( obj, int_reset, obj.gammaOut( 1:obj.memDepth ), obj.gammaValid, smsize, countidx, numrows );
end 

obj.betaDecomp1( : ) = obj.betaDelayBalancer1( betadecomp1 );
obj.betaDecomp2( : ) = obj.betaDelayBalancer2( betadecomp2 );
obj.betaValid( : ) = obj.betaDelayBalancer3( betavalid );

obj.gammaOut( : ) = obj.delayBalancer1( [ gamma;zeros( obj.memDepth1 - obj.memDepth, 1 ) ] );
obj.gammaValid( : ) = obj.delayBalancer2( gammavalid );


[ datao, starto, valido, finshift ] = obj.finalDecision( coldata( 1:obj.memDepth ), iterdone, smsize, coderate, finalshift, int_reset );
obj.iterDoneReg( : ) = iterdone;

if obj.scalarFlag
obj.dataO( : ) = datao;
[ fdata, fvalid ] = obj.circularShifterOutput( obj.dataO, smsize, finshift, fi( 0, 0, 3, 0 ), valido );
else 
obj.dataO( : ) = [ datao;zeros( 8, 1 ) ];
[ fdata, fvalid ] = obj.circularShifterOutput( obj.dataO, smsize, obj.finalShift, fi( 0, 0, 3, 0 ), valido );
end 
obj.finalShift( : ) = finshift;
start_reg = obj.delayBalancer3( starto );
termpass_reg = obj.delayBalancer4( obj.termPass );


if obj.scalarFlag
[ data_out, start_out, end_out, valid_out ] = outputGenerationSerial( obj, fdata( 1:obj.memDepth ), start_reg, fvalid, blocklen, coderate, int_reset );
else 
[ data_out, start_out, end_out, valid_out ] = outputGenerationVector( obj, fdata( 1:obj.memDepth ), start_reg, fvalid, blocklen, coderate, int_reset );
end 

obj.ctrlOut.start( : ) = start_out;
obj.ctrlOut.end( : ) = end_out;
obj.ctrlOut.valid( : ) = valid_out;

if valid_out
obj.iterOut( : ) = iterout;
obj.dataOut( : ) = data_out;
obj.parCheck( : ) = termpass_reg;
else 
if obj.scalarFlag
obj.dataOut( : ) = 0;
else 
obj.dataOut( : ) = zeros( 8, 1 );
end 
obj.iterOut( : ) = 0;
obj.parCheck( : ) = false;
end 
end 

function [ wr_data, wr_addr, wr_en, rd_addr, rd_valid, layeridx,  ...
count, iterind, validcount, iterdone, betaread, iterout, submatrixsize ] = iterationControllerSerial( obj, data,  ...
valid, framevalid, reset, blklen, rate, layerdone, softreset, numiter, termpass, datamc, validmc )


addrLUT11ac = fi( [ 1;5;6;9;12;13;14;1;2;5;7;8;9;14;15;1;3;5;9;
11;15;16;1;4;5;9;10;16;17;1;5;9;11;12;17;18;1;3;
4;5;7;9;18;19;1;5;9;10;13;19;20;1;2;5;7;9;20;
21;1;2;4;5;6;9;21;22;1;5;9;11;12;22;23;1;3;5;
6;8;9;23;24;1;5;8;9;10;13;24;1;2;3;5;7;9;12;
14;16;17;18;1;2;3;4;6;8;11;13;15;18;19;1;2;3;4;
5;7;9;10;12;19;20;1;2;3;4;6;8;11;14;16;20;21;1;
2;3;5;7;9;13;15;17;21;22;1;2;3;4;6;8;10;12;14;
22;23;1;2;3;4;5;7;9;11;16;23;24;1;2;3;4;6;8;
10;13;15;17;24;1;2;3;4;5;6;7;9;10;11;13;15;17;19;
20;1;2;3;4;5;6;7;8;10;11;13;15;18;20;21;1;2;3;
4;5;6;7;9;11;13;15;16;17;21;22;1;2;3;4;5;8;9;
11;12;14;17;19;22;23;1;2;3;4;5;8;9;10;12;14;16;18;
23;24;1;2;3;4;5;6;7;8;10;12;14;16;18;19;24;1;2;
3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;
22;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;
19;20;22;23;1;2;3;4;5;6;7;8;9;10;11;12;14;15;16;
17;18;19;20;21;23;24;1;2;3;4;5;6;7;8;9;10;11;12;
13;14;15;16;17;18;19;20;21;24;1;5;7;8;9;13;14;1;2;
5;6;9;11;14;15;1;2;5;7;12;15;16;1;4;5;8;9;16;
17;1;5;6;9;10;17;18;1;4;5;9;11;18;19;1;2;6;9;
13;19;20;1;3;5;7;9;10;20;21;1;4;5;9;12;21;22;1;
3;5;9;11;22;23;2;5;8;9;10;23;24;1;3;5;9;12;13;
24;1;2;3;4;6;7;9;12;16;17;18;1;2;3;4;5;7;9;
13;15;18;19;1;2;3;4;5;7;10;13;15;19;20;1;2;3;5;
6;8;11;14;15;20;21;1;2;3;4;5;6;10;13;17;21;22;1;
2;3;4;5;8;11;12;14;22;23;1;2;3;4;5;8;11;14;16;
23;24;1;2;3;4;5;9;10;12;16;17;24;1;2;3;4;5;6;
7;8;10;12;14;16;18;19;20;1;2;3;4;5;6;7;9;11;13;
15;17;20;21;1;2;3;4;5;6;7;8;10;12;14;16;18;21;22;
1;2;3;4;5;6;7;9;11;13;15;17;19;22;23;1;2;3;4;
5;6;7;8;10;12;14;16;18;23;24;1;2;3;4;5;6;7;9;
11;13;15;17;19;24;1;2;3;4;5;6;7;8;9;10;11;12;13;
14;15;16;17;19;20;21;22;1;2;3;4;5;6;7;8;9;10;11;
12;13;14;15;16;17;18;19;22;23;1;2;3;4;5;6;7;8;9;
10;11;12;13;14;15;16;18;19;20;21;23;24;1;2;3;4;5;6;
7;8;9;10;11;12;13;14;15;16;17;18;20;21;24;1;5;7;9;
11;13;14;1;3;5;9;10;14;15;1;5;6;9;10;15;16;1;2;
5;8;9;16;17;1;4;5;8;9;17;18;1;5;7;9;12;18;19;
1;2;3;7;9;13;19;20;1;5;6;9;11;20;21;1;5;6;9;
12;21;22;2;4;5;9;10;22;23;1;2;4;5;11;23;24;1;3;
5;8;9;12;13;24;1;2;3;4;5;12;14;15;16;17;18;1;2;
3;4;8;9;10;11;13;18;19;1;2;3;4;5;6;7;11;15;19;
20;1;2;3;4;5;10;11;13;14;20;21;1;2;3;4;6;7;9;
12;17;21;22;1;2;3;4;5;7;13;14;15;22;23;1;2;3;4;
5;6;8;12;16;23;24;1;2;3;4;5;8;9;10;16;17;24;1;
2;3;4;5;6;10;11;12;16;17;18;19;20;1;2;3;4;5;6;
10;11;12;13;14;16;20;21;1;2;3;4;5;6;7;9;10;14;15;
18;21;22;1;2;3;4;5;6;7;8;9;13;17;18;19;22;23;1;
2;3;4;5;6;8;9;11;13;15;17;23;24;1;2;3;4;5;6;
7;8;12;14;15;16;19;24;1;2;3;4;5;6;7;8;9;10;11;
12;14;15;16;17;18;19;21;22;1;2;3;4;5;6;7;8;9;10;
11;13;15;16;17;18;19;20;22;23;1;2;3;4;5;6;7;8;9;
10;11;12;13;14;16;18;20;21;23;24;1;2;3;4;5;6;7;8;
9;10;12;13;14;15;17;19;20;21;24;1 ], 0, 5, 0 );

initCountLUT11ac = fi( [ 1;89;177;265;353;439;527;615;700;786;874;959 ] - 1, 0, 11, 0 );

nonCount11ac = fi( [ 6;7;6;6;6;7;6;6;7;6;7;6;0;0;0;0;10;10;10;
10;10;10;10;10;0;0;0;0;0;0;0;0;14;14;14;13;13;14;
0;0;0;0;0;0;0;0;0;0;21;21;21;21;0;0;0;0;0;
0;0;0;0;0;0;0;6;7;6;6;6;6;6;7;6;6;6;6;
0;0;0;0;10;10;10;10;10;10;10;10;0;0;0;0;0;0;0;
0;14;13;14;14;14;13;0;0;0;0;0;0;0;0;0;0;20;20;
21;20;0;0;0;0;0;0;0;0;0;0;0;0;6;6;6;6;6;
6;7;6;6;6;6;7;0;0;0;0;10;10;10;10;10;10;10;10;
0;0;0;0;0;0;0;0;13;13;13;14;13;13;0;0;0;0;0;
0;0;0;0;0;19;19;19;18;0;0;0;0;0;0;0;0;0;0;
0;0; ], 0, 5, 0 );


addrLUT11ad = fi( [ 1;3;5;7;9;1;3;5;8;9;10;2;4;6;8;10;11;2;4;
6;7;11;12;1;3;5;7;9;12;13;1;3;6;8;10;12;14;2;
4;6;8;11;14;15;2;4;5;7;9;13;15;16;1;2;3;4;5;
6;7;8;10;11;1;2;4;6;7;8;9;10;11;12;1;3;5;7;
9;12;13;1;3;6;8;10;12;13;14;2;4;6;8;10;11;14;15;
2;4;5;7;9;15;16;1;2;3;4;5;6;7;8;9;10;11;12;
13;1;2;3;4;5;6;7;8;9;10;11;12;13;14;1;2;3;4;
5;6;7;8;9;10;11;12;14;15;1;2;3;4;5;6;7;8;9;
11;12;13;14;15;16;1;2;3;4;5;6;7;8;9;10;11;12;13;
14;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;1;2;3;
4;5;6;7;8;9;10;11;12;13;14;15;16;1; ], 0, 5, 0 );

initCountLUT11ad = fi( [ 1;53;103;159 ] - 1, 0, 8, 0 );

nonCount11ad = fi( [ 4;5;5;5;6;6;6;7;zeros( 8, 1 );9;9;6;7;7;6;0;0;zeros( 8, 1 );12;13;13;
14;0;0;0;0;zeros( 8, 1 );13;14;15;0;0;0;0;0;zeros( 8, 1 ); ], 0, 5, 0 );

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
numRows = fi( [ 12, 8, 6, 4 ], 0, 4, 0 );
maxCol = fi( [ 12, 16, 18, 20 ], 0, 5, 0 );
smSizeLUT = fi( [ 27, 54, 81 ], 0, 7, 0 );
AddrLUT = addrLUT11ac;
else 
numRows = fi( [ 8, 6, 4, 3 ], 0, 4, 0 );
maxCol = fi( [ 8, 10, 12, 13 ], 0, 5, 0 );
smSizeLUT = fi( 42, 0, 6, 0 );
AddrLUT = addrLUT11ad;
end 


layeridx = obj.countLayer;
betaread = obj.betaRead;
iterind = obj.iterInd;
wr_data = cast( obj.wrData, 'like', obj.wrData );
wr_en = obj.wrEnb;
wr_addr = obj.wrAddr;
iterdone = obj.iterDone;
count = obj.countIdx;

if obj.dataSel
if obj.iterDone
rd_addr = obj.rdAddrFinal;
else 
if obj.iterInd
rd_addr = obj.rdAddrReg;
else 
rd_addr = obj.rdAddr;
end 
end 
else 
rd_addr = cast( 1, 'like', obj.rdAddr );
end 

validcount = cast( obj.vldCount + 1, 'like', obj.vldCount );
obj.maxCount( : ) = maxCol( rate + 1 );


if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
x = 7;
obj.countIdx( : ) = nonCount11ac( fi( bitconcat( blklen, rate, obj.countLayer ), 0, 8, 0 ) );
submatrixsize = smSizeLUT( blklen + 1 );
obj.initCount( : ) = initCountLUT11ac( fi( bitconcat( blklen, rate ) + 1, 0, 4, 0 ) );
else 
x = 6;
obj.countIdx( : ) = nonCount11ad( fi( bitconcat( rate, obj.countLayer ), 0, 6, 0 ) );
submatrixsize = smSizeLUT;
obj.initCount( : ) = initCountLUT11ad( rate + 1 );
end 

obj.layerDone( : ) = layerdone;

if strcmpi( obj.Termination, 'Early' )
if termpass
iterout = uint8( obj.iterCount );
else 
iterout = uint8( numiter );
end 
else 
iterout = uint8( numiter );
end 

if reset
obj.noOp( : ) = true;
elseif softreset
obj.noOp( : ) = false;
end 


if obj.noOp
obj.dataSel( : ) = logical( false );
else 
obj.dataSel( : ) = logical( ( framevalid ) );
end 

nrow = numRows( rate + 1 );


if reset
obj.iterDone( : ) = false;
obj.countLayer( : ) = 1;
obj.iterCount( : ) = 0;
obj.betaRead( : ) = false;
resetcount = true;
else 
if ( obj.iterCount == fi( numiter, 0, 8, 0 ) || termpass )
obj.iterDone( : ) = true;
resetcount = true;
else 
obj.iterDone( : ) = false;
if obj.layerDone && obj.dataSel
if obj.countLayer == nrow
obj.betaRead( : ) = true;
obj.iterCount( : ) = obj.iterCount + 1;
obj.countLayer( : ) = 1;
resetcount = true;
else 
obj.countLayer( : ) = obj.countLayer + 1;
resetcount = false;
end 
else 
resetcount = false;
end 
end 
end 

if obj.iterCount == fi( 0, 0, 6, 0, hdlfimath )
obj.iterInd( : ) = false;
else 
obj.iterInd( : ) = true;
end 


if reset
obj.wrAddr( : ) = 1;
obj.wrEnb( : ) = ones( obj.memDepth1, 1 );
obj.wrData( : ) = zeros( obj.memDepth1, 1 );
obj.wrCount( : ) = 1;
obj.zCount( : ) = 0;
obj.vldCount( : ) = 0;
obj.rdEnb( : ) = false;
obj.readValid( : ) = false;
obj.rdAddrFinal( : ) = 1;
obj.rdAddr( : ) = 0;
obj.rdAddrReg( : ) = 0;
obj.rdCount( : ) = 1;
obj.finalEnb( : ) = false;
obj.wrLUTAddr( : ) = 0;
obj.rdLUTAddr1( : ) = 0;
obj.rdLUTAddr2( : ) = 0;
obj.countIdx( : ) = 1;
obj.initCount( : ) = 1;
obj.maxCount( : ) = 12;
obj.colCount( : ) = 1;
else 
if ~obj.dataSel
if valid
for idx = 1:obj.memDepth
if obj.colCount == fi( idx, 0, x, 0 )
obj.wrEnb( idx ) = true;
obj.wrData( idx ) = data;
else 
obj.wrEnb( idx ) = false;
obj.wrData( idx ) = 0;
end 
end 
obj.wrAddr( : ) = obj.wrCount;
if obj.colCount == submatrixsize
obj.colCount( : ) = 1;
obj.wrCount( : ) = obj.wrCount + 1;
else 
obj.colCount( : ) = obj.colCount + 1;
end 
end 
else 
if validmc
obj.wrData( : ) = datamc;
obj.wrEnb( : ) = ones( obj.memDepth1, 1 ) > 0;
obj.wrLUTAddr( : ) = obj.initCount + obj.colCount;
obj.wrAddr( : ) = AddrLUT( obj.wrLUTAddr );
else 
obj.wrEnb( : ) = zeros( obj.memDepth1, 1 ) > 0;
end 

if resetcount
obj.colCount( : ) = 1;
elseif validmc
obj.colCount( : ) = obj.colCount + 1;
end 
end 
end 










trigger = softreset || obj.layerDone;

if trigger && ~obj.iterDone && obj.dataSel
obj.rdEnb( : ) = true;
else 
if obj.iterDone
obj.rdEnb( : ) = false;
end 
end 

if obj.dataSel
rd_valid = obj.readValid;
else 
rd_valid = false;
end 

obj.readValid( : ) = obj.rdEnb;

if obj.rdEnb && obj.dataSel
if obj.vldCount == obj.countIdx
obj.vldCount( : ) = 0;
obj.rdEnb( : ) = false;
else 
obj.vldCount( : ) = obj.vldCount + 1;
end 
else 
obj.vldCount( : ) = 0;
end 

obj.rdLUTAddr1( : ) = obj.initCount + obj.rdCount;

obj.rdAddr( : ) = AddrLUT( obj.rdLUTAddr1 );

if obj.dataSel
if resetcount
obj.rdCount( : ) = 1;
else 
if obj.readValid
obj.rdCount( : ) = obj.rdCount + 1;
end 
end 
else 
obj.rdCount( : ) = 1;
end 

obj.rdLUTAddr2( : ) = obj.initCount + obj.rdCount;

obj.rdAddrReg( : ) = AddrLUT( obj.rdLUTAddr2 );

if obj.iterDone
obj.finalEnb( : ) = true;
end 

if obj.zCount == submatrixsize - 1
obj.zCount( : ) = 0;
obj.rdFinEnb( : ) = true;
else 
if obj.finalEnb
obj.zCount( : ) = obj.zCount + 1;
end 
obj.rdFinEnb( : ) = false;
end 

if obj.finalEnb
if obj.rdAddrFinal == obj.maxCount
obj.finalEnb( : ) = false;
else 
if obj.rdFinEnb
obj.rdAddrFinal( : ) = obj.rdAddrFinal + 1;
end 
end 
else 
obj.rdAddrFinal( : ) = 1;
end 

end 

function [ wr_data, wr_addr, wr_en, rd_addr, rd_valid, layeridx,  ...
count, iterind, validcount, iterdone, betaread, iterout, submatrixsize ] = iterationControllerVector( obj, data,  ...
valid, framevalid, reset, blklen, rate, smdone, layerdone, softreset, numiter, termpass, datamc, validmc )


addrLUT11ac = fi( [ 1;5;6;9;12;13;14;1;2;5;7;8;9;14;15;1;3;5;9;
11;15;16;1;4;5;9;10;16;17;1;5;9;11;12;17;18;1;3;
4;5;7;9;18;19;1;5;9;10;13;19;20;1;2;5;7;9;20;
21;1;2;4;5;6;9;21;22;1;5;9;11;12;22;23;1;3;5;
6;8;9;23;24;1;5;8;9;10;13;24;1;2;3;5;7;9;12;
14;16;17;18;1;2;3;4;6;8;11;13;15;18;19;1;2;3;4;
5;7;9;10;12;19;20;1;2;3;4;6;8;11;14;16;20;21;1;
2;3;5;7;9;13;15;17;21;22;1;2;3;4;6;8;10;12;14;
22;23;1;2;3;4;5;7;9;11;16;23;24;1;2;3;4;6;8;
10;13;15;17;24;1;2;3;4;5;6;7;9;10;11;13;15;17;19;
20;1;2;3;4;5;6;7;8;10;11;13;15;18;20;21;1;2;3;
4;5;6;7;9;11;13;15;16;17;21;22;1;2;3;4;5;8;9;
11;12;14;17;19;22;23;1;2;3;4;5;8;9;10;12;14;16;18;
23;24;1;2;3;4;5;6;7;8;10;12;14;16;18;19;24;1;2;
3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;
22;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;
19;20;22;23;1;2;3;4;5;6;7;8;9;10;11;12;14;15;16;
17;18;19;20;21;23;24;1;2;3;4;5;6;7;8;9;10;11;12;
13;14;15;16;17;18;19;20;21;24;1;5;7;8;9;13;14;1;2;
5;6;9;11;14;15;1;2;5;7;12;15;16;1;4;5;8;9;16;
17;1;5;6;9;10;17;18;1;4;5;9;11;18;19;1;2;6;9;
13;19;20;1;3;5;7;9;10;20;21;1;4;5;9;12;21;22;1;
3;5;9;11;22;23;2;5;8;9;10;23;24;1;3;5;9;12;13;
24;1;2;3;4;6;7;9;12;16;17;18;1;2;3;4;5;7;9;
13;15;18;19;1;2;3;4;5;7;10;13;15;19;20;1;2;3;5;
6;8;11;14;15;20;21;1;2;3;4;5;6;10;13;17;21;22;1;
2;3;4;5;8;11;12;14;22;23;1;2;3;4;5;8;11;14;16;
23;24;1;2;3;4;5;9;10;12;16;17;24;1;2;3;4;5;6;
7;8;10;12;14;16;18;19;20;1;2;3;4;5;6;7;9;11;13;
15;17;20;21;1;2;3;4;5;6;7;8;10;12;14;16;18;21;22;
1;2;3;4;5;6;7;9;11;13;15;17;19;22;23;1;2;3;4;
5;6;7;8;10;12;14;16;18;23;24;1;2;3;4;5;6;7;9;
11;13;15;17;19;24;1;2;3;4;5;6;7;8;9;10;11;12;13;
14;15;16;17;19;20;21;22;1;2;3;4;5;6;7;8;9;10;11;
12;13;14;15;16;17;18;19;22;23;1;2;3;4;5;6;7;8;9;
10;11;12;13;14;15;16;18;19;20;21;23;24;1;2;3;4;5;6;
7;8;9;10;11;12;13;14;15;16;17;18;20;21;24;1;5;7;9;
11;13;14;1;3;5;9;10;14;15;1;5;6;9;10;15;16;1;2;
5;8;9;16;17;1;4;5;8;9;17;18;1;5;7;9;12;18;19;
1;2;3;7;9;13;19;20;1;5;6;9;11;20;21;1;5;6;9;
12;21;22;2;4;5;9;10;22;23;1;2;4;5;11;23;24;1;3;
5;8;9;12;13;24;1;2;3;4;5;12;14;15;16;17;18;1;2;
3;4;8;9;10;11;13;18;19;1;2;3;4;5;6;7;11;15;19;
20;1;2;3;4;5;10;11;13;14;20;21;1;2;3;4;6;7;9;
12;17;21;22;1;2;3;4;5;7;13;14;15;22;23;1;2;3;4;
5;6;8;12;16;23;24;1;2;3;4;5;8;9;10;16;17;24;1;
2;3;4;5;6;10;11;12;16;17;18;19;20;1;2;3;4;5;6;
10;11;12;13;14;16;20;21;1;2;3;4;5;6;7;9;10;14;15;
18;21;22;1;2;3;4;5;6;7;8;9;13;17;18;19;22;23;1;
2;3;4;5;6;8;9;11;13;15;17;23;24;1;2;3;4;5;6;
7;8;12;14;15;16;19;24;1;2;3;4;5;6;7;8;9;10;11;
12;14;15;16;17;18;19;21;22;1;2;3;4;5;6;7;8;9;10;
11;13;15;16;17;18;19;20;22;23;1;2;3;4;5;6;7;8;9;
10;11;12;13;14;16;18;20;21;23;24;1;2;3;4;5;6;7;8;
9;10;12;13;14;15;17;19;20;21;24;1 ], 0, 5, 0 );

initCountLUT11ac = fi( [ 1;89;177;265;353;439;527;615;700;786;874;959 ] - 1, 0, 11, 0 );

nonCount11ac = fi( [ 6;7;6;6;6;7;6;6;7;6;7;6;0;0;0;0;10;10;10;
10;10;10;10;10;0;0;0;0;0;0;0;0;14;14;14;13;13;14;
0;0;0;0;0;0;0;0;0;0;21;21;21;21;0;0;0;0;0;
0;0;0;0;0;0;0;6;7;6;6;6;6;6;7;6;6;6;6;
0;0;0;0;10;10;10;10;10;10;10;10;0;0;0;0;0;0;0;
0;14;13;14;14;14;13;0;0;0;0;0;0;0;0;0;0;20;20;
21;20;0;0;0;0;0;0;0;0;0;0;0;0;6;6;6;6;6;
6;7;6;6;6;6;7;0;0;0;0;10;10;10;10;10;10;10;10;
0;0;0;0;0;0;0;0;13;13;13;14;13;13;0;0;0;0;0;
0;0;0;0;0;19;19;19;18;0;0;0;0;0;0;0;0;0;0;
0;0; ], 0, 5, 0 );


addrLUT11ad = fi( [ 1;3;5;7;9;1;3;5;8;9;10;2;4;6;8;10;11;2;4;
6;7;11;12;1;3;5;7;9;12;13;1;3;6;8;10;12;14;2;
4;6;8;11;14;15;2;4;5;7;9;13;15;16;1;2;3;4;5;
6;7;8;10;11;1;2;4;6;7;8;9;10;11;12;1;3;5;7;
9;12;13;1;3;6;8;10;12;13;14;2;4;6;8;10;11;14;15;
2;4;5;7;9;15;16;1;2;3;4;5;6;7;8;9;10;11;12;
13;1;2;3;4;5;6;7;8;9;10;11;12;13;14;1;2;3;4;
5;6;7;8;9;10;11;12;14;15;1;2;3;4;5;6;7;8;9;
11;12;13;14;15;16;1;2;3;4;5;6;7;8;9;10;11;12;13;
14;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;1;2;3;
4;5;6;7;8;9;10;11;12;13;14;15;16;1; ], 0, 5, 0 );

initCountLUT11ad = fi( [ 1;53;103;159 ] - 1, 0, 8, 0 );

nonCount11ad = fi( [ 4;5;5;5;6;6;6;7;zeros( 8, 1 );9;9;6;7;7;6;0;0;zeros( 8, 1 );12;13;13;
14;0;0;0;0;zeros( 8, 1 );13;14;15;0;0;0;0;0;zeros( 8, 1 ); ], 0, 5, 0 );

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
numRows = fi( [ 12, 8, 6, 4 ], 0, 4, 0 );
maxCol = fi( [ 12, 16, 18, 20 ], 0, 5, 0 );
smSizeLUT = fi( [ 27, 54, 81 ], 0, 7, 0 );
AddrLUT = addrLUT11ac;
else 
numRows = fi( [ 8, 6, 4, 3 ], 0, 4, 0 );
maxCol = fi( [ 8, 10, 12, 13 ], 0, 5, 0 );
smSizeLUT = fi( 42, 0, 6, 0 );
AddrLUT = addrLUT11ad;
end 


layeridx = obj.countLayer;
betaread = obj.betaRead;
iterind = obj.iterInd;
wr_data = cast( obj.wrData, 'like', obj.wrData );
wr_en = obj.wrEnb;
wr_addr = obj.wrAddr;
iterdone = obj.iterDone;
count = obj.countIdx;

if obj.dataSel
if obj.iterDone
rd_addr = obj.rdAddrFinal;
else 
if obj.iterInd
rd_addr = obj.rdAddrReg;
else 
rd_addr = obj.rdAddr;
end 
end 
else 
rd_addr = cast( 1, 'like', obj.rdAddr );
end 

validcount = cast( obj.vldCount + 1, 'like', obj.vldCount );
obj.maxCount( : ) = maxCol( rate + 1 );


if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
obj.countIdx( : ) = nonCount11ac( fi( bitconcat( blklen, rate, obj.countLayer ), 0, 8, 0 ) );
submatrixsize = smSizeLUT( blklen + 1 );
obj.initCount( : ) = initCountLUT11ac( fi( bitconcat( blklen, rate ) + 1, 0, 4, 0 ) );
else 
obj.countIdx( : ) = nonCount11ad( fi( bitconcat( rate, obj.countLayer ), 0, 6, 0 ) );
submatrixsize = smSizeLUT;
obj.initCount( : ) = initCountLUT11ad( rate + 1 );
end 

obj.layerDone( : ) = layerdone;

if strcmpi( obj.Termination, 'Early' )
if termpass
iterout = uint8( obj.iterCount );
else 
iterout = uint8( numiter );
end 
else 
iterout = uint8( numiter );
end 

if reset
obj.noOp( : ) = true;
elseif softreset
obj.noOp( : ) = false;
end 


if obj.noOp
obj.dataSel( : ) = logical( false );
else 
obj.dataSel( : ) = logical( ( framevalid ) );
end 

nrow = numRows( rate + 1 );


if reset
obj.iterDone( : ) = false;
obj.countLayer( : ) = 1;
obj.iterCount( : ) = 0;
obj.betaRead( : ) = false;
resetcount = true;
else 
if ( obj.iterCount == fi( numiter, 0, 8, 0 ) || termpass )
obj.iterDone( : ) = true;
resetcount = true;
else 
obj.iterDone( : ) = false;
if obj.layerDone && obj.dataSel
if obj.countLayer == nrow
obj.betaRead( : ) = true;
obj.iterCount( : ) = obj.iterCount + 1;
obj.countLayer( : ) = 1;
resetcount = true;
else 
obj.countLayer( : ) = obj.countLayer + 1;
resetcount = false;
end 
else 
resetcount = false;
end 
end 
end 

if obj.iterCount == fi( 0, 0, 6, 0, hdlfimath )
obj.iterInd( : ) = false;
else 
obj.iterInd( : ) = true;
end 


if reset
obj.wrAddr( : ) = 1;
obj.wrEnb( : ) = ones( obj.memDepth1, 1 );
obj.wrData( : ) = zeros( obj.memDepth1, 1 );
obj.wrCount( : ) = 1;
obj.zCount( : ) = 0;
obj.vldCount( : ) = 0;
obj.rdEnb( : ) = false;
obj.readValid( : ) = false;
obj.rdAddrFinal( : ) = 1;
obj.rdAddr( : ) = 0;
obj.rdAddrReg( : ) = 0;
obj.rdCount( : ) = 1;
obj.finalEnb( : ) = false;
obj.wrLUTAddr( : ) = 0;
obj.rdLUTAddr1( : ) = 0;
obj.rdLUTAddr2( : ) = 0;
obj.countIdx( : ) = 1;
obj.initCount( : ) = 1;
obj.maxCount( : ) = 12;
obj.colCount( : ) = 1;
else 
if ~obj.dataSel
obj.wrCount( : ) = 1;
if valid
if smdone
obj.zCount( : ) = 1;
obj.wrAddr( : ) = obj.wrAddr + 1;
else 
obj.zCount( : ) = obj.zCount + 1;
end 

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
if obj.zCount == fi( 1, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ ones( 8, 1 );zeros( 81, 1 ) ] > 0;
obj.wrData( : ) = [ data;zeros( 81, 1 ) ];
elseif obj.zCount == fi( 2, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 8, 1 );ones( 8, 1 );zeros( 73, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 8, 1 );data;zeros( 73, 1 ) ];
elseif obj.zCount == fi( 3, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 16, 1 );ones( 8, 1 );zeros( 65, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 16, 1 );data;zeros( 65, 1 ) ];
elseif obj.zCount == fi( 4, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 24, 1 );ones( 8, 1 );zeros( 57, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 24, 1 );data;zeros( 57, 1 ) ];
elseif obj.zCount == fi( 5, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 32, 1 );ones( 8, 1 );zeros( 49, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 32, 1 );data;zeros( 49, 1 ) ];
elseif obj.zCount == fi( 6, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 40, 1 );ones( 8, 1 );zeros( 41, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 40, 1 );data;zeros( 41, 1 ) ];
elseif obj.zCount == fi( 7, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 48, 1 );ones( 8, 1 );zeros( 33, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 48, 1 );data;zeros( 33, 1 ) ];
elseif obj.zCount == fi( 8, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 56, 1 );ones( 8, 1 );zeros( 25, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 56, 1 );data;zeros( 25, 1 ) ];
elseif obj.zCount == fi( 9, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 64, 1 );ones( 8, 1 );zeros( 17, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 64, 1 );data;zeros( 17, 1 ) ];
elseif obj.zCount == fi( 10, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 72, 1 );ones( 8, 1 );zeros( 9, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 72, 1 );data;zeros( 9, 1 ) ];
elseif obj.zCount == fi( 11, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 80, 1 );ones( 8, 1 );zeros( 1, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 80, 1 );data;zeros( 1, 1 ) ];
elseif obj.zCount == fi( 12, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 88, 1 );ones( 1, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 88, 1 );data( 1 ); ];
else 
obj.wrEnb( : ) = zeros( obj.memDepth1, 1 ) > 0;
obj.wrData( : ) = zeros( obj.memDepth1, 1 );
end 
else 
if obj.zCount == fi( 1, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ ones( 8, 1 );zeros( 42, 1 ) ] > 0;
obj.wrData( : ) = [ data;zeros( 42, 1 ) ];
elseif obj.zCount == fi( 2, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 8, 1 );ones( 8, 1 );zeros( 34, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 8, 1 );data;zeros( 34, 1 ) ];
elseif obj.zCount == fi( 3, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 16, 1 );ones( 8, 1 );zeros( 26, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 16, 1 );data;zeros( 26, 1 ) ];
elseif obj.zCount == fi( 4, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 24, 1 );ones( 8, 1 );zeros( 18, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 24, 1 );data;zeros( 18, 1 ) ];
elseif obj.zCount == fi( 5, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 32, 1 );ones( 8, 1 );zeros( 10, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 32, 1 );data;zeros( 10, 1 ) ];
elseif obj.zCount == fi( 6, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 40, 1 );ones( 8, 1 );zeros( 2, 1 ) ] > 0;
obj.wrData( : ) = [ zeros( 40, 1 );data;zeros( 2, 1 ) ];
elseif obj.zCount == fi( 7, 0, 4, 0, hdlfimath )
obj.wrEnb( : ) = [ zeros( 48, 1 );ones( 2, 1 ); ] > 0;
obj.wrData( : ) = [ zeros( 48, 1 );data( 1 );data( 2 ); ];
else 
obj.wrEnb( : ) = zeros( obj.memDepth1, 1 ) > 0;
obj.wrData( : ) = zeros( obj.memDepth1, 1 );
end 
end 
end 
else 
if validmc
obj.wrData( : ) = datamc;
obj.wrEnb( : ) = ones( obj.memDepth1, 1 ) > 0;
obj.wrLUTAddr( : ) = obj.initCount + obj.wrCount;
obj.wrAddr( : ) = AddrLUT( obj.wrLUTAddr );
else 
obj.wrEnb( : ) = zeros( obj.memDepth1, 1 ) > 0;
end 

if resetcount
obj.wrCount( : ) = 1;
elseif validmc
obj.wrCount( : ) = obj.wrCount + 1;
end 
end 
end 










trigger = softreset || obj.layerDone;

if trigger && ~obj.iterDone && obj.dataSel
obj.rdEnb( : ) = true;
else 
if obj.iterDone
obj.rdEnb( : ) = false;
end 
end 

if obj.dataSel
rd_valid = obj.readValid;
else 
rd_valid = false;
end 

obj.readValid( : ) = obj.rdEnb;

if obj.rdEnb && obj.dataSel
if obj.vldCount == obj.countIdx
obj.vldCount( : ) = 0;
obj.rdEnb( : ) = false;
else 
obj.vldCount( : ) = obj.vldCount + 1;
end 
else 
obj.vldCount( : ) = 0;
end 

obj.rdLUTAddr1( : ) = obj.initCount + obj.rdCount;

obj.rdAddr( : ) = AddrLUT( obj.rdLUTAddr1 );

if obj.dataSel
if resetcount
obj.rdCount( : ) = 1;
else 
if obj.readValid
obj.rdCount( : ) = obj.rdCount + 1;
end 
end 
else 
obj.rdCount( : ) = 1;
end 

obj.rdLUTAddr2( : ) = obj.initCount + obj.rdCount;

obj.rdAddrReg( : ) = AddrLUT( obj.rdLUTAddr2 );

if obj.iterDone
obj.finalEnb( : ) = true;
end 

if obj.finalEnb
if obj.rdAddrFinal == obj.maxCount
obj.finalEnb( : ) = false;
else 
if obj.finalEnb
obj.rdAddrFinal( : ) = obj.rdAddrFinal + 1;
end 
end 
else 
obj.rdAddrFinal( : ) = 1;
end 

end 

function termpass = earlyTermination( obj, reset, gamma, valid, smsize, countidx, maxlayer )

hardDec = gamma <= 0;

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
p = 7;
else 
p = 6;
end 


if reset
obj.fPChecks( : ) = zeros( obj.memDepth, 1 );
else 
if valid
for idx = 1:obj.memDepth
if fi( idx, 0, p, 0 ) <= smsize
if hardDec( idx )
obj.fPChecks( idx ) = ~obj.fPChecks( idx );
end 
end 
end 
else 
obj.fPChecks( : ) = zeros( obj.memDepth, 1 );
end 
end 


if reset
obj.eColCount( : ) = 0;
obj.eLayCount( : ) = 0;
obj.eEnb( : ) = false;
obj.eEnbLayer( : ) = false;
else 
if valid
if obj.eColCount == countidx
obj.eColCount( : ) = 0;
obj.eEnb( : ) = true;
if obj.eLayCount == maxlayer - fi( 1, 0, 1, 0 )
obj.eLayCount( : ) = 0;
obj.eEnbLayer( : ) = true;
else 
obj.eLayCount( : ) = obj.eLayCount + 1;
end 
else 
obj.eColCount( : ) = obj.eColCount + 1;
obj.eEnb( : ) = false;
end 
else 
obj.eEnb( : ) = false;
obj.eEnbLayer( : ) = false;
end 
end 

if obj.eEnbDelay
if ~obj.checkFailed
for idx = 1:obj.memDepth
if ( obj.fPChecksD( idx ) == 1 )
obj.checkFailed( : ) = true;
end 
end 
end 
end 

obj.eEnbDelay( : ) = obj.eEnb;
obj.fPChecksD( : ) = obj.fPChecks;

if reset
obj.termPassD( : ) = false;
obj.checkFailed( : ) = false;
elseif obj.eEnbLayerD
obj.termPassD( : ) = ~obj.checkFailed;
if obj.eLayCount == 0
obj.checkFailed( : ) = false;
end 
end 

obj.eEnbLayerD( : ) = obj.eEnbLayer;

if reset
termpass = false;
else 
termpass = obj.termPassD;
end 


end 

function [ dataout, starto, endo, valido ] = outputGenerationSerial( obj, datai, starti, validi, blocklen, coderate, reset )

dataout = obj.dataOutG;

starto = obj.startOut;
endo = obj.endOut;
valido = obj.validOut;

subMatrixSize = fi( [ 27, 54, 81, 81 ], 0, 7, 0 );
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
obj.smSize( : ) = subMatrixSize( blocklen + 1 );
oCountLUT = fi( [ 324, 432, 486, 540, 648, 864, 972, 1080, 972, 1296, 1458, 1620 ] - 1, 0, 11, 0 );
oCount = oCountLUT( fi( bitconcat( blocklen, coderate ) + 1, 0, 5, 0 ) );
else 
obj.smSize( : ) = 42;
oCountLUT = fi( [ 336, 420, 504, 546 ] - 1, 0, 11, 0 );
oCount = oCountLUT( fi( coderate + 1, 0, 3, 0 ) );
end 

if reset
obj.ocountIdx( : ) = 1;
obj.startOut( : ) = false;
obj.validOut( : ) = false;
obj.outCount( : ) = 1;
else 
if obj.startReg && obj.validReg
obj.ocountIdx( : ) = 1;
obj.startOut( : ) = true;
obj.validOut( : ) = true;
obj.outCount( : ) = 1;
else 
obj.startOut( : ) = false;
if obj.validReg

if ( obj.ocountIdx == cast( obj.smSize, 'like', obj.ocountIdx ) )
obj.ocountIdx( : ) = 1;
else 
obj.ocountIdx( : ) = obj.ocountIdx + 1;
end 

obj.validOut( : ) = true;

if ( obj.outCount == cast( oCount, 'like', obj.outCount ) )
obj.outCount( : ) = 1;
obj.endOut( : ) = true;
else 
obj.outCount( : ) = obj.outCount + 1;
obj.endOut = false;
end 

else 
obj.validOut( : ) = false;
obj.endOut = false;
end 
end 
end 

obj.outWrData( : ) = obj.dataReg( obj.ocountIdx );

if obj.validReg
obj.dataOutG( : ) = cast( obj.outWrData, 'like', obj.outWrData );
else 
obj.dataOutG( : ) = cast( 0, 'like', obj.outWrData );
end 

if reset
obj.startReg( : ) = false;
obj.validReg( : ) = false;
obj.dataReg( : ) = zeros( obj.memDepth, 1 );
else 
obj.dataReg( : ) = datai;
obj.startReg( : ) = starti;
obj.validReg( : ) = validi;
end 

end 

function [ dataout, starto, endo, valido ] = outputGenerationVector( obj, datai, starti, validi, blocklen, coderate, reset )

subMatrixSize = fi( [ 27, 54, 81, 81 ], 0, 7, 0 );

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
maxCountLUT = fi( [ 320, 424, 480, 536, 640, 856, 968, 1072, 968, 1288, 1456, 1616 ], 0, 11, 0 );
maxVal = maxCountLUT( fi( bitconcat( blocklen, coderate ) + 1, 0, 4, 0 ) );
else 
maxCountLUT = fi( [ 328, 416, 496, 544 ], 0, 10, 0 );
maxVal = maxCountLUT( fi( coderate + 1, 0, 3, 0 ) );
end 

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
if reset
obj.dataPad( : ) = zeros( 1624, 1 );
else 
if blocklen == fi( 0, 0, 2, 0 )
obj.dataPad( : ) = [ obj.dataPad27;zeros( 1080, 1 ) > 0 ];
elseif blocklen == fi( 1, 0, 2, 0 )
obj.dataPad( : ) = [ obj.dataPad54;zeros( 544, 1 ) > 0 ];
elseif blocklen == fi( 2, 0, 2, 0 )
obj.dataPad( : ) = obj.dataPad81;
else 
obj.dataPad( : ) = zeros( 1624, 1 );
end 
end 
obj.smSize( : ) = subMatrixSize( blocklen + 1 );
else 
if reset
obj.dataPad( : ) = zeros( 552, 1 );
else 
obj.dataPad( : ) = obj.dataPad42;
end 
obj.smSize( : ) = 42;
end 

for i = 1:8
obj.dataOutG( i ) = obj.dataPad( obj.countReg1 + i );
end 

obj.countReg1( : ) = obj.countReg;

dataout = obj.dataOutG;

starto = obj.startOut;
endo = obj.endOut;
valido = obj.validOut;

if reset
obj.count( : ) = 1;
else 
if obj.startReg && obj.validReg
obj.count( : ) = 1;
elseif obj.validReg
obj.count( : ) = obj.count + 1;
end 
end 

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
if reset
obj.dataPad27( : ) = zeros( 544, 1 ) > 0;
obj.dataPad54( : ) = zeros( 1080, 1 ) > 0;
obj.dataPad81( : ) = zeros( 1624, 1 ) > 0;
else 
if obj.validReg
if obj.count == fi( 1, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataReg( 1:27 );zeros( 517, 1 ) ];
obj.dataPad54( : ) = [ obj.dataReg( 1:54 );zeros( 1026, 1 ) ];
obj.dataPad81( : ) = [ obj.dataReg;zeros( 1543, 1 ) ];
elseif obj.count == fi( 2, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:27 );obj.dataReg( 1:27 );zeros( 490, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:54 );obj.dataReg( 1:54 );zeros( 972, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:81 );obj.dataReg;zeros( 1462, 1 ) ];
elseif obj.count == fi( 3, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:54 );obj.dataReg( 1:27 );zeros( 463, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:108 );obj.dataReg( 1:54 );zeros( 918, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:162 );obj.dataReg;zeros( 1381, 1 ) ];
elseif obj.count == fi( 4, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:81 );obj.dataReg( 1:27 );zeros( 436, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:162 );obj.dataReg( 1:54 );zeros( 864, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:243 );obj.dataReg;zeros( 1300, 1 ) ];
elseif obj.count == fi( 5, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:108 );obj.dataReg( 1:27 );zeros( 409, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:216 );obj.dataReg( 1:54 );zeros( 810, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:324 );obj.dataReg;zeros( 1219, 1 ) ];
elseif obj.count == fi( 6, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:135 );obj.dataReg( 1:27 );zeros( 382, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:270 );obj.dataReg( 1:54 );zeros( 756, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:405 );obj.dataReg;zeros( 1138, 1 ) ];
elseif obj.count == fi( 7, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:162 );obj.dataReg( 1:27 );zeros( 355, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:324 );obj.dataReg( 1:54 );zeros( 702, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:486 );obj.dataReg;zeros( 1057, 1 ) ];
elseif obj.count == fi( 8, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:189 );obj.dataReg( 1:27 );zeros( 328, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:378 );obj.dataReg( 1:54 );zeros( 648, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:567 );obj.dataReg;zeros( 976, 1 ) ];
elseif obj.count == fi( 9, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:216 );obj.dataReg( 1:27 );zeros( 301, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:432 );obj.dataReg( 1:54 );zeros( 594, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:648 );obj.dataReg;zeros( 895, 1 ) ];
elseif obj.count == fi( 10, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:243 );obj.dataReg( 1:27 );zeros( 274, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:486 );obj.dataReg( 1:54 );zeros( 540, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:729 );obj.dataReg;zeros( 814, 1 ) ];
elseif obj.count == fi( 11, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:270 );obj.dataReg( 1:27 );zeros( 247, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:540 );obj.dataReg( 1:54 );zeros( 486, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:810 );obj.dataReg;zeros( 733, 1 ) ];
elseif obj.count == fi( 12, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:297 );obj.dataReg( 1:27 );zeros( 220, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:594 );obj.dataReg( 1:54 );zeros( 432, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:891 );obj.dataReg;zeros( 652, 1 ) ];
elseif obj.count == fi( 13, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:324 );obj.dataReg( 1:27 );zeros( 193, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:648 );obj.dataReg( 1:54 );zeros( 378, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:972 );obj.dataReg;zeros( 571, 1 ) ];
elseif obj.count == fi( 14, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:351 );obj.dataReg( 1:27 );zeros( 166, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:702 );obj.dataReg( 1:54 );zeros( 324, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:1053 );obj.dataReg;zeros( 490, 1 ) ];
elseif obj.count == fi( 15, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:378 );obj.dataReg( 1:27 );zeros( 139, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:756 );obj.dataReg( 1:54 );zeros( 270, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:1134 );obj.dataReg;zeros( 409, 1 ) ];
elseif obj.count == fi( 16, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:405 );obj.dataReg( 1:27 );zeros( 112, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:810 );obj.dataReg( 1:54 );zeros( 216, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:1215 );obj.dataReg;zeros( 328, 1 ) ];
elseif obj.count == fi( 17, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:432 );obj.dataReg( 1:27 );zeros( 85, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:864 );obj.dataReg( 1:54 );zeros( 162, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:1296 );obj.dataReg;zeros( 247, 1 ) ];
elseif obj.count == fi( 18, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:459 );obj.dataReg( 1:27 );zeros( 58, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:918 );obj.dataReg( 1:54 );zeros( 108, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:1377 );obj.dataReg;zeros( 166, 1 ) ];
elseif obj.count == fi( 19, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:486 );obj.dataReg( 1:27 );zeros( 31, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:972 );obj.dataReg( 1:54 );zeros( 54, 1 ) ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:1458 );obj.dataReg;zeros( 85, 1 ) ];
elseif obj.count == fi( 20, 0, 5, 0, hdlfimath )
obj.dataPad27( : ) = [ obj.dataPad27( 1:513 );obj.dataReg( 1:27 );zeros( 4, 1 ) ];
obj.dataPad54( : ) = [ obj.dataPad54( 1:1026 );obj.dataReg( 1:54 ); ];
obj.dataPad81( : ) = [ obj.dataPad81( 1:1539 );obj.dataReg;zeros( 4, 1 ) ];
end 
end 
end 
else 
if reset
obj.dataPad42( : ) = zeros( 552, 1 ) > 0;
else 
if obj.validReg
if obj.count == fi( 1, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataReg;zeros( 510, 1 ) ];
elseif obj.count == fi( 2, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:42 );obj.dataReg;zeros( 468, 1 ) ];
elseif obj.count == fi( 3, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:84 );obj.dataReg;zeros( 426, 1 ) ];
elseif obj.count == fi( 4, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:126 );obj.dataReg;zeros( 384, 1 ) ];
elseif obj.count == fi( 5, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:168 );obj.dataReg;zeros( 342, 1 ) ];
elseif obj.count == fi( 6, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:210 );obj.dataReg;zeros( 300, 1 ) ];
elseif obj.count == fi( 7, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:252 );obj.dataReg;zeros( 258, 1 ) ];
elseif obj.count == fi( 8, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:294 );obj.dataReg;zeros( 216, 1 ) ];
elseif obj.count == fi( 9, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:336 );obj.dataReg;zeros( 174, 1 ) ];
elseif obj.count == fi( 10, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:378 );obj.dataReg;zeros( 132, 1 ) ];
elseif obj.count == fi( 11, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:420 );obj.dataReg;zeros( 90, 1 ) ];
elseif obj.count == fi( 12, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:462 );obj.dataReg;zeros( 48, 1 ) ];
elseif obj.count == fi( 13, 0, 5, 0, hdlfimath )
obj.dataPad42( : ) = [ obj.dataPad42( 1:504 );obj.dataReg;zeros( 6, 1 ) ];
end 
end 
end 
end 

if reset
obj.startOut( : ) = false;
else 
if obj.startReg && obj.validReg
obj.validEnb( : ) = true;
obj.startOut( : ) = true;
else 
obj.startOut( : ) = false;
end 
end 

if reset
obj.countReg( : ) = 0;
obj.validOut( : ) = false;
obj.endOut( : ) = false;
obj.validEnb( : ) = false;
else 
if obj.validEnb
if obj.countReg == maxVal
obj.countReg( : ) = 0;
obj.validEnb( : ) = false;
obj.endOut( : ) = true;
else 
obj.countReg( : ) = obj.countReg + 8;
obj.endOut( : ) = false;
end 
obj.validOut( : ) = true;
else 
obj.countReg( : ) = 0;
obj.validOut( : ) = false;
obj.endOut( : ) = false;
end 
end 

if reset
obj.startReg( : ) = false;
obj.validReg( : ) = false;
obj.dataReg( : ) = zeros( obj.memDepth, 1 );
else 
obj.dataReg( : ) = datai;
obj.startReg( : ) = starti;
obj.validReg( : ) = validi;
end 
end 

function num = getNumInputsImpl( ~ )
num = 9;
end 

function num = getNumOutputsImpl( obj )
if strcmpi( obj.Termination, 'Early' )
num = 4;
else 
num = 3;
end 
end 

























































function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked

s.variableNodeRAM = obj.variableNodeRAM;
s.checkMatrixLUT = obj.checkMatrixLUT;
s.circularShifter = obj.circularShifter;
s.functionalUnit = obj.functionalUnit;
s.checkNodeRAM = obj.checkNodeRAM;
s.finalDecision = obj.finalDecision;
s.circularShifterOutput = obj.circularShifterOutput;


s.gammaOut = obj.gammaOut;
s.gammaValid = obj.gammaValid;
s.termPass = obj.termPass;
s.gammaValidReg = obj.gammaValidReg;
s.endInd = obj.endInd;
s.validCount = obj.validCount;
s.rdValid = obj.rdValid;
s.rdValidReg = obj.rdValidReg;
s.rdValidReg1 = obj.rdValidReg1;
s.betaDecomp1 = obj.betaDecomp1;
s.betaDecomp2 = obj.betaDecomp2;
s.betaValid = obj.betaValid;
s.dataO = obj.dataO;
s.finalShift = obj.finalShift;
s.iterDoneReg = obj.iterDoneReg;


s.countLayer = obj.countLayer;
s.layerDone = obj.layerDone;
s.iterCount = obj.iterCount;
s.betaRead = obj.betaRead;
s.iterInd = obj.iterInd;
s.zCount = obj.zCount;
s.wrAddr = obj.wrAddr;
s.rdAddr = obj.rdAddr;
s.rdAddrReg = obj.rdAddrReg;
s.rdAddrFinal = obj.rdAddrFinal;
s.wrEnb = obj.wrEnb;
s.wrData = obj.wrData;
s.wrCount = obj.wrCount;
s.vldCount = obj.vldCount;
s.rdEnb = obj.rdEnb;
s.finalEnb = obj.finalEnb;
s.readValid = obj.readValid;
s.rdCount = obj.rdCount;
s.wrLUTAddr = obj.wrLUTAddr;
s.rdLUTAddr1 = obj.rdLUTAddr1;
s.rdLUTAddr2 = obj.rdLUTAddr2;
s.noOp = obj.noOp;
s.dataSel = obj.dataSel;
s.iterDone = obj.iterDone;
s.countIdx = obj.countIdx;
s.initCount = obj.initCount;
s.maxCount = obj.maxCount;
s.colCount = obj.colCount;
s.rdFinEnb = obj.rdFinEnb;


s.fPChecks = obj.fPChecks;
s.fPChecksD = obj.fPChecksD;
s.eColCount = obj.eColCount;
s.eLayCount = obj.eLayCount;
s.eEnb = obj.eEnb;
s.eEnbDelay = obj.eEnbDelay;
s.checkFailed = obj.checkFailed;
s.eEnbLayer = obj.eEnbLayer;
s.eEnbLayerD = obj.eEnbLayerD;
s.termPassD = obj.termPassD;


s.startReg = obj.startReg;
s.validReg = obj.validReg;
s.smSize = obj.smSize;
s.dataReg = obj.dataReg;
s.dataPad = obj.dataPad;
s.dataPad27 = obj.dataPad27;
s.dataPad54 = obj.dataPad54;
s.dataPad81 = obj.dataPad81;
s.dataPad42 = obj.dataPad42;
s.count = obj.count;
s.validEnb = obj.validEnb;
s.countReg = obj.countReg;
s.countReg1 = obj.countReg1;
s.startOut = obj.startOut;
s.endOut = obj.endOut;
s.validOut = obj.validOut;
s.dataOutG = obj.dataOutG;
s.outCount = obj.outCount;
s.ocountIdx = obj.ocountIdx;
s.outWrData = obj.outWrData;
s.memDepth = obj.memDepth;
s.memDepth1 = obj.memDepth1;
s.scalarFlag = obj.scalarFlag;


s.dataOut = obj.dataOut;
s.ctrlOut = obj.ctrlOut;
s.iterOut = obj.iterOut;
s.parCheck = obj.parCheck;


s.delayBalancer1 = obj.delayBalancer1;
s.delayBalancer2 = obj.delayBalancer2;
s.delayBalancer3 = obj.delayBalancer3;
s.delayBalancer4 = obj.delayBalancer4;
s.betaDelayBalancer1 = obj.betaDelayBalancer1;
s.betaDelayBalancer2 = obj.betaDelayBalancer2;
s.betaDelayBalancer3 = obj.betaDelayBalancer3;

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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7doCtI.p.
% Please follow local copyright laws when handling this file.

