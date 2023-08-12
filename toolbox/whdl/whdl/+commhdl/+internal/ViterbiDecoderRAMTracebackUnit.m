classdef ( StrictDefaults )ViterbiDecoderRAMTracebackUnit < matlab.System








%#codegen





properties ( Nontunable )
tbd = 32;
K = 7;

continuousModeReset( 1, 1 )logical = false;
end 

properties ( Access = private )
addressGeneratorObj;
readAndWriteRAMobj;
traceBackEngineObj;
lifoRamUnitObj;
dataDelayBalanceObj;
dataDelayBalanceObjL;
dataDelayBalanceObjH;
minUnitDelayBalanceObj;
lifoResetDelayBalanceObj;
tracebackResetDelayBalanceObj;
dataOutreg;
validReg;

end 





methods 

function obj = ViterbiDecoderRAMTracebackUnit( varargin )
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
function resetImpl( obj )
reset( obj.addressGeneratorObj );
reset( obj.readAndWriteRAMobj );
reset( obj.traceBackEngineObj );
reset( obj.lifoRamUnitObj );

if ( obj.K == 9 )
reset( obj.dataDelayBalanceObjL );
reset( obj.dataDelayBalanceObjH );
else 
reset( obj.dataDelayBalanceObj );
end 
reset( obj.minUnitDelayBalanceObj );
reset( obj.lifoResetDelayBalanceObj );
reset( obj.tracebackResetDelayBalanceObj );
obj.dataOutreg = fi( 0, 0, 1, 0 );
obj.validReg = false;
end 

function setupImpl( obj, varargin )

obj.addressGeneratorObj = commhdl.internal.ViterbiDecoderAddressGenerator( 'tbd', obj.tbd,  ...
'continuousModeReset', obj.continuousModeReset );

if ( obj.K == 9 )
obj.readAndWriteRAMobj = commhdl.internal.ViterbiDecoderReadAndWriteRAMConst9;
else 
obj.readAndWriteRAMobj = commhdl.internal.ViterbiDecoderReadAndWriteRAM;
end 

if ( obj.K == 9 )
obj.traceBackEngineObj = commhdl.internal.ViterbiDecoderTracebackEngineConst9( 'tbd', obj.tbd,  ...
'continuousModeReset', obj.continuousModeReset );
else 
obj.traceBackEngineObj = commhdl.internal.ViterbiDecoderTracebackEngine( 'tbd', obj.tbd,  ...
'continuousModeReset', obj.continuousModeReset );
end 

obj.lifoRamUnitObj = commhdl.internal.ViterbiDecoderLIFORAMEngine( 'tbd', obj.tbd,  ...
'continuousModeReset', obj.continuousModeReset );


if ( obj.K == 9 )
obj.dataDelayBalanceObjL = dsp.Delay( 1 );
obj.dataDelayBalanceObjH = dsp.Delay( 1 );
else 
obj.dataDelayBalanceObj = dsp.Delay( 1 );
end 
obj.minUnitDelayBalanceObj = dsp.Delay( 3 );
obj.dataOutreg = fi( 0, 0, 1, 0 );
obj.validReg = false;
obj.lifoResetDelayBalanceObj = dsp.Delay( 1 );
obj.tracebackResetDelayBalanceObj = dsp.Delay( 3 );
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ decOut, validOut ] = outputImpl( obj, varargin )
decOut = obj.dataOutreg;
validOut = obj.validReg;
end 

function updateImpl( obj, varargin )

if ( obj.K == 9 )
datainfiL = varargin{ 1 };
datainfiH = varargin{ 2 };
idx = 3;
else 
datainfi = varargin{ 1 };
idx = 2;
end 
enb = varargin{ idx };
minIndex = varargin{ idx + 1 };

if ( obj.continuousModeReset )
reset = varargin{ idx + 2 };
tbrst = obj.tracebackResetDelayBalanceObj( reset );
liforst = obj.lifoResetDelayBalanceObj( tbrst );
[ writeAdress, readAdress, ramWriteEnb ] = obj.addressGeneratorObj( enb, reset );
else 
[ writeAdress, readAdress, ramWriteEnb ] = obj.addressGeneratorObj( enb );
end 

if ( obj.K == 9 )
datadL = obj.dataDelayBalanceObjL( datainfiL );
datadH = obj.dataDelayBalanceObjH( datainfiH );
[ decodeAdrsDataL, decodeAdrsDataH, tracbackAdrsDataL, tracbackAdrsDataH,  ...
RamvalidOut ] = obj.readAndWriteRAMobj( datadL, datadH, writeAdress,  ...
ramWriteEnb, readAdress );
else 
datad = obj.dataDelayBalanceObj( datainfi );

[ decodeAdrsData, tracbackAdrsData,  ...
RamvalidOut ] = obj.readAndWriteRAMobj( datad, writeAdress,  ...
ramWriteEnb, readAdress );
end 


minIndexd = obj.minUnitDelayBalanceObj( minIndex );

if ( obj.continuousModeReset )

if ( obj.K == 9 )
[ decOut, decValidOut ] =  ...
obj.traceBackEngineObj( tracbackAdrsDataL, tracbackAdrsDataH,  ...
decodeAdrsDataL, decodeAdrsDataH, minIndexd, RamvalidOut, tbrst );
else 
[ decOut, decValidOut ] =  ...
obj.traceBackEngineObj( tracbackAdrsData, decodeAdrsData,  ...
minIndexd, RamvalidOut, tbrst );
end 

[ obj.dataOutreg, obj.validReg ] = obj.lifoRamUnitObj( decOut, decValidOut, liforst );
else 
if ( obj.K == 9 )
[ decOut, decValidOut ] = obj.traceBackEngineObj( tracbackAdrsDataL, tracbackAdrsDataH,  ...
decodeAdrsDataL, decodeAdrsDataH, minIndexd, RamvalidOut );
else 
[ decOut, decValidOut ] = obj.traceBackEngineObj( tracbackAdrsData, decodeAdrsData,  ...
minIndexd, RamvalidOut );
end 
[ obj.dataOutreg, obj.validReg ] = obj.lifoRamUnitObj( decOut, decValidOut );
end 
end 


function num = getNumInputsImpl( obj )
if ( obj.K == 9 )
plus = 1;
else 
plus = 0;
end 

num = 3 + plus;

if ( obj.continuousModeReset )
num = num + 1;
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
if ( obj.K == 9 )
varargout{ 1 } = 'datainfiL';
varargout{ 2 } = 'datainfiH';
idx = 3;
else 
varargout{ 1 } = 'datainfi';
idx = 2;
end 
varargout{ idx } = 'enb';
varargout{ idx + 1 } = 'minIndex';
if ( obj.continuousModeReset )
varargout{ idx + 2 } = 'reset';
end 
end 

function num = getNumOutputsImpl( ~ )
num = 2;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'decodedBit';
varargout{ 2 } = 'valid';
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.addressGeneratorObj = obj.addressGeneratorObj;
s.readAndWriteRAMobj = obj.readAndWriteRAMobj;
s.traceBackEngineObj = obj.traceBackEngineObj;
s.lifoRamUnitObj = obj.lifoRamUnitObj;
s.dataDelayBalanceObj = obj.dataDelayBalanceObj;
s.dataDelayBalanceObjL = obj.dataDelayBalanceObjL;
s.dataDelayBalanceObjH = obj.dataDelayBalanceObjH;
s.minUnitDelayBalanceObj = obj.minUnitDelayBalanceObj;
s.lifoResetDelayBalanceObj = obj.lifoResetDelayBalanceObj;
s.tracebackResetDelayBalanceObj = obj.tracebackResetDelayBalanceObj;
s.dataOutreg = obj.dataOutreg;
s.validReg = obj.validReg;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcWsOXu.p.
% Please follow local copyright laws when handling this file.

