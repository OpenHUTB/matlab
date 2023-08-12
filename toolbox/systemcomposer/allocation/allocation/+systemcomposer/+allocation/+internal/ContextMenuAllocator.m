classdef ContextMenuAllocator < handle


















properties 
sourceElem
targetElem
sourceHier
targetHier
sourceModel
targetModel
currentScenario
end 

properties ( Access = private )
useNotificationTimer = true
end 

methods ( Static )
function inst = getInstance(  )
persistent theInstance
if isempty( theInstance ) || ~isvalid( theInstance )
theInstance = systemcomposer.allocation.internal.ContextMenuAllocator(  );
end 
inst = theInstance;
end 

function selectForAllocation( srcElem )


this = systemcomposer.allocation.internal.ContextMenuAllocator.getInstance(  );
this.selectForAllocationImpl( srcElem );
end 

function allocateTo( tgtElem, useCurrentScenario )


R36
tgtElem
useCurrentScenario = true
end 

this = systemcomposer.allocation.internal.ContextMenuAllocator.getInstance(  );


assert( this.hasSourceImpl(  ) );
this.allocateToImpl( tgtElem, useCurrentScenario );
end 

function has = hasSource(  )


this = systemcomposer.allocation.internal.ContextMenuAllocator.getInstance(  );
has = this.hasSourceImpl(  );
end 
end 

methods ( Access = {  ...
?systemcomposer.allocation.internal.AllocationScenarioSelector,  ...
?systemcomposer.allocation.internal.AllocationSetCreator } )

function setCurrentScenarioAndContinueAllocate( this, scenarioPath )
[ allocSetName, scenarioName ] = strtok( scenarioPath, '/' );
allocSet = systemcomposer.allocation.AllocationSet.find( allocSetName );
this.currentScenario = allocSet.getScenario( scenarioName( 2:end  ) );
this.doAllocate(  );
end 

function mdl = getSourceModel( this )
mdl = this.sourceModel;
end 

function mdl = getTargetModel( this )
mdl = this.targetModel;
end 

function matches = allocSetMatchesElems( this, allocSet )



R36
this
allocSet = this.currentScenario.AllocationSet;
end 

try 


allocSetSource = allocSet.SourceModel.Name;
allocSetTarget = allocSet.TargetModel.Name;

matches = isequal( allocSetSource, this.sourceModel ) &&  ...
isequal( allocSetTarget, this.targetModel );
catch 
matches = false;
end 
end 
end 

methods ( Access = private )
function obj = ContextMenuAllocator(  )
obj.resetElems(  );
end 

function selectForAllocationImpl( this, obj )
this.sourceElem = systemcomposer.internal.getWrapperForImpl( obj );
if isempty( this.sourceElem )
error( message( 'SystemArchitecture:studio:CouldNotSelectElementAsSource' ) );
end 


editor = this.getActiveEditor(  );
this.sourceHier = GLUE2.HierarchyService.getPaths( editor.getHierarchyId );
topModelElement = this.sourceHier{ 1 };
this.sourceModel = bdroot( topModelElement );
end 

function has = hasSourceImpl( this )
has = ~isempty( this.sourceElem ) && isvalid( this.sourceElem );
end 

function allocateToImpl( this, obj, useCurrentScenario )
this.targetElem = systemcomposer.internal.getWrapperForImpl( obj );
if isempty( this.targetElem )
error( message( 'SystemArchitecture:studio:CouldNotSelectElementAsTarget' ) );
end 


editor = this.getActiveEditor(  );
this.targetHier = GLUE2.HierarchyService.getPaths( editor.getHierarchyId );
this.targetModel = bdroot( this.targetHier{ 1 } );

this.doAllocate( useCurrentScenario );
end 

function doAllocate( this, useCurrentScenario )


R36
this
useCurrentScenario = true
end 




if useCurrentScenario && this.hasCurrentScenario(  ) && this.allocSetMatchesElems(  )
this.doAllocateImpl(  );
else 

obj = systemcomposer.allocation.internal.AllocationScenarioSelector( this );
DAStudio.Dialog( obj );
end 
end 

function has = hasCurrentScenario( this )
has = ~isempty( this.currentScenario ) && isvalid( this.currentScenario );
end 

function doAllocateImpl( this )

assert( this.hasCurrentScenario(  ) );



srcElem = systemcomposer.internal.resolveElementInHierarchy( this.sourceElem, this.sourceModel, this.sourceHier );
tgtElem = systemcomposer.internal.resolveElementInHierarchy( this.targetElem, this.targetModel, this.targetHier );

alloc = this.currentScenario.allocate( srcElem, tgtElem );
this.notifyEditor( alloc );
this.resetElems(  );
end 

function resetElems( this )
this.sourceElem = [  ];
this.targetElem = [  ];
this.sourceHier = {  };
this.targetHier = {  };
this.sourceModel = '';
this.targetModel = '';
end 

function notifyEditor( this, alloc )


srcElem = [ this.getSourceModel, '/../', this.sourceElem.Name ];
tgtElem = [ this.getTargetModel, '/../', this.targetElem.Name ];
allocName = [ alloc.Scenario.AllocationSet.Name, '/', alloc.Scenario.Name ];

editor = this.getActiveEditor(  );
editor.deliverInfoNotification(  ...
'SystemComposer:ContextMenuAllocator:Allocated',  ...
DAStudio.message( 'SystemArchitecture:studio:AllocatedSuccessNotification',  ...
srcElem, tgtElem, allocName ) );


if this.useNotificationTimer
t = timer;
t.StartDelay = 5;
t.TimerFcn = @( t, e )this.dismissNotification( t, editor, e );
start( t );
end 
end 

function dismissNotification( ~, timerObj, editor, ~ )

editor.closeNotificationByMsgID( 'SystemComposer:ContextMenuAllocator:Allocated' );
stop( timerObj );
delete( timerObj );
end 

function editor = getActiveEditor( ~ )
studios = DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
studio = studios( 1 );
editor = studio.App.getActiveEditor(  );
end 
end 

methods ( Static, Access = ?matlab.unittest.TestCase )
function setCurrentScenarioForTest( scenarioPath )
instance = systemcomposer.allocation.internal.ContextMenuAllocator.getInstance(  );
[ allocSetName, scenarioName ] = strtok( scenarioPath, '/' );
allocSet = systemcomposer.allocation.AllocationSet.find( allocSetName );
instance.currentScenario = allocSet.getScenario( scenarioName( 2:end  ) );
end 

function setNotificationTimerEnabled( val )
instance = systemcomposer.allocation.internal.ContextMenuAllocator.getInstance(  );
instance.useNotificationTimer = val;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpiXYM_n.p.
% Please follow local copyright laws when handling this file.

