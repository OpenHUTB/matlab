classdef ( StrictDefaults )ViterbiDecoderAddressGenerator < matlab.System







%#codegen





properties ( Nontunable )
tbd = 32;

continuousModeReset( 1, 1 )logical = false;
end 

properties ( Access = private )
state;
ptWr;
ptTb;
count;
wrAdrr;
tbdAdrr;
enbReg;
bankDepth;
offsetWriteAdrr;
offsetReadAdrr;
end 

properties ( Nontunable, Access = private )
wordLen;
memwordLen;
end 





methods 

function obj = ViterbiDecoderAddressGenerator( varargin )
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
resetparams( obj );
end 

function setupImpl( obj )
obj.wordLen = ceil( log2( obj.tbd ) );
obj.memwordLen = ceil( log2( 3 * obj.tbd ) );
obj.bankDepth = fi( obj.tbd - 1, 0, obj.wordLen, 0, hdlfimath );
resetparams( obj );
end 

function resetparams( obj )
obj.state = fi( 0, 0, 2, 0 );
obj.ptWr = true;
obj.ptTb = true;
obj.count = fi( 0, 0, obj.wordLen, 0, hdlfimath );
obj.wrAdrr = fi( 0, 0, obj.memwordLen, 0, hdlfimath );
obj.tbdAdrr = fi( 0, 0, obj.memwordLen, 0, hdlfimath );
obj.offsetWriteAdrr = fi( 0, 0, obj.memwordLen, 0, hdlfimath );
obj.offsetReadAdrr = fi( 2 * obj.tbd, 0, obj.memwordLen, 0, hdlfimath );
obj.enbReg = false;
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ writeAdress, readAdress, valid ] = outputImpl( obj, varargin )
valid = obj.enbReg;
writeAdress = cast( obj.wrAdrr + obj.offsetWriteAdrr,  ...
'like', obj.offsetWriteAdrr );
readAdress = cast( obj.tbdAdrr + obj.offsetReadAdrr,  ...
'like', obj.offsetReadAdrr );
end 

function updateImpl( obj, varargin )
enb = varargin{ 1 };
if ( obj.continuousModeReset )
reset = varargin{ 2 };
if ( reset )
resetParameters( obj );
else 
addresscontroller( obj, enb );
end 
else 
addresscontroller( obj, enb );
end 
end 

function resetParameters( obj )

resetparams( obj );
end 

function addresscontroller( obj, enb )
obj.enbReg( : ) = enb;
revCount = cast( obj.bankDepth - obj.count, 'like', obj.count );


if ( obj.ptWr )
obj.wrAdrr( : ) = obj.count;
else 
obj.wrAdrr( : ) = revCount;
end 

if ( obj.ptTb )
obj.tbdAdrr( : ) = obj.count;
else 
obj.tbdAdrr( : ) = revCount;
end 
statechange = ( obj.count( : ) == obj.bankDepth ) && enb;

switch ( int32( obj.state ) )
case int32( 0 )
obj.offsetWriteAdrr( : ) = 0;
obj.offsetReadAdrr( : ) = 2 * obj.tbd;
if ( statechange )
obj.state( : ) = 1;
obj.ptTb = ~obj.ptTb;
end 
case int32( 1 )
obj.offsetWriteAdrr( : ) = obj.tbd;
obj.offsetReadAdrr( : ) = 0;
if ( statechange )
obj.state( : ) = 2;
end 
case int32( 2 )
obj.offsetWriteAdrr( : ) = 2 * obj.tbd;
obj.offsetReadAdrr( : ) = obj.tbd;
if ( statechange )
obj.state( : ) = 0;
obj.ptWr = ~obj.ptWr;
end 
otherwise 
obj.offsetWriteAdrr( : ) = 0;
obj.offsetReadAdrr( : ) = 2 * obj.tbd;
obj.state( : ) = 0;
end 

if ( enb )
rst = obj.count( : ) == obj.bankDepth;
if ( rst )
obj.count( : ) = 0;
else 
obj.count( : ) = obj.count + fi( 1, 0, 1, 0, hdlfimath );
end 
end 
end 

function num = getNumInputsImpl( obj )
num = 1;
if ( obj.continuousModeReset )
num = num + 1;
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
varargout{ 1 } = 'enb';
if ( obj.continuousModeReset )
varargout{ 2 } = 'reset';
end 
end 


function num = getNumOutputsImpl( ~ )
num = 3;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'writeAdress';
varargout{ 2 } = 'readAdress';
varargout{ 3 } = 'valid';
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.state = obj.state;
s.ptWr = obj.ptWr;
s.ptTb = obj.ptTb;
s.count = obj.count;
s.wrAdrr = obj.wrAdrr;
s.tbdAdrr = obj.tbdAdrr;
s.enbReg = obj.enbReg;
s.bankDepth = obj.bankDepth;
s.offsetWriteAdrr = obj.offsetWriteAdrr;
s.offsetReadAdrr = obj.offsetReadAdrr;
s.wordLen = obj.wordLen;
s.memwordLen = obj.memwordLen;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpt0yDDp.p.
% Please follow local copyright laws when handling this file.

