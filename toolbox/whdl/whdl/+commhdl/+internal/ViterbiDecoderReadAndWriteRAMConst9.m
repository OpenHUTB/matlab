classdef ( StrictDefaults )ViterbiDecoderReadAndWriteRAMConst9 < matlab.System








%#codegen





properties ( Access = private )
dualPortRamL;
dualPortRamH;
validReg;
dataOutDecRegL;
dataOutWrRegL;
dataOutDecRegH;
dataOutWrRegH;
validRegReg;
end 

properties ( Nontunable, Access = private )
dataType;
end 





methods 

function obj = ViterbiDecoderReadAndWriteRAMConst9( varargin )
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
dataIn = varargin{ 1 };
obj.dualPortRamL = hdl.RAM( 'Dual port', 'Old data', 0 );
obj.dualPortRamH = hdl.RAM( 'Dual port', 'Old data', 0 );
obj.dataType = cast( 0, 'like', dataIn );
resetparams( obj );
end 

function resetparams( obj )
obj.validReg = false;
obj.validRegReg = false;
obj.dataOutDecRegL = cast( 0, 'like', obj.dataType );
obj.dataOutWrRegL = cast( 0, 'like', obj.dataType );
obj.dataOutDecRegH = cast( 0, 'like', obj.dataType );
obj.dataOutWrRegH = cast( 0, 'like', obj.dataType );
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ decodeOutL, decodeOutH, tracbackOutL,  ...
tracbackOutH, validOut ] = outputImpl( obj, varargin )
decodeOutL = obj.dataOutDecRegL;
tracbackOutL = obj.dataOutWrRegL;
decodeOutH = obj.dataOutDecRegH;
tracbackOutH = obj.dataOutWrRegH;
validOut = obj.validRegReg;
end 

function updateImpl( obj, dataInfiL, dataInfiH, writeAdress, ramWriteEnb, readAdress )
[ obj.dataOutDecRegL, obj.dataOutWrRegL ] = step( obj.dualPortRamL,  ...
dataInfiL, writeAdress, ramWriteEnb, readAdress );
[ obj.dataOutDecRegH, obj.dataOutWrRegH ] = step( obj.dualPortRamH,  ...
dataInfiH, writeAdress, ramWriteEnb, readAdress );
obj.validRegReg = obj.validReg;
obj.validReg = ramWriteEnb;
end 

function num = getNumInputsImpl( ~ )
num = 5;
end 













function num = getNumOutputsImpl( ~ )
num = 5;
end 












function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.dualPortRamL = obj.dualPortRamL;
s.dualPortRamH = obj.dualPortRamH;
s.validReg = obj.validReg;
s.dataOutDecRegL = obj.dataOutDecRegL;
s.dataOutWrRegL = obj.dataOutWrRegL;
s.dataOutDecRegH = obj.dataOutDecRegH;
s.dataOutWrRegH = obj.dataOutWrRegH;
s.validRegReg = obj.validRegReg;
s.dataType = obj.dataType;
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ1FUSv.p.
% Please follow local copyright laws when handling this file.

