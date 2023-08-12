classdef DUTPort




properties ( SetAccess = private )
PortName = '';
PortPath = '';
Direction hdl.ip.port.PortDirection
DataType = numerictype( 0, 32, 0 );
Dimensions = [ 1, 1 ];
Min =  - Inf;
Max = Inf;
IsComplex logical = false;
SampleTime =  - 1;
end 

properties ( Dependent )
IsSigned
WordLength
FractionLength
end 

methods ( Static )
function obj = createDUTPortFromMapping( mapping )
import hdlcoder.mapping.internal.validation.*

if isa( mapping, 'Simulink.HDLTarget.IOMapping' )

blockHandle = get_param( mapping.Block, 'Handle' );
portName = get_param( blockHandle, 'Name' );
portPath = getfullname( blockHandle );


portHandles = get_param( blockHandle, 'PortHandles' );
blockType = get_param( blockHandle, 'BlockType' );
switch blockType
case 'Inport'
direction = hdl.ip.port.PortDirection.IN;
portHandle = portHandles.Outport;
case 'Outport'
direction = hdl.ip.port.PortDirection.OUT;
portHandle = portHandles.Inport;
otherwise 
error( 'Expected port type to be "Inport" or "Outport".' );
end 
elseif isa( mapping, 'Simulink.HDLTarget.SignalMapping' )
portName = get_param( mapping.OwnerBlockPath, 'Name' );
portPath = mapping.OwnerBlockPath;
direction = hdl.ip.port.PortDirection.OUT;
portHandle = mapping.PortHandle;
blockHandle = mapping.OwnerBlockHandle;
else 
error( 'Unexpected mapping type.' );
end 


dataType = getCompiledPropertyValue( blockHandle, portHandle, 'DataType*' );
min = getCompiledPropertyValue( blockHandle, portHandle, 'Min*' );
max = getCompiledPropertyValue( blockHandle, portHandle, 'Max*' );
dim = getCompiledPropertyValue( blockHandle, portHandle, 'Dimensions*' );
complexity = getCompiledPropertyValue( blockHandle, portHandle, 'Complexity*' );
sampleTime = getCompiledPropertyValue( blockHandle, portHandle, 'LastKnownCompiledSampleTime' );


obj = hdlcoder.mapping.internal.DUTPort( portName, portPath, direction, dataType, min, max, dim, complexity, sampleTime );
end 
end 

methods ( Access = protected )
function obj = DUTPort( name, path, direction, dataType, min, max, dim, complexity, sampleTime )
R36
name = '';
path = '';
direction = [  ];
dataType = [  ];
min = [  ];
max = [  ];
dim = [  ];
complexity = [  ];
sampleTime = [  ];
end 

if ~isempty( name )
obj.PortName = name;
end 

if ~isempty( path )
obj.PortPath = path;
end 

if ~isempty( direction )
obj.Direction = direction;
end 

if ~isempty( dataType )
obj.DataType = numerictype( dataType );
end 

if ~isempty( min )
obj.Min = min;
end 

if ~isempty( max )
obj.Max = max;
end 

if ~isempty( dim )
obj.Dimensions = dim;
end 

if ~isempty( complexity )
obj.IsComplex = ~strcmp( complexity, 'real' );
end 

if ~isempty( sampleTime )
obj.SampleTime = sampleTime;
end 
end 
end 

methods 
function isSigned = get.IsSigned( obj )
if ~isempty( obj.DataType )
isSigned = obj.DataType.SignednessBool;
else 
isSigned = [  ];
end 
end 

function wordLen = get.WordLength( obj )
if ~isempty( obj.DataType )
wordLen = obj.DataType.WordLength;
else 
wordLen = [  ];
end 
end 

function fracLen = get.FractionLength( obj )
if ~isempty( obj.DataType )
fracLen = obj.DataType.FractionLength;
else 
fracLen = [  ];
end 

end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsQdRwi.p.
% Please follow local copyright laws when handling this file.

