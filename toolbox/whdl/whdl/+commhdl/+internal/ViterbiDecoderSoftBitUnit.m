classdef ( StrictDefaults )ViterbiDecoderSoftBitUnit < matlab.System









%#codegen





properties ( Nontunable )
enbErasure( 1, 1 )logical = false;
enbReset( 1, 1 )logical = true;
end 


properties ( Access = private )
posSoftBit;
negSoftBit;
valid;
end 

properties ( Nontunable, Access = private )
Len;
Max;
end 





methods 

function obj = ViterbiDecoderSoftBitUnit( varargin )
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
obj.valid = false;
obj.posSoftBit( : ) = 0;
obj.negSoftBit( : ) = 0;
end 

function setupImpl( obj, varargin )
softBits = varargin{ 1 };
obj.Len = length( softBits );

obj.valid = false;

if ( isa( softBits, 'embedded.fi' ) && isfixed( softBits ) ) &&  ...
~issigned( softBits )
obj.Max = realmax( softBits );
end 

if ( isa( softBits, 'embedded.fi' ) && isfixed( softBits ) ) &&  ...
issigned( softBits )
obj.posSoftBit = fi( zeros( 1, obj.Len ), 1, softBits.WordLength + 1, 0 );
obj.negSoftBit = fi( zeros( 1, obj.Len ), 1, softBits.WordLength + 1, 0 );
else 
obj.posSoftBit = zeros( 1, obj.Len, 'like', softBits );
obj.negSoftBit = zeros( 1, obj.Len, 'like', softBits );
end 
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ softValue0, softValue1, validOut ] = outputImpl( obj, varargin )
softValue0 = obj.posSoftBit;
softValue1 = obj.negSoftBit;
validOut = obj.valid;
end 

function updateImpl( obj, varargin )
softBits = varargin{ 1 };
validIn = varargin{ 2 };
obj.valid = validIn;
if ( obj.enbReset )

reset = varargin{ 3 };
if ( obj.enbErasure )
erasure = varargin{ 4 };
end 
else 
if ( obj.enbErasure )
erasure = varargin{ 3 };
end 
end 

if ( obj.enbReset )

if ( reset )
for i = 1:obj.Len
obj.posSoftBit( i ) = 0;
obj.negSoftBit( i ) = 0;
end 
else 
if ( validIn )
if ( obj.enbErasure )
posNegSoftBitsWithErasure( obj, softBits, erasure )
else 
posNegSoftBits( obj, softBits )
end 
end 
end 
else 
if ( validIn )
if ( obj.enbErasure )
posNegSoftBitsWithErasure( obj, softBits, erasure )
else 
posNegSoftBits( obj, softBits )
end 
end 
end 

end 

function posNegSoftBits( obj, softBits )
softBits = cast( softBits, 'like', obj.posSoftBit );
if ( isa( softBits, 'embedded.fi' ) && isfixed( softBits ) ) && ~issigned( softBits )

for i = 1:obj.Len
obj.posSoftBit( i ) = softBits( i );
obj.negSoftBit( i ) = obj.Max - softBits( i );
end 
else 
for i = 1:obj.Len
obj.posSoftBit( i ) = softBits( i );
obj.negSoftBit( i ) =  - softBits( i );
end 
end 
end 

function posNegSoftBitsWithErasure( obj, softBits, erasure )
softBits = cast( softBits, 'like', obj.posSoftBit );
if ( isa( softBits, 'embedded.fi' ) && isfixed( softBits ) ) && ~issigned( softBits )

for i = 1:obj.Len
if ( erasure( i ) )
obj.posSoftBit( i ) = 0;
obj.negSoftBit( i ) = 0;
else 
obj.posSoftBit( i ) = softBits( i );
obj.negSoftBit( i ) = obj.Max - softBits( i );
end 
end 
else 
for i = 1:obj.Len
if ( erasure( i ) )
obj.posSoftBit( i ) = 0;
obj.negSoftBit( i ) = 0;
else 
obj.posSoftBit( i ) = softBits( i );
obj.negSoftBit( i ) =  - softBits( i );
end 
end 
end 

end 

function num = getNumInputsImpl( obj )
num = 2;
if ( ~obj.enbReset )
if ( obj.enbErasure )
num = num + 1;
end 
else 
num = num + 1;
if ( obj.enbErasure )
num = num + 1;
end 
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'softBits';
varargout{ 2 } = 'valid';
if ( ~obj.enbReset )
if ( obj.enbErasure )
varargout{ 3 } = 'erasure';
end 
else 
varargout{ 3 } = 'reset';
if ( obj.enbErasure )
varargout{ 4 } = 'erasure';
end 
end 
end 

function num = getNumOutputsImpl( ~ )
num = 3;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'posSoftVal';
varargout{ 2 } = 'negSoftVal';
varargout{ 3 } = 'validOut';
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.posSoftBit = obj.posSoftBit;
s.negSoftBit = obj.negSoftBit;
s.valid = obj.valid;
s.Len = obj.Len;
s.Max = obj.Max;
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpHjX4dy.p.
% Please follow local copyright laws when handling this file.

