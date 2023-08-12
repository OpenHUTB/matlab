classdef EventConnectorManager




properties ( SetAccess = private )
ModelHandle double
ModelName string
end 

properties ( Access = private )
ClientContent diagram.markup.ClientContent
EventManager sltp.EventManager
TaskConnectivityGraph sltp.TaskConnectivityGraph
EventConnectors containers.Map
Styler diagram.style.Styler
end 

properties ( Access = private, Constant )

ClientName( 1, : )char = 'sltp'
end 


methods ( Hidden = true )
function obj = EventConnectorManager( model )
obj.ModelHandle = get_param( model, 'Handle' );
obj.ModelName = get_param( model, 'Name' );

obj = obj.initializeClientContent(  );

obj.EventManager = sltp.EventManager( obj.ModelHandle );
obj.TaskConnectivityGraph = sltp.TaskConnectivityGraph( obj.ModelHandle );
obj.EventConnectors = containers.Map;
obj.Styler = obj.initializeStyler(  );
end 
end 

methods ( Access = private, Static = true )

function styler = initializeStyler(  )
stylerName = "sltpEventConnectorStyler";
styler = diagram.style.getStyler( stylerName );
if isempty( styler )
diagram.style.createStyler( stylerName );
styler = diagram.style.getStyler( stylerName );
style = diagram.style.Style;


constraintList = {  ...
sltp.internal.EventConnectorManager.ClientName,  ...
'diagram::markup'
 };
stylerSelector = diagram.style.MultiSelector(  ...
{  }, constraintList );


r = 0.0;
g = 0.5;
b = 0.5;
a = 1.0;
styleColor = [ r, g, b, a ];

style.set( 'CornerStyle', 'Rounded' );
style.set( 'StrokeColor', styleColor );
style.set( 'StrokeWidth', 2.0 );
style.set( 'TextColor', styleColor );


styler.addRule( style, stylerSelector );
end 
end 
end 

methods 
function obj = initializeClientContent( obj )


client = sltp.internal.initializeDiagramMarkupClient( obj.ClientName );
obj.ClientContent = client.getClientContent( obj.ModelName );
end 

function draw( this )

this = this.clearClientContent(  );



em = this.EventManager;
for event = em.getEvents(  )
if ( ~em.getBehaviorCanShowConnectors( event ) )
continue 
end 

label = em.getEventName( event );
eventBlockSIDs = this.getEventBlockSIDs( event );
tasks = em.getEventTasks( event )';

if isempty( tasks )
this.createUnboundBroadcasterConnectors( eventBlockSIDs, label );
end 

if isempty( eventBlockSIDs )
this.createUnboundListenerConnectors( tasks, label );
end 

this.createBoundConnectors( eventBlockSIDs, tasks, label );
end 


for targetMap = this.EventConnectors.values
for connector = targetMap{ 1 }.values
connector{ 1 }.create(  );
end 
end 
end 

function this = clearClientContent( this )

if ~isempty( this.ClientContent.MarkupConnectors )
this.ClientContent.clear;
end 
end 
end 

methods ( Access = private )
function fullSid = sid2FullSid( this, sid )
fullSid = string( strcat( this.ModelName, ':', sid ) );
end 

function out = getEventBlockSIDs( this, event )
sids = this.EventManager.getSenderSIDs( event );
out = this.removeInvalidBlockSIDs( sids );
end 

function out = getTaskBlockSIDs( this, task )
R36
this( 1, 1 )sltp.internal.EventConnectorManager
task( 1, : )char
end 

sids = this.TaskConnectivityGraph.getSourceBlockSIDs( task );
out = this.removeInvalidBlockSIDs( sids );
end 

function out = removeInvalidBlockSIDs( this, sids )
sids = this.sid2FullSid( sids )';



validFilter = arrayfun( @( x )Simulink.ID.isValid( x ), sids );
out = sids( validFilter );
end 

function createUnboundBroadcasterConnectors( this, eventBlockSIDs, label )
for sourceSID = eventBlockSIDs
sourcePath = Simulink.ID.getFullName( sourceSID );
targetPath = get_param( sourcePath, 'Parent' );
this.updateOrCreateConnector( sourcePath, targetPath, label );
end 
end 

function createUnboundListenerConnectors( this, tasks, label )
for task = tasks
taskBlockSIDs = this.getTaskBlockSIDs( task );
for targetSID = taskBlockSIDs
targetPath = Simulink.ID.getFullName( targetSID );
sourcePath = get_param( targetPath, 'Parent' );
this.updateOrCreateConnector( sourcePath, targetPath, label );
end 
end 
end 

function createBoundConnectors( this, eventBlockSIDs, tasks, label )
for source = eventBlockSIDs
for task = tasks
taskBlockSIDs = this.getTaskBlockSIDs( task );
for target = taskBlockSIDs
path = sltp.internal.ConnectorRouting.computePath( source, target );
for p = path'
this.updateOrCreateConnector( p.source, p.target, label );
end 
end 
end 
end 
end 

function connector = updateOrCreateConnector( this, sourcePath, targetPath, label )
cc = this.ClientContent;
sourceKey = sourcePath;
targetKey = targetPath;

if this.EventConnectors.isKey( sourceKey )
targetMap = this.EventConnectors( sourceKey );
if targetMap.isKey( targetKey )
connector = targetMap( targetKey );
else 
connector = sltp.internal.EventConnector( cc, sourcePath, targetPath );
end 
else 
targetMap = containers.Map;
connector = sltp.internal.EventConnector( cc, sourcePath, targetPath );
end 

connector.addLabel( label );
targetMap( targetKey ) = connector;
this.EventConnectors( sourceKey ) = targetMap;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpdMMqFk.p.
% Please follow local copyright laws when handling this file.

