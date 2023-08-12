classdef ( StrictDefaults )ViterbiDecoderReadAndWriteRAM < matlab.System







%#codegen





properties ( Access = private )
dualPortRam;
validReg;
dataOutDecReg;
dataOutWrReg;
validRegReg;
end 





methods 

function obj = ViterbiDecoderReadAndWriteRAM( varargin )
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
obj.validReg = false;
obj.validRegReg = false;
obj.dataOutDecReg( : ) = 0;
obj.dataOutWrReg( : ) = 0;
end 

function setupImpl( obj, varargin )
dataIn = varargin{ 1 };
obj.dualPortRam = hdl.RAM( 'Dual port', 'Old data', 0 );
obj.validReg = false;
obj.validRegReg = false;
obj.dataOutDecReg = cast( 0, 'like', dataIn );
obj.dataOutWrReg = cast( 0, 'like', dataIn );
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ decodeOut, tracbackOut, validOut ] = outputImpl( obj, varargin )
decodeOut = obj.dataOutDecReg;
tracbackOut = obj.dataOutWrReg;
validOut = obj.validRegReg;
end 

function updateImpl( obj, varargin )

dataInfi = varargin{ 1 };
writeAdress = varargin{ 2 };
ramWriteEnb = varargin{ 3 };
readAdress = varargin{ 4 };
[ obj.dataOutDecReg, obj.dataOutWrReg ] = step( obj.dualPortRam,  ...
dataInfi, writeAdress, ramWriteEnb, readAdress );
obj.validRegReg = obj.validReg;
obj.validReg = ramWriteEnb;
end 

function num = getNumInputsImpl( ~ )
num = 4;
end 











function num = getNumOutputsImpl( ~ )
num = 3;
end 










function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.dualPortRam = obj.dualPortRam;
s.validReg = obj.validReg;
s.dataOutDecReg = obj.dataOutDecReg;
s.dataOutWrReg = obj.dataOutWrReg;
s.validRegReg = obj.validRegReg;
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmptL0PFl.p.
% Please follow local copyright laws when handling this file.

