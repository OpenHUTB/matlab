classdef ( StrictDefaults )ViterbiDecoderFrameController < matlab.System








%#codegen





properties ( Nontunable )
tbd = 32;
end 

properties ( Nontunable, Access = private )
bufferDepth;
end 

properties ( Access = private )
enbReg;
enbFramEndOp;
startOutBuffer;
validOutBuffer;
endOutBuffer;
startInFlagReg;
enbProcessReg;
frameGapValidReg;
startOutReg;
endOutReg;
validOutReg;
end 





methods 

function obj = ViterbiDecoderFrameController( varargin )
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
obj.bufferDepth = 4 * obj.tbd;
obj.startOutBuffer = false( 1, obj.bufferDepth );
obj.validOutBuffer = false( 1, obj.bufferDepth );
obj.endOutBuffer = false( 1, obj.bufferDepth );
end 

function setupImpl( obj )
obj.bufferDepth = 4 * obj.tbd;
obj.startOutBuffer = false( 1, obj.bufferDepth );
obj.validOutBuffer = false( 1, obj.bufferDepth );
obj.endOutBuffer = false( 1, obj.bufferDepth );
resetparams( obj );
end 

function resetparams( obj )
obj.bufferDepth = 4 * obj.tbd;
obj.enbReg = false;
obj.enbFramEndOp = false;


obj.startInFlagReg = false;
obj.enbProcessReg = false;
obj.frameGapValidReg = false;
obj.startOutReg = false;
obj.endOutReg = false;
obj.validOutReg = false;
end 

function flag = getExecutionSemanticsImpl( obj )%#ok

flag = { 'Classic', 'Synchronous' };
end 

function [ startOut, endOut, validOut, startInFlag,  ...
frameGapValid, enbProcess ] = outputImpl( obj, varargin )

startInFlag = obj.startInFlagReg;
enbProcess = obj.enbProcessReg;
frameGapValid = obj.frameGapValidReg;
startOut = obj.startOutReg;
endOut = obj.endOutReg;
validOut = obj.validOutReg;
end 

function updateImpl( obj, varargin )
startIn = varargin{ 1 };
endIn = varargin{ 2 };
validIn = varargin{ 3 };

startInFlag = startIn && validIn;
obj.startInFlagReg = startInFlag;

processStart = startIn && validIn || obj.enbReg;
obj.enbReg = processStart;
enbProcess = ( validIn || obj.enbFramEndOp ) && processStart;
obj.enbProcessReg = enbProcess;


frameGapValid = ~startInFlag && obj.enbFramEndOp;
obj.frameGapValidReg = frameGapValid;

if ( enbProcess )

obj.startOutReg = obj.startOutBuffer( 1 );
obj.startOutBuffer( 1:end  - 1 ) = obj.startOutBuffer( 2:end  );
obj.startOutBuffer( end  ) = startIn && validIn;

obj.endOutReg = obj.endOutBuffer( 1 );
obj.endOutBuffer( 1:end  - 1 ) = obj.endOutBuffer( 2:end  );


obj.endOutBuffer( end  ) = ~obj.enbFramEndOp && ~startIn && endIn;

obj.validOutReg = obj.validOutBuffer( 1 );
obj.validOutBuffer( 1:end  - 1 ) = obj.validOutBuffer( 2:end  );


obj.validOutBuffer( end  ) = ~frameGapValid && validIn;
else 
obj.startOutReg = false;
obj.endOutReg = false;
obj.validOutReg = false;
end 

if ( validIn )
obj.enbFramEndOp = ~startIn && ( obj.enbFramEndOp || endIn );
end 
end 



function num = getNumInputsImpl( ~ )
num = 3;
end 

function varargout = getInputNamesImpl( obj )
varargout = cell( 1, getNumInputs( obj ) );
inputPortInd = 1;
varargout{ inputPortInd } = 'startIn';
inputPortInd = 2;
varargout{ inputPortInd } = 'endIn';
inputPortInd = 3;
varargout{ inputPortInd } = 'validIn';

end 

function num = getNumOutputsImpl( ~ )
num = 6;
end 

function varargout = getOutputNamesImpl( obj )
varargout = cell( 1, getNumOutputs( obj ) );
varargout{ 1 } = 'startOut';
varargout{ 2 } = 'endOut';
varargout{ 3 } = 'validOut';
varargout{ 4 } = 'startInFlag';
varargout{ 5 } = 'frameGapValid';
varargout{ 6 } = 'enbProcess';
end 



function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.enbReg = obj.enbReg;
s.enbFramEndOp = obj.enbFramEndOp;
s.startOutBuffer = obj.startOutBuffer;
s.validOutBuffer = obj.validOutBuffer;
s.endOutBuffer = obj.endOutBuffer;
s.startInFlagReg = obj.startInFlagReg;
s.enbProcessReg = obj.enbProcessReg;
s.frameGapValidReg = obj.frameGapValidReg;
s.startOutReg = obj.startOutReg;
s.endOutReg = obj.endOutReg;
s.validOutReg = obj.validOutReg;
s.bufferDepth = obj.bufferDepth;
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



% Decoded using De-pcode utility v1.2 from file /tmp/tmpWM36Gh.p.
% Please follow local copyright laws when handling this file.

