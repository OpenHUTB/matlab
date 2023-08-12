function result = MAExecCheckReadWriteOrderChecking( system )









result = '';
passString = [ '<p /><font color="#008000">', DAStudio.message( 'Simulink:tools:MAPassedMsg' ), '</font>' ];
model = bdroot( system );
hScope = get_param( system, 'Handle' );
hModel = get_param( model, 'Handle' );
mdladvObj = Simulink.ModelAdvisor.getModelAdvisor( system );
mdladvObj.setCheckResultStatus( false );

if ( hScope == hModel )



memBlocks = find_system( hModel, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'LookUnderMasks', 'all', 'BlockType', 'DataStoreMemory' );
memBlocks = filterBlocksInsideSF( memBlocks );
memBlocks = mdladvObj.filterResultWithExclusion( memBlocks );

[ msg_rbw, rbw_flag ] = locGlobalDataStoreCheck( hModel, 'ReadBeforeWriteMsg', memBlocks, 'read before write' );
[ msg_war, war_flag ] = locGlobalDataStoreCheck( hModel, 'WriteAfterReadMsg', memBlocks, 'write after read' );
[ msg_waw, waw_flag ] = locGlobalDataStoreCheck( hModel, 'WriteAfterWriteMsg', memBlocks, 'write after write' );

if ( rbw_flag && war_flag && waw_flag )
result = passString;
mdladvObj.setCheckResultStatus( true );
else 
result = [ '<ul><li>', msg_rbw, '</li><p /><li>', msg_war, '</li><p /><li>', msg_waw, '</li></ul>', DAStudio.message( 'Simulink:tools:MADiagHasPerformanceHit', 'Disable all' ) ];
mdladvObj.setCheckResultStatus( false );
end 
else 
result = passString;
mdladvObj.setCheckResultStatus( true );
end 


function [ msg, ok_flag ] = locGlobalDataStoreCheck( hModel, blkParmName, memBlocks, checkStr )

nl = sprintf( '\n' );
val = get_param( hModel, blkParmName );
passString = DAStudio.message( 'Simulink:tools:CheckPassed', checkStr );
enableString = DAStudio.message( 'Simulink:tools:CheckEnabled', checkStr );

[ tmp, flag ] = max( strcmp( val,  ...
{ 'DisableAll', 'UseLocalSettings', 'EnableAllAsWarning', 'EnableAllAsError' } ) );

switch flag( 1 )
case 1
if ( length( memBlocks ) )
encodedModelName = modeladvisorprivate( 'HTMLjsencode', get_param( hModel, 'Name' ), 'encode' );
encodedModelName = [ encodedModelName{ : } ];

msg = DAStudio.message( 'Simulink:tools:MAMsgGlobalDataStoreRWOrder', checkStr, encodedModelName, blkParmName );

ok_flag = 0;
else 
msg = passString;
ok_flag = 1;
end 
case 2
msg = [  ];
ok_flag = 1;
for i = 1:length( memBlocks )
p_val = get_param( memBlocks( i ), blkParmName );
if ( strcmp( p_val, 'none' ) )
if ( isempty( msg ) )
encodedModelName = modeladvisorprivate( 'HTMLjsencode', get_param( hModel, 'Name' ), 'encode' );
encodedModelName = [ encodedModelName{ : } ];
msg = DAStudio.message( 'Simulink:tools:MAMsgLocalDataStoreRWOrder', checkStr, encodedModelName, blkParmName );
end 
blkName = [ get_param( memBlocks( i ), 'Parent' ), '/', get_param( memBlocks( i ), 'Name' ) ];
dispBlkName = regexprep( blkName, nl, ' ' );
codeBlkName = modeladvisorprivate( 'HTMLjsencode', blkName, 'encode' );
codeBlkName = [ codeBlkName{ : } ];
msg = [ msg, ' <p /> <a href="matlab:modeladvisorprivate(''hiliteSystem'',''', codeBlkName, ''')">', dispBlkName, '</a>' ];
ok_flag = 0;
end 
end 
if isempty( msg )
if length( memBlocks )
msg = enableString;
else 
msg = passString;
end 
end 
case 3
msg = enableString;
ok_flag = 1;
case 4
msg = enableString;
ok_flag = 1;
otherwise 
msg = [ 'Bad flag from find global setting of ', checkStr ];
ok_flag = 0;
end 


function newblocks = filterBlocksInsideSF( blocks )
newblocks = [  ];
for i = 1:length( blocks )
if ~IsInsideStateflow( blocks( i ) )
newblocks( end  + 1 ) = blocks( i );%#ok<AGROW>
end 
end 


function value = IsInsideStateflow( block )
value = false;
parentBlk = get_param( block, 'Parent' );
if ~isempty( parentBlk ) && slprivate( 'is_stateflow_based_block', parentBlk )
value = true;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKEElr1.p.
% Please follow local copyright laws when handling this file.

