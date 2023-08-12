classdef ( StrictDefaults )ViterbiDecoderBranchMetricUnit < matlab.System







%#codegen





properties ( Access = private )
branchMetReg;
valid;
end 

properties ( Nontunable, Access = private )
Len;
branchMetWordLen;
selUnit;
numOutputSyms;
end 




methods 

function obj = ViterbiDecoderBranchMetricUnit( varargin )
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
obj.branchMetReg( : ) = 0;
obj.valid = false;
end 

function setupImpl( obj, varargin )
type = varargin{ 1 };
obj.Len = length( type );
obj.selUnit = fi( obj.Len - 2, 0, 3, 0 );
obj.valid = false;
obj.numOutputSyms = pow2( obj.Len );
nBranchs = obj.Len;
if ( isa( type, 'embedded.fi' ) && isfixed( type ) )
if ( issigned( type ) )
nsDec = type.WordLength - 1;
else 
nsDec = type.WordLength;
end 
calculateWordLen( obj, nsDec, nBranchs, type );
else 
obj.branchMetReg = zeros( 1, obj.numOutputSyms );
end 
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ branchMetOut, validOut ] = outputImpl( obj, varargin )
validOut = obj.valid;
branchMetOut = obj.branchMetReg;
end 

function updateImpl( obj, varargin )
softValue0 = varargin{ 1 };
softValue1 = varargin{ 2 };
obj.valid( : ) = varargin{ 3 };
obj.branchMetReg( : ) = selectionUnit( obj, softValue0, softValue1 );
end 

function branchMet = selectionUnit( obj, softValue0, softValue1 )
switch ( uint32( obj.selUnit ) )
case uint32( 0 )
branchMet = treeArchBranchMetCompute0( obj, softValue0,  ...
softValue1 );
case uint32( 1 )
branchMet = treeArchBranchMetCompute1( obj, softValue0,  ...
softValue1 );
case uint32( 2 )
branchMet = treeArchBranchMetCompute2( obj, softValue0,  ...
softValue1 );
case uint32( 3 )
branchMet = treeArchBranchMetCompute3( obj, softValue0,  ...
softValue1 );
case uint32( 4 )
branchMet = treeArchBranchMetCompute4( obj, softValue0,  ...
softValue1 );
case uint32( 5 )
branchMet = treeArchBranchMetCompute5( obj, softValue0,  ...
softValue1 );
otherwise 

branchMet = treeArchBranchMetCompute0( obj, softValue0,  ...
softValue1 );
end 
end 


function branchMet = treeArchBranchMetCompute0( obj, softValue0, softValue1 )
branchMet = zeros( obj.numOutputSyms, 1, 'like', obj.branchMetReg );
branchMet( 1 ) = softValue0( 1 ) + softValue0( 2 );
branchMet( 2 ) = softValue0( 1 ) + softValue1( 2 );
branchMet( 3 ) = softValue1( 1 ) + softValue0( 2 );
branchMet( 4 ) = softValue1( 1 ) + softValue1( 2 );
end 


function branchMet = treeArchBranchMetCompute1( obj, softValue0, softValue1 )
branchMet = zeros( obj.numOutputSyms, 1, 'like', obj.branchMetReg );
branchMet( 1 ) = branchMetricAdd3( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ) );
branchMet( 2 ) = branchMetricAdd3( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ) );
branchMet( 3 ) = branchMetricAdd3( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ) );
branchMet( 4 ) = branchMetricAdd3( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ) );
branchMet( 5 ) = branchMetricAdd3( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ) );
branchMet( 6 ) = branchMetricAdd3( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ) );
branchMet( 7 ) = branchMetricAdd3( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ) );
branchMet( 8 ) = branchMetricAdd3( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ) );
end 
function brachMerticAddOut = branchMetricAdd3( ~, BMin1, BMin2, BMin3 )
add0 = BMin1 + BMin2;
brachMerticAddOut = add0 + BMin3;
end 


function branchMet = treeArchBranchMetCompute2( obj, softValue0, softValue1 )
branchMet = zeros( obj.numOutputSyms, 1, 'like', obj.branchMetReg );
branchMet( 1 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ) );
branchMet( 2 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ) );
branchMet( 3 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ) );
branchMet( 4 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ) );
branchMet( 5 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ) );
branchMet( 6 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ) );
branchMet( 7 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ) );
branchMet( 8 ) = branchMetricAdd4( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ) );
branchMet( 9 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ) );
branchMet( 10 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ) );
branchMet( 11 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ) );
branchMet( 12 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ) );
branchMet( 13 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ) );
branchMet( 14 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ) );
branchMet( 15 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ) );
branchMet( 16 ) = branchMetricAdd4( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ) );
end 

function brachMerticAddOut = branchMetricAdd4( ~, BMin1, BMin2, BMin3, BMin4 )
add0 = BMin1 + BMin2;
add1 = BMin3 + BMin4;
brachMerticAddOut = add0 + add1;
end 


function branchMet = treeArchBranchMetCompute3( obj, softValue0, softValue1 )
branchMet = zeros( obj.numOutputSyms, 1, 'like', obj.branchMetReg );
branchMet( 1 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 2 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 3 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 4 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ) );
branchMet( 5 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 6 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 7 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 8 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ) );
branchMet( 9 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 10 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 11 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 12 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ) );
branchMet( 13 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 14 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 15 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 16 ) = branchMetricAdd5( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ) );
branchMet( 17 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 18 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 19 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 20 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ) );
branchMet( 21 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 22 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 23 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 24 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ) );
branchMet( 25 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 26 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 27 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 28 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ) );
branchMet( 29 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ) );
branchMet( 30 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ) );
branchMet( 31 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ) );
branchMet( 32 ) = branchMetricAdd5( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ) );

end 
function brachMerticAddOut = branchMetricAdd5( ~, BMin1, BMin2, BMin3, BMin4, BMin5 )
add0 = BMin1 + BMin2;
add1 = BMin3 + BMin4;
add2 = add0 + add1;
brachMerticAddOut = BMin5 + add2;
end 


function branchMet = treeArchBranchMetCompute4( obj, softValue0, softValue1 )
branchMet = zeros( obj.numOutputSyms, 1, 'like', obj.branchMetReg );
branchMet( 2 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 3 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 1 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 4 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 5 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 6 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 7 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 8 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 9 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 10 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 11 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 12 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 13 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 14 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 15 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 16 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 17 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 18 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 19 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 20 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 21 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 22 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 23 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 24 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 25 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 26 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 27 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 28 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 29 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 30 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 31 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 32 ) = branchMetricAdd6( obj, softValue0( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 33 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 34 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 35 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 36 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 37 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 38 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 39 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 40 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 41 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 42 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 43 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 44 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 45 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 46 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 47 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 48 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue0( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 49 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 50 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 51 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 52 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 53 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 54 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 55 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 56 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 57 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 58 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 59 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 60 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ) );
branchMet( 61 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ) );
branchMet( 62 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ) );
branchMet( 63 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ) );
branchMet( 64 ) = branchMetricAdd6( obj, softValue1( 1 ), softValue1( 2 ),  ...
softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ) );
end 
function brachMerticAddOut = branchMetricAdd6( ~, BMin1, BMin2, BMin3, BMin4, BMin5, BMin6 )
add0 = BMin1 + BMin2;
add1 = BMin3 + BMin4;
add2 = BMin5 + BMin6;
add3 = add0 + add1;
brachMerticAddOut = add3 + add2;
end 


function branchMet = treeArchBranchMetCompute5( obj, softValue0, softValue1 )
branchMet = zeros( obj.numOutputSyms, 1, 'like', obj.branchMetReg );
branchMet( 1 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 2 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 3 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 4 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 5 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 6 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 7 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 8 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 9 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 10 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 11 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 12 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 13 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 14 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 15 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 16 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 17 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 18 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 19 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 20 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 21 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 22 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 23 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 24 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 25 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 26 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 27 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 28 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 29 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 30 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 31 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 32 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 33 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 34 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 35 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 36 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 37 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 38 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 39 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 40 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 41 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 42 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 43 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 44 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 45 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 46 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 47 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 48 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 49 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 50 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 51 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 52 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 53 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 54 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 55 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 56 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 57 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 58 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 59 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 60 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 61 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 62 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 63 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 64 ) = branchMetricAdd7( obj, softValue0( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 65 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 66 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 67 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 68 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 69 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 70 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 71 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 72 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 73 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 74 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 75 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 76 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 77 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 78 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 79 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 80 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 81 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 82 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 83 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 84 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 85 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 86 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 87 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 88 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 89 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 90 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 91 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 92 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 93 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 94 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 95 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 96 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue0( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 97 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 98 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 99 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 100 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 101 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 102 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 103 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 104 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 105 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 106 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 107 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 108 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 109 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 110 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 111 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 112 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue0( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 113 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 114 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 115 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 116 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 117 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 118 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 119 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 120 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue0( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 121 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 122 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 123 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 124 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue0( 5 ), softValue1( 6 ), softValue1( 7 ) );
branchMet( 125 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue0( 7 ) );
branchMet( 126 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue0( 6 ), softValue1( 7 ) );
branchMet( 127 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue0( 7 ) );
branchMet( 128 ) = branchMetricAdd7( obj, softValue1( 1 ), softValue1( 2 ), softValue1( 3 ), softValue1( 4 ), softValue1( 5 ), softValue1( 6 ), softValue1( 7 ) );
end 
function brachMerticAddOut = branchMetricAdd7( ~, BMin1, BMin2, BMin3, BMin4, BMin5, BMin6, BMin7 )
add0 = BMin1 + BMin2;
add1 = BMin3 + BMin4;
add2 = BMin5 + BMin6;
add3 = add0 + add1;
add4 = BMin7 + add2;
brachMerticAddOut = add3 + add4;
end 

function calculateWordLen( obj, nsDec, nBranchs, type )
if ( isa( type, 'embedded.fi' ) && isfixed( type ) )
if issigned( type )
branchMetMax = ( 2 ^ ( nsDec - 1 ) ) * nBranchs;
obj.branchMetWordLen = ( floor( log2( branchMetMax ) ) + 1 ) + 1;
obj.branchMetReg = fi( zeros( 1, obj.numOutputSyms ), 1, obj.branchMetWordLen, 0 );
else 
branchMetMax = ( ( 2 ^ nsDec ) - 1 ) * nBranchs;
obj.branchMetWordLen = ( floor( log2( branchMetMax ) ) + 1 );
obj.branchMetReg = fi( zeros( 1, obj.numOutputSyms ), 0, obj.branchMetWordLen, 0 );
end 

else 
obj.branchMetReg = zeros( 1, obj.numOutputSyms );
end 
end 

function num = getNumInputsImpl( ~ )
num = 3;
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'posSoftVal';
varargout{ 2 } = 'negSoftVal';
varargout{ 3 } = 'valid';
end 

function num = getNumOutputsImpl( ~ )
num = 2;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'branchMet';
varargout{ 2 } = 'validOut';
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.branchMetReg = obj.branchMetReg;
s.valid = obj.valid;
s.Len = obj.Len;
s.branchMetWordLen = obj.branchMetWordLen;
s.selUnit = obj.selUnit;
s.numOutputSyms = obj.numOutputSyms;
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmp7yeL3T.p.
% Please follow local copyright laws when handling this file.

