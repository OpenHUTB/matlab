classdef ( StrictDefaults )WLANLDPCCyclicShifter < matlab.System




%#codegen

properties ( Nontunable )
memDepth1 = 81;
end 


properties ( Access = private )
dataOut;
validOut;
dataOutReg;
validOutReg;
end 

methods 


function obj = WLANLDPCCyclicShifter( varargin )
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

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function resetImpl( obj )

obj.dataOut( : ) = zeros( obj.memDepth1, 1 );
obj.validOut = false;
obj.dataOutReg( : ) = zeros( obj.memDepth1, 1 );
obj.validOutReg = false;
end 

function setupImpl( obj, varargin )
obj.dataOut = cast( zeros( obj.memDepth1, 1 ), 'like', varargin{ 1 } );
obj.validOut = false;
obj.dataOutReg = cast( zeros( obj.memDepth1, 1 ), 'like', varargin{ 1 } );
obj.validOutReg = false;
end 

function varargout = outputImpl( obj, varargin )
varargout{ 1 } = obj.dataOutReg;
varargout{ 2 } = obj.validOutReg;
end 

function updateImpl( obj, varargin )
data = varargin{ 1 };

smsize = varargin{ 2 };
V = varargin{ 3 };
offV = cast( varargin{ 4 }, 'like', V );

validin = varargin{ 5 };
shiftData = circshift( data( offV + 1:smsize + offV ), int32( smsize - mod( V, smsize ) ) );
dataout = shiftData';

obj.dataOutReg = obj.dataOut;
if validin
obj.dataOut( 1:smsize ) = dataout;
end 

obj.validOutReg = obj.validOut;
obj.validOut = validin;

end 

function num = getNumInputsImpl( ~ )
num = 5;
end 

function num = getNumOutputsImpl( ~ )
num = 2;
end 












































function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.dataOut = obj.dataOut;
s.validOut = obj.validOut;
s.dataOutReg = obj.dataOutReg;
s.validOutReg = obj.validOutReg;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_KdEol.p.
% Please follow local copyright laws when handling this file.

