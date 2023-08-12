classdef ( StrictDefaults )ViterbiDecoderTracebackEngineConst9 < matlab.System







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

function obj = ViterbiDecoderTracebackEngineConst9( varargin )
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
minIndex = varargin{ 5 };
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
tbOutL = varargin{ 1 };
tbOutH = varargin{ 2 };
decOutL = varargin{ 3 };
decOutH = varargin{ 4 };
minIndex = varargin{ 5 };
enb = varargin{ 6 };
if ( obj.continuousModeReset )
rst = varargin{ 7 };
if ( rst )
resetParams( obj )
else 
tracebackunit( obj, tbOutL, tbOutH, decOutL, decOutH, minIndex, enb )
end 
else 
tracebackunit( obj, tbOutL, tbOutH, decOutL, decOutH, minIndex, enb )
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

function tracebackunit( obj, tbOutL, tbOutH, decOutL, decOutH, minIndex, enb )
obj.decBit = bitget( obj.decIndex, obj.stateWordlen );
const_one = fi( 1, 0, obj.stateWordlen, 0 );
if ( obj.tbIndex( : ) > 127 )
tbhigh = fi( obj.tbIndex - 128, 0, obj.stateWordlen, 0 );
tbBit = bitget( tbOutH, tbhigh + const_one );
else 
tbBit = bitget( tbOutL, obj.tbIndex + const_one );
end 

if ( obj.decIndex( : ) > 127 )
dechigh = cast( obj.decIndex - 128, 'like', obj.decIndex );
tbDecBit = bitget( decOutH, dechigh + const_one );
else 
tbDecBit = bitget( decOutL, obj.decIndex + const_one );
end 


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
num = 6;
if ( obj.continuousModeReset )
num = num + 1;
end 
end 















function num = getNumOutputsImpl( ~ )
num = 2;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMOwuHF.p.
% Please follow local copyright laws when handling this file.

