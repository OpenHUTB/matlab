classdef ( StrictDefaults )ViterbiDecoderTracebackEngine < matlab.System







%#codegen





properties ( Nontunable )
tbd = 32;
end 

properties ( Nontunable, Access = private )
wordLen;
stateWordlen;
end 

properties ( Nontunable )
continuousModeReset( 1, 1 )logical = false;
end 

properties ( Access = private )
count;
tbIndex;
decIndex;
state;
bankDepth;
decBit;
valid;
end 





methods 

function obj = ViterbiDecoderTracebackEngine( varargin )
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

function setupImpl( obj, varargin )
minIndex = varargin{ 3 };
obj.wordLen = ceil( log2( obj.tbd ) );
obj.stateWordlen = minIndex.WordLength;
resetparams( obj );
end 

function resetparams( obj )
obj.count = fi( 0, 0, obj.wordLen, 0, hdlfimath );
obj.tbIndex = fi( 0, 0, obj.stateWordlen, 0 );
obj.decIndex = fi( 0, 0, obj.stateWordlen, 0 );
obj.state = fi( 0, 0, 2, 0, hdlfimath );
obj.bankDepth = fi( obj.tbd - 1, 0, obj.wordLen, 0, hdlfimath );
obj.decBit = fi( 0, 0, 1, 0 );
obj.valid = false;

end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ decOut, validOut ] = outputImpl( obj, varargin )
decOut = obj.decBit;
validOut = obj.valid;
end 

function updateImpl( obj, varargin )
tbOut = varargin{ 1 };
decOut = varargin{ 2 };
minIndex = varargin{ 3 };
enb = varargin{ 4 };
if ( obj.continuousModeReset )
rst = varargin{ 5 };
if ( rst )
resetParams( obj )
else 
tracebackunit( obj, tbOut, decOut, minIndex, enb )
end 
else 
tracebackunit( obj, tbOut, decOut, minIndex, enb )
end 
end 

function resetParams( obj )
obj.decBit( : ) = 0;
obj.valid = false;
obj.state( : ) = 0;
obj.tbIndex( : ) = 0;
obj.decIndex( : ) = 0;
counter( obj, true, true );
end 

function tracebackunit( obj, tbOut, decOut, minIndex, enb )
obj.decBit = bitget( obj.decIndex, obj.stateWordlen );
const_one = fi( 1, 0, obj.stateWordlen, 0 );
tbBit = bitget( tbOut, obj.tbIndex + const_one );
tbDecBit = bitget( decOut, obj.decIndex + const_one );

toggle = ( obj.count( : ) == obj.bankDepth ) && enb;
if ( enb )
if ( toggle )
obj.decIndex = bitconcat( bitsliceget( obj.tbIndex,  ...
obj.stateWordlen - 1, 1 ), tbBit );
obj.tbIndex = minIndex;
else 
obj.tbIndex = bitconcat( bitsliceget( obj.tbIndex,  ...
obj.stateWordlen - 1, 1 ), tbBit );
obj.decIndex = bitconcat( bitsliceget( obj.decIndex,  ...
obj.stateWordlen - 1, 1 ), tbDecBit );
end 
end 

switch ( int32( obj.state ) )
case int32( 0 )
obj.valid = false;
if ( toggle )
obj.state( : ) = obj.state + fi( 1, 0, 1, 0, hdlfimath );
end 
case int32( 1 )
obj.valid = false;
if ( toggle )
obj.state( : ) = obj.state + fi( 1, 0, 1, 0, hdlfimath );
end 
case int32( 2 )
obj.valid = false;
if ( toggle )
obj.state( : ) = obj.state + fi( 1, 0, 1, 0, hdlfimath );
end 
case int32( 3 )
obj.valid = enb;
obj.state( : ) = 3;
otherwise 
obj.valid = false;
obj.state( : ) = 0;
end 

counter( obj, enb, toggle );
end 

function counter( obj, enb, rst )
if ( enb )
if ( rst )
obj.count( : ) = 0;
else 
obj.count( : ) = obj.count + fi( 1, 0, 1, 0, hdlfimath );
end 
end 
end 

function num = getNumInputsImpl( obj )
num = 4;
if ( obj.continuousModeReset )
num = num + 1;
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );

varargout{ 1 } = 'tbOut';
varargout{ 2 } = 'decOut';
varargout{ 3 } = 'minIndex';
varargout{ 4 } = 'enb';
if ( obj.continuousModeReset )
varargout{ 5 } = 'rst';
end 
end 

function num = getNumOutputsImpl( ~ )
num = 2;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'decOut';
varargout{ 2 } = 'validOut';
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.count = obj.count;
s.tbIndex = obj.tbIndex;
s.decIndex = obj.decIndex;
s.state = obj.state;
s.bankDepth = obj.bankDepth;
s.decBit = obj.decBit;
s.valid = obj.valid;
s.wordLen = obj.wordLen;
s.stateWordlen = obj.stateWordlen;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqPqUsQ.p.
% Please follow local copyright laws when handling this file.

