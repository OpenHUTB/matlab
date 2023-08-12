function result = MAExecCheckContOrZohDataStore( system )









result = [  ];
nl = sprintf( '\n' );
passString = [ '<p /><font color="#008000">', DAStudio.message( 'Simulink:tools:MAPassedMsg' ), '</font>' ];
model = bdroot( system );
hScope = get_param( system, 'Handle' );
hModel = get_param( model, 'Handle' );
mdladvObj = Simulink.ModelAdvisor.getModelAdvisor( system );
mdladvObj.setCheckResultStatus( false );
contBlocks = [  ];

if ( hScope == hModel )


readBlocks = find_system( hModel, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'LookUnderMasks', 'all', 'BlockType', 'DataStoreRead' );
writeBlocks = find_system( hModel, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'LookUnderMasks', 'all', 'BlockType', 'DataStoreWrite' );
memBlocks = find_system( hModel, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'LookUnderMasks', 'all', 'BlockType', 'DataStoreMemory' );
DSBlocks = [ reshape( readBlocks, 1, [  ] ),  ...
reshape( writeBlocks, 1, [  ] ),  ...
reshape( memBlocks, 1, [  ] ) ];
contTime = [ 0, 0 ];
zohTime = [ 0, 1 ];

val = get_param( hModel, 'MultiTaskDSMMsg' );
[ tmp, flag ] = max( strcmp( val, { 'none', 'warning', 'error' } ) );
if ( flag == 2 || flag == 3 )
mt_flag = 1;
else 
mt_flag = 0;
end 

for i = 1:length( DSBlocks )
ts = get_param( DSBlocks( i ), 'CompiledSampleTime' );
if ( isequal( ts, contTime ) || isequal( ts, zohTime ) )
contBlocks = [ contBlocks, DSBlocks( i ) ];
end 

end 

contBlocks = mdladvObj.filterResultWithExclusion( contBlocks );

if ( length( contBlocks ) || ~mt_flag )

if ( length( contBlocks ) )
result = [ '<ul> <li> ', DAStudio.message( 'Simulink:tools:MAMsgNonDiscSigDataStore' ), nl, '<ul> ' ];

for i = 1:length( contBlocks )
blkName = [ get_param( contBlocks( i ), 'Parent' ), '/', get_param( contBlocks( i ), 'Name' ) ];
dispBlkName = regexprep( blkName, nl, ' ' );
codeBlkName = modeladvisorprivate( 'HTMLjsencode', blkName, 'encode' );
codeBlkName = [ codeBlkName{ : } ];
result = [ result, nl, ' <li> <a href="matlab:modeladvisorprivate(''hiliteSystem'',''', codeBlkName, ''')">', dispBlkName, '</a></li>' ];
end 
result = [ result, nl, '</ul> ', nl, DAStudio.message( 'Simulink:tools:MAMsgNonDiscSigDataStoreSuggest' ), ' </li> ' ];
else 
result = [ '<ul> <li>', DAStudio.message( 'Simulink:tools:MANonContDSMPass' ), '</li>' ];
end 

if ( mt_flag )
result = [ result, nl, '<li> ', DAStudio.message( 'Simulink:tools:CheckEnabled', 'Multitasking Data Store blocks' ), ' </li> </ul>' ];
else 
encodedModelName = modeladvisorprivate( 'HTMLjsencode', get_param( hModel, 'Name' ), 'encode' );
encodedModelName = [ encodedModelName{ : } ];
result = [ result, nl, '<li> ', DAStudio.message( 'Simulink:tools:MAMultiTaskCheck', encodedModelName ), ' </li> </ul>' ];
end 

mdladvObj.setCheckResultStatus( false );

else 
result = passString;
mdladvObj.setCheckResultStatus( true );
end 

else 
result = passString;
mdladvObj.setCheckResultStatus( true );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpVokX7v.p.
% Please follow local copyright laws when handling this file.

