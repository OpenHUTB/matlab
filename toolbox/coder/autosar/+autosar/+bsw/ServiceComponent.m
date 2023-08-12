classdef ServiceComponent < handle




properties ( Constant, Access = private )
ReferenceImplLibNames = { 'Dem Module', 'NvM Module', 'FiM Module' };

DemServiceBlockPath = 'autosarlibdem/Diagnostic Service Component';
NvMServiceBlockPath = 'autosarlibnvm/NVRAM Service Component';

FreezeRTE( 1, 1 )autosar.bsw.rte.FreezeRte = autosar.bsw.rte.FreezeRte(  );
end 

properties ( Constant, Access = public )
DemServiceBlockMaskType = 'Diagnostic Service Component';
NvMServiceBlockMaskType = 'NVRAM Service Component';
end 

methods ( Static )
function serviceBlocks = find( sys )

serviceBlocks = find_system( sys,  ...
'Regexp', 'on',  ...
'FollowLinks', 'on',  ...
'LookUnderMasks', 'on',  ...
'MatchFilter', @Simulink.match.activeVariants,  ...
'BlockType', 'SubSystem',  ...
'MaskType', [ '(^', autosar.bsw.ServiceComponent.NvMServiceBlockMaskType, '$|',  ...
'^', autosar.bsw.ServiceComponent.DemServiceBlockMaskType, '$)' ] );
end 

function retImpl = getBswCallerImplementation( m3iOperation )
operationName = m3iOperation.Name;
[ isDem, demImpl ] = autosar.bsw.ServiceComponent.isDemOperation( operationName );
[ isFim, fimImpl ] = autosar.bsw.ServiceComponent.isFiMOperation( operationName );
[ isNvm, nvmImpl ] = autosar.bsw.ServiceComponent.isNvMOperation( operationName );

retImpl = [  ];
if isDem
impl = demImpl;
elseif isFim
impl = fimImpl;
elseif isNvm
impl = nvmImpl;
else 
return ;
end 

inArgs = {  };
outArgs = {  };
errorArgs = {  };
for ii = 1:m3iOperation.Arguments.size
m3iArg = m3iOperation.Arguments.at( ii );
switch m3iArg.Direction
case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In
inArgs = [ inArgs, m3iArg.Name ];%#ok<AGROW>
case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out
outArgs = [ outArgs, m3iArg.Name ];%#ok<AGROW>
case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error
errorArgs = [ errorArgs, m3iArg.Name ];%#ok<AGROW>
otherwise 

return ;
end 
end 

if numel( errorArgs ) > 1

return ;
end 

outArgs = [ outArgs, errorArgs ];
outStr = strjoin( outArgs, ',' );
inStr = strjoin( inArgs, ',' );
if ~isempty( outStr )
if numel( outArgs ) > 1
expectedFcn = sprintf( '[%s] = %%s_%s(%s)', outStr, m3iOperation.Name, inStr );
else 
expectedFcn = sprintf( '%s = %%s_%s(%s)', outStr, m3iOperation.Name, inStr );
end 
else 
expectedFcn = sprintf( '%%s_%s(%s)', outStr, m3iOperation.Name, inStr );
end 

if ~strcmp( impl.FunctionPrototypeMap( operationName ), expectedFcn )


return ;
end 

retImpl = impl;
end 


function isServiceComp = isBswServiceComponent( blkH )
maskType = get_param( blkH, 'MaskType' );
isServiceComp = ~isempty( maskType ) ...
 && ( strcmp( maskType, autosar.bsw.ServiceComponent.DemServiceBlockMaskType ) ...
 || strcmp( maskType, autosar.bsw.ServiceComponent.NvMServiceBlockMaskType ) );
end 

function updateApplicationPorts( bswCompPath )
try 

autosar.bsw.ServiceComponent.doUpdateApplicationPorts( bswCompPath );
catch ME

autosar.mm.util.MessageReporter.throwException( ME );
end 
end 





function preCopyCallback( blkPath, dstModel )
if autosar.api.Utils.isMappedToComponent( dstModel )
blockName = strrep( blkPath, [ dstModel, '/' ], '' );
error( message( 'autosarstandard:bsw:BSWComponentBlockAdditionNotAllowed',  ...
blockName, dstModel ) );
end 
end 



function serviceBlockPath = getServiceBlockForAppFcnName( applicationFcnName )


operationName = autosar.bsw.ServiceComponent.parseOperationAndPortNames(  ...
applicationFcnName );



if autosar.bsw.ServiceComponent.isDemOperation( operationName ) ||  ...
autosar.bsw.ServiceComponent.isFiMOperation( operationName )
serviceBlockPath = autosar.bsw.ServiceComponent.DemServiceBlockPath;
elseif autosar.bsw.ServiceComponent.isNvMOperation( operationName )
serviceBlockPath = autosar.bsw.ServiceComponent.NvMServiceBlockPath;
else 

serviceBlockPath = '';
end 
end 


function deleteRTELayer( sys )
if autosar.bsw.ServiceComponent.FreezeRTE.IsFrozen



return ;
end 
subsystems = find_system( sys, 'SearchDepth', 1,  ...
'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
'BlockType', 'SubSystem', 'IsSimulinkFunction', 'on' );
for subIdx = 1:length( subsystems )
subsys = subsystems{ subIdx };
trigPort = find_system( subsys, 'SearchDepth', 1,  ...
'FollowLinks', 'on', 'BlockType', 'TriggerPort' );
if strcmp( get_param( trigPort, 'FunctionVisibility' ), 'global' )
delete_block( subsys );
end 
end 
end 

function freezeRte( status )
R36
status( 1, 1 ){ islogical }
end 
freezeRteH = autosar.bsw.ServiceComponent.FreezeRTE;
freezeRteH.IsFrozen = status;
end 
end 

methods ( Static )

function bswCompType = getBswCompType( bswCompPath )
blkMaskType = get_param( bswCompPath, 'MaskType' );
switch ( blkMaskType )
case autosar.bsw.ServiceComponent.DemServiceBlockMaskType
bswCompType = 'Dem';
case autosar.bsw.ServiceComponent.NvMServiceBlockMaskType
bswCompType = 'NvM';
otherwise 
assert( false, 'Unsupported BSW block mask type: %s', blkMaskType );
end 
end 

function blkPath = createBlock( sys, serviceImplStr )


serviceImpl = eval( serviceImplStr );

blkName = serviceImpl.getType(  );
blkPath = [ sys, '/', blkName ];
blkH = add_block( 'built-in/Subsystem', blkPath, 'MakeNameUnique', 'on' );
blkPath = getfullname( blkH );

rteConnectorBlockPath = 'autosarspkglib_internal/RTE Service Connector';
add_block( rteConnectorBlockPath, [ blkPath, '/RTE Service Connector' ], 'Position', [ 265, 49, 405, 86 ] );


serviceImpl.addBlocks( blkPath );


mo = get_param( blkPath, 'MaskObject' );
if isempty( mo )
mo = Simulink.Mask.create( blkPath );
end 


mo.Description = serviceImpl.getDescription(  );
mo.Help = serviceImpl.getHelp(  );
mo.Type = serviceImpl.getType(  );

mo.Initialization = 'autosar.bsw.Dem_defineIntEnumTypes(bdroot(gcb));';



mo.SelfModifiable = 'on';


mo.removeAllParameters(  );
mo.addParameter( 'Type', 'edit',  ...
'Name', 'ClientPortNames',  ...
'Prompt', 'Application port names:',  ...
'Value', '{}',  ...
'Tunable', 'on',  ...
'Evaluate', 'off',  ...
'Hidden', 'off' );
mo.addParameter( 'Type', 'edit',  ...
'Name', 'ClientPortPortDefinedArguments',  ...
'Prompt', 'Port defined arguments:',  ...
'Value', '{}',  ...
'Tunable', 'on',  ...
'Evaluate', 'off',  ...
'Hidden', 'off' );



mo.addParameter( 'Type', 'edit',  ...
'Name', 'IdTypes',  ...
'Prompt', 'IdTypes:',  ...
'Value', '{}',  ...
'Tunable', 'on',  ...
'Evaluate', 'off',  ...
'Hidden', 'on',  ...
'NeverSave', 'on' );
serviceImpl.addMaskObjectParameters( mo );


set_param( blkPath, 'DialogController', 'bsw_create_dialog' );
set_param( blkPath, 'DialogControllerArgs', { 'Component' } );


set_param( blkPath, 'PreCopyFcn', 'autosar.bsw.ServiceComponent.preCopyCallback(gcb, bdroot);' );


dialogControls = mo.getDialogControls(  );
for ii = 1:length( dialogControls )
dc = dialogControls( ii );
if strcmp( dc.Name, 'DescGroupVar' )
dc.Prompt = serviceImpl.getType(  );
break 
end 
end 

blockIconType = serviceImpl.getBlockIconType(  );
if ~isempty( blockIconType )
blockDVGIcon = [ 'BSWBlockIcon.', blockIconType ];
mo.BlockDVGIcon = blockDVGIcon;


width = 140;
height = 65;


set_param( bdroot( sys ), 'PreLoadFcn', 'autosar.bsw.BasicSoftwareCaller.registerIcons();' );
else 
mo.Display = serviceImpl.getDisplay(  );
width = 140;
height = 65;
end 


pos = get_param( blkPath, 'Position' );
pos( 3 ) = pos( 1 ) + width;
pos( 4 ) = pos( 2 ) + height;
set_param( blkPath, 'Position', pos );


set_param( blkPath, 'BlockKeywords', serviceImpl.getKeywords(  ) );



Simulink.Block.eval( get_param( blkPath, 'Handle' ) );


set_param( blkPath, 'MaskHideContents', 'on' );
end 

function isBsw = isBswOperation( fcnName )

operationName = autosar.bsw.ServiceComponent.parseOperationAndPortNames(  ...
fcnName );

isBsw = autosar.bsw.ServiceComponent.isDemOperation( operationName ) ||  ...
autosar.bsw.ServiceComponent.isFiMOperation( operationName ) ||  ...
autosar.bsw.ServiceComponent.isNvMOperation( operationName );
end 
end 

methods ( Static, Access = private )

function doUpdateApplicationPorts( bswCompPath )
isLib = strcmp( get_param( bdroot( bswCompPath ), 'BlockDiagramType' ), 'library' );
if isLib
return 
end 

modelName = bdroot( bswCompPath );
if ~autosar.validation.CompiledModelUtils.isCompiled( modelName )
return 
end 




autosar.api.Utils.autosarlicensed( true );


autosar.bsw.ServiceComponent.verifySingletonBlock( bswCompPath );

if autosar.bsw.ServiceComponent.FreezeRTE.IsFrozen



return ;
end 


[ allApplicationFcnNames, allApplicationFcnTypeData ] = autosar.bsw.ServiceComponent.getApplicationFcnNames( modelName );


serviceFunctionNames = {  };
applicationFcnNames = {  };

clientPortNames = {  };
idTypes = {  };

bswCompType = autosar.bsw.ServiceComponent.getBswCompType( bswCompPath );
for fcnIdx = 1:length( allApplicationFcnNames )

applicationFcnName = allApplicationFcnNames{ fcnIdx };
[ operationName, portName ] = autosar.bsw.ServiceComponent.parseOperationAndPortNames(  ...
applicationFcnName );

if isempty( operationName )

continue ;
end 

switch ( bswCompType )
case 'Dem'
if autosar.bsw.ServiceComponent.isDemOperation( operationName )
applicationFcnNames{ end  + 1 } = applicationFcnName;%#ok<AGROW>
serviceFunctionNames{ end  + 1 } = [ bswCompType, '_', operationName ];%#ok<AGROW>
clientPortNames{ end  + 1 } = portName;%#ok<AGROW>
defaultPortDefinedArgument = '1';
if strcmp( operationName, 'SetOperationCycleState' ) ||  ...
strcmp( operationName, 'GetOperationCycleState' )
idTypes{ end  + 1 } = 'OperationCycleId';%#ok<AGROW>
elseif strcmp( operationName, 'SetEnableCondition' )
idTypes{ end  + 1 } = 'EnableConditionId';%#ok<AGROW>
elseif strcmp( operationName, 'SetStorageCondition' )
idTypes{ end  + 1 } = 'StorageConditionId';%#ok<AGROW>
else 
idTypes{ end  + 1 } = 'EventId';%#ok<AGROW>
end 
elseif autosar.bsw.ServiceComponent.isFiMOperation( operationName )
applicationFcnNames{ end  + 1 } = applicationFcnName;%#ok<AGROW>
serviceFunctionNames{ end  + 1 } = [ 'FiM', '_', operationName ];%#ok<AGROW>
clientPortNames{ end  + 1 } = portName;%#ok<AGROW>
defaultPortDefinedArgument = '1';
idTypes{ end  + 1 } = 'FID';%#ok<AGROW>
end 
case 'NvM'
if autosar.bsw.ServiceComponent.isNvMOperation( operationName )
applicationFcnNames{ end  + 1 } = applicationFcnName;%#ok<AGROW>
serviceFunctionNames{ end  + 1 } = [ bswCompType, '_', operationName ];%#ok<AGROW>
clientPortNames{ end  + 1 } = portName;%#ok<AGROW>
defaultPortDefinedArgument = '-1';
idTypes{ end  + 1 } = 'BlockId';%#ok<AGROW>
end 
otherwise 
assert( false, 'Unsupported bsw component type: %s', bswCompType );
end 
end 

clientPortPortDefinedArguments = cell( 1, length( clientPortNames ) );


oldClientPortNames = eval( get_param( bswCompPath, 'ClientPortNames' ) );
oldPortDefinedArguments = eval( get_param( bswCompPath, 'ClientPortPortDefinedArguments' ) );

for ii = 1:length( clientPortNames )
portName = clientPortNames{ ii };
portDefinedArgumentCell = oldPortDefinedArguments( strcmp( oldClientPortNames, portName ) );
if isempty( portDefinedArgumentCell )
clientPortPortDefinedArguments{ ii } = defaultPortDefinedArgument;
else 
clientPortPortDefinedArguments{ ii } = portDefinedArgumentCell{ 1 };
end 
end 


if any( strcmp( clientPortPortDefinedArguments, '-1' ) )


uniqueIDs = cell( size( clientPortPortDefinedArguments ) );
for ii = 1:length( clientPortPortDefinedArguments )
uniqueIDs{ ii } = num2str( ii );
end 
[ ~, usedIds ] = intersect( uniqueIDs, clientPortPortDefinedArguments );
uniqueIDs( usedIds ) = [  ];


replaceIdx = find( strcmp( clientPortPortDefinedArguments, '-1' ) );
replaceClientPortNames = clientPortNames( replaceIdx );
[ ~, ~, replaceClientPortNamesIdx ] = unique( replaceClientPortNames );
for ii = 1:length( replaceIdx )
clientPortPortDefinedArguments( replaceIdx( ii ) ) = uniqueIDs( replaceClientPortNamesIdx( ii ) );
end 
end 


connecterPath = [ bswCompPath, '/RTE Service Connector' ];
set_param( connecterPath, 'ApplicationFunctionNames', [ '{', autosar.api.Utils.cell2str( applicationFcnNames ), '}' ] );
set_param( connecterPath, 'ServiceFunctionNames', [ '{', autosar.api.Utils.cell2str( serviceFunctionNames ), '}' ] );
set_param( connecterPath, 'ServicePortDefinedArguments', [ '{', autosar.api.Utils.cell2str( clientPortPortDefinedArguments ), '}' ] );
if strcmp( bswCompType, 'NvM' ) && slfeature( 'NVRAMInitialValue' )
set_param( connecterPath, 'NvMInitValues', get_param( bswCompPath, 'NvInitValues' ) );
end 


[ clientPortNames, index ] = unique( clientPortNames );
clientPortPortDefinedArguments = clientPortPortDefinedArguments( index );
idTypes = idTypes( index );


set_param( bswCompPath, 'ClientPortNames', [ '{', autosar.api.Utils.cell2str( clientPortNames ), '}' ] );


set_param( bswCompPath, 'ClientPortPortDefinedArguments', [ '{', autosar.api.Utils.cell2str( clientPortPortDefinedArguments ), '}' ] );


set_param( bswCompPath, 'IdTypes', [ '{', autosar.api.Utils.cell2str( idTypes ), '}' ] );

if strcmp( bswCompType, 'Dem' )
demOverrideBlocks = autosar.bsw.ServiceComponent.findAndVerifyDemStatusBlocks( bswCompPath );
autosar.bsw.ServiceComponent.setOverriddenEventIds( bswCompPath, demOverrideBlocks );
end 

autosar.bsw.ServiceComponent.checkClientPortIDs( bswCompPath );



autosar.bsw.ServiceComponent.configureRTE( connecterPath, allApplicationFcnTypeData );
end 

function [ demOverrideBlocks, demInjectBlocks ] = findAndVerifyDemStatusBlocks( bswCompPath )
[ demOverrideBlocks, demInjectBlocks ] =  ...
autosar.bsw.DemStatusValidator.findDemStatusBlocks( bdroot( bswCompPath ) );

autosar.bsw.DemStatusValidator.verifyNoDupeAndInject( demOverrideBlocks, demInjectBlocks );
autosar.bsw.DemStatusValidator.verifyNoSharedEventIds( demOverrideBlocks );

idTypes = eval( get_param( bswCompPath, 'IdTypes' ) );
portDefinedArgs = eval( get_param( bswCompPath, 'ClientPortPortDefinedArguments' ) );
portDefinedArgs = cellfun( @( x )str2double( x ), portDefinedArgs, 'UniformOutput', true );
eventIdIdxs = strcmp( idTypes, 'EventId' );
eventIds = portDefinedArgs( eventIdIdxs );

autosar.bsw.DemStatusValidator.verifyValidEventIds( demOverrideBlocks, eventIds );
autosar.bsw.DemStatusValidator.verifyValidEventIds( demInjectBlocks, eventIds );
end 

function setOverriddenEventIds( bswCompPath, demOverrideBlocks )
overriddenEventIds = autosar.bsw.DemStatusValidator.getEventIds( bdroot( bswCompPath ), demOverrideBlocks );
if ~isempty( overriddenEventIds )
overriddenEventIds = mat2str( overriddenEventIds );
else 
overriddenEventIds = '[]';
end 
set_param( [ bswCompPath, '/DEM' ], 'OverriddenEventIds', overriddenEventIds );
end 

function checkClientPortIDs( bswCompPath )

clientPortPortDefinedArguments = eval( get_param( bswCompPath, 'ClientPortPortDefinedArguments' ) );
clientPortNames = eval( get_param( bswCompPath, 'ClientPortNames' ) );
emptyIDs = cellfun( @( x )isempty( x ), clientPortPortDefinedArguments );
if any( emptyIDs )
invalidNames = clientPortNames( emptyIDs );
baseException = MSLException( 'autosarstandard:bsw:ServiceComponentConfigInvalid', getfullname( bswCompPath ) );
for ii = 1:numel( invalidNames )
causeExp = MSLException( 'autosarstandard:bsw:InvalidPortId', invalidNames{ ii } );
baseException = baseException.addCause( causeExp );
end 
if ~isempty( baseException.cause )
baseException.throw(  );
end 
end 
end 

function [ operationName, portName ] = parseOperationAndPortNames( fcnName )
operationName = '';
portName = '';

pat = '(?<PortName>\w+)\_(?<OperationName>\w+)';
names = regexp( fcnName, pat, 'names' );
if ~isempty( names )
operationName = names.OperationName;
portName = names.PortName;
end 
end 


function verifySingletonBlock( blkPath )

maskType = get_param( blkPath, 'MaskType' );


serviceBlocks = find_system( bdroot( blkPath ),  ...
'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookUnderMasks', 'on',  ...
'BlockType', 'SubSystem',  ...
'MaskType', maskType );
if length( serviceBlocks ) > 1
DAStudio.error( 'autosarstandard:bsw:multipleServiceComponents', maskType, serviceBlocks{ 1 }, serviceBlocks{ 2 } );
end 

end 




function configureRTE( connectorPath, compiledTypeData )

isLib = strcmp( get_param( bdroot( connectorPath ), 'BlockDiagramType' ), 'library' );
if isLib
return 
end 

applicationFcnNamesStr = get_param( connectorPath, 'ApplicationFunctionNames' );
applicationFcnNames = eval( applicationFcnNamesStr );

serviceFunctionNamesStr = get_param( connectorPath, 'ServiceFunctionNames' );
serviceFunctionNames = eval( serviceFunctionNamesStr );

portDefArgumentsStr = get_param( connectorPath, 'ServicePortDefinedArguments' );
portDefArguments = eval( portDefArgumentsStr );

if isempty( applicationFcnNames )

return 
end 


[ ~, bswCompType ] = autosar.bsw.ServiceComponent.parseOperationAndPortNames(  ...
serviceFunctionNames{ 1 } );



applicationFcnsInfo = autosar.bsw.ServiceComponent.getApplicationFcnsInfo(  ...
applicationFcnNames, bswCompType );
if isempty( applicationFcnsInfo )
return 
end 


sortOrder = autosar.bsw.ServiceComponent.sortRteFunctions( applicationFcnsInfo );
applicationFcnNames = applicationFcnNames( sortOrder );
applicationFcnsInfo = applicationFcnsInfo( sortOrder );
serviceFunctionNames = serviceFunctionNames( sortOrder );
portDefArguments = portDefArguments( sortOrder );


defaultPos = [ 105, 115, 327, 215 ];
gap = 140;
for fcnIdx = 1:numel( applicationFcnsInfo )
compTypeData = compiledTypeData{  ...
cellfun( @( x )strcmp( x.fcnName, applicationFcnNames{ fcnIdx } ), compiledTypeData ) };

simulinkFcnBlk = autosar.bsw.ServiceComponent.defineCaller(  ...
connectorPath, applicationFcnsInfo( fcnIdx ),  ...
serviceFunctionNames{ fcnIdx }, portDefArguments{ fcnIdx },  ...
compTypeData );


set_param( simulinkFcnBlk, 'Position',  ...
[ defaultPos( 1 ), defaultPos( 2 ) + ( gap * ( fcnIdx - 1 ) ) ...
, defaultPos( 3 ), defaultPos( 4 ) + ( gap * ( fcnIdx - 1 ) ) ] );
autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock( simulinkFcnBlk );
end 

if slfeature( 'FaultAnalyzerBsw' )

faultInjector = autosar.bsw.rte.FaultInjector( connectorPath );
faultInjector.clearUnfaultedEvents(  );
end 
end 

function sortOrder = sortRteFunctions( applicationFcnsInfo )

basicOrder = 1:numel( applicationFcnsInfo );




readWriteOperationIdx = contains( { applicationFcnsInfo.ApplicationFcnPrototype }, { 'ReadBlock', 'WriteBlock' } );
sortOrder = [ basicOrder( readWriteOperationIdx ), basicOrder( ~readWriteOperationIdx ) ];
end 

function simulinkFcnBlk = defineCaller( destPath, callerInfo,  ...
serviceFunctionName, portDefArgument, compTypeData )


[ simulinkFcnBlk, inArgHandles, outArgHandles ] =  ...
autosar.bsw.ServiceComponent.createOrGetSimulinkFcnForCaller(  ...
callerInfo, destPath );

if autosar.bsw.ServiceComponent.isOverriddenCall( destPath, callerInfo, portDefArgument )
rteStrategy = autosar.bsw.rte.NullRTEStrategy( serviceFunctionName );
else 

rteStrategy = autosar.bsw.rte.RTEStrategy.getRTEStrategy( serviceFunctionName );
end 
rteStrategy.createRTE( simulinkFcnBlk, inArgHandles, outArgHandles, portDefArgument, compTypeData );
end 

function isOverriddenCall = isOverriddenCall( destPath, callerInfo, portDefArgument )
isOverriddenCall = false;
bswCompBlk = get_param( destPath, 'Parent' );
if ~strcmp( autosar.bsw.ServiceComponent.getBswCompType( bswCompBlk ), 'Dem' )

return ;
end 

overriddenEvents = eval( get_param( [ bswCompBlk, '/DEM' ], 'OverriddenEventIds' ) );
if isempty( overriddenEvents )
return ;
end 

if contains( callerInfo.ApplicationFcnPrototype, '_SetEventStatus(' ) && any( overriddenEvents == str2double( portDefArgument ) )
isOverriddenCall = true;
end 
end 



function fcnsInfo = getApplicationFcnsInfo( applicationFcnNames, bswCompType )
fcnsInfo = [  ];

if isempty( applicationFcnNames )
return 
end 




fcnInfo = struct( 'ApplicationFcnPrototype', '',  ...
'InArgSpecs', '',  ...
'OutArgSpecs', '',  ...
'EnumDatatype', '' );
for fcnIdx = 1:length( applicationFcnNames )
applicationFcnName = applicationFcnNames{ fcnIdx };
[ operationName, portName ] = autosar.bsw.ServiceComponent.parseOperationAndPortNames(  ...
applicationFcnName );

switch ( bswCompType )
case { 'Dem', 'FiM' }
if autosar.bsw.DemDiagnosticMonitor.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemDiagnosticMonitor';
elseif autosar.bsw.DemDiagnosticInfo.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemDiagnosticInfo';
elseif autosar.bsw.DemEnableCondition.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemEnableCondition';
elseif autosar.bsw.DemEventAvailable.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemEventAvailable';
elseif autosar.bsw.DemIUMPRDenominator.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemIUMPRDenominator';
elseif autosar.bsw.DemIUMPRDenominatorCondition.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemIUMPRDenominatorCondition';
elseif autosar.bsw.DemIUMPRNumerator.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemIUMPRNumerator';
elseif autosar.bsw.DemOperationCycle.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemOperationCycle';
elseif autosar.bsw.DemPfcCycleQualified.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemPfcCycleQualified';
elseif autosar.bsw.DemStorageCondition.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.DemStorageCondition';
elseif autosar.bsw.FiM_ControlFunctionAvailable.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.FiM_ControlFunctionAvailable';
elseif autosar.bsw.FiM_FunctionInhibition.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.FiM_FunctionInhibition';
else 


continue ;
end 
case 'NvM'
if autosar.bsw.NvMService.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.NvMService';
elseif autosar.bsw.NvMAdmin.FunctionPrototypeMap.isKey( operationName )
serviceClassName = 'autosar.bsw.NvMAdmin';
else 


continue ;
end 
otherwise 
assert( false, 'Unsupported bsw component type: %s', bswCompType );
end 


serviceFcnPrototype = eval( [ serviceClassName, '.FunctionPrototypeMap(''', operationName, ''')' ] );%#ok<EVLDOT>
fcnInfo.ApplicationFcnPrototype = sprintf( serviceFcnPrototype, portName );
fcnInfo.InArgSpecs = eval( [ serviceClassName, '.InputArgSpecMap(''', operationName, ''')' ] );%#ok<EVLDOT>
fcnInfo.OutArgSpecs = eval( [ serviceClassName, '.OutputArgSpecMap(''', operationName, ''')' ] );%#ok<EVLDOT>
if any( contains( properties( serviceClassName ), 'EnumDatatypeMap' ) )
fcnInfo.EnumDatatype = eval( [ serviceClassName, '.EnumDatatypeMap(''', operationName, ''')' ] );%#ok<EVLDOT>
end 
fcnsInfo = [ fcnsInfo, fcnInfo ];%#ok<AGROW>
end 
end 



function [ simulinkFcnBlk, inArgHandles, outArgHandles ] =  ...
createOrGetSimulinkFcnForCaller( callerInfo, destPath )


[ inArgNames, outArgNames, fcnName ] =  ...
autosar.validation.ClientServerValidator.getFcnInOutParamNames(  ...
callerInfo.ApplicationFcnPrototype );


simulinkFcnBlk = [ destPath, '/', fcnName ];
if isempty( find_system( destPath, 'SearchDepth', 1,  ...
'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
'BlockType', 'SubSystem', 'Name', fcnName ) )

add_block( 'built-in/SubSystem',  ...
[ destPath, '/', fcnName ] );

add_block( 'built-in/TriggerPort',  ...
[ simulinkFcnBlk, '/', fcnName ],  ...
'TriggerType', 'function-call',  ...
'StatesWhenEnabling', 'held',  ...
'IsSimulinkFunction', 'on',  ...
'FunctionVisibility', 'global',  ...
'FunctionName', fcnName,  ...
'Position', [ 400, 20, 420, 40 ] );
else 
assert( strcmp( get_param( simulinkFcnBlk, 'IsSimulinkFunction' ), 'on' ),  ...
'%s is not a Simulink function', simulinkFcnBlk );
end 


inArgSpecs = regexp( callerInfo.InArgSpecs, '\s*,\s*', 'split' );
outArgSpecs = regexp( callerInfo.OutArgSpecs, '\s*,\s*', 'split' );

inArgPosition = [ 85, 60, 170, 80 ];
gap = 80;
inArgHandles = [  ];
for argIdx = 1:length( inArgNames )
inArgName = inArgNames{ argIdx };
inArgSpec = inArgSpecs{ argIdx };
argH = autosar.bsw.ServiceComponent.createOrGetArgumentBlk(  ...
simulinkFcnBlk, inArgName, inArgSpec,  ...
callerInfo.EnumDatatype, true );


set_param( argH, 'Position',  ...
[ inArgPosition( 1 ), inArgPosition( 2 ) + ( gap * argIdx ) ...
, inArgPosition( 3 ), inArgPosition( 4 ) + ( gap * argIdx ) ] );
autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock( argH );
inArgHandles = [ inArgHandles, argH ];%#ok<AGROW>
end 


outArgPosition = [ 685, 60, 735, 80 ];
outArgHandles = [  ];
for argIdx = 1:length( outArgNames )
outArgName = outArgNames{ argIdx };
outArgSpec = outArgSpecs{ argIdx };

argH = autosar.bsw.ServiceComponent.createOrGetArgumentBlk(  ...
simulinkFcnBlk, outArgName, outArgSpec,  ...
callerInfo.EnumDatatype, false );


set_param( argH, 'Position',  ...
[ outArgPosition( 1 ), outArgPosition( 2 ) + ( gap * argIdx ) ...
, outArgPosition( 3 ), outArgPosition( 4 ) + ( gap * argIdx ) ] );
autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock( argH );
outArgHandles = [ outArgHandles, argH ];%#ok<AGROW>
end 


simulinkFcnBlk = getfullname( simulinkFcnBlk );
end 



function argH = createOrGetArgumentBlk( simulinkFcnPath, argName, argSpec,  ...
enumDatatype, isArgIn )

portDimStr = '1';
if contains( argSpec, '%s' )
outDatatype = enumDatatype;
else 
value = eval( argSpec );
outDatatype = class( value );
if numel( value ) > 1
portDimStr = mat2str( size( value ) );
end 
end 

if strcmp( outDatatype, 'logical' )
outDatatype = 'boolean';
end 

if isArgIn
argBlkType = 'ArgIn';
else 
argBlkType = 'ArgOut';
end 

argBlock = [ simulinkFcnPath, '/', argName ];
if isempty( find_system( simulinkFcnPath, 'SearchDepth', 1,  ...
'BlockType', argBlkType, 'Name', argName ) )
argH = add_block( [ 'built-in/', argBlkType ], argBlock,  ...
'ArgumentName', argName );
else 
argH = get_param( argBlock, 'Handle' );
end 
set_param( argH, 'OutDataTypeStr', outDatatype,  ...
'PortDimensions', portDimStr );
autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock( argH );
end 



function [ fcnNames, typeDimData ] = getApplicationFcnNames( model )
fcnNames = {  };
typeDimData = {  };
compiledFcns = autosar.bsw.ServiceComponent.getCompiledRequiredAndProvidedFunctions( model );

if isempty( compiledFcns )
return 
end 


serviceImpls = autosar.bsw.ServiceImplementation.getServiceImpls(  );
operationToImplMap = containers.Map(  );
for implIdx = 1:numel( serviceImpls )
serviceImpl = serviceImpls{ implIdx };
operations = serviceImpl.getOperations(  );
for operationIdx = 1:numel( operations )
operationToImplMap( operations{ operationIdx } ) = serviceImpl;
end 
end 

for fcnIdx = 1:length( compiledFcns )
requiredFunctions = compiledFcns( fcnIdx ).RequiredFunctions;
arBlocksetCallers = zeros( 1, numel( requiredFunctions ) );

if isempty( requiredFunctions )
continue ;
end 

for ii = 1:numel( requiredFunctions )
reqFcnName = requiredFunctions( ii ).FunctionName;
reqFcnNameParts = strsplit( reqFcnName, '_' );
reqFcnNameActual = reqFcnNameParts{ end  };

if ~operationToImplMap.isKey( reqFcnNameActual )

continue ;
end 


implToReference = operationToImplMap( reqFcnNameActual );
implFcnProto = implToReference.FunctionPrototypeMap( reqFcnNameActual );





reqFcnArgs = requiredFunctions( ii ).FcnArgs;

argNames = reqFcnArgs.argNameMap.keys;
argNameWithPosition = cellfun( @( x )reqFcnArgs.argNameMap.getByKey( x ), argNames );

argIndexKeys = reqFcnArgs.argIndexMap.keys;
argIndexWithPosition = cellfun( @( x )reqFcnArgs.argIndexMap.getByKey( x ), argIndexKeys );

namesByPosition = cell( 1, numel( argNameWithPosition ) );
for jj = 1:numel( argNameWithPosition )
namesByPosition{ argNameWithPosition( jj ).position + 1 } = argNameWithPosition( jj ).name;
end 

inArgs = {  };
outArgs = {  };
inOutArgs = {  };
for jj = 1:numel( argIndexWithPosition )
position = argIndexWithPosition( jj ).position;
dirStr = argIndexWithPosition( jj ).index;
if startsWith( dirStr, 'IO' )
posInGroup = str2double( dirStr( 3:end  ) ) + 1;
inOutArgs{ posInGroup } = namesByPosition{ position + 1 };%#ok<AGROW>
elseif startsWith( dirStr, 'I' )
posInGroup = str2double( dirStr( 2:end  ) ) + 1;
inArgs{ posInGroup } = namesByPosition{ position + 1 };%#ok<AGROW>
elseif startsWith( dirStr, 'O' )
posInGroup = str2double( dirStr( 2:end  ) ) + 1;
outArgs{ posInGroup } = namesByPosition{ position + 1 };%#ok<AGROW>
else 
assert( false, 'Unexpected argument type' );
end 
end 

if ~isempty( inOutArgs )

continue ;
end 



if numel( outArgs ) > 1
constructedOutStr = [ '[', strrep( autosar.api.Utils.cell2str( outArgs ), '''', '' ), ']' ];
else 
constructedOutStr = strrep( autosar.api.Utils.cell2str( outArgs ), '''', '' );
end 
constructedInStr = [ '(', strrep( autosar.api.Utils.cell2str( inArgs ), '''', '' ), ')' ];
constuctedFcn = [ constructedOutStr, ' = %s_', reqFcnNameActual, constructedInStr ];

typeParser = autosar.bsw.rte.CompFunctionTypeParser(  );
typeData = typeParser.convert( requiredFunctions( ii ).FcnArgs );
typeData.fcnName = reqFcnName;
typeDimData = [ typeDimData, typeData ];%#ok<AGROW>


if strcmp( autosar.bsw.ServiceComponent.formatFcnString( constuctedFcn ),  ...
autosar.bsw.ServiceComponent.formatFcnString( implFcnProto ) )
arBlocksetCallers( ii ) = true;
end 
end 

requiredFunctionNames = { requiredFunctions.FunctionName };
fcnNames = [ fcnNames, requiredFunctionNames( logical( arBlocksetCallers ) ) ];%#ok
end 
fcnNames = unique( fcnNames );
end 


function compiledFcns = getCompiledRequiredAndProvidedFunctions( model )
assert( autosar.validation.CompiledModelUtils.isCompiled( model ),  ...
'Getting application names is only supported when model is compiled' );

compiledFcns = [  ];





allModelBlocks = find_system( model, 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookUnderMasks', 'all', 'BlockType', 'ModelReference' );


modelBlocks = [  ];
for blkIdx = 1:length( allModelBlocks )
modelBlock = allModelBlocks{ blkIdx };
if ~any( strcmp( autosar.bsw.ServiceComponent.getRefModelName( modelBlock ),  ...
autosar.bsw.ServiceComponent.ReferenceImplLibNames ) )
modelBlocks{ end  + 1 } = modelBlock;%#ok<AGROW>
end 
end 

if isempty( modelBlocks )
return 
end 


for blkIdx = 1:length( modelBlocks )
modelBlock = modelBlocks{ blkIdx };
refMdlInfo = Simulink.internal.ModelRefCompileInterface( modelBlock );
compiledFcns = [ compiledFcns, refMdlInfo.requiredAndProvidedFunctions(  ) ];%#ok
end 
end 

function refModelName = getRefModelName( hBlock )
lIsProtected = strcmp( get_param( hBlock, 'ProtectedModel' ), 'on' );
if lIsProtected
lModelFile = get_param( hBlock, 'ModelFile' );
refModelName = strrep( lModelFile, '.slxp', '' );
else 
refModelName = get_param( hBlock, 'ModelName' );
end 
end 


function fcnNames = getApplicationFcnNames_graph( modelH )
assert( ishandle( modelH ), 'modelH should be a handle' );

functionCatalog = Simulink.FunctionGraphCatalog( modelH, 'ListFunctionsAndCallers' );
fcnNames = {  };
for fcnIdx = 1:length( functionCatalog )
fcn = functionCatalog{ fcnIdx };
if ~isempty( fcn{ 2 } )
fcnName = functionCatalog{ fcnIdx }{ 1 };
if ~isempty( fcnName )
fcnNames{ end  + 1 } = fcnName;%#ok<AGROW>
end 
end 
end 
fcnNames = unique( fcnNames );
end 

function [ isDem, impl ] = isDemOperation( operationName )
demImplementations = { 
'autosar.bsw.DemDiagnosticMonitor'
'autosar.bsw.DemDiagnosticInfo'
'autosar.bsw.DemEventAvailable'
'autosar.bsw.DemOperationCycle'
 };
if slfeature( 'AUTOSARNonShippingBSW' )
demImplementations = [ demImplementations;
{ 
'autosar.bsw.DemEnableCondition'
'autosar.bsw.DemIUMPRDenominator'
'autosar.bsw.DemIUMPRDenominatorCondition'
'autosar.bsw.DemIUMPRNumerator'
'autosar.bsw.DemPfcCycleQualified'
'autosar.bsw.DemStorageCondition'
 } ];
end 

isDem = false;
impl = [  ];
for ii = 1:numel( demImplementations )
implClass = eval( demImplementations{ ii } );
if implClass.FunctionPrototypeMap.isKey( operationName )
isDem = true;
impl = implClass;
return ;
end 
end 
end 

function [ isNvM, impl ] = isNvMOperation( operationName )
nvmImplementations = { 
'autosar.bsw.NvMService'
'autosar.bsw.NvMAdmin'
 };

isNvM = false;
impl = [  ];
for ii = 1:numel( nvmImplementations )
implClass = eval( nvmImplementations{ ii } );
if implClass.FunctionPrototypeMap.isKey( operationName )
isNvM = true;
impl = implClass;
return ;
end 
end 
end 

function [ isFiM, impl ] = isFiMOperation( operationName )
fimImplementations = { 
'autosar.bsw.FiM_FunctionInhibition'
'autosar.bsw.FiM_ControlFunctionAvailable'
 };

isFiM = false;
impl = [  ];
for ii = 1:numel( fimImplementations )
implClass = eval( fimImplementations{ ii } );
if implClass.FunctionPrototypeMap.isKey( operationName )
isFiM = true;
impl = implClass;
return ;
end 
end 
end 

function formattedStr = formatFcnString( functionStr )
formattedStr = strrep( functionStr, ', ', ',' );
formattedStr = strrep( formattedStr, '  ', ' ' );
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpwLtaZY.p.
% Please follow local copyright laws when handling this file.

