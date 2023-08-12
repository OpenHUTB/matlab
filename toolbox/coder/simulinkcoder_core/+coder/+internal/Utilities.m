




classdef Utilities < handle
properties ( Constant )
BuiltinType = { 'double', 'single', 'int8', 'uint8', 'int16', 'uint16',  ...
'int32', 'uint32', 'boolean' };
end 

methods ( Static, Access = public )
function loc_setFcnCallSubsystemToInlineInNewModel( s )

assert( ~isempty( s.origInlineSubsystemName ) );
origInlineSubsystemName = s.origInlineSubsystemName;
origSubsystemParentName = s.origSubsystemParentName;
newSubsysteParentName = s.newSubsysteParentName;
if length( origInlineSubsystemName ) > length( origSubsystemParentName ) &&  ...
strcmp( origInlineSubsystemName( 1:length( origSubsystemParentName ) ), origSubsystemParentName )

origInlineSubsystemName( 1:length( origSubsystemParentName ) ) = '';
if ~isempty( s.origInlineSubsystemName )
newInlineSubsystemName = strcat( newSubsysteParentName, origInlineSubsystemName );



pass = false;
hdl = get_param( newInlineSubsystemName, 'Handle' );
if ~isempty( hdl )
if strcmp( get_param( hdl, 'BlockType' ), 'SubSystem' ) &&  ...
strcmp( get_param( hdl, 'IsSubsystemVirtual' ), 'off' )
opHandles = get_param( hdl, 'PortHandles' );
if ~isempty( opHandles.Trigger )
pass = true;
end 
end 
end 
assert( pass, 'verifying function-call subsystem fails' );

if pass

set_param( newInlineSubsystemName, 'RTWSystemCode', 'Inline' );
end 
end 
end 
end 


function firstch = LocalFindFirstValidChar( str )




firstch = 0;
for i = 1:length( str )
thischar = str( i );

if ( ( thischar >= 'a' && thischar <= 'z' ) ||  ...
( thischar >= 'A' && thischar <= 'Z' ) )
firstch = i;
return ;
end 
end 
end 


function firstch = LocalFindFirstInvalidChar( str )




firstch = 0;
for i = 1:length( str )
thischar = str( i );

if ( ( thischar >= 'a' && thischar <= 'z' ) ||  ...
( thischar >= 'A' && thischar <= 'Z' ) ||  ...
( thischar >= '0' && thischar <= '9' ) ||  ...
( thischar == '_' ) )

else 
firstch = i;
return ;
end 
end 
end 

function ret = locNeedNameChange( base_name, block_hdl, origMdlName )
ret = coder.internal.Utilities.locCheckForSpecificName( base_name, block_hdl, origMdlName );
if ( ~ret && ispc )



ret = coder.internal.Utilities.locCheckForSpecificName( lower( base_name ), block_hdl,  ...
lower( origMdlName ) );
end 
end 


function LocalCopyWSData( slObj, dstWS )



if strcmp( slObj.type, 'block' ) && strcmp( slObj.blockType, 'SubSystem' )
coder.internal.Utilities.LocalCopyWSData( get_param( slObj.parent, 'Object' ), dstWS );
end 


copiedParamObject = {  };
if isa( slObj, 'Simulink.BlockDiagram' )
srcDict = slObj.DictionarySystem;
srcP = srcDict.Parameter;
dstBD = get_param( dstWS.ownerName, 'UDDObject' );
dstDict = dstBD.DictionarySystem;
dstP = dstDict.Parameter;
pNames = srcP.keys;
for idx = 1:length( pNames )
srcParam = srcP.getByKey( pNames{ idx } );
dstWS.assignin( srcParam.Name, srcParam.WorkspaceObjectSharedCopy );
dstParam = dstP.getByKey( pNames{ idx } );
dstParam.Argument = srcParam.Argument;
copiedParamObject{ end  + 1 } = srcParam.Name;%#ok

if ~slfeature( 'AutoMigrationIM' ) && ~strcmp( srcParam.StorageClass, 'Auto' )
dstParam.StorageClass = srcParam.StorageClass;
end 
end 
end 

srcWS = slObj.getWorkspace(  );

if ~isempty( srcWS )
srcData = srcWS.data(  );
for idx = 1:length( srcData )

if ~any( strcmp( copiedParamObject, srcData( idx ).Name ) )
dstWS.assignin( srcData( idx ).Name, srcData( idx ).Value );
end 
end 
end 
end 


function retVal = LocalCheckBusStruct( origMdlHdl, busStruct )
retVal = false;
if busStruct.node.hasBusObject &&  ...
~strcmp( get_param( origMdlHdl, 'BusObjectLabelMismatch' ), 'error' )
retVal = true;
elseif busStruct.type == 2 && busStruct.node.isVirtualBus
for i = 1:length( busStruct.node.leafe )
if coder.internal.Utilities.LocalCheckBusStruct( origMdlHdl, busStruct.node.leafe{ i } )
retVal = true;
end 
end 
end 
end 


function WarnIfMemSecsDifferent( block_hdl, origMdlHdl )





ssType = Simulink.SubsystemType( block_hdl );
if ( ( strcmp( get_param( origMdlHdl, 'IsERTTarget' ), 'on' ) ) &&  ...
~ssType.isVirtualSubsystem(  ) )
systemCode = get_param( block_hdl, 'RTWSystemCode' );
isFcn = strcmp( systemCode, 'Nonreusable function' );
isReusable = strcmp( systemCode, 'Reusable function' );


if ( isFcn || isReusable )
try 
subsysSettings = {  ...
get_param( block_hdl, 'RTWMemSecFuncInitTerm' ); ...
get_param( block_hdl, 'RTWMemSecFuncExecute' ); ...
 };
modelSettings = coder.internal.Utilities.locGetModelFunctionSettings( origMdlHdl );
if ( isFcn )
subsysSettings =  ...
[ subsysSettings; ...
get_param( block_hdl, 'RTWMemSecDataConstants' ); ...
get_param( block_hdl, 'RTWMemSecDataInternal' ); ...
get_param( block_hdl, 'RTWMemSecDataParameters' ); ...
get_param( block_hdl, 'RTWMemSecDataParameters' ) ];
modelSettings = [ modelSettings; ...
coder.internal.Utilities.locGetModelDataSettings( origMdlHdl ) ...
 ];
end 

for i = 1:length( subsysSettings )
if ( ( ~strcmp( subsysSettings{ i }, 'Inherit from model' ) ) &&  ...
( ~strcmp( subsysSettings{ i }, modelSettings{ i } ) ) )
[ ~, errText ] = coder.internal.localRetrieveErrorText( 'MemSecsDifferentWarning',  ...
getfullname( block_hdl ),  ...
get_param( origMdlHdl, 'Name' ) );
warning( 'RTW:buildProcess:MemSecsDifferentWarning', errText );
break ;
end 
end 
catch exc %#ok<NASGU>







end 
end 
end 
end 


function modelName = localBdroot( h )
if ishandle( h )
modelName = get_param( bdroot( h ), 'Name' );
else 
modelName = bdroot( h );
end 
end 


function isContainedInSS = checkIfGivenBlkIsContainedInGivenSS( destBlkH, ssBlkH )
destBlkParSSH = get_param( destBlkH, 'Handle' );
isContainedInSS = false;
while ~strcmp( get_param( destBlkParSSH, 'Type' ), 'block_diagram' )
if destBlkParSSH == ssBlkH
isContainedInSS = true;
break ;
end 
destBlkParSSH = get_param( get_param( destBlkParSSH, 'Parent' ), 'Handle' );
end 
end 


function checkIfGotoAndFromBlksAreContainedInGivenSS( ssBlkH, currSSBlkH )
blockList = find_system( currSSBlkH, 'SearchDepth', 1, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on' );

for bIdx = 1:length( blockList )
blkH = blockList( bIdx );
blockType = get_param( blkH, 'BlockType' );
if isequal( blkH, currSSBlkH )
continue ;
end 
if strcmp( blockType, 'Goto' )
fromBlkH = get_param( blkH, 'FromBlocks' );
for fIdx = 1:length( fromBlkH )
if ~isempty( fromBlkH( fIdx ).handle ) &&  ...
~coder.internal.Utilities.checkIfGivenBlkIsContainedInGivenSS( fromBlkH( fIdx ).handle, ssBlkH )
DAStudio.error( 'RTW:buildProcess:invalidFcnCallGotoFromErr',  ...
getfullname( blkH ),  ...
getfullname( fromBlkH( fIdx ).handle ) );
end 
end 
elseif strcmp( blockType, 'From' )
gotoBlkH = get_param( blkH, 'GotoBlock' );
if ~isempty( gotoBlkH ) && ~isempty( gotoBlkH.handle )
if ~coder.internal.Utilities.checkIfGivenBlkIsContainedInGivenSS( gotoBlkH.handle, ssBlkH )
DAStudio.error( 'RTW:buildProcess:invalidFcnCallGotoFromErr',  ...
getfullname( gotoBlkH.handle ),  ...
getfullname( blkH ) );
end 
end 
elseif strcmp( get_param( blkH, 'virtual' ), 'on' ) &&  ...
strcmpi( blockType, 'Subsystem' )
coder.internal.Utilities.checkIfGotoAndFromBlksAreContainedInGivenSS( ssBlkH, blkH );
end 
end 
end 




function symbDims = getSymbolicFromNumericDims( numericDims )
symbDims = '-1';
if ~isempty( numericDims )
numberOfDimensions = numericDims( 1 );
dimensions = numericDims( 2:end  );
if numberOfDimensions == 1
symbDims = sprintf( '%d', dimensions );
elseif numberOfDimensions >= 2
spcVal = '';
symbDims = '[';
for dimsIdx = 1:numberOfDimensions
if dimsIdx > 1
spcVal = ',';
end 
symbDims = sprintf( '%s%s%d', symbDims, spcVal,  ...
dimensions( dimsIdx ) );
end 
symbDims = [ symbDims, ']' ];
end 
end 
end 




function symbDims = getCompiledSymbolicDims( portH )
symbDims = get_param( portH, 'CompiledPortSymbolicDimensions' );
if any( strcmp( { 'NOSYMBOLIC', 'INHERIT' }, symbDims ) )
numericDims = get_param( portH, 'CompiledPortDimensions' );
symbDims = coder.internal.Utilities.getSymbolicFromNumericDims( numericDims );
end 
end 


function posMinMax = maxCoordinate( cellPosition )
min_x = inf;
min_y = inf;
max_x = 0;
max_y = 0;
N = length( cellPosition );
for i = 1:N
tmpvar = cellPosition{ i }( 1 );
if ( tmpvar > max_x );max_x = tmpvar;end 
if ( tmpvar < min_x );min_x = tmpvar;end 
tmpvar = cellPosition{ i }( 2 );
if ( tmpvar > max_y );max_y = tmpvar;end 
if ( tmpvar < min_y );min_y = tmpvar;end 
end 
posMinMax = [ min_x, min_y, max_x, max_y ];
end 


function dt = resolveDT( dt )
if ~any( strcmp( coder.internal.Utilities.BuiltinType, dt ) )
dt = 'internal unresolved';
end 
end 




function blkSid = extractBlkSid( strucBus )
if strucBus.type == 2 && strucBus.node.isVirtualBus
blkSid = coder.internal.Utilities.extractBlkSid( strucBus.node.leafe{ 1 } );
elseif strucBus.type == 1 || strucBus.node.hasBusObject
blkSid = strucBus.blkSid;
else 
disp( DAStudio.message( 'RTW:buildProcess:UnknownTypeOfNode' ) );
end 
end 


end 


methods ( Static, Access = private )
function ret = locGetModelDataSettings( mdlHdl )
if coder.internal.CoderDataStaticAPI.migratedToCoderDictionary( mdlHdl )

ret = { 
codermapping.internal.c.defaultmapping.getDataDefaultsMemorySectionName( mdlHdl, 'Constants' ); ...
codermapping.internal.c.defaultmapping.getDataDefaultsMemorySectionName( mdlHdl, 'InternalData' ); ...
codermapping.internal.c.defaultmapping.getDataDefaultsMemorySectionName( mdlHdl, 'ModelParameters' ); ...
codermapping.internal.c.defaultmapping.getDataDefaultsMemorySectionName( mdlHdl, 'GlobalParameters' ) };
else 
cs = getActiveConfigSet( mdlHdl );
ret = { 
get_param( cs, 'MemSecDataConstants' ); ...
get_param( cs, 'MemSecDataInternal' ); ...
get_param( cs, 'MemSecDataParameters' ); ...
get_param( cs, 'MemSecDataParameters' ) };
end 
end 
function ret = locGetModelFunctionSettings( mdlHdl )
if coder.internal.CoderDataStaticAPI.migratedToCoderDictionary( mdlHdl )

ret = { 
codermapping.internal.c.defaultmapping.getFunctionDefaultsMemorySectionName( mdlHdl, 'InitializeTerminate' ); ...
codermapping.internal.c.defaultmapping.getFunctionDefaultsMemorySectionName( mdlHdl, 'Execution' ) };
else 
cs = getActiveConfigSet( mdlHdl );
ret = {  ...
get_param( cs, 'MemSecFuncInitTerm' ); ...
get_param( cs, 'MemSecFuncExecute' ); ...
 };
end 
end 

function ret = locCheckForSpecificName( baseName, block_hdl, origMdlName )
root = get_param( 0, 'Object' );
ret = false;
if strcmp( baseName, origMdlName )
ret = true;
elseif any( exist( baseName ) == [ 1, 3, 4, 5, 6 ] ) || exist( [ baseName, '.m' ], 'file' )%#ok
ret = true;
elseif root.isValidSlObject( baseName )

if get_param( baseName, 'SubsystemHdlForRightClickBuild' ) == block_hdl &&  ...
strcmp( get_param( baseName, 'Shown' ), 'off' )


ret = true;
else 
ret = true;
end 
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp1lNwTe.p.
% Please follow local copyright laws when handling this file.

