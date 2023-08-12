

classdef ( Sealed )Products



emumeration 
MatlabCoder( 'MATLAB_Coder', 'toolbox/coder/matlabcoder' )
EmbeddedCoder( 'RTW_Embedded_Coder', 'toolbox/coder/embeddedcoder' )
FixedPointDesigner( 'Fixed_Point_Toolbox', 'toolbox/fixedpoint/fixedpoint' )
GpuCoder( 'GPU_Coder', 'toolbox/gpucoder/gpucoder' )
HdlCoder( 'Simulink_HDL_Coder', 'toolbox/hdlcoder/hdlcoder' )
Polyspace( 'Polyspace_BF', 'toolbox/polyspace/psbugfinder' )
Simulink( 'SIMULINK', 'toolbox/simulink/simulink' )
Stateflow( 'Stateflow', 'toolbox/stateflow/stateflow' )
DeepLearning( 'Neural_Network_Toolbox', 'toolbox/nnet' )
Requirements( 'Simulink_Requirements', 'toolbox/slrequirements/slrequirements' )
end 

properties ( SetAccess = immutable )
LicenseName( 1, : )char
SignpostFile( 1, : )char
IsInstalled( 1, 1 )logical
end 

properties ( Dependent, SetAccess = immutable )
IsAvailable( 1, 1 )logical
IsInUse( 1, 1 )logical
end 

properties ( GetAccess = private, SetAccess = immutable )
Bitmask( 1, 1 )uint32
end 

methods 
function this = Products( licenseName, contentsFilePath )
R36
licenseName( 1, : )char
contentsFilePath( 1, : )char
end 

this.LicenseName = licenseName;

persistent bit;
if isempty( bit )
bit = 0;
end 
this.Bitmask = bitshift( 1, bit );
bit = bit + 1;

if ~endsWith( contentsFilePath, '.m' )
contentsFilePath = fullfile( contentsFilePath, 'Contents.m' );
end 
this.SignpostFile = fullfile( matlabroot(  ), contentsFilePath );
this.IsInstalled = isfile( this.SignpostFile );
end 

function result = checkout( obj )
R36
obj( 1, : )
end 

result = false( size( obj ) );
for i = 1:numel( obj )
result( i ) = license( 'checkout', obj( i ).LicenseName );
end 
end 

function encoded = encode( obj )
encoded = uint32( 0 );
for i = 1:numel( obj )
encoded = bitor( encoded, obj( i ).Bitmask );
end 
end 

function avail = available( obj )
avail = [ obj.IsAvailable ];
end 

function isInstalled = installed( obj )
isInstalled = [ obj.IsInstalled ];
end 

function used = inUse( obj )
used = [ obj.IsInUse ];
end 

function avail = get.IsAvailable( this )
avail = this.IsInstalled && license( 'test', this.LicenseName );
end 

function used = get.IsInUse( this )
used = ~isempty( license( 'inuse', this.LicenseName ) );
end 
end 

methods ( Static, Hidden )
function [ matched, filter ] = decode( encoded )
R36
encoded( 1, 1 )uint32
end 

values = enumeration( 'coderapp.internal.Products' );
filter = false( size( values ) );
for i = 1:numel( values )
filter( i ) = bitand( encoded, values( i ).Bitmask ) ~= 0;
end 
matched = values( filter );
end 

function matched = select( opts )
R36
opts.Status( 1, 1 )string{ mustBeMember( opts.Status, [ "inuse", "available", "unavailable", "installed", "uninstalled" ] ) } = "available"
end 

values = enumeration( 'coderapp.internal.Products' );
switch opts.Status
case 'available'
matched = values( values.available(  ) );
case 'installed'
matched = values( values.installed(  ) );
case 'inuse'
matched = values( values.inUse(  ) );
case 'unavailable'
matched = values( ~values.available(  ) );
case 'uninstalled'
matched = values( ~values.installed(  ) );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQJMn2t.p.
% Please follow local copyright laws when handling this file.

