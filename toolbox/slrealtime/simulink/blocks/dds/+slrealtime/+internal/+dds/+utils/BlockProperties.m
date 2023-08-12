classdef BlockProperties







methods ( Access = public, Static )



function blkPresent = systemhasblocks( mdlName )
blkPresent = slrealtime.internal.dds.utils.BlockProperties.manageProperties( 'systemhasblocks', mdlName );
end 




function clear(  )
slrealtime.internal.dds.utils.BlockProperties.manageProperties( 'clear' );
end 




function set( mdlName, blkId, blkType, data )
slrealtime.internal.dds.utils.BlockProperties.manageProperties( 'set', mdlName, blkId, blkType, data );
end 




function data = getParametersFromAllBlocks( mdlName, blkType, paramName )
data = slrealtime.internal.dds.utils.BlockProperties.manageProperties( 'getParams', mdlName, blkType, paramName );
end 
end 

methods ( Access = private, Static )

function varargout = manageProperties( command, varargin )

R36
command( 1, : )char{ mustBeMember( command, { 'systemhasblocks',  ...
'set', 'getParams', 'clear' } ) }
end 
R36( Repeating )
varargin
end 

persistent theModelname;
persistent theSendBlocksMap;
persistent theRecvBlocksMap;


if isempty( theSendBlocksMap )
theSendBlocksMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
end 
if isempty( theRecvBlocksMap )
theRecvBlocksMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
end 
if isempty( theModelname )
theModelname = '';
end 

switch ( command )
case 'systemhasblocks'
mdl = varargin{ 1 };
if strcmp( mdl, theModelname )
varargout{ 1 } = theSendBlocksMap.Count || theRecvBlocksMap.Count;
else 
varargout{ 1 } = false;
end 
case 'set'
mdl = varargin{ 1 };
blkId = varargin{ 2 };
blkType = varargin{ 3 };
data = varargin{ 4 };
theModelname = mdl;
switch ( blkType )
case 'send'
theSendBlocksMap( blkId ) = data;
case 'recv'
theRecvBlocksMap( blkId ) = data;
otherwise 
assert( false );
end 
case 'getParams'
mdl = varargin{ 1 };
blkType = varargin{ 2 };
paramName = varargin{ 3 };
switch ( blkType )
case 'send'
allBlksParamsValues = theSendBlocksMap.values;
case 'recv'
allBlksParamsValues = theRecvBlocksMap.values;
otherwise 
assert( false );
end 


if isempty( allBlksParamsValues )
varargout{ 1 } = [  ];
else 
values = {  };
for ii = 1:length( allBlksParamsValues )
paramValues = allBlksParamsValues{ ii };
if ~isfield( paramValues, paramName )
error( 'Invalid parameter name' );
end 
switch ( paramName )
case 'TopicName'
curvalue = paramValues.TopicName;
case 'DataWriterPath'
curvalue = paramValues.DataWriterPath;
case 'DataReaderPath'
curvalue = paramValues.DataReaderPath;
case 'DDSType'
curvalue = paramValues.DDSType;
case 'ParticipantName'
curvalue = paramValues.ParticipantName;
otherwise 
assert( false );
end 
values = [ values;curvalue ];
end 
varargout{ 1 } = values;
end 


case 'clear'
theSendBlocksMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
theRecvBlocksMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
theModelname = '';
otherwise 
assert( false );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDYFEZi.p.
% Please follow local copyright laws when handling this file.

