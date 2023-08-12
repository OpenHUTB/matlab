function result = createMissingDataStore_cb( varargin )








assert( ~isempty( varargin ) );

action = varargin{ 1 };
isCompileTime = false;

switch action
case 'missingDataStoreWithBlock'
assert( nargin == 3 )
result = createWithBlockInformation( varargin{ 2:3 }, isCompileTime );
case 'missingDataStoreCompileTime'
assert( nargin == 3 )
isCompileTime = true;
result = createWithBlockInformation( varargin{ 2:3 }, isCompileTime );
otherwise 
assert( false );
end 

end 

function result = createWithBlockInformation( dataStoreName, blkLocation, isCompileTime )
blkObj = get_param( blkLocation, 'Object' );


blkHandle = get_param( blkLocation, 'Handle' );
modelHandle = bdroot( blkHandle );
model = get_param( modelHandle, 'Name' );


dsBlks = find_system( model, 'LookUnderMasks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FollowLinks', 'on', 'BlockType', 'DataStoreMemory' );
blkCtrlr = Simulink.BlockEditTimeController;
if isCompileTime
isMissingDataStore = blkCtrlr.isMissingDataStoreCompileTime( blkHandle, model, { dataStoreName } );
else 
isMissingDataStore = blkCtrlr.isMissingDataStore( blkHandle, model, { dataStoreName } );
end 

if ~isMissingDataStore
result = DAStudio.message( 'Simulink:dialog:ResolvedGlobalDataStore', model );
return ;
end 
if ~isempty( dsBlks )
for idx = 1:length( dsBlks )
if isequal( { dataStoreName }, get_param( dsBlks( idx ), 'DataStoreName' ) )
result = DAStudio.message( 'Simulink:dialog:BlockEditTimeNotification_DSMBlockExists' );
return ;
end 
end 
end 
dlgSrc = addNewBlock( dataStoreName, 'DataStoreName', '', blkObj.getDialogSource, blkHandle );
slprivate( 'showDDG', dlgSrc );


openDlgs = DAStudio.ToolRoot.getOpenDialogs;
dlg = openDlgs.find( 'dialogTag', dlgSrc.mDialogTag );
waitfor( dlg );


if isempty( dlgSrc.mResult )
DAStudio.error( 'SLDD:sldd:OperationCanceled' );
else 
result = dlgSrc.mResult;
end 


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDgt818.p.
% Please follow local copyright laws when handling this file.

