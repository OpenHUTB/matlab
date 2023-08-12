classdef ( StrictDefaults )ViterbiDecoderLIFORAMEngine < matlab.System







%#codegen





properties ( Nontunable )
tbd = 32;
end 
properties ( Nontunable, Access = private )
wordLen;
end 

properties ( Nontunable )
continuousModeReset( 1, 1 )logical = false;
end 

properties ( Access = private )
writCnt;
revWrEnb;
bankDepth;
dataInReg;
hRam;
dataOutreg;
validReg;
validEnb;
validRegReg;
end 






methods 

function obj = ViterbiDecoderLIFORAMEngine( varargin )
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
obj.dataOutreg( : ) = 0;
resetparams( obj );
end 
function setupImpl( obj, varargin )
dataIn = varargin{ 1 };
obj.wordLen = ceil( log2( obj.tbd ) );
obj.bankDepth = fi( obj.tbd - 1, 0, obj.wordLen, 0, hdlfimath );
obj.hRam = hdl.RAM( 'RAMType', 'Simple dual port' );
obj.dataOutreg = cast( 0, 'like', dataIn );
resetparams( obj );
end 

function resetparams( obj )
obj.writCnt = fi( 0, 0, obj.wordLen, 0, hdlfimath );
obj.revWrEnb = false;
obj.validEnb = false;
obj.validReg = false;
obj.validRegReg = false;
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ decOut, validOut ] = outputImpl( obj, varargin )
decOut = obj.dataOutreg;
validOut = obj.validRegReg;
end 

function updateImpl( obj, varargin )
dataIn = varargin{ 1 };
enb = varargin{ 2 };
if ( obj.continuousModeReset )
rst = varargin{ 3 };
if ( rst )
resetLifoParams( obj, dataIn, enb );
else 
lifounit( obj, dataIn, enb );
end 
else 
lifounit( obj, dataIn, enb );
end 
end 

function resetLifoParams( obj, dataIn, enb )
revRdWrCount = cast( obj.bankDepth - obj.writCnt, 'like', obj.writCnt );
if ( ~obj.revWrEnb )
readWriteAddrs = obj.writCnt;
else 
readWriteAddrs = revRdWrCount;
end 
obj.dataOutreg = step( obj.hRam, dataIn, readWriteAddrs,  ...
enb, readWriteAddrs );
resetparams( obj );
end 

function lifounit( obj, dataIn, enb )

revRdWrCount = cast( obj.bankDepth - obj.writCnt, 'like', obj.writCnt );
if ( ~obj.revWrEnb )
readWriteAddrs = obj.writCnt;
else 
readWriteAddrs = revRdWrCount;
end 

obj.dataOutreg = step( obj.hRam, dataIn, readWriteAddrs,  ...
enb, readWriteAddrs );
resetCounter = obj.writCnt( : ) == obj.bankDepth;
obj.validRegReg = obj.validReg;

if ( obj.validEnb )
obj.validReg = enb;
else 
obj.validReg = false;
end 

if ( enb )
if ( resetCounter )
obj.validEnb = true;
obj.revWrEnb = ~obj.revWrEnb;
obj.writCnt( : ) = 0;
else 
obj.writCnt( : ) = obj.writCnt + fi( 1, 0, 1, 0, hdlfimath );
end 
end 
end 

function num = getNumInputsImpl( obj )
num = 2;
if ( obj.continuousModeReset )
num = num + 1;
end 
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );

varargout{ 1 } = 'dataIn';
varargout{ 2 } = 'enb';
if ( obj.continuousModeReset )
varargout{ 3 } = 'rst';

end 
end 

function num = getNumOutputsImpl( ~ )
num = 2;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
outputPortInd = 1;
varargout{ outputPortInd } = 'decOut';
outputPortInd = outputPortInd + 1;
varargout{ outputPortInd } = 'validOut';
end 




function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.writCnt = obj.writCnt;
s.revWrEnb = obj.revWrEnb;
s.bankDepth = obj.bankDepth;
s.dataInReg = obj.dataInReg;
s.hRam = obj.hRam;
s.dataOutreg = obj.dataOutreg;
s.validReg = obj.validReg;
s.validEnb = obj.validEnb;
s.validRegReg = obj.validRegReg;
s.wordLen = obj.wordLen;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVaQfm0.p.
% Please follow local copyright laws when handling this file.

