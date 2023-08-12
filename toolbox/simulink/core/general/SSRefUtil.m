classdef SSRefUtil




methods ( Static, Access = 'public' )


function [ status, m_message ] = passesSSRefChecksForConversion( blockHandle )
[ status, m_message ] = SSRefUtil.passesBlockTypeCheckForConversion( blockHandle );
if ~status
return ;
end 

[ status, m_message ] = SSRefUtil.passesBlockDiagramTypeCheck( blockHandle );
if ~status
return ;
end 

[ status, m_message ] = SSRefUtil.passesRootLevelBlockCheck( blockHandle );
if ~status
return ;
end 

[ status, m_message ] = SSRefUtil.passesPortTypeCheck( blockHandle );
if ~status
return ;
end 

[ status, m_message ] = SSRefUtil.passesStateReadWriteBlockCheck( blockHandle );
if ~status
return ;
end 
end 




function [ status, m_message ] = passesBlockTypeCheckForConversion( blockHandle )
status = false;
m_message = '';
blockpath = getfullname( blockHandle );

if ( 0 == strcmp( 'SubSystem', get_param( blockHandle, 'BlockType' ) ) )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:OnlySubsystemCanBeConverted' );
return ;
end 

variant = get_param( blockHandle, 'Variant' );
if strcmp( variant, 'on' )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:VSSBlockCannotBeConverted', blockpath );
return ;
end 

if strcmp( get_param( blockHandle, 'IsSimulinkFunction' ), 'on' )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:SimFunctionBlockCannotBeConverted', blockpath );
return ;
end 

if slInternal( 'isInitTermOrResetSubsystem', blockHandle )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:InitTermOrResetCannotBeConverted', blockpath );
return ;
end 

if ~slInternal( 'isStateOwnerAndAccessorInsideSameSubsystem', blockHandle )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:StateOwnerAndAccessorNotInsideSameSubsystemCannotBeConverted', blockpath );
return ;
end 

if Stateflow.SLUtils.isStateflowBlock( blockHandle ) ||  ...
Stateflow.SLUtils.isChildOfStateflowBlock( blockHandle )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:StateflowBlockCannotBeConverted', blockpath );
return ;
end 


aTemplateBlock = get_param( blockHandle, 'TemplateBlock' );
if ~isempty( aTemplateBlock )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:ConfigurableSubsystemBlockCannotBeConverted', blockpath );
return ;
end 


linkstatus = get_param( blockHandle, 'StaticLinkStatus' );
if strcmp( linkstatus, 'none' ) ~= 1
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:LinkedBlockCannotBeConverted', blockpath );
return ;
end 

if strcmp( get_param( blockHandle, 'MaskHideContents' ), 'on' )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:SSWithMaskHideContentsCannotBeConverted', blockpath );
return ;
end 

aPermissions = get_param( blockHandle, 'Permissions' );
if ~strcmp( aPermissions, 'ReadWrite' )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:NoReadOrWriteSubsystemCannotBeConverted', blockpath, aPermissions );
return ;
end 

if Simulink.harness.internal.isHarnessCUT( blockHandle )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:HarnessCUTCannotBeConverted', blockpath );
return ;
end 

if ~isempty( get_param( blockHandle, 'ReferencedSubsystem' ) )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:SSRefBlockCannotBeConverted', blockpath );
return ;
end 





harnessList = Simulink.harness.find( blockpath );
hdl = get_param( blockpath, 'handle' );
scopedList = harnessList( arrayfun( @( s )~isequal( s.ownerHandle, hdl ), harnessList ) );
if ~isempty( scopedList )
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:UnableToDeleteHarnessDuringConversion' );
return ;
end 

status = true;
end 





function deleteFunctionInterfaces( blockpath )



if ~bdIsLibrary( bdroot( blockpath ) )
return ;
end 

allCC = Simulink.libcodegen.internal.getAllCodeContexts( bdroot( blockpath ) );
if isempty( allCC )
return ;
end 

hdl = get_param( blockpath, 'handle' );


nestedSS = find_system( blockpath, 'MatchFilter',  ...
@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'SubSystem' );
for i = 1:numel( nestedSS )
ssHdl = get_param( nestedSS{ i }, 'handle' );
if ssHdl == hdl
continue ;
end 
ccList = Simulink.libcodegen.internal.getBlockCodeContexts( bdroot( blockpath ), ssHdl );
for j = 1:numel( ccList )
Simulink.libcodegen.internal.deleteCodeContext( ccList( j ).ownerHandle, ccList( j ).name );
end 
end 
end 


end 

methods ( Static, Access = 'private' )


function [ status, m_message ] = passesBlockDiagramTypeCheck( m_block_handle )
status = false;
m_message = '';
topBd = bdroot( m_block_handle );
if Simulink.internal.isArchitectureModel( topBd, 'AUTOSARArchitecture' ) ||  ...
Simulink.internal.isArchitectureModel( topBd, 'SoftwareArchitecture' )
return ;
end 
status = true;
end 

function [ status, m_message ] =  ...
passesRootLevelBlockCheck( m_block_handle )

m_message = '';

child_blocks = find_system( m_block_handle, 'LookUnderMasks', 'on', 'SearchDepth', 1 );
for ii = 1:length( child_blocks )
block_type = get_param( child_blocks( ii ), 'BlockType' );
if contains( block_type, SSRefUtil.m_forbidden_rootlevel_blocks )
status = false;
m_message =  ...
DAStudio.message(  ...
'Simulink:SubsystemReference:UnsupportedBlockAtRootLevel', block_type );
return ;
elseif strcmp( block_type, 'Outport' )
if ( strcmpi( get_param( child_blocks( ii ), 'IsStateOwnerBlock' ), 'on' ) )
stateAccessorMap = get_param( bdroot( child_blocks( ii ) ), 'StateAccessorInfoMap' );
for i = 1:length( stateAccessorMap )
if ( stateAccessorMap( i ).StateOwnerBlock == child_blocks( ii ) )
status = false;
m_message =  ...
DAStudio.message(  ...
'Simulink:SubsystemReference:UnsupportedOutportBlockAsStateOwnerAtTopLevel',  ...
getfullname( m_block_handle ),  ...
getfullname( child_blocks( ii ) ) );
return ;
end 
end 
end 
end 
end 
status = true;

end 

function count = getPortBlockCount( portType, m_block_handle )
inport_blocks = find_system( m_block_handle, 'LookUnderMasks',  ...
'on', 'SearchDepth', 1, 'BlockType', portType );
count = length( inport_blocks );
end 

function [ status, m_message ] = passesPortTypeCheck( m_block_handle )
status = true;
m_message = '';
port_handles = get_param( m_block_handle, 'PortHandles' );


if length( port_handles.Inport ) > SSRefUtil.getPortBlockCount( 'Inport', m_block_handle )
status = false;
end 

if status

if length( port_handles.Outport ) > SSRefUtil.getPortBlockCount( 'Outport', m_block_handle )
status = false;
end 
end 

if ~status
block_name = getfullname( m_block_handle );
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:UnsupportedGapPortOnSSRef', block_name );
end 
end 


function [ status, m_message ] = passesStateReadWriteBlockCheck( m_block_handle )
m_message = '';
blockPath = getfullname( m_block_handle );


stateRWBlocks = find_system( gcs, 'MatchFilter',  ...
@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookUnderMasks', 'all', 'RegExp', 'on', 'BlockType', 'StateReader|StateWriter' );

for ii = 1:length( stateRWBlocks )
stateRWBlock = stateRWBlocks{ ii };
stateOwnerBlock = get_param( stateRWBlock, "StateOwnerBlock" );
if ( ~isempty( stateOwnerBlock ) && ( startsWith( stateRWBlock, blockPath ) && ~startsWith( stateOwnerBlock, blockPath ) ) )
status = false;
m_message = DAStudio.message(  ...
'Simulink:SubsystemReference:InvalidStateBlockOnSSRef', get_param( m_block_handle, 'Name' ) );
return ;
end 
end 
status = true;
end 


end 

properties ( Constant, Access = 'private' )

m_forbidden_rootlevel_blocks = { 'ForEach',  ...
'ForIterator',  ...
'WhileIterator',  ...
'EventListener' ...
, 'ResetPort' };
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYLUF5K.p.
% Please follow local copyright laws when handling this file.

