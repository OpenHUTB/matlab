classdef ( StrictDefaults )WLANLDPCFinalDecision < matlab.System




%#codegen

properties ( Nontunable )
Standard = 'IEEE 802.11 n/ac/ax'
scalarFlag = 8;
end 


properties ( Access = private )
decBits;
ctrl;
countMax;
count;
decision;
dataOut;
finShift;
offSetVal;
offsetLUT;
iterDone;
zCount;
zCount2;
cntEnb;
endD;
zLUT;
memDepth;
end 

properties ( Constant, Hidden )
StandardSet = matlab.system.StringSet( { 'IEEE 802.11 n/ac/ax', 'IEEE 802.11 ad' } );
end 

methods 


function obj = WLANLDPCFinalDecision( varargin )
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

obj.decBits( : ) = zeros( obj.memDepth, 1 );
obj.ctrl = struct( 'start', false, 'end', false, 'valid', false );
obj.finShift( : ) = fi( 0, 0, 7, 0 );
end 

function setupImpl( obj, varargin )
if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
ramWL = 5;maxCol = fi( [ 12, 16, 18, 20 ], 0, ramWL, 0 );%#ok<*NASGU> 
obj.memDepth = 81;
else 
ramWL = 4;maxCol = fi( [ 8, 10, 12, 13 ], 0, ramWL, 0 );
obj.memDepth = 42;
end 
obj.decBits = zeros( obj.memDepth, 1 ) > 0;
obj.ctrl = struct( 'start', false, 'end', false, 'valid', false );
obj.countMax = fi( 12, 0, ramWL, 0, hdlfimath );
obj.count = fi( 0, 0, ramWL, 0, hdlfimath );
obj.decision = false;
obj.dataOut = cast( zeros( obj.memDepth, 1 ), 'like', varargin{ 1 } );
obj.finShift = fi( 0, 0, ramWL + 2, 0 );
obj.iterDone = false;
obj.cntEnb = false;
obj.endD = false;
obj.zCount = fi( 1, 0, ramWL + 2, 0 );
obj.zCount2 = fi( 1, 0, ramWL + 2, 0 );
end 

function varargout = outputImpl( obj, varargin )
varargout{ 1 } = obj.decBits;
varargout{ 2 } = obj.ctrl.start;
varargout{ 3 } = obj.ctrl.valid;
varargout{ 4 } = obj.finShift;
end 

function updateImpl( obj, varargin )

data = varargin{ 1 };
iter_done = obj.iterDone;
obj.iterDone = varargin{ 2 };
smsize = varargin{ 3 };
rate = varargin{ 4 };
finalV = varargin{ 5 };
reset = varargin{ 6 };

if strcmpi( obj.Standard, 'IEEE 802.11 n/ac/ax' )
ramWL = 5;maxCol = fi( [ 12, 16, 18, 20 ], 0, ramWL, 0 );
else 
ramWL = 4;maxCol = fi( [ 8, 10, 12, 13 ], 0, ramWL, 0 );
end 

if reset
obj.decBits( : ) = zeros( obj.memDepth, 1 );
obj.ctrl = struct( 'start', false, 'end', false, 'valid', false );
obj.count = fi( 0, 0, ramWL, 0, hdlfimath );
obj.decision = false;
obj.dataOut = cast( zeros( obj.memDepth, 1 ), 'like', varargin{ 1 } );
obj.finShift = fi( 0, 0, ramWL + 2, 0 );
obj.iterDone = false;
obj.zCount = fi( 1, 0, ramWL + 2, 0 );
obj.zCount2 = fi( 1, 0, ramWL + 2, 0 );
obj.cntEnb = false;
obj.endD = false;
end 

obj.countMax( : ) = maxCol( rate + 1 );

starti = ~iter_done && obj.iterDone;

if starti
obj.decision( : ) = true;
end 

if obj.scalarFlag
if ( obj.decision )
if obj.count == obj.countMax - 1
else 
if obj.cntEnb
obj.count( : ) = obj.count + 1;
end 
end 
end 

if obj.decision
if obj.zCount == cast( smsize, 'like', obj.zCount )
obj.zCount( : ) = 1;
obj.cntEnb = true;
else 
obj.cntEnb = false;
obj.zCount( : ) = obj.zCount + 1;
end 
end 

if ( obj.decision )
if obj.count == obj.countMax - 1
obj.endD = true;
obj.decision( : ) = false;
end 
validi = true;
else 
validi = false;
end 

else 
if ( obj.decision )
if obj.count == obj.countMax - 1
obj.endD = true;
obj.decision( : ) = false;
else 
obj.count( : ) = obj.count + 1;
end 
validi = true;
else 
validi = false;
obj.endD = false;
end 
end 

finaldecision( obj, data, smsize, finalV );

bits = obj.dataOut <= 0;

obj.decBits( : ) = bits;
obj.ctrl.start( : ) = starti;

if obj.scalarFlag
if obj.endD
if obj.zCount2 == cast( smsize, 'like', obj.zCount )
obj.zCount2( : ) = 1;
obj.ctrl.end( : ) = true;
obj.endD( : ) = false;
else 
obj.ctrl.end( : ) = false;
obj.zCount2( : ) = obj.zCount2 + 1;
end 
else 
obj.ctrl.end( : ) = false;
end 
else 
if obj.endD
obj.ctrl.end( : ) = true;
else 
obj.ctrl.end( : ) = false;
end 
end 

obj.ctrl.valid( : ) = validi || obj.endD || obj.ctrl.end;

if obj.ctrl.end
obj.count( : ) = 0;
end 

end 

function finaldecision( obj, data, Z, finalV )

obj.finShift = mod( finalV( obj.count + 1 ), Z );
obj.dataOut( 1:Z ) = data( 1:Z );
end 

function num = getNumInputsImpl( ~ )
num = 6;
end 

function num = getNumOutputsImpl( ~ )
num = 4;
end 


















































function s = saveObjectImpl( obj )

s = saveObjectImpl@matlab.System( obj );

if obj.isLocked
s.decBits = obj.decBits;
s.ctrl = obj.ctrl;
s.countMax = obj.countMax;
s.count = obj.count;
s.decision = obj.decision;
s.dataOut = obj.dataOut;
s.finShift = obj.finShift;
s.iterDone = obj.iterDone;
s.zCount = obj.zCount;
s.zCount2 = obj.zCount2;
s.cntEnb = obj.cntEnb;
s.endD = obj.endD;
s.memDepth = obj.memDepth;
s.offSetVal = obj.offSetVal;
s.offsetLUT = obj.offsetLUT;
s.zLUT = obj.zLUT;
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMXbZUN.p.
% Please follow local copyright laws when handling this file.

