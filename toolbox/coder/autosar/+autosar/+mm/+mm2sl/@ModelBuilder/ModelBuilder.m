classdef ModelBuilder < m3i.Visitor






properties ( Hidden = true, GetAccess = public, SetAccess = private )
m3iModel;
m3iComponent;
m3iSwcTiming;


slTypeBuilder;
slConstBuilder;
slParameterBuilder;
SLModelBuilder;
SLLookupTableBuilder;
slCurrentSS = [  ];

slModelName;
slSystemName;
ModelPeriodicRunnablesAs;
NumPeriodicRunnables;
schemaVersion;
InitRunnable;
ResetRunnables;
TerminateRunnable;


slPort2RefBiMap;
slPort2AccessMap;
slIrvRef2RunnableMap;

msgStream;
SampleTimes;
UpdateMode;
AutoDelete;
ChangeLogger;
XmlOptsGetter;
DDConnectionCleanupObj;
ShareAUTOSARProperties;

DsmBlockMap;
SlParamMap;
SlParam2RefMap;

IsCompositionComponent;
ComponentHasBehavior;

SysConstsValueMap;
PostBuildCritsValueMap;
NVServiceNeedsPIMSet;
UsedDataElementName2M3iServiceNeedMap;


OrderedM3IRunnables;
CompatibleSwAddrMethods;

ManualIRVAdditionsMap;

M3IConnectedPortFinder autosar.mm.mm2sl.utils.M3IConnectedPortFinder;


ForceLegacyWorkspaceBehavior = false;

UseBusElementPorts;
end 

methods ( Access = public )

sysHandle = createApplicationComponent( self, m3iComp, varargin )
createCalibrationComponentObjects( self, m3iComp, varargin )




function self = ModelBuilder( m3iModel, dataDictionary, shareAUTOSARProperties,  ...
changeLogger, xmlOptsGetter, m3iSwcTiming, namedargs )
R36
m3iModel
dataDictionary
shareAUTOSARProperties
changeLogger
xmlOptsGetter
m3iSwcTiming
namedargs.PredefinedVariant = ''
namedargs.SystemConstValueSets = {  }
namedargs.UseValueTypes = false
end 

assert( isa( m3iModel, 'Simulink.metamodel.foundation.Domain' ), 'Expected m3i model' );


if isempty( dataDictionary )
workSpace = 'base';
else 
workSpace = Simulink.dd.open( dataDictionary );
self.DDConnectionCleanupObj = onCleanup( @workSpace.close );
end 

self.ModelPeriodicRunnablesAs = 'Auto';
self.ChangeLogger = changeLogger;
self.m3iModel = m3iModel;
self.m3iSwcTiming = m3iSwcTiming;
self.ShareAUTOSARProperties = shareAUTOSARProperties;
self.XmlOptsGetter = xmlOptsGetter;
self.SysConstsValueMap =  ...
autosar.api.Utils.createSystemConstantMap( m3iModel, namedargs.PredefinedVariant, namedargs.SystemConstValueSets );
self.PostBuildCritsValueMap =  ...
autosar.api.Utils.createPostBuildVariantCriterionMap( m3iModel, namedargs.PredefinedVariant, namedargs.SystemConstValueSets );
self.slTypeBuilder = autosar.mm.mm2sl.TypeBuilder( self.m3iModel, true, workSpace, self.ChangeLogger, self.SysConstsValueMap,  ...
self.PostBuildCritsValueMap, UseValueTypes = namedargs.UseValueTypes );
self.slConstBuilder = autosar.mm.mm2sl.ConstantBuilder( self.m3iModel, self.slTypeBuilder );
if slfeature( 'AUTOSARPPortInitValue' )
self.M3IConnectedPortFinder = autosar.mm.mm2sl.utils.M3IConnectedPortFinder( m3iModel );
else 
self.M3IConnectedPortFinder = autosar.mm.mm2sl.utils.M3IConnectedPortFinder.empty;
end 
self.slParameterBuilder = autosar.mm.mm2sl.ParameterBuilder( self.m3iModel, self.M3IConnectedPortFinder, self.slTypeBuilder, self.slConstBuilder, self.ChangeLogger );


self.registerVisitor( 'mmVisit', 'mmVisit' );




self.bind( 'Simulink.metamodel.arplatform.component.Component', @mmWalkComponent, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.component.AtomicComponent', @mmWalkApplicationComponent, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior', @mmWalkApplicationComponentBehavior, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.port.Port', @mmWalkPort, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.SenderReceiverInterface', @mmWalkSenderReceiverInterface, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.NvDataInterface', @mmWalkNvDataInterface, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.ModeSwitchInterface', @mmWalkModeSwitchInterface, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.ClientServerInterface', @mmWalkClientServerInterface, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.ServiceInterface', @mmWalkServiceInterface, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement', @mmWalkModeDeclarationGroupElement, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.FlowData', @mmWalkFlowData, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.Operation', @mmWalkOperation, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.ArgumentData', @mmWalkArgumentData, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.IrvData', @mmWalkIrvData, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.Runnable', @mmWalkRunnable, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.ModeSwitchEvent', @mmWalkModeSwitchEvent, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.OperationInvokedEvent', @mmWalkOperationInvokedEvent, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.OperationBlockingAccess', @mmWalkOperationBlockingAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.OperationNonBlockingAccess', @mmWalkOperationNonBlockingAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.InternalTrigger', @mmWalkInternalTriggeringPoint, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.ComponentParameterAccess', @mmWalkComponentParameterAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.PortParameterAccess', @mmWalkPortParameterAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.FlowDataAccess', @mmWalkFlowDataAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.DataAccess', @mmWalkDataAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.ModeAccess', @mmWalkModeAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.ModeSwitch', @mmWalkModeAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.ServiceDependency', @mmWalkServiceDependency, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef', @mmWalkFlowDataPortInstanceRef, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.behavior.IrvAccess', @mmWalkIrvAccess, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef', @mmModeDeclarationInstanceRef, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.instance.OperationPortInstanceRef', @mmWalkOperationPortInstanceRef, 'mmVisit' );
self.bind( 'Simulink.metamodel.arplatform.interface.VariableData', @walkVariableData, 'mmVisit' );

self.msgStream = autosar.mm.util.MessageStreamHandler.instance(  );


load_system( 'simulink' );

self.SlParamMap = containers.Map(  );
self.SlParam2RefMap = containers.Map(  );
self.DsmBlockMap = containers.Map(  );
self.UsedDataElementName2M3iServiceNeedMap = containers.Map(  );
end 



function ret = mmVisitM3IObject( ~, ~, varargin )
ret = [  ];
end 




function ret = visitM3IObject( ~, ~, varargin )
ret = [  ];
end 



function ret = mmWalkComponent( self, m3iComp )
import autosar.mm.util.XmlOptionsAdapter;
ret = [  ];

self.slSystemName = self.slModelName;
self.NumPeriodicRunnables = autosar.mm.mm2sl.RunnableHelper.getPeriodicRunnablesCount( m3iComp );



self.ComponentHasBehavior = ~self.IsCompositionComponent &&  ...
self.m3iComponent.Behavior.isvalid(  ) &&  ...
~self.m3iComponent.Behavior.Runnables.isEmpty(  );

maxShortNameLength = get_param( self.slModelName, 'AutosarMaxShortNameLength' );

if ~self.IsCompositionComponent


if isempty( self.InitRunnable )
if self.ComponentHasBehavior
excludeRunnableNames = m3i.mapcell( @( x )x.Name, m3iComp.Behavior.Runnables );
else 
excludeRunnableNames = {  };
end 
initRunnableName = arxml.arxml_private( 'p_create_aridentifier',  ...
matlab.lang.makeUniqueStrings( [ m3iComp.Name, '_Init' ], excludeRunnableNames ),  ...
maxShortNameLength );
initRunnable = Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(  ...
m3iComp.Behavior, m3iComp.Behavior.Runnables,  ...
initRunnableName, 'Simulink.metamodel.arplatform.behavior.Runnable' );
initRunnable.symbol = initRunnable.Name;
self.InitRunnable = initRunnableName;
end 
end 


xmlOpts = self.XmlOptsGetter.getXmlOpts( m3iComp, maxShortNameLength );


if autosar.dictionary.Utils.hasReferencedModels( self.m3iModel )
sharedM3IModel = autosar.dictionary.Utils.getUniqueReferencedModel( self.m3iModel );
assert( sharedM3IModel.RootPackage.size(  ) == 1 );
arRootShared = sharedM3IModel.RootPackage.front(  );
else 
assert( self.m3iModel.RootPackage.size(  ) == 1 );
arRootShared = self.m3iModel.RootPackage.front(  );
end 


XmlOptionsAdapter.set( self.m3iComponent, 'InternalBehaviorQualifiedName',  ...
xmlOpts.InternalBehaviorQualifiedName );

if ~self.UpdateMode
arRootShared.ArxmlFilePackaging =  ...
Simulink.metamodel.arplatform.common.ArxmlFilePackagingKind.Modular;


XmlOptionsAdapter.set( self.m3iComponent, 'InternalBehaviorQualifiedName',  ...
xmlOpts.InternalBehaviorQualifiedName );
XmlOptionsAdapter.set( self.m3iComponent, 'ImplementationQualifiedName',  ...
xmlOpts.ImplementationQualifiedName );


autosar.mm.util.XmlOptionsSetter.setCommonXmlOpts( arRootShared, xmlOpts );
end 

XmlOptionsAdapter.set( arRootShared, 'InternalDataConstraintExport',  ...
xmlOpts.InternalDataConstraintExport );
XmlOptionsAdapter.set( arRootShared, 'ImplementationTypeReference',  ...
xmlOpts.ImplementationTypeReference );


if self.IsCompositionComponent

self.slTypeBuilder.buildAllDataTypeMappings( self.m3iModel );
else 
self.slTypeBuilder.buildDataTypeMappingsReferencedByComp( m3iComp );
end 

layoutLayers = autosar.mm.mm2sl.layout.LayoutLayers( {  }, {  } );

if self.ComponentHasBehavior


[ self.OrderedM3IRunnables, layoutLayers ] = autosar.mm.mm2sl.ModelBuilder.getOrderedRunnables(  ...
m3iComp.Behavior.Runnables, self.m3iModel, self.InitRunnable );
end 



self.SLModelBuilder = autosar.mm.mm2sl.SLModelBuilder(  ...
self.slModelName, self.ChangeLogger,  ...
self.UpdateMode, self.AutoDelete, self.slTypeBuilder,  ...
self.slParameterBuilder, self.slConstBuilder,  ...
self.ModelPeriodicRunnablesAs, layoutLayers,  ...
self.SysConstsValueMap, self.ComponentHasBehavior,  ...
self.UseBusElementPorts );

self.SLLookupTableBuilder = autosar.mm.mm2sl.SLLookupTableBuilder( self.ChangeLogger,  ...
self.SLModelBuilder, self.slTypeBuilder, self.slModelName );

self.SLModelBuilder.addComponent( m3iComp );

self.slTypeBuilder.setModelWorkSpace( get_param( self.slModelName, 'ModelWorkspace' ) );

if ~self.ComponentHasBehavior



self.applySeq( 'mmVisit', m3iComp.Port );
end 
end 



function ret = mmWalkApplicationComponent( self, m3iComp )
ret = [  ];

self.mmWalkComponent( m3iComp );


assert( m3iComp.Behavior.isvalid(  ) );
self.apply( 'mmVisit', m3iComp.Behavior );
end 



function ret = mmWalkPort( self, m3iPort )
ret = [  ];
if ~isempty( m3iPort.Interface ) && m3iPort.Interface.isvalid(  )
self.apply( 'mmVisit', m3iPort.Interface, m3iPort );
end 
end 



function ret = mmWalkSenderReceiverInterface( self, m3iPortIf, m3iPort )
ret = [  ];
if nargin < 3
m3iPort = [  ];
end 

self.applySeq( 'mmVisit', m3iPortIf.ModeGroup, m3iPortIf, m3iPort, '' );

self.mmWalkDataInterface( m3iPortIf, m3iPort );
end 


function ret = mmWalkNvDataInterface( self, m3iPortIf, m3iPort )
ret = self.mmWalkDataInterface( m3iPortIf, m3iPort );
end 


function ret = mmWalkDataInterface( self, m3iPortIf, m3iPort )
ret = [  ];

if isa( m3iPort, 'Simulink.metamodel.arplatform.port.RequiredPort' )

self.applySeq( 'mmVisit', m3iPortIf.DataElements, m3iPort, 'read', [  ], '' );
end 

if isa( m3iPort, 'Simulink.metamodel.arplatform.port.ProvidedPort' )

self.applySeq( 'mmVisit', m3iPortIf.DataElements, m3iPort, 'write', [  ], '' );
end 
end 






function ret = mmWalkModeDeclarationGroupElement( self, m3iModeGroup,  ...
~, m3iPort, periodStr )
ret = [  ];
if nargin > 2 && m3iPort.isvalid(  )



if ~self.IsCompositionComponent
modeRef = autosar.mm.Model.findInstanceRef( m3iPort.containerM3I,  ...
'Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef',  ...
m3iModeGroup, 'groupElement', m3iPort, 'Port',  ...
Simulink.metamodel.arplatform.common.ModeDeclaration.empty(  ), 'Mode' );
end 

if self.IsCompositionComponent || isempty( modeRef ) || ~modeRef.isvalid(  )
modeRef = Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef( self.m3iModel );
modeRef.Port = m3iPort;
modeRef.groupElement = m3iModeGroup;
end 


if ~self.IsCompositionComponent
m3iPort.containerM3I.instanceMapping.instance.push_back( modeRef );
end 

self.slTypeBuilder.buildModeDeclarationGroup( m3iModeGroup.ModeGroup );

isCreated = false;
portPath = '';
if isa( m3iPort, 'Simulink.metamodel.arplatform.port.RequiredPort' )
[ portPath, isCreated ] = self.SLModelBuilder.addModeElement( m3iPort, m3iModeGroup, 'Inport' );
elseif isa( m3iPort, 'Simulink.metamodel.arplatform.port.ProvidedPort' )
[ portPath, isCreated ] = self.SLModelBuilder.addModeElement( m3iPort, m3iModeGroup, 'Outport' );
end 

if isempty( portPath )
return 
end 


if isCreated && ( nargin > 4 )
self.setRootPortSampleTime( portPath, periodStr );
end 


slPortH = get_param( portPath, 'Handle' );
self.slPort2RefBiMap.setLeft( slPortH, modeRef );
if ~self.slPort2AccessMap.isKey( slPortH )
self.slPort2AccessMap.set( slPortH, {  } );
end 

modeRef.slURL = Simulink.ID.getSID( portPath );

end 
end 



function ret = mmWalkModeSwitchInterface( self, m3iPortIf, m3iPort )
ret = [  ];
if nargin < 3
m3iPort = [  ];
end 
self.apply( 'mmVisit', m3iPortIf.ModeGroup, m3iPortIf, m3iPort );
end 



function ret = mmWalkClientServerInterface( self, m3iPortIf, m3iPort )
ret = [  ];
if nargin < 3
m3iPort = [  ];
end 


self.applySeq( 'mmVisit', m3iPortIf.Operations, m3iPort );
end 



function ret = mmWalkServiceInterface( self, m3iPortIf, m3iPort )
ret = [  ];
if nargin < 3
m3iPort = [  ];
end 

if isa( m3iPort, 'Simulink.metamodel.arplatform.port.RequiredPort' )

self.applySeq( 'mmVisit', m3iPortIf.Events, m3iPort, 'read', [  ], '' );

self.applySeq( 'mmVisit', m3iPortIf.Methods, m3iPort );
end 

if isa( m3iPort, 'Simulink.metamodel.arplatform.port.ProvidedPort' )

self.applySeq( 'mmVisit', m3iPortIf.Events, m3iPort, 'write', [  ], '' );

self.applySeq( 'mmVisit', m3iPortIf.Methods, m3iPort );
end 
end 



function ret = mmWalkOperation( self, m3iOperation, m3iPort, sys )
ret = [  ];

if self.IsCompositionComponent

return ;
end 

if nargin < 4
sys = self.slSystemName;
end 


m3iRef = autosar.mm.Model.getOrCreateInstanceRef(  ...
self.m3iComponent,  ...
'Simulink.metamodel.arplatform.instance.OperationPortInstanceRef',  ...
m3iPort,  ...
'Port',  ...
m3iOperation,  ...
'Operations' );%#ok<NASGU>

autosar.mm.mm2sl.ModelBuilder.validateOperationNameLength( m3iOperation );

if m3iPort.getMetaClass(  ) == Simulink.metamodel.arplatform.port.ClientPort.MetaClass(  ) ||  ...
m3iPort.getMetaClass(  ) == Simulink.metamodel.arplatform.port.ServiceRequiredPort.MetaClass(  )
self.SLModelBuilder.addPortOperation( sys, m3iPort, m3iOperation );
elseif self.ComponentHasBehavior

assert( m3iPort.getMetaClass(  ) == Simulink.metamodel.arplatform.port.ServerPort.MetaClass(  ),  ...
'Expected server port' );

self.applySeq( 'mmVisit', m3iOperation.Arguments, m3iPort );
elseif m3iPort.getMetaClass(  ) == Simulink.metamodel.arplatform.port.ServiceProvidedPort.MetaClass(  )
slFcnPath = self.SLModelBuilder.addServerFunction( sys, m3iPort, m3iOperation );
self.slCurrentSS = slFcnPath;
self.applySeq( 'mmVisit', m3iOperation.Arguments, m3iPort );

self.slCurrentSS = [  ];
else 

assert( m3iPort.getMetaClass(  ) == Simulink.metamodel.arplatform.port.ServerPort.MetaClass(  ),  ...
'Expected server port' );
end 
end 



function ret = mmWalkArgumentData( self, m3iArgument, ~ )
ret = [  ];

directionStr = m3iArgument.Direction.toString(  );


switch directionStr
case { 'In', 'InOut' }
self.SLModelBuilder.createOrUpdateSimulinkArgumentPort(  ...
self.slCurrentSS,  ...
m3iArgument.Type,  ...
'ArgIn', m3iArgument, [  ] );
case 'Error'
typeName = self.slTypeBuilder.buildStdReturnType(  );
self.SLModelBuilder.createOrUpdateSimulinkArgumentPort(  ...
self.slCurrentSS,  ...
typeName,  ...
'ArgOut', m3iArgument, [  ] );
case 'Out'

otherwise 
assert( false, 'Did not recognize argument direction %s', directionStr );
end 


switch directionStr
case { 'InOut', 'Out' }
self.SLModelBuilder.createOrUpdateSimulinkArgumentPort(  ...
self.slCurrentSS,  ...
m3iArgument.Type,  ...
'ArgOut', m3iArgument, [  ] );
case { 'In', 'Error' }

otherwise 
assert( false, 'Did not recognize argument direction %s', directionStr );
end 
end 





function slPortDefined = mmWalkFlowData( self, m3iData, m3iPort, accessKindStr, m3iRef, periodStr )

slPortDefined = false;
if nargin > 2 && m3iPort.isvalid(  )
if isempty( m3iRef ) || ~m3iRef.isvalid(  )

m3iRef = Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef( self.m3iModel );
m3iRef.Port = m3iPort;
m3iRef.DataElements = m3iData;
end 


if ~self.IsCompositionComponent
m3iPort.containerM3I.instanceMapping.instance.push_back( m3iRef );
end 

isWriteAccess = contains( accessKindStr, 'write', 'IgnoreCase', true );
if isWriteAccess
slPortType = 'Outport';
else 
slPortType = 'Inport';
end 

if isa( m3iData.Type, 'Simulink.metamodel.types.String' )
isClassicComponent = isa( self.m3iComponent, 'Simulink.metamodel.arplatform.component.AtomicComponent' );


if isClassicComponent && slfeature( 'AUTOSARStringsClassic' ) == 0 ||  ...
~isClassicComponent && slfeature( 'AUTOSARStringsAdaptive' ) == 0
DAStudio.error( 'autosarstandard:importer:StringNotSupportedInSimulink', m3iData.Type.Name );
end 
end 

[ portPath, isCreated ] = self.SLModelBuilder.addPortElement( m3iPort, m3iData, accessKindStr, slPortType );

if isempty( portPath )
return 
end 


if isCreated && ( nargin > 5 )
self.setRootPortSampleTime( portPath, periodStr );
end 


slPortH = get_param( portPath, 'Handle' );
self.slPort2RefBiMap.setLeft( slPortH, m3iRef );
if ~self.slPort2AccessMap.isKey( slPortH )
self.slPort2AccessMap.set( slPortH, {  } );
end 
m3iRef.slURL = Simulink.ID.getSID( portPath );
slPortDefined = true;
end 
end 



function ret = mmWalkApplicationComponentBehavior( self, m3iBehavior )
ret = [  ];

if self.m3iComponent.Behavior.isMultiInstantiable
autosar.mm.mm2sl.ModelBuilder.set_param( self.ChangeLogger, self.slModelName,  ...
'CodeInterfacePackaging', 'Reusable function',  ...
'InlineParams', 'on',  ...
'ERTFilePackagingFormat', 'Modular' );
else 
autosar.mm.mm2sl.ModelBuilder.set_param( self.ChangeLogger, self.slModelName,  ...
'CodeInterfacePackaging', 'Nonreusable function' );
end 

self.NVServiceNeedsPIMSet = autosar.mm.util.Set(  ...
'InitCapacity', 20,  ...
'KeyType', 'char',  ...
'HashFcn', @( x )x );
self.applySeq( 'mmVisit', m3iBehavior.ServiceDependency );

self.applySeq( 'mmVisit', m3iBehavior.IRV );

if ~isempty( self.OrderedM3IRunnables )
self.applySeq( 'mmVisit', self.OrderedM3IRunnables );
end 
self.applySeq( 'mmVisit', m3iBehavior.DataTypeMapping );

self.applySeq( 'mmVisit', m3iBehavior.ArTypedPIM );
self.applySeq( 'mmVisit', m3iBehavior.StaticMemory );
end 

function ret = walkVariableData( self, m3iData )
ret = [  ];
assert( m3iData.isvalid(  ), 'Expected valid m3iData' );

function context = getDSMContext( blkH, variableRole, m3iData )
context = struct(  );
context.blkH = blkH;

if ~isempty( m3iData.SwAddrMethod )
swAddrMethod = m3iData.SwAddrMethod.Name;
else 
swAddrMethod = '';
end 

context.codeProperties = struct(  );
context.codeProperties.VariableRole = variableRole;
context.codeProperties.Volatile = m3iData.Type.IsVolatile;
context.codeProperties.AdditionalNativeTypeQualifier = m3iData.Type.Qualifier;
context.codeProperties.SwAddrMethod = swAddrMethod;
context.codeProperties.SwCalibAccess = autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr( m3iData.SwCalibrationAccess );
context.codeProperties.DisplayFormat = m3iData.DisplayFormat;
if slfeature( 'AUTOSARLongNameAuthoring' )
context.codeProperties.LongName =  ...
autosar.ui.codemapping.PortCalibrationAttributeHandler.getLongNameValueFromMultiLanguageLongName( m3iData.longName );
end 

needsNVRAMAccess = self.NVServiceNeedsPIMSet.isKey( m3iData.Name );
context.codeProperties.NeedsNVRAMAccess = needsNVRAMAccess;
if needsNVRAMAccess

if self.UsedDataElementName2M3iServiceNeedMap.isKey( m3iData.Name )
m3iNvBlockNeeds = self.UsedDataElementName2M3iServiceNeedMap( m3iData.Name );
context.codeProperties.NvBlockNeeds = autosar.mm.util.NvBlockNeedsCodePropsHelper.createStructOfNvBlockNeeds( m3iNvBlockNeeds );
end 
end 
end 








variableRole = autosar.mm.util.getVariableRoleFromM3IData( m3iData );
hasNVServiceNeeds = self.NVServiceNeedsPIMSet.isKey( m3iData.Name );
if strcmp( variableRole, 'ArTypedPerInstanceMemory' )
if slfeature( 'ArSynthesizedDS' ) > 0

if self.SLModelBuilder.getSLMatcher(  ).isMappedToSynthDSM( m3iData )
self.SLModelBuilder.updateSynthDSM( m3iData, 'ArTypedPerInstanceMemory', hasNVServiceNeeds );
return ;
end 
end 

if hasNVServiceNeeds || self.SLModelBuilder.getSLMatcher(  ).isMappedToDSM( m3iData )
[ blockH, alreadyExists ] = self.SLModelBuilder.createOrUpdateDataStoreMemory( m3iData );
if alreadyExists
self.SLModelBuilder.mapDataStore( m3iData, 'ArTypedPerInstanceMemory', hasNVServiceNeeds );
end 
self.DsmBlockMap( m3iData.Name ) = getDSMContext( blockH, 'ArTypedPerInstanceMemory', m3iData );
return ;
end 

if self.SLModelBuilder.getSLMatcher(  ).isMappedToSignal( m3iData )
self.SLModelBuilder.updateSignal( m3iData, 'ArTypedPerInstanceMemory' );
return ;
end 

if self.SLModelBuilder.getSLMatcher(  ).isMappedToState( m3iData )
self.SLModelBuilder.updateState( m3iData, 'ArTypedPerInstanceMemory' );
return ;
end 
elseif strcmp( variableRole, 'StaticMemory' )
if slfeature( 'ArSynthesizedDS' ) > 0

if self.SLModelBuilder.getSLMatcher(  ).isMappedToSynthDSM( m3iData )
self.SLModelBuilder.updateSynthDSM( m3iData, 'StaticMemory', hasNVServiceNeeds );
return ;
end 
end 

[ isMappedToDSM, blockH ] = self.SLModelBuilder.getSLMatcher(  ).isMappedToDSM( m3iData );
if isMappedToDSM
self.SLModelBuilder.mapDataStore( m3iData, 'StaticMemory', hasNVServiceNeeds );
self.DsmBlockMap( m3iData.Name ) = getDSMContext( blockH, 'StaticMemory', m3iData );
return ;
end 

if self.SLModelBuilder.getSLMatcher(  ).isMappedToSignal( m3iData )
self.SLModelBuilder.updateSignal( m3iData, 'StaticMemory' );
return ;
end 

if self.SLModelBuilder.getSLMatcher(  ).isMappedToState( m3iData )
self.SLModelBuilder.updateState( m3iData, 'StaticMemory' );
return ;
end 
end 


end 



function ret = mmWalkIrvData( self, m3iData )
ret = [  ];

if ~self.ComponentHasBehavior || strcmp( self.slCurrentSS, self.slModelName )
return ;
end 

m3iBehav = m3iData.containerM3I;
if m3iBehav.isvalid(  ) && m3iData.isvalid(  )
m3iComp = m3iBehav.containerM3I;
if m3iComp.isvalid(  )
dataRef = autosar.mm.Model.findInstanceRef( m3iComp,  ...
'Simulink.metamodel.arplatform.instance.FlowDataCompInstanceRef',  ...
m3iData, 'DataElements' );

if isempty( dataRef ) || ~dataRef.isvalid(  )
dataRef = Simulink.metamodel.arplatform.instance.FlowDataCompInstanceRef( self.m3iModel );
dataRef.DataElements = m3iData;
m3iComp.instanceMapping.instance.push_back( dataRef );
else 
dataRef.slURL = '';
end 

end 

end 

end 




function ret = mmWalkModeSwitchEvent( self, m3iEvent )
ret = [  ];

m3iRun = m3iEvent.StartOnEvent;
if strcmp( m3iRun.Name, self.InitRunnable )
self.slTypeBuilder.buildModeDeclarationGroup(  ...
m3iEvent.instanceRef.at( 1 ).groupElement.ModeGroup );
end 
end 




function ret = mmWalkOperationInvokedEvent( self, m3iEvent )
ret = [  ];
self.apply( 'mmVisit', m3iEvent.instanceRef );
end 



function ret = mmWalkRunnable( self, m3iRun )
ret = [  ];


if ~self.ComponentHasBehavior
return ;
end 


if isempty( m3iRun.symbol )
m3iRun.symbol = m3iRun.Name;
end 

m3iRunRef = autosar.mm.Model.findInstanceRef( m3iRun.containerM3I.containerM3I,  ...
'Simulink.metamodel.arplatform.instance.RunnableInstanceRef',  ...
m3iRun, 'Runnables' );

if isempty( m3iRunRef ) || ~m3iRunRef.isvalid(  )
m3iRunRef = Simulink.metamodel.arplatform.instance.RunnableInstanceRef( self.m3iModel );
m3iRunRef.Runnables = m3iRun;
m3iRun.containerM3I.containerM3I.instanceMapping.instance.push_back( m3iRunRef );
else 

end 



if strcmp( m3iRun.Name, self.InitRunnable )
irtRunnableType = autosar.mm.mm2sl.IRTRunnableType.Initialization;
elseif ismember( m3iRun.Name, self.ResetRunnables )
irtRunnableType = autosar.mm.mm2sl.IRTRunnableType.Reset;
elseif strcmp( m3iRun.Name, self.TerminateRunnable )
irtRunnableType = autosar.mm.mm2sl.IRTRunnableType.Terminate;
else 
irtRunnableType = autosar.mm.mm2sl.IRTRunnableType.NotAnIRTRunnable;
end 










if self.UpdateMode
switch irtRunnableType
case autosar.mm.mm2sl.IRTRunnableType.Initialization
initFcnBlocks = autosar.utils.InitResetTermFcnBlock.findInitFunctionBlocks( self.slSystemName );
if ~( ( length( initFcnBlocks ) == 1 ) && strcmp( get_param( initFcnBlocks{ 1 }, 'Parent' ), self.slSystemName ) )
return ;
end 
case autosar.mm.mm2sl.IRTRunnableType.Terminate
termFcnBlocks = autosar.utils.InitResetTermFcnBlock.findTermFunctionBlocks( self.slSystemName );
if ~( ( length( termFcnBlocks ) == 1 ) && strcmp( get_param( termFcnBlocks{ 1 }, 'Parent' ), self.slSystemName ) )
return ;
end 
otherwise 

end 
end 


[ runnablePath, finalizeObj, isCreated ] = self.SLModelBuilder.addFunction(  ...
self.slSystemName, m3iRun, m3iRunRef, irtRunnableType );%#ok<ASGLU>
self.slCurrentSS = runnablePath;

self.addSampleTime( m3iRun );

periodStr = '';
if strcmp( self.ModelPeriodicRunnablesAs, 'AtomicSubsystem' )
[ isPeriodic, m3iEvent ] = autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent( m3iRun,  ...
Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass );
if isPeriodic
periodStr = Simulink.metamodel.arplatform.getRealStringCompact( m3iEvent.Period );
end 
end 


isIRTRunnable = ( irtRunnableType ~= autosar.mm.mm2sl.IRTRunnableType.NotAnIRTRunnable );
if isIRTRunnable



m3iRunnables = self.m3iComponent.Behavior.Runnables;
rootModel = self.m3iComponent.rootModel;
dataAccess = autosar.mm.mm2sl.ModelBuilder.getInitRunnableDataAccess(  ...
m3iRun, m3iRunnables, rootModel, 'FlowDataAccess',  ...
self.ModelPeriodicRunnablesAs );

modeAccessPoint = autosar.mm.mm2sl.ModelBuilder.getInitRunnableDataAccess(  ...
m3iRun, m3iRunnables, rootModel, 'ModeAccess',  ...
self.ModelPeriodicRunnablesAs );

modeSwitchPoint = autosar.mm.mm2sl.ModelBuilder.getInitRunnableDataAccess(  ...
m3iRun, m3iRunnables, rootModel, 'ModeSwitch',  ...
self.ModelPeriodicRunnablesAs );
else 
dataAccess = m3iRun.dataAccess;
modeAccessPoint = m3iRun.ModeAccessPoint;
modeSwitchPoint = m3iRun.ModeSwitchPoint;
end 
self.applySeq( 'mmVisit', dataAccess, periodStr );


if ~isIRTRunnable
self.applySeq( 'mmVisit', m3iRun.irvRead, 0, periodStr );
self.applySeq( 'mmVisit', m3iRun.irvWrite, 1, periodStr );
end 
self.applySeq( 'mmVisit', m3iRun.compParamRead, periodStr );
self.applySeq( 'mmVisit', m3iRun.portParamRead, periodStr );
self.applySeq( 'mmVisit', m3iRun.operationBlockingCall );
self.applySeq( 'mmVisit', m3iRun.OperationNonBlockingCall );
self.applySeq( 'mmVisit', modeAccessPoint, periodStr );
self.applySeq( 'mmVisit', modeSwitchPoint, periodStr );
self.applySeq( 'mmVisit', m3iRun.InternalTriggeringPoint );
self.applySeq( 'mmVisit', m3iRun.Events );

if ~isempty( runnablePath ) && isCreated
self.SLModelBuilder.positionBlockInLayout( runnablePath );
end 


self.slCurrentSS = [  ];
end 



function ret = mmWalkOperationBlockingAccess( self, m3iAccess, varargin )
ret = [  ];
iRef = m3iAccess.instanceRef;
if ~isempty( iRef ) && iRef.isvalid(  )
self.applySeq( 'mmVisit', iRef, varargin{ : } );
end 
end 



function ret = mmWalkOperationNonBlockingAccess( self, m3iAccess, varargin )
ret = [  ];
iRef = m3iAccess.instanceRef;
if ~isempty( iRef ) && iRef.isvalid(  )
if autosar.validation.ClientServerValidator.isNvMService( iRef.at( 1 ).Operations )
self.applySeq( 'mmVisit', iRef, varargin{ : } );
end 
end 
end 

function ret = mmWalkInternalTriggeringPoint( self, m3iTrigPoint )
ret = [  ];


m3iIntTrigEvents = m3i.filter( @( x ) ...
isequal( x.MetaClass, Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass ),  ...
self.m3iComponent.Behavior.Events );


numInternalTrigBlocks = 0;
for k = 1:length( m3iIntTrigEvents )
m3iIntTrigEvent = m3iIntTrigEvents{ k };
if ( m3iTrigPoint == m3iIntTrigEvent.InternalTriggeringPoint )
numInternalTrigBlocks = numInternalTrigBlocks + 1;




if numInternalTrigBlocks > 1
DAStudio.error(  ...
'autosarstandard:importer:MultipleTriggeredRunnablesForSameTriggerPoint',  ...
autosar.api.Utils.getQualifiedName( m3iTrigPoint ),  ...
lastIntTrigEventQName,  ...
autosar.api.Utils.getQualifiedName( m3iIntTrigEvent ) );
end 


m3iTriggeredRun = m3iIntTrigEvent.StartOnEvent;




for i = 1:m3iTriggeredRun.Events.size(  )
m3iEvent = m3iTriggeredRun.Events.at( i );
if ~isequal( m3iEvent.MetaClass,  ...
Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass )
MSLDiagnostic( 'autosarstandard:importer:TriggeredRunnableHasUnsupportedEvents',  ...
autosar.api.Utils.getQualifiedName( m3iEvent ),  ...
autosar.api.Utils.getQualifiedName( m3iTriggeredRun ) ).reportAsWarning;
m3iEvent.destroy(  );
end 
end 

triggeringRunPath = self.slCurrentSS;
m3iTriggeringRun = m3iTrigPoint.containerM3I;
assert( ~isempty( triggeringRunPath ), 'runnable path should not be empty' );
self.SLModelBuilder.addInternalTriggerPoint( m3iTrigPoint,  ...
m3iTriggeredRun, m3iTriggeringRun, triggeringRunPath );
lastIntTrigEventQName = autosar.api.Utils.getQualifiedName( m3iIntTrigEvent );
end 
end 
end 




function ret = mmWalkComponentParameterAccess( self, m3iAccess, varargin )
ret = [  ];

if ~m3iAccess.instanceRef.DataElements.isvalid(  )
return 
end 

currentSys = self.slCurrentSS;
periodStr = '';
if isempty( currentSys )


currentSys = self.slModelName;
periodStr = varargin{ 1 };
end 

slParamName = self.getOrCreateSlParamName( m3iAccess.instanceRef.DataElements.Name );
if ~self.UpdateMode || isempty( Simulink.findVars( currentSys, 'SearchMethod', 'cached', 'Name', slParamName ) )



m3iType = m3iAccess.instanceRef.DataElements.Type;

m3iBaseType = autosar.mm.mm2sl.TypeBuilder.getUnderlyingType( m3iType );
if isa( m3iBaseType, 'Simulink.metamodel.types.Structure' )

self.slTypeBuilder.errorOutForAnonStructType = false;
slTypeInfo = self.slTypeBuilder.buildType( m3iType );
self.slTypeBuilder.errorOutForAnonStructType = true;

if slTypeInfo.hasAnonStructName

return 
else 
typeStr = self.slTypeBuilder.getSLBlockDataTypeStr( m3iType );
end 

else 
typeStr = [  ];
end 
if isa( m3iType, 'Simulink.metamodel.types.SharedAxisType' )
if m3iAccess.instanceRef.isvalid(  ) && strcmp( m3iAccess.instanceRef.DataElements.category, 'VAL_BLK' )
isLUT = false;
else 
isLUT = true;
end 
elseif isa( m3iType, 'Simulink.metamodel.types.LookupTableType' )
isLUT = true;
else 
isLUT = false;
end 
if isLUT && m3iAccess.instanceRef.isvalid(  )
self.SlParam2RefMap( slParamName ) = m3iAccess.instanceRef;
self.SLLookupTableBuilder.deferLookupTableBlockAddition( slParamName, m3iAccess, currentSys, typeStr );
else 
[ paramExists, paramObj ] = autosar.utils.Workspace.objectExistsInModelScope( self.slModelName, slParamName );
if paramExists && ~isa( paramObj, 'Simulink.Parameter' )


DAStudio.error( 'autosarstandard:importer:InvalidConstantBlkValue', slParamName );
end 

constantBlkPath = self.SLModelBuilder.createOrUpdateSimulinkBlock( currentSys,  ...
'Constant', m3iAccess.Name, typeStr, [  ], { 'Value', slParamName } );
if ~isempty( periodStr )
autosar.mm.mm2sl.ModelBuilder.set_param(  ...
self.ChangeLogger, constantBlkPath, 'SampleTime', periodStr )
end 
end 
elseif self.UpdateMode && m3iAccess.instanceRef.isvalid(  ) &&  ...
autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxisLUT( m3iAccess.instanceRef.DataElements.Type )
self.SlParam2RefMap( slParamName ) = m3iAccess.instanceRef;
self.SLLookupTableBuilder.lookupTableBlockUpdate( slParamName, m3iAccess, currentSys );
end 
end 




function ret = mmWalkPortParameterAccess( self, m3iAccess, varargin )
ret = [  ];

currentSys = self.slCurrentSS;
periodStr = '';
if isempty( currentSys )


currentSys = self.slModelName;
periodStr = varargin{ 1 };
end 
slParamName = self.getOrCreateSlParamName( [ m3iAccess.instanceRef.Port.Name, '_', m3iAccess.instanceRef.DataElements.Name ] );
if ~self.UpdateMode || isempty( Simulink.findVars( currentSys, 'SearchMethod', 'cached', 'Name', slParamName ) )



m3iType = m3iAccess.instanceRef.DataElements.Type;

m3iBaseType = autosar.mm.mm2sl.TypeBuilder.getUnderlyingType( m3iType );
if isa( m3iBaseType, 'Simulink.metamodel.types.Structure' )

self.slTypeBuilder.errorOutForAnonStructType = false;
slTypeInfo = self.slTypeBuilder.buildType( m3iType );
self.slTypeBuilder.errorOutForAnonStructType = true;

if slTypeInfo.hasAnonStructName

return 
else 
typeStr = self.slTypeBuilder.getSLBlockDataTypeStr( m3iType );
end 
else 
typeStr = [  ];
end 
if isa( m3iType, 'Simulink.metamodel.types.SharedAxisType' )
if m3iAccess.instanceRef.isvalid(  ) && strcmp( m3iAccess.instanceRef.DataElements.category, 'VAL_BLK' )
isLUT = false;
else 
isLUT = true;
end 
elseif isa( m3iType, 'Simulink.metamodel.types.LookupTableType' )
isLUT = true;
else 
isLUT = false;
end 
if isLUT
m3iInitValue = autosar.mm.mm2sl.utils.getM3iInitValueFromPort( m3iAccess.instanceRef.Port,  ...
m3iAccess.instanceRef.DataElements );
if slfeature( 'AUTOSARPPortInitValue' ) && isempty( m3iInitValue ) &&  ...
isa( m3iAccess.instanceRef.Port, 'Simulink.metamodel.arplatform.port.ParameterReceiverPort' )
m3iPPort = self.M3IConnectedPortFinder.findParameterPPort( m3iAccess.instanceRef.Port );
if ~isempty( m3iPPort )
m3iInitValue = autosar.mm.mm2sl.utils.getM3iInitValueFromPort( m3iPPort,  ...
m3iAccess.instanceRef.DataElements );
end 
end 



if isempty( m3iInitValue ) && ( isa( m3iType, 'Simulink.metamodel.types.LookupTableType' ) ||  ...
isa( m3iType, 'Simulink.metamodel.types.SharedAxisType' ) )
MSLDiagnostic( 'autosarstandard:importer:MissingPortComSpecForLookupTable',  ...
m3iAccess.instanceRef.DataElements.Name, m3iAccess.instanceRef.Port.Name ).reportAsWarning;
return ;
end 
if isempty( m3iInitValue ) || ~m3iAccess.instanceRef.isvalid(  )
return ;
else 
self.SlParam2RefMap( slParamName ) = m3iAccess.instanceRef;
self.SLLookupTableBuilder.deferLookupTableBlockAddition( slParamName, m3iAccess, currentSys, typeStr );
end 
else 
constantBlkPath = self.SLModelBuilder.createOrUpdateSimulinkBlock( currentSys,  ...
'Constant', m3iAccess.Name, typeStr, [  ], { 'Value', slParamName } );
end 
if ~isempty( periodStr )
autosar.mm.mm2sl.ModelBuilder.set_param(  ...
self.ChangeLogger, constantBlkPath, 'SampleTime', periodStr )
end 
elseif self.UpdateMode && m3iAccess.instanceRef.isvalid(  ) &&  ...
autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxisLUT( m3iAccess.instanceRef.DataElements.Type )
self.SlParam2RefMap( slParamName ) = m3iAccess.instanceRef;
self.SLLookupTableBuilder.lookupTableBlockUpdate( slParamName, m3iAccess, currentSys );
end 

end 





function ret = mmWalkModeAccess( self, m3iAccess, varargin )
ret = [  ];
iRef = m3iAccess.InstanceRef;
if ~isempty( iRef ) && iRef.isvalid(  )
self.apply( 'mmVisit', m3iAccess.InstanceRef, varargin{ : } );

slBlock = self.slPort2RefBiMap.getRight( iRef );
if ~isempty( slBlock )
actAccesses = self.slPort2AccessMap.get( slBlock );
if ~iscell( actAccesses ) && isempty( actAccesses )
actAccesses = {  };
end 
actAccesses{ end  + 1 } = m3iAccess;
self.slPort2AccessMap.set( slBlock, actAccesses );
end 
end 
end 




function ret = mmWalkFlowDataAccess( self, m3iAccess, periodStr )
ret = [  ];
accessKindStr = m3iAccess.Kind.toString(  );
self.mmWalkDataAccess( m3iAccess, accessKindStr, periodStr );
end 



function ret = mmWalkDataAccess( self, m3iAccess, varargin )
ret = [  ];
iRef = m3iAccess.instanceRef;
if ~isempty( iRef ) && iRef.isvalid(  ) && iRef.DataElements.isvalid(  )

self.apply( 'mmVisit', iRef, varargin{ : } );


slBlock = self.slPort2RefBiMap.getRight( iRef );
if ~isempty( slBlock )
actAccesses = self.slPort2AccessMap.get( slBlock );
if ~iscell( actAccesses ) && isempty( actAccesses )
actAccesses = {  };
end 
actAccesses{ end  + 1 } = m3iAccess;
self.slPort2AccessMap.set( slBlock, actAccesses );
end 
end 
end 



function ret = mmWalkFlowDataPortInstanceRef( self, m3iRef, accessKindStr, periodStr )
ret = [  ];


slPortDefined = self.apply( 'mmVisit', m3iRef.DataElements, m3iRef.Port, accessKindStr, m3iRef, periodStr );

if ~slPortDefined

return 
end 

if strcmp( self.slCurrentSS, self.slModelName )

return 
end 




if ~isempty( self.slCurrentSS )
slBlock = self.slPort2RefBiMap.getRight( m3iRef );
if ~isempty( slBlock )
blockType = get_param( slBlock, 'BlockType' );
if strcmpi( blockType, 'Inport' )


connectedPort = self.SLModelBuilder.connectRootInportBlockToSSInportBlock(  ...
slBlock, get_param( self.slCurrentSS, 'Handle' ) );


self.SLModelBuilder.connectRootIsUpdatedInportBlockToSSInportBlock(  ...
slBlock, get_param( self.slCurrentSS, 'Handle' ) );


self.SLModelBuilder.connectRootErrorStatusInportBlockToSSInportBlock(  ...
slBlock, get_param( self.slCurrentSS, 'Handle' ) );
else 







enableEnsureOutputIsVirtual = true;
connectedPort = self.SLModelBuilder.connectSSOutportBlockToRootOutportBlock(  ...
slBlock, get_param( self.slCurrentSS, 'Handle' ), enableEnsureOutputIsVirtual );


self.SLModelBuilder.connectSignalInvalidationBlockToSSOutportBlock(  ...
connectedPort, getfullname( slBlock ), self.slCurrentSS, m3iRef, self.UpdateMode );
end 
portInfo = autosar.mm.Model.findPortInfo( m3iRef.Port, m3iRef.DataElements, 'DataElements' );
if slfeature( 'MessageModelRefSupport' ) > 0 &&  ...
autosar.mm.mm2sl.SLModelBuilder.isQueuedPort( portInfo ) &&  ...
~self.UpdateMode
m3iType = m3iRef.DataElements.Type;
typename = self.slTypeBuilder.getSLBlockDataTypeStr( m3iType );
slDesignData = self.slTypeBuilder.getSLDesignData( m3iType );
dimensionsStr = num2str( slDesignData.Dimensions );
self.SLModelBuilder.addQueuedPortStateflowBlock(  ...
connectedPort, blockType, portInfo, typename,  ...
dimensionsStr )
end 
else 
assert( false, 'Should have a valid Simulink block.' );
end 
end 

end 



function ret = mmWalkOperationPortInstanceRef( self, m3iRef, varargin )
ret = [  ];


self.mmWalkOperation( m3iRef.Operations, m3iRef.Port, self.slCurrentSS );
end 





function ret = mmModeDeclarationInstanceRef( self, m3iRef, varargin )
ret = [  ];


self.mmWalkModeDeclarationGroupElement( m3iRef.groupElement, [  ], m3iRef.Port, varargin{ : } );

if strcmp( self.slCurrentSS, self.slModelName )

return 
end 



if ~isempty( self.slCurrentSS )
slBlock = self.slPort2RefBiMap.getRight( m3iRef );
if ~isempty( slBlock )
if strcmpi( get_param( slBlock, 'BlockType' ), 'Inport' )


self.SLModelBuilder.connectRootInportBlockToSSInportBlock(  ...
slBlock, get_param( self.slCurrentSS, 'Handle' ) );
else 


self.SLModelBuilder.connectSSOutportBlockToRootOutportBlock(  ...
slBlock, get_param( self.slCurrentSS, 'Handle' ), true );
end 
else 
assert( false, 'Should have a valid Simulink block.' );
end 
end 

end 





function ret = mmWalkIrvAccess( self, m3iAccess, isWriteAccess, ~ )
ret = [  ];

m3iRef = m3iAccess.instanceRef;
if isempty( m3iRef ) || ~m3iRef.isvalid(  ) || ~m3iRef.DataElements.isvalid(  )
return ;
end 

if self.UpdateMode



















irvName = m3iRef.DataElements.Name;


vssIsInTopLevelSys = false;
if strcmp( self.ModelPeriodicRunnablesAs, 'FunctionCallSubsystem' )
runnableIsInsideSubsystem = ~strcmp( self.slSystemName, get_param( self.slCurrentSS, 'Parent' ) );
if runnableIsInsideSubsystem

ssContainingRunnable = get_param( self.slCurrentSS, 'Parent' );
if strcmp( get_param( ssContainingRunnable, 'IsSubsystemVirtual' ), 'on' )
vssIsInTopLevelSys = strcmp( self.slSystemName, get_param( ssContainingRunnable, 'Parent' ) );
end 
end 
end 
needManualIRVAddition = strcmp( self.ModelPeriodicRunnablesAs, 'AtomicSubsystem' ) ||  ...
( ~vssIsInTopLevelSys && runnableIsInsideSubsystem ) || self.ManualIRVAdditionsMap.isKey( irvName );

if needManualIRVAddition
[ isIRVMapped, ~ ] = self.SLModelBuilder.isIRVMapped( m3iRef.DataElements );
if ~isIRVMapped
if self.ManualIRVAdditionsMap.isKey( irvName )
data = self.ManualIRVAdditionsMap( irvName );
else 
data = struct( 'src', [  ], 'dst', [  ] );
end 
if isWriteAccess
data.src = self.slCurrentSS;
else 
data.dst = self.slCurrentSS;
end 
self.ManualIRVAdditionsMap( irvName ) = data;
end 
return ;
end 
end 


assert( ~isempty( self.slCurrentSS ), 'slCurrentSS should not be empty when adding IRVs' );
ssH = get_param( self.slCurrentSS, 'Handle' );


data = self.slIrvRef2RunnableMap( m3iRef );
if isempty( data )
data = struct( 'src', [  ], 'dst', [  ], 'm3iAccess', [  ] );
end 


if ~isWriteAccess

data.m3iAccess = [ data.m3iAccess, m3iAccess ];
data.dst = unique( [ data.dst;ssH ] );
self.createDestinationIrvPort( m3iRef, ssH );
else 

data.m3iAccess = [ data.m3iAccess, m3iAccess ];
data.src = unique( [ data.src;ssH ] );
self.createSourceIrvPort( m3iRef, ssH );
end 


self.slIrvRef2RunnableMap( m3iRef ) = data;
end 



function ret = mmWalkServiceDependency( self, m3iServiceDependency )
ret = [  ];


if ~isempty( m3iServiceDependency.UsedDataElement )
if ~isempty( m3iServiceDependency.ServiceNeeds )
self.NVServiceNeedsPIMSet.set( m3iServiceDependency.UsedDataElement.Name );
self.UsedDataElementName2M3iServiceNeedMap( m3iServiceDependency.UsedDataElement.Name ) = m3iServiceDependency.ServiceNeeds;
end 
end 
end 

function createDestinationIrvPort( self, m3iIrvRef, destSSH )
self.SLModelBuilder.getOrCreateIrvPorts( m3iIrvRef.DataElements, [  ], destSSH );
end 

function createSourceIrvPort( self, m3iIrvRef, srcSSH )
self.SLModelBuilder.getOrCreateIrvPorts( m3iIrvRef.DataElements, srcSSH, [  ] );
end 

function connectIrvPorts( self, m3iIrvRef, srcSSH, dstSSH )
if strcmp( self.ModelPeriodicRunnablesAs, 'FunctionCallSubsystem' )
if isempty( srcSSH ) || isempty( dstSSH )

return ;
end 

if strcmp( get_param( srcSSH, 'Parent' ), get_param( dstSSH, 'Parent' ) )

self.SLModelBuilder.connectIrv( m3iIrvRef.DataElements, srcSSH, dstSSH );
else 


irvAlreadyConnected = self.isIrvAlreadyConnected( m3iIrvRef, srcSSH, dstSSH );
if ~irvAlreadyConnected



self.slIrvRef2RunnableMap.remove( m3iIrvRef );
end 

[ isIRVMapped, ~ ] = self.SLModelBuilder.isIRVMapped( m3iIrvRef.DataElements );
if ~isIRVMapped

manualAdditionData = struct( 'src', [  ], 'dst', [  ] );
manualAdditionData.src = get_param( srcSSH, 'Parent' );
manualAdditionData.dst = get_param( dstSSH, 'Parent' );
self.ManualIRVAdditionsMap( m3iIrvRef.DataElements.Name ) = manualAdditionData;
end 
end 
else 

self.SLModelBuilder.connectIrv( m3iIrvRef.DataElements, srcSSH, dstSSH );
end 
end 

function irvAlreadyConnected = isIrvAlreadyConnected( self, m3iIrvData, srcSS, dstSS )
irvAlreadyConnected = false;
[ ~, dstPort, ~ ] = self.SLModelBuilder.getOrCreateIrvPorts( m3iIrvData.DataElements, srcSS, dstSS );
dstLine = get_param( dstPort, 'Line' );
if dstLine > 0
irvAlreadyConnected = true;
end 
end 


systemName = createComponent( self, m3iComp,  ...
createSimulinkObject, nameConflictAction,  ...
createTypes, createCalPrms,  ...
createInternalBehavior, initializationRunnable, resetRunnables,  ...
terminateRunnable, dataDictionary,  ...
updateMode, autoDelete, modelName, openModel, schemaVersion,  ...
forceLegacyWorkspaceBehavior, predefinedVariant );
end 

methods ( Access = private )

function addSampleTime( self, m3iRun )
[ isPeriodic, m3iEvent ] = autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent( m3iRun,  ...
Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass );
if isPeriodic
self.SampleTimes = [ self.SampleTimes, m3iEvent.Period ];
end 
end 

function setRootPortSampleTime( self, portPath, periodStr )








if self.UpdateMode && isempty( self.slCurrentSS ) &&  ...
strcmp( self.ModelPeriodicRunnablesAs, 'AtomicSubsystem' ) &&  ...
~isempty( periodStr ) && strcmp( self.slSystemName, get_param( portPath, 'Parent' ) )



isOutport = strcmp( get_param( portPath, 'BlockType' ), 'Outport' );
if isOutport || ( self.NumPeriodicRunnables > 1 )
autosar.mm.mm2sl.SLModelBuilder.set_param( self.ChangeLogger, portPath,  ...
'SampleTime', periodStr );
end 
end 
end 

function slParamName = getOrCreateSlParamName( self, arParam )
slMatcher = self.SLModelBuilder.getSLMatcher(  );
if ~isempty( slMatcher )
slParamName = slMatcher.getSlParamName( arParam );
else 
slParamName = arParam;
end 

exists = isvarname( slParamName ) && autosar.utils.Workspace.objectExistsInModelScope( self.slModelName, slParamName );

if ~exists
slParamName = arxml.arxml_private( 'p_create_aridentifier',  ...
arParam,  ...
namelengthmax );
end 
end 
end 


methods ( Static )

slModelName = getOrCreateSimulinkModel( m3iComponent, nameConflictAction, modelName, template );
m3iComp = getM3IComp( m3iModel, componentName );



function mdlFileName = checkModelFileName( mdlFileName, nameConflictAction )


loadedMdl = find_system( 'type', 'block_diagram' );
bdExist = any( strcmp( mdlFileName, loadedMdl ) );


mdlFileExist = exist( fullfile( pwd, mdlFileName ), 'file' ) == 4;


messageStream = autosar.mm.util.MessageStreamHandler.instance(  );

switch lower( nameConflictAction )
case 'overwrite'
if bdExist == true
messageStream.createError( 'RTW:autosar:importerCannotOverwriteBD',  ...
mdlFileName );
end 

case 'makenameunique'

mdlFileName = autosar.api.Utils.getUniqueModelName( mdlFileName );

case 'error'
if ( mdlFileExist == true ) || ( bdExist == true )
if ( bdExist == true )
messageStream.createError( 'RTW:autosar:importerCannotOverwriteBD',  ...
mdlFileName );
else 
messageStream.createError( 'RTW:autosar:importerCannotOverwriteMDL',  ...
mdlFileName );
end 
end 

otherwise 
assert( false, 'Unexpected name conflict action' );
end 

end 
end 

methods ( Static, Access = private )


function set_param( changeLogger, blk, varargin )
autosar.mm.mm2sl.SLModelBuilder.set_param( changeLogger, blk, varargin{ : } );
end 





function enumFileName = checkEnumFileName( nameConflictAction, enumFileName )


messageStream = autosar.mm.util.MessageStreamHandler.instance(  );


enumFileExist = exist( fullfile( pwd, [ enumFileName, '.m' ] ), 'file' ) ~= 0;


switch lower( nameConflictAction )
case 'overwrite'

case 'makenameunique'
if ( enumFileExist == true )
enumFileName = arxml.arxml_private( 'p_create_aridentifier', enumFileName, 32, 1 );
end 
case 'error'
if ( enumFileExist == true )
messageStream.createError( 'RTW:autosar:importerCannotOverwriteMFile',  ...
enumFileName );
end 
otherwise 
assert( false, 'Should not be here' );
end 
end 

function createDefaultBehavior( m3iComp )

assert( isempty( m3iComp.Behavior ), 'Expected behavior to be undefined.' );

m3iComp.Behavior =  ...
Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior( m3iComp.modelM3I );
m3iComp.Behavior.Name = 'behavior';


autosar.mm.arxml.Exporter.findByBaseType(  ...
m3iComp.Behavior.DataTypeMapping, m3iComp.rootModel,  ...
'Simulink.metamodel.arplatform.common.DataTypeMappingSet' );
end 




function [ m3iRunnablesOut, layoutLayers ] = getOrderedRunnables( m3iRunnablesIn, rootModel, initRunnableName )

[ m3iSrcRun, m3iDstRun, m3iLeafNonServerRun, m3iLeafServerRun ] =  ...
autosar.mm.mm2sl.ModelBuilder.findConnectedAndLeafRunnables( m3iRunnablesIn );



srcBlkNames = {  };
dstBlkNames = {  };
leafBlkNames = {  };
if ~isempty( m3iSrcRun )
srcBlkNames = { m3iSrcRun.Name };
dstBlkNames = { m3iDstRun.Name };
end 
if ~isempty( m3iLeafNonServerRun )
leafBlkNames = { m3iLeafNonServerRun.Name };
end 

layers = autosar.mm.mm2sl.layout.LayoutGraphUtils.getLayoutLayers(  ...
srcBlkNames, dstBlkNames, leafBlkNames );


if ~strcmp( layers{ 1 }{ 1 }, initRunnableName )
foundInitRunnable = false;
for layerIdx = 1:length( layers )
layer = layers{ layerIdx };
idx = strcmp( layer, initRunnableName );
if any( idx )

layer( idx ) = [  ];
layers{ layerIdx } = layer;
foundInitRunnable = true;
break ;
end 
end 

if ( foundInitRunnable )
layers{ 1 } = [ initRunnableName, layers{ 1 } ];
end 
end 


m3iAllRuns = [ m3iSrcRun, m3iDstRun, m3iLeafNonServerRun, m3iLeafServerRun ];
m3iAllRunsLen = length( m3iAllRuns );
[ ~, uniqIdx ] = unique( { m3iAllRuns.Name } );
m3iAllRuns = m3iAllRuns( uniqIdx );




m3iRunnablesOut = Simulink.metamodel.arplatform.behavior.SequenceOfRunnable.make( rootModel );
for layerIdx = 1:length( layers )
layer = layers{ layerIdx };
for elmIdx = 1:length( layer )
m3iRun = m3iAllRuns( arrayfun( @( x )strcmp( x.Name, layer{ elmIdx } ), m3iAllRuns ) );
if ~isempty( m3iRun )
m3iRunnablesOut.append( m3iRun );
end 
end 
end 

serverUniqIdx = uniqIdx - m3iAllRunsLen + length( m3iLeafServerRun );
serverUniqIdx = serverUniqIdx( arrayfun( @( x )( x > 0 ) .* x, serverUniqIdx ) ~= 0 );
m3iLeafServerRun = m3iLeafServerRun( serverUniqIdx );

if ~isempty( m3iLeafServerRun )
arrayfun( @( x )m3iRunnablesOut.append( x ), m3iLeafServerRun )
end 

servRunSS = autosar.mm.mm2sl.ModelBuilder.getServRunSSBlocks( m3iLeafServerRun );
layoutLayers = autosar.mm.mm2sl.layout.LayoutLayers( layers, servRunSS );
end 


function servRunSS = getServRunSSBlocks( m3iServerRunnables )
servRunSS = {  };
for i = 1:length( m3iServerRunnables )
m3iRun = m3iServerRunnables( i );
subsystemName = m3iRun.Events.at( 1 ).instanceRef.Port.Name;
servRunSS = [ servRunSS, subsystemName ];%#ok<AGROW>
end 
[ ~, unqIdx ] = unique( servRunSS );
servRunSS = servRunSS( unqIdx );
end 

function [ m3iSrcRun, m3iDstRun, m3iLeafNonServerRun, m3iLeafServerRun ] = findConnectedAndLeafRunnables( m3iRunnablesIn )
m3iRunnablesSize = m3iRunnablesIn.size(  );

m3iLeafNonServerRun = [  ];
m3iSrcRun = [  ];
m3iDstRun = [  ];
m3iLeafServerRun = [  ];
irvSourceMapping = containers.Map;

for m3iRunIdx = 1:m3iRunnablesSize
m3iRun = m3iRunnablesIn.at( m3iRunIdx );
irvWriteSize = m3iRun.irvWrite.size(  );
if ~( irvWriteSize == 0 )
for irvIdx = 1:irvWriteSize
irvInstanceRef = m3iRun.irvWrite.at( irvIdx ).instanceRef;
if irvInstanceRef.isvalid && ~isempty( irvInstanceRef.DataElements )
irvName = irvInstanceRef.DataElements.Name;
irvSourceMapping( irvName ) = m3iRun;
end 
end 
end 
end 

for m3iRunIdx = 1:m3iRunnablesSize
m3iRun = m3iRunnablesIn.at( m3iRunIdx );
irvReadSize = m3iRun.irvRead.size(  );
if ~( irvReadSize == 0 )
hasNoConnections = true;
for irvIdx = 1:irvReadSize
irvInstanceRef = m3iRun.irvRead.at( irvIdx ).instanceRef;
if irvInstanceRef.isvalid && ~isempty( irvInstanceRef.DataElements )
irvName = irvInstanceRef.DataElements.Name;
if isKey( irvSourceMapping, irvName )
m3iSrcRun = [ m3iSrcRun, irvSourceMapping( irvName ) ];%#ok<AGROW>
m3iDstRun = [ m3iDstRun, m3iRun ];%#ok<AGROW>
hasNoConnections = false;
end 
end 
end 
if hasNoConnections




if ( autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent( m3iRun,  ...
Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass ) ...
 && ~autosar.mm.mm2sl.RunnableHelper.hasIrvOrIOConnections( m3iRun ) )
m3iLeafServerRun = [ m3iLeafServerRun, m3iRun ];%#ok<AGROW>
else 
m3iLeafNonServerRun = [ m3iLeafNonServerRun, m3iRun ];%#ok<AGROW>
end 
end 
else 
if ( autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent( m3iRun,  ...
Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass ) ...
 && ~autosar.mm.mm2sl.RunnableHelper.hasIrvOrIOConnections( m3iRun ) )
m3iLeafServerRun = [ m3iLeafServerRun, m3iRun ];%#ok<AGROW>
else 
m3iLeafNonServerRun = [ m3iLeafNonServerRun, m3iRun ];%#ok<AGROW>

end 
end 
end 




if ~isempty( m3iSrcRun )
index = 1;
while index <= length( m3iLeafNonServerRun )
m3iRun = m3iLeafNonServerRun( index );
if any( strcmp( { m3iSrcRun.Name }, m3iRun.Name ) )
m3iLeafNonServerRun( index ) = [  ];%#ok<AGROW>
continue ;
else 
index = index + 1;
end 
end 
end 
m3iAllRuns = [ m3iSrcRun, m3iDstRun, m3iLeafNonServerRun, m3iLeafServerRun ];
[ ~, uniqIdx ] = unique( { m3iAllRuns.Name } );
m3iAllRuns = m3iAllRuns( uniqIdx );
m3iAllRunsLen = length( m3iAllRuns );

assert( length( m3iSrcRun ) == length( m3iDstRun ), 'All Sources should have destinations' );
assert( m3iAllRunsLen == m3iRunnablesSize, 'Expected %d unique Runnables to be returned', m3iRunnablesSize );
end 



function seqOut = createSequenceWithOrder( seqIn, rootModel, order )%#ok<INUSL>
assert( length( order ) == seqIn.size(  ), 'order must be same size as seqIn' );
seqClass = class( seqIn );
seqOut = eval( [ seqClass, '.make(rootModel)' ] );
for idx = 1:length( order )
seqOut.append( seqIn.at( order( idx ) ) );
end 
end 



function seqOut = getInitRunnableDataAccess( m3iInitRun, m3iRunnables, rootModel, accessType, modelPeriodicRunnablesAs )%#ok<INUSL>


seqOut = eval( [ 'Simulink.metamodel.arplatform.behavior.SequenceOf', accessType, '.make(rootModel)' ] );%#ok<EVLDOT>

switch ( accessType )
case 'FlowDataAccess'
accessPropName = 'dataAccess';
instanceRefPropName = 'instanceRef';
case 'ModeAccess'
accessPropName = 'ModeAccessPoint';
instanceRefPropName = 'InstanceRef';
case 'ModeSwitch'
accessPropName = 'ModeSwitchPoint';
instanceRefPropName = 'InstanceRef';
otherwise 
assert( false, 'Invalid accessType value: %s', accessType );
end 


for initIdx = 1:m3iInitRun.( accessPropName ).size(  )
initDataAccess = m3iInitRun.( accessPropName ).at( initIdx );
addDataAccessToInitRunnable = true;


for otherRunIdx = 1:m3iRunnables.size(  )
m3iRun = m3iRunnables.at( otherRunIdx );

if isequal( m3iRun, m3iInitRun )
continue ;
end 


for otherRunAccessIdx = 1:m3iRun.( accessPropName ).size(  )
otherDataAccess = m3iRun.( accessPropName ).at( otherRunAccessIdx );
if isequal( otherDataAccess.( instanceRefPropName ), initDataAccess.( instanceRefPropName ) ) &&  ...
initDataAccess.( instanceRefPropName ).isvalid(  )



isWriteAccess = autosar.mm.mm2sl.ModelBuilder.isWriteAccess( otherDataAccess );
isOperationInvoked = autosar.mm.mm2sl.ModelBuilder.isOperationInvokedRunnable( m3iRun );
isAtomicSubsystem = strcmp( modelPeriodicRunnablesAs, 'AtomicSubsystem' );
if ( isOperationInvoked && ~isWriteAccess ) || isAtomicSubsystem
addDataAccessToInitRunnable = false;
break ;
end 
end 
end 

if ~addDataAccessToInitRunnable
break ;
end 
end 
if addDataAccessToInitRunnable
seqOut.append( initDataAccess );
end 
end 
end 

function isWrite = isWriteAccess( m3iAccess )
if isa( m3iAccess, 'Simulink.metamodel.arplatform.behavior.ModeAccess' ) ||  ...
isa( m3iAccess, 'Simulink.metamodel.arplatform.behavior.ModeSwitch' )
isWrite = isa( m3iAccess.InstanceRef.Port, 'Simulink.metamodel.arplatform.port.ProvidedPort' );
else 
assert( isa( m3iAccess, 'Simulink.metamodel.arplatform.behavior.FlowDataAccess' ),  ...
'm3iAccess type %s not expected.', class( m3iAccess ) );
isWrite = contains( m3iAccess.Kind.toString(  ), 'write', 'IgnoreCase', true );
end 
end 

function isOpInvRun = isOperationInvokedRunnable( m3iRun )



isOpInvRun = false;
events = m3iRun.Events;
for ii = 1:events.size(  )
if isa( events.at( ii ), 'Simulink.metamodel.arplatform.behavior.OperationInvokedEvent' )
isOpInvRun = true;
return ;
end 
end 
end 

function validateOperationNameLength( m3iOperation )
m3iInterface = m3iOperation.containerM3I;
if ~isa( m3iInterface, 'Simulink.metamodel.arplatform.interface.ServiceInterface' )



return ;
end 
if numel( m3iOperation.Name ) > namelengthmax
DAStudio.error( 'autosarstandard:importer:MethodNameTooLong',  ...
autosar.api.Utils.getQualifiedName( m3iOperation ), num2str( namelengthmax ) );
end 
end 
end 
end 








% Decoded using De-pcode utility v1.2 from file /tmp/tmplkResL.p.
% Please follow local copyright laws when handling this file.

