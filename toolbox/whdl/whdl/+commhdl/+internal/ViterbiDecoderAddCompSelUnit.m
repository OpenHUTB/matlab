classdef ( StrictDefaults )ViterbiDecoderAddCompSelUnit < matlab.System







%#codegen





properties ( Nontunable )
K = 7;
G = [ 133, 171 ];
nsDec = 4;

frameSignal( 1, 1 )logical = true;
continuousModeReset( 1, 1 )logical = false;
end 

properties ( Access = private, Nontunable )
trellis;
branchOutputsA;
branchOutputsB;
prevStateA;
prevStateB;
initstateMet;
StateMetWL;
numStates;
sign;
end 

properties ( Access = private )
nextStateMets;
decisions;
valid;
ctrl;
end 





methods 

function obj = ViterbiDecoderAddCompSelUnit( varargin )
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
function setupImpl( obj, varargin )
branchMetricsDT = varargin{ 1 };
initializeResettableProperties( obj, branchMetricsDT );
end 

function resetImpl( obj )
obj.nextStateMets = obj.initstateMet;
obj.decisions = fi( zeros( 1, obj.numStates ), 0, 1, 0 );
obj.valid = false;
obj.ctrl = [ false, false, false ];
end 

function initializeResettableProperties( obj, BMdataType )
obj.trellis = poly2trellis( obj.K, obj.G );
states = ( 0:obj.trellis.numStates - 1 );
obj.prevStateA = mod( bitshift( states, 1 ),  ...
obj.trellis.numStates ) + 1;
obj.prevStateB = mod( bitshift( states, 1 ) + 1,  ...
obj.trellis.numStates ) + 1;
branchIndexs = oct2dec( obj.trellis.outputs ) + 1;
obj.branchOutputsA = branchIndexs( 2 * states + 1 );
obj.branchOutputsB = branchIndexs( 2 * states + 1 + 1 );
obj.numStates = obj.trellis.numStates;
obj.decisions = fi( zeros( 1, obj.numStates ), 0, 1, 0 );
obj.valid = false;
calculateWordLenAndInit( obj, BMdataType );
obj.ctrl = [ false, false, false ];
end 

function calculateWordLenAndInit( obj, bmtype )


nBranchs = numel( obj.G );
if ( isa( bmtype, 'embedded.fi' ) && isfixed( bmtype ) )
if ( issigned( bmtype ) )
softBitMin =  - 2 ^ ( obj.nsDec - 1 );
branchMetMin = softBitMin * nBranchs;
branchMetMax =  - softBitMin * nBranchs;
obj.sign = 1;
else 
softBitMax = 2 ^ ( obj.nsDec ) - 1;
branchMetMin = 0;
branchMetMax = ( softBitMax ) * nBranchs;
obj.sign = 0;
end 
obj.StateMetWL = ( floor( log2( 2 * ( obj.K - 1 ) * branchMetMax ) ) + 1 ) ...
 + obj.sign + 1;
stateMetMin = ( obj.K - 1 ) * branchMetMin;
stateMetMax = ( obj.K - 1 ) * branchMetMax;
initstateMet_ = fi( ones( obj.numStates, 1 ) * stateMetMax,  ...
obj.sign, obj.StateMetWL, 0, hdlfimath );
initstateMet_( 1 ) = fi( stateMetMin, 0, obj.StateMetWL, 0, hdlfimath );
else 
obj.sign = 1;
stateMetMin = 0;
stateMetMax = 3.4028e+38;
initstateMet_ = ones( obj.numStates, 1 ) * stateMetMax;
initstateMet_( 1 ) = stateMetMin;
end 

obj.initstateMet = initstateMet_;
obj.nextStateMets = obj.initstateMet;
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ varargout ] = outputImpl( obj, varargin )

stateMetrics = obj.nextStateMets;
decsBits = obj.decisions;
validOut = obj.valid;
varargout{ 1 } = stateMetrics;
varargout{ 2 } = decsBits;
varargout{ 3 } = validOut;
if ( obj.frameSignal )
varargout{ 4 } = obj.ctrl;
end 
end 

function updateImpl( obj, varargin )
branchMetrics = varargin{ 1 };
validIn = varargin{ 2 };
if ( obj.frameSignal )
reset = varargin{ 3 };
ctrl1 = varargin{ 4 };
obj.ctrl = ctrl1( : )';
ACSWithFrameReset( obj, branchMetrics, reset, validIn );
else 
if ( obj.continuousModeReset )
reset = varargin{ 3 };
ACSWithContReset( obj, branchMetrics, reset, validIn );
else 
ACSWithOutContReset( obj, branchMetrics, validIn )
end 
end 
obj.valid = validIn;
end 

function ACSWithFrameReset( obj, branchMetrics, rst, validIn )

if ( rst )
stateMetrics = obj.initstateMet;
else 
stateMetrics = obj.nextStateMets;
end 

[ nextStateMetsTmp, decisionsTmp ] = addCompSelUnit( obj, stateMetrics,  ...
branchMetrics );
obj.decisions = decisionsTmp;
if ( validIn || rst )
obj.nextStateMets( : ) = nextStateMetsTmp;
end 
end 

function ACSWithOutContReset( obj, branchMetrics, validIn )
stateMetrics = obj.nextStateMets;

[ nextStateMetsTmp, decisionsTmp ] = addCompSelUnit( obj, stateMetrics,  ...
branchMetrics );

obj.decisions = decisionsTmp;
if ( validIn )
obj.nextStateMets( : ) = nextStateMetsTmp;
end 
end 

function ACSWithContReset( obj, branchMetrics, rst, validIn )
stateMetrics = obj.nextStateMets;

[ nextStateMetsTmp, decisionsTmp ] = addCompSelUnit( obj, stateMetrics,  ...
branchMetrics );

obj.decisions = decisionsTmp;
if ( validIn || rst )
if ( rst )
obj.nextStateMets( : ) = obj.initstateMet;
else 
obj.nextStateMets( : ) = nextStateMetsTmp;
end 
end 
end 

function [ nextStateMetsTmp, decisionsTmp ] = addCompSelUnit( obj, prevStateMets, branchMets )
nextStateMetsTmp = cast( zeros( 1, obj.numStates ), 'like', obj.nextStateMets );
decisionsTmp = cast( zeros( 1, obj.numStates ), 'like', obj.decisions );
for i = 1:obj.numStates
stateMetricsA = cast( prevStateMets( obj.prevStateA( i ) ) ...
 + branchMets( obj.branchOutputsA( i ) ),  ...
'like', obj.nextStateMets );
stateMetricsB = cast( prevStateMets( obj.prevStateB( i ) ) ...
 + branchMets( obj.branchOutputsB( i ) ),  ...
'like', obj.nextStateMets );
[ nextStateMetsTmp( i ),  ...
decisionsTmp( i ) ] = compSelUnit( obj, stateMetricsA, stateMetricsB );
end 
end 

function [ nxtStateMet, decsBits ] = compSelUnit( obj, stateMetricsA, stateMetricsB )


diff = cast( stateMetricsB - stateMetricsA, 'like', obj.nextStateMets );
if isa( diff, 'single' ) || isa( diff, 'double' )
tmp = diff >= 0;
else 
tmp = getmsb( diff ) == fi( 0, 0, 1, 0 );
end 

if ( tmp )
nxtStateMet = stateMetricsA;
decsBits = fi( 0, 0, 1, 0 );
else 
nxtStateMet = stateMetricsB;
decsBits = fi( 1, 0, 1, 0 );
end 
end 

function num = getNumInputsImpl( obj )
num = 2;
if ( obj.frameSignal )
num = num + 2;
else 
if ( obj.continuousModeReset )
num = num + 1;
end 
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'branchMetrics';
varargout{ 2 } = 'validIn';
if ( obj.frameSignal )
varargout{ 3 } = 'reset';
varargout{ 4 } = 'ctrl';
else 
if ( obj.continuousModeReset )
varargout{ 3 } = 'reset';
end 
end 
end 

function num = getNumOutputsImpl( obj )
num = 3;
if ( obj.frameSignal )
num = num + 1;
end 
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'stateMetrics';
varargout{ 2 } = 'decsBits';
varargout{ 3 } = 'validOut';
if ( obj.frameSignal )
varargout{ 4 } = 'ctrl';
end 
end 




function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.nextStateMets = obj.nextStateMets;
s.decisions = obj.decisions;
s.valid = obj.valid;
s.ctrl = obj.ctrl;
s.nextStateMets = obj.nextStateMets;
s.decisions = obj.decisions;
s.valid = obj.valid;
s.ctrl = obj.ctrl;
s.branchOutputsA = obj.branchOutputsA;
s.branchOutputsB = obj.branchOutputsB;
s.prevStateA = obj.prevStateA;
s.prevStateB = obj.prevStateB;
s.numStates = obj.numStates;
s.initstateMet = obj.initstateMet;
s.StateMetWL = obj.StateMetWL;
s.sign = obj.sign;
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpj2NRoc.p.
% Please follow local copyright laws when handling this file.

