classdef ( StrictDefaults )ViterbiDecoderMinmetricUnit < matlab.System







%#codegen




properties ( Nontunable )
Stage = 8;
end 


properties ( Access = private )
minPathIndx;
minPathMet;
validIn;
NxtTreeStageA;
NxtTreeStageB;
minPathIndxA;
minPathMetA;
minPathIndxB;
minPathMetB;
validA;
end 




methods 

function obj = ViterbiDecoderMinmetricUnit( varargin )
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
stateType = varargin{ 1 };
minInxType = varargin{ 2 };
resetparams( obj, stateType, minInxType );
obj.NxtTreeStageA = commhdl.internal.ViterbiDecoderMinmetricUnit( 'Stage', obj.Stage - 1 );
obj.NxtTreeStageB = commhdl.internal.ViterbiDecoderMinmetricUnit( 'Stage', obj.Stage - 1 );
end 

function resetparams( obj, stateType, minInxType )
obj.validIn = false;
obj.minPathIndx = cast( 0, 'like', minInxType );
obj.minPathMet = cast( 0, 'like', stateType );
obj.minPathIndxA = cast( 0, 'like', minInxType );
obj.minPathMetA = cast( 0, 'like', stateType );
obj.minPathIndxB = cast( 1, 'like', minInxType );
obj.minPathMetB = cast( 0, 'like', stateType );
obj.validA = false;
end 

function resetImpl( obj )
resetparams( obj, obj.minPathMet, obj.minPathIndx )
if ~( obj.Stage == 2 )
reset( obj.NxtTreeStageB )
reset( obj.NxtTreeStageA )
end 
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ minState, minIndex, validOut ] = outputImpl( obj, varargin )
minState = obj.minPathMet;
minIndex = obj.minPathIndx;
validOut = obj.validIn;
end 


function updateImpl( obj, varargin )

stateMetrics = varargin{ 1 };
indices = varargin{ 2 };
valid = varargin{ 3 };
nxtTreestageMetA = stateMetrics( 1:2 ^ ( obj.Stage - 1 ) );
nxtTreestageMetB = stateMetrics( ( 2 ^ ( obj.Stage - 1 ) + 1 ):2 ^ ( obj.Stage ) );
nxtTreestageIndxA = indices( 1:2 ^ ( obj.Stage - 1 ) );
nxtTreestageIndxB = indices( ( 2 ^ ( obj.Stage - 1 ) + 1 ):2 ^ ( obj.Stage ) );

if ( obj.Stage == 2 )
minMet = [ obj.minPathMetA, obj.minPathMetB ];
minIndx = [ obj.minPathIndxA, obj.minPathIndxB ];
[ obj.minPathMet, obj.minPathIndx, obj.validIn ] = findMinUnit0( obj, minMet,  ...
minIndx, obj.validA );
[ obj.minPathMetA, obj.minPathIndxA, obj.validA ] = findMinUnit0( obj, nxtTreestageMetA,  ...
nxtTreestageIndxA, valid );
[ obj.minPathMetB, obj.minPathIndxB, ~ ] = findMinUnit0( obj, nxtTreestageMetB,  ...
nxtTreestageIndxB, valid );
else 
[ minMetA, minIndxA, validtmp ] = step( obj.NxtTreeStageA, nxtTreestageMetA,  ...
nxtTreestageIndxA, valid );
[ minMetB, minIndxB, ~ ] = step( obj.NxtTreeStageB, nxtTreestageMetB,  ...
nxtTreestageIndxB, valid );
minMet = [ minMetA, minMetB ];
minIndx = [ minIndxA, minIndxB ];

[ obj.minPathMet, obj.minPathIndx, obj.validIn ] = findMinUnit0( obj, minMet,  ...
minIndx, validtmp );
end 

end 

function [ minMetric, minIndex, valid ] = findMinUnit0( ~, stateMetrics, indices, validIn )
valid = validIn;
metricA = stateMetrics( 1 );
metricB = stateMetrics( 2 );
indexA = indices( 1 );
indexB = indices( 2 );

diff = cast( metricB - metricA, 'like', metricA );
if isa( diff, 'single' ) || isa( diff, 'double' )
tmp = diff >= 0;
else 
tmp = getmsb( diff ) == cast( 0, 'like', diff );
end 

if ( tmp )
minMetric = metricA;
minIndex = indexA;
else 
minMetric = metricB;
minIndex = indexB;
end 
end 
function num = getNumInputsImpl( obj )
num = 3;
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
inputPortInd = 1;
varargout{ inputPortInd } = 'StateMetrics';
inputPortInd = 2;
varargout{ inputPortInd } = 'Indices';
inputPortInd = 3;
varargout{ inputPortInd } = 'validIn';

end 

function num = getNumOutputsImpl( ~ )
num = 3;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
outputPortInd = 1;
varargout{ outputPortInd } = 'minState';
outputPortInd = outputPortInd + 1;
varargout{ outputPortInd } = 'minIndx';
outputPortInd = outputPortInd + 1;
varargout{ outputPortInd } = 'validOut';
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.minPathIndx = obj.minPathIndx;
s.minPathMet = obj.minPathMet;
s.validIn = obj.validIn;
s.NxtTreeStageA = obj.NxtTreeStageA;
s.NxtTreeStageB = obj.NxtTreeStageB;

s.minPathIndxA = obj.minPathIndxA;
s.minPathMetA = obj.minPathMetA;
s.minPathIndxB = obj.minPathIndxB;
s.minPathMetB = obj.minPathMetB;
s.validA = obj.validA;
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



% Decoded using De-pcode utility v1.2 from file /tmp/tmpPP4x9A.p.
% Please follow local copyright laws when handling this file.

