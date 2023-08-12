classdef ( StrictDefaults )ViterbiDecoderBranchMetricUnitTop < matlab.System








%#codegen





properties ( Nontunable )
enbErasure( 1, 1 )logical = false;
frameSignal( 1, 1 )logical = true;
continuousModeReset( 1, 1 )logical = false;
end 

properties ( Access = private )
softBitUnitObj;
branchMetricUnitObj;
ctrld;
delayBalance;
nbranches;
branchMetReg;
validReg;
ctrlReg;
end 
properties ( Nontunable, Access = private )
nBranches;
numOutputSyms;
branchMetWordLen;
end 





methods 

function obj = ViterbiDecoderBranchMetricUnitTop( varargin )
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
reset( obj.softBitUnitObj );
reset( obj.branchMetricUnitObj );
reset( obj.delayBalance );
obj.validReg = false;
obj.ctrld = [ false, false, false ];
obj.ctrlReg = [ false, false, false ];
obj.branchMetReg( : ) = zeros( 1, obj.numOutputSyms );
end 

function setupImpl( obj, varargin )
obj.softBitUnitObj = commhdl.internal.ViterbiDecoderSoftBitUnit( 'enbErasure', obj.enbErasure,  ...
'enbReset', obj.frameSignal || obj.continuousModeReset );
obj.branchMetricUnitObj = commhdl.internal.ViterbiDecoderBranchMetricUnit;
obj.ctrld = [ false, false, false ];
obj.delayBalance = dsp.Delay( 2 );
bmtype = varargin{ 1 };
obj.nBranches = ( length( varargin{ 1 } ) );
obj.numOutputSyms = pow2( obj.nBranches );
obj.validReg = false;
obj.ctrlReg = [ false, false, false ];
if ( isa( bmtype, 'embedded.fi' ) && isfixed( bmtype ) )
nsDec = bmtype.WordLength;
calculateWordLen( obj, nsDec, obj.nBranches, bmtype );
else 
obj.branchMetReg = zeros( 1, obj.numOutputSyms );
end 
end 

function calculateWordLen( obj, nsDec, nBranchs, bmtype )

if ( isa( bmtype, 'embedded.fi' ) && isfixed( bmtype ) )
if issigned( bmtype )
branchMetMax = ( 2 ^ ( nsDec - 1 ) ) * nBranchs;
obj.branchMetWordLen = ( floor( log2( branchMetMax ) ) + 1 ) + 1;
obj.branchMetReg = fi( zeros( 1, obj.numOutputSyms ), 1,  ...
obj.branchMetWordLen, 0 );
else 
branchMetMax = ( ( 2 ^ nsDec ) - 1 ) * nBranchs;
obj.branchMetWordLen = ( floor( log2( branchMetMax ) ) + 1 );
obj.branchMetReg = fi( zeros( 1, obj.numOutputSyms ), 0,  ...
obj.branchMetWordLen, 0 );
end 

else 
obj.branchMetReg = zeros( 1, obj.numOutputSyms );
end 
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ varargout ] = outputImpl( obj, varargin )
varargout{ 1 } = obj.branchMetReg;
varargout{ 2 } = obj.validReg;

if ( obj.frameSignal )
varargout{ 3 } = obj.ctrlReg;
end 
end 

function updateImpl( obj, varargin )
softBits = varargin{ 1 };
valid = varargin{ 2 };
if ( obj.frameSignal )
frameGapValid = varargin{ 3 };
ctrl = varargin{ 4 };
ctrl = ctrl( : )';


if ( obj.enbErasure )
erasure = varargin{ 5 };
[ softValue0, softValue1, validOut ] = obj.softBitUnitObj( softBits,  ...
valid, frameGapValid, erasure );
else 

[ softValue0, softValue1, validOut ] = obj.softBitUnitObj( softBits,  ...
valid, frameGapValid );
end 
[ branchMetOut, BmvalidOut ] =  ...
obj.branchMetricUnitObj( softValue0, softValue1, validOut );
obj.branchMetReg = branchMetOut;
obj.validReg = BmvalidOut;
obj.ctrlReg = obj.delayBalance( ctrl );
else 

if ( obj.enbErasure )
erasure = varargin{ 3 };

if ( obj.continuousModeReset )
reset = varargin{ 4 };
[ softValue0, softValue1, validOut ] =  ...
obj.softBitUnitObj( softBits, valid, reset, erasure );
else 
[ softValue0, softValue1, validOut ] = obj.softBitUnitObj( softBits,  ...
valid, erasure );
end 
else 

if ( obj.continuousModeReset )
reset = varargin{ 3 };
[ softValue0, softValue1, validOut ] =  ...
obj.softBitUnitObj( softBits, valid, reset );
else 
[ softValue0, softValue1, validOut ] = obj.softBitUnitObj( softBits,  ...
valid );
end 
end 
[ branchMetOut, validOut ] = obj.branchMetricUnitObj( softValue0,  ...
softValue1, validOut );
obj.branchMetReg = branchMetOut;
obj.validReg = validOut;
end 
end 

function num = getNumInputsImpl( obj )
num = 2;
if ( obj.frameSignal )
num = num + 2;
if ( obj.enbErasure )
num = num + 1;
end 
else 
if ( obj.enbErasure )
num = num + 1;
if ( obj.continuousModeReset )
num = num + 1;
end 
else 
if ( obj.continuousModeReset )
num = num + 1;
end 
end 
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'softBits';
varargout{ 2 } = 'valid';
if ( obj.frameSignal )
varargout{ 3 } = 'frameGapValid';
varargout{ 4 } = 'ctrl';
if ( obj.enbErasure )
varargout{ 5 } = 'erasure';
end 
else 
varargout{ 2 } = 'valid';
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
num = 2;
if ( obj.frameSignal )
num = num + 1;
end 
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'branchMetOut';
varargout{ 2 } = 'validOut';
if ( obj.frameSignal )
varargout{ 3 } = 'ctrl';
end 
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.softBitUnitObj = obj.softBitUnitObj;
s.branchMetricUnitObj = obj.branchMetricUnitObj;
s.ctrld = obj.ctrld;
s.delayBalance = obj.delayBalance;
s.nbranches = obj.nbranches;
s.branchMetReg = obj.branchMetReg;
s.validReg = obj.validReg;
s.ctrlReg = obj.ctrlReg;
s.nBranches = obj.nBranches;
s.numOutputSyms = obj.numOutputSyms;
s.branchMetWordLen = obj.branchMetWordLen;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDiTEcz.p.
% Please follow local copyright laws when handling this file.

