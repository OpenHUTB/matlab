

function switchToCodeMappingView2( modelName, displayName, tabToSelect )




if isempty( modelName )

param = evalin( "base", displayName );
slidParam = param.getSlidParam;
displayName = slidParam.Name;
system = slidParam.System;
handle = system.Handle;
modelName = get_param( handle, 'Name' );
end 

src = simulinkcoder.internal.util.getSource( modelName );
editor = src.editor;

found = false;
if ~isempty( editor )
if editor.isVisible || strcmp( editor.getName, modelName )
found = true;
end 
end 

if ~found
open( modelName );

src = simulinkcoder.internal.util.getSource( modelName );
editor = src.editor;

if isempty( editor )
return 
end 
end 

cp = simulinkcoder.internal.CodePerspective.getInstance;
cp.turnOnPerspective( src.studio, 'nonblocking' );

studio = editor.getStudio;
label = 'CodeProperties';

ssComp = studio.getComponent( 'GLUE2:SpreadSheet', label );
if isempty( ssComp )

cm = cp.getTask( 'CodeMapping' );
cm.turnOn( editor );

ssComp = studio.getComponent( 'GLUE2:SpreadSheet', label );
end 

if ~strcmp( tabToSelect, 'Parameters' )
[ cmp, tabToSelect ] = findTabName( displayName, modelName );
else 
cmp = simulinkcoder.internal.util.getMappingObject( modelName, 'ModelScopedParameters', displayName );
end 

[ ~, mappingType ] = Simulink.CodeMapping.getCurrentMapping( modelName );

if strcmp( mappingType, 'AutosarTarget' )
tabToSelect = tabToSelect + "_ClassicAUTOSAR";
elseif strcmp( mappingType, 'CoderDictionary' )
tabToSelect = tabToSelect + "_ERT";
elseif strcmp( mappingType, 'SimulinkCoderCTarget' )
tabToSelect = tabToSelect + "_GRT";
else 

end 

if ~isempty( ssComp )
if ssComp.isVisible
ssComp.restore;
else 
studio.showComponent( ssComp );
end 

studio.setActiveComponent( ssComp );

dlg = ssComp.getTitleView;
dataView = dlg.getDialogSource;
dataView.selectItemsOnTab( cmp, tabToSelect );
end 

studio.raise;
end 

function [ cmp, tab ] = findTabName( signalObjName, modelName )
found = false;
tab = 'DataStores';
cmp = simulinkcoder.internal.util.getMappingObject( modelName, tab, 0 );

if ~found


dsms = find_system( modelName, 'LookUnderMasks', 'on', 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'StateMustResolveToSignalObject', 'on', 'BlockType', 'DataStoreMemory',  ...
'DataStoreName', signalObjName );
if ~isempty( dsms )
hBlk = get_param( dsms{ 1 }, 'Handle' );
tab = 'DataStores';
mappingObj = simulinkcoder.internal.util.getMappingObject( modelName, tab, hBlk );
if ~isempty( mappingObj )
cmp = get_param( mappingObj.OwnerBlockHandle, 'Object' );
end 
found = true;
end 
end 

if ~found


ports = find_system( modelName, 'LookUnderMasks', 'on', 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FindAll', 'on', 'Type', 'port',  ...
'MustResolveToSignalObject', 'on',  ...
'Name', signalObjName );
if ~isempty( ports )
cmp = {  };
for ii = 1:numel( ports )
tab = 'Inports';
blk = get_param( ports( ii ), 'Parent' );
blk_type = get_param( blk, 'BlockType' );
hBlk = get_param( blk, 'Handle' );
mappingObj = simulinkcoder.internal.util.getMappingObject( modelName, 'Inports', hBlk );
if ~isempty( mappingObj )
cmp{ end  + 1 } = get_param( mappingObj.Block, 'Object' );
else 
tab = 'Signals/States';
portObj = simulinkcoder.internal.util.getMappingObject( modelName, 'Signals', ports( ii ) );
if ~isempty( portObj )
cmp{ end  + 1 } = get_param( portObj.PortHandle, 'Object' );
end 
end 
end 
if ~isempty( cmp )
found = true;
end 
end 
end 

if ~found


outports = find_system( modelName, 'LookUnderMasks', 'on', 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'FindAll', 'on', 'BlockType', 'Outport',  ...
'MustResolveToSignalObject', 'on',  ...
'SignalName', signalObjName );
if ~isempty( outports )
cmp = {  };
tab = 'Outports';
for ii = 1:numel( outports )
mappingObj = simulinkcoder.internal.util.getMappingObject( modelName, tab, outports( ii ) );
if ~isempty( mappingObj )
cmp{ end  + 1 } = get_param( mappingObj.Block, 'Object' );
end 
end 
if ~isempty( cmp )
found = true;
end 
end 
end 

if ~found


states = find_system( modelName, 'LookUnderMasks', 'on', 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'StateMustResolveToSignalObject', 'on',  ...
'StateName', signalObjName );
if ~isempty( states )
cmp = {  };
for ii = 1:numel( states )
h = get_param( states{ ii }, 'Handle' );
tab = 'Signals/States';
mappingObj = simulinkcoder.internal.util.getMappingObject( modelName, 'States', h );
if ~isempty( mappingObj )
cmp{ end  + 1 } = get_param( mappingObj.OwnerBlockHandle, 'Object' );
else 
portObj = simulinkcoder.internal.util.getMappingObject( modelName, 'Signals', h );
cmp{ end  + 1 } = get_param( portObj.PortHandle, 'Object' );
end 
end 
if ~isempty( cmp )
found = true;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQk8uVX.p.
% Please follow local copyright laws when handling this file.

