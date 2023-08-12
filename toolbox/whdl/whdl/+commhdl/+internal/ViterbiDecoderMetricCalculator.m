classdef ( StrictDefaults )ViterbiDecoderMetricCalculator < matlab.System








%#codegen





properties ( Nontunable )
K = 7;
G = [ 133, 171 ];
nsDec = 4;

enbErasure( 1, 1 )logical = false;
frameSignal( 1, 1 )logical = true;
continuousModeReset( 1, 1 )logical = false;
terminationMode( 1, 1 )logical = true;
end 

properties ( Access = private )
branchMetricUnitTopObj;
addCompareSelectUnitObj;
minSelectUnitObj;
delayBanlanceReset;
BMdelayReset;
minStateIndex;
minUnitValidOut;
continousResetOut;
decsBitsDelayBalance;
ctrlDelayBalance;
ctrlDelay;
decsDelay;
decsBitsDelayBalanceL;
decsBitsDelayBalanceH;
decsDelayH;
decsDelayL;
end 

properties ( Nontunable, Access = private )
indices;
indicesWordLen;
numStates;
end 





methods 

function obj = ViterbiDecoderMetricCalculator( varargin )
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
reset( obj.branchMetricUnitTopObj );
reset( obj.addCompareSelectUnitObj );
reset( obj.minSelectUnitObj );

reset( obj.BMdelayReset );
reset( obj.delayBanlanceReset );
if ( obj.K == 9 )
reset( obj.decsBitsDelayBalanceL );
reset( obj.decsBitsDelayBalanceH );
else 
reset( obj.decsBitsDelayBalance );
end 

resetparams( obj );
end 

function setupImpl( obj )

obj.branchMetricUnitTopObj = commhdl.internal.ViterbiDecoderBranchMetricUnitTop( 'enbErasure',  ...
obj.enbErasure, 'frameSignal', obj.frameSignal, 'continuousModeReset', obj.continuousModeReset );

obj.addCompareSelectUnitObj = commhdl.internal.ViterbiDecoderAddCompSelUnit( 'K', obj.K, 'G', obj.G,  ...
'nsDec', obj.nsDec, 'frameSignal', obj.frameSignal,  ...
'continuousModeReset', obj.continuousModeReset );

obj.BMdelayReset = dsp.Delay( 3 );
obj.delayBanlanceReset = dsp.Delay( obj.K );
obj.decsBitsDelayBalance = dsp.Delay( obj.K - 1 );
obj.ctrlDelayBalance = dsp.Delay( obj.K - 1 );
if ( obj.K == 9 )
obj.decsBitsDelayBalanceL = dsp.Delay( obj.K - 1 );
obj.decsBitsDelayBalanceH = dsp.Delay( obj.K - 1 );
else 
obj.decsBitsDelayBalance = dsp.Delay( obj.K - 1 );
end 

obj.numStates = 2 ^ ( obj.K - 1 );
obj.indicesWordLen = obj.K - 1;
obj.indices = fi( 0:obj.numStates - 1, 0, obj.indicesWordLen, 0 );

obj.minSelectUnitObj = commhdl.internal.ViterbiDecoderMinmetricUnit( 'Stage', obj.K - 1 );
resetparams( obj );
end 

function resetparams( obj )
obj.minStateIndex = fi( 0, 0, obj.indicesWordLen, 0 );
obj.minUnitValidOut = false;
obj.continousResetOut = false;
obj.ctrlDelay = [ false, false, false ];
if ( obj.K == 9 )
obj.decsDelayH = fi( 0, 0, obj.numStates / 2, 0 );
obj.decsDelayL = fi( 0, 0, obj.numStates / 2, 0 );
else 
obj.decsDelay = fi( 0, 0, obj.numStates, 0 );
end 


end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ varargout ] = outputImpl( obj, varargin )
varargout{ 1 } = obj.minStateIndex;
varargout{ 2 } = obj.minUnitValidOut;
if ( obj.K == 9 )
varargout{ 3 } = obj.decsDelayL;
varargout{ 4 } = obj.decsDelayH;
idx = 5;
else 
varargout{ 3 } = obj.decsDelay;
idx = 4;
end 

if ( obj.frameSignal )
varargout{ idx } = obj.ctrlDelay;
else 
if ( obj.continuousModeReset )
varargout{ idx } = obj.continousResetOut;
end 
end 
end 

function updateImpl( obj, varargin )
softBits = varargin{ 1 };
valid = varargin{ 2 };
if ( obj.frameSignal )


frameGapValid = varargin{ 3 };
startSignal = varargin{ 4 };
if ( obj.terminationMode )
ACSreset = frameGapValid || startSignal;
else 
ACSreset = startSignal;
end 

enbACSreset = obj.BMdelayReset( ACSreset );

if ( obj.enbErasure )
erasure = varargin{ 5 };
ctrl = varargin{ 6 };
ctrl = ctrl( : )';
[ branchMetOut, branchMetvalidOut, ctrld ] =  ...
obj.branchMetricUnitTopObj( softBits,  ...
valid, frameGapValid, ctrl, erasure );
else 
ctrl = varargin{ 5 };
ctrl = ctrl( : )';
[ branchMetOut, branchMetvalidOut, ctrld ] =  ...
obj.branchMetricUnitTopObj( softBits,  ...
valid, frameGapValid, ctrl );
end 

[ stateMetrics, decsBits,  ...
stateMetValidOut, ctrldd ] =  ...
obj.addCompareSelectUnitObj( branchMetOut, branchMetvalidOut,  ...
enbACSreset, ctrld );

[ ~, obj.minStateIndex, obj.minUnitValidOut ] =  ...
obj.minSelectUnitObj( stateMetrics,  ...
obj.indices, stateMetValidOut );
obj.ctrlDelay = obj.ctrlDelayBalance( ctrldd );

else 

if ( obj.enbErasure )
erasure = varargin{ 3 };

if ( obj.continuousModeReset )
resetBMUnit = varargin{ 4 };
[ branchMetOut, branchMetvalidOut ] =  ...
obj.branchMetricUnitTopObj( softBits,  ...
valid, erasure, resetBMUnit );
else 
[ branchMetOut, branchMetvalidOut ] =  ...
obj.branchMetricUnitTopObj( softBits,  ...
valid, erasure );
end 
else 

if ( obj.continuousModeReset )
resetBMUnit = varargin{ 3 };
[ branchMetOut, branchMetvalidOut ] =  ...
obj.branchMetricUnitTopObj( softBits,  ...
valid, resetBMUnit );
else 
[ branchMetOut, branchMetvalidOut ] =  ...
obj.branchMetricUnitTopObj( softBits,  ...
valid );
end 
end 


if ( obj.continuousModeReset )
delayResetACS = obj.BMdelayReset( resetBMUnit );
[ stateMetrics, decsBits, stateMetValidOut ] =  ...
obj.addCompareSelectUnitObj( branchMetOut, branchMetvalidOut,  ...
delayResetACS );
obj.continousResetOut = obj.delayBanlanceReset( delayResetACS );
else 
[ stateMetrics, decsBits, stateMetValidOut ] =  ...
obj.addCompareSelectUnitObj( branchMetOut, branchMetvalidOut );
end 

[ ~, obj.minStateIndex, obj.minUnitValidOut ] = obj.minSelectUnitObj( stateMetrics,  ...
obj.indices, stateMetValidOut );

end 

if ( obj.K == 9 )
dataInfiL = bitconcat( fliplr( decsBits( 1:end  / 2 ) ) );
dataInfiH = bitconcat( fliplr( decsBits( end  / 2 + 1:end  ) ) );
obj.decsDelayL = obj.decsBitsDelayBalanceL( dataInfiL );
obj.decsDelayH = obj.decsBitsDelayBalanceH( dataInfiH );
else 
dataInfi = bitconcat( fliplr( decsBits ) );
obj.decsDelay = obj.decsBitsDelayBalance( dataInfi );
end 
end 

function num = getNumInputsImpl( obj )

num = 2;
if ( obj.frameSignal )
num = num + 3;
if ( obj.enbErasure )
num = num + 1;
end 
else 
if ( obj.continuousModeReset )
num = num + 1;
end 
if ( obj.enbErasure )
num = num + 1;
end 
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'softBits';
varargout{ 2 } = 'valid';
if ( obj.frameSignal )
varargout{ 3 } = 'frameGapValid';
varargout{ 4 } = 'framStartSignal';
if ( obj.enbErasure )
varargout{ 5 } = 'erasure';
varargout{ 6 } = 'ctrl';
else 
varargout{ 5 } = 'ctrl';
end 
else 
if ( obj.enbErasure )
varargout{ 3 } = 'erasure';
if ( obj.continuousModeReset )
varargout{ 4 } = 'reset';
end 
else 
if ( obj.continuousModeReset )
varargout{ 3 } = 'reset';
end 
end 
end 
end 

function num = getNumOutputsImpl( obj )
if ( obj.K == 9 )
plus = 1;
else 
plus = 0;
end 

num = 3 + plus;
if ( obj.frameSignal )
num = num + 1;
else 
if ( obj.continuousModeReset )
num = num + 1;
end 
end 
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'minStateIndx';
varargout{ 2 } = 'validOut';
if ( obj.K == 9 )
varargout{ 3 } = 'decisionsBitL';
varargout{ 4 } = 'decisionsBitH';
idx = 5;
else 
varargout{ 3 } = 'decisionsBit';
idx = 4;
end 

if ( obj.frameSignal )
varargout{ idx } = 'ctrlSignals';
else 
if ( obj.continuousModeReset )
varargout{ idx } = 'continousResetOut';
end 
end 
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.branchMetricUnitTopObj = obj.branchMetricUnitTopObj;

s.addCompareSelectUnitObj = obj.addCompareSelectUnitObj;
s.minSelectUnitObj = obj.minSelectUnitObj;
s.delayBanlanceReset = obj.delayBanlanceReset;
s.BMdelayReset = obj.BMdelayReset;
s.minStateIndex = obj.minStateIndex;
s.minUnitValidOut = obj.minUnitValidOut;
s.continousResetOut = obj.continousResetOut;
s.decsBitsDelayBalance = obj.decsBitsDelayBalance;
s.ctrlDelayBalance = obj.ctrlDelayBalance;
s.ctrlDelay = obj.ctrlDelay;
s.decsDelay = obj.decsDelay;
s.decsBitsDelayBalanceL = obj.decsBitsDelayBalanceL;
s.decsBitsDelayBalanceH = obj.decsBitsDelayBalanceH;
s.decsDelayH = obj.decsDelayH;
s.decsDelayL = obj.decsDelayL;
s.indices = obj.indices;
s.indicesWordLen = obj.indicesWordLen;
s.numStates = obj.numStates;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3FrOWp.p.
% Please follow local copyright laws when handling this file.

