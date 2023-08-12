classdef MultiSimJobViewer < handle
properties ( SetAccess = private )
URL
Job
UUID
end 

properties ( SetAccess = private, Hidden = true )
Dialog
end 

properties ( Dependent = true )
Title
IsDirty
ReuseWindowForNextJob
end 

properties ( Constant )
SharedConfig = MultiSim.internal.JobViewerSharedConfig
end 

properties ( Access = private )
Connector
Title_ = message( 'multisim:SimulationManager:WindowTitleNoArg' ).getString(  )
ReuseWindowForNextJob_ = false
IsDirty_( 1, 1 )logical{ mustBeNonempty } = false
DirtyFlagListener
end 

properties ( Transient, Access = private )
ExitPending = false
end 

methods 

function obj = MultiSimJobViewer( job )
MultiSim.internal.MultiSimManager.getMultiSimManager(  ).registerWindow( obj );
if ( nargin < 1 )
job = [  ];
end 
obj.Job = job;

if ~isempty( job )
obj.DirtyFlagListener = addlistener( obj.Job, 'IsDirty', 'PostSet', @obj.handleJobDirtyFlagChange );
MultiSim.internal.MultiSimManager.getMultiSimManager(  ).linkViewerToModel( obj, job.SimulationManager.ModelName );
end 

connector.ensureServiceOn;
[ ~, obj.UUID ] = fileparts( tempname );

if obj.getConfig( 'DebugMode' )
html = 'index-debug.html';
nonce = '&snc=dev';
else 
html = 'index.html';
nonce = '';
end 

enableDebugging = slfeature( 'ParallelSimulationDebugging' );
parameterView = slfeature( 'SimulationManagerParameterView' );
obj.URL = connector.getUrl( [ '/toolbox/multisim/jobviewer/web/',  ...
html, '?uuid=', obj.UUID,  ...
'&parameterView=', num2str( parameterView ),  ...
'&enableDebugging=', num2str( enableDebugging ),  ...
nonce ] );


obj.Connector = obj.SharedConfig.ConnectorConstructor( obj );


if obj.getConfig( 'DebugMode' )
disp( obj.URL );
end 
obj.Connector.startJobSync(  );
obj.show(  );
obj.Connector.waitForJobSyncToFinish(  );
if ~isempty( job )
obj.IsDirty = job.IsDirty;
end 
end 

function title = get.Title( obj )
title = obj.Dialog.Title;
end 

function set.Title( obj, newTitle )
obj.Title_ = newTitle;
dialogTitle = newTitle;
if obj.IsDirty_
dialogTitle = [ dialogTitle, '*' ];
end 
obj.Dialog.Title = dialogTitle;
end 

function set.IsDirty( obj, isDirty )
obj.IsDirty_ = isDirty;
obj.Title = obj.Title_;
end 

function isDirty = get.IsDirty( obj )
isDirty = obj.IsDirty_;
end 

function value = get.ReuseWindowForNextJob( obj )
value = obj.ReuseWindowForNextJob_;
end 

function set.ReuseWindowForNextJob( obj, value )
multiSimMgr = MultiSim.internal.MultiSimManager.getMultiSimManager(  );
if obj.ReuseWindowForNextJob_ ~= value
obj.ReuseWindowForNextJob_ = value;
if ( value )
multiSimMgr.JobWindow = obj;
else 
if multiSimMgr.JobWindow == obj
multiSimMgr.JobWindow = [  ];
end 
end 
obj.Connector.publish( struct( 'command', 'reuseWindow', 'value', value ) );
end 
end 

function setReuseWindowForNextJob( obj, value )
obj.ReuseWindowForNextJob = value;
end 


function show( obj )
if isempty( obj.Dialog )
obj.createDialog;
end 
windowCreator = obj.getConfig( 'WindowCreator' );
windowCreator.show( obj.Dialog );
end 

function hide( obj )
obj.Dialog.hide(  );
end 

function close( obj )
exitPending = obj.ExitPending;
obj.ExitPending = false;

if obj.Job.SimulationManager.ForRunAll && ~exitPending
obj.hide(  );
return ;
end 

obj.show(  );
if obj.Job.IsRunning
msg = struct( 'command', 'confirmCloseRunningJob' );
obj.Connector.publish( msg );
return ;
end 

if obj.IsDirty_
msg = struct( 'command', 'confirmSaveOnClose' );
obj.Connector.publish( msg );
else 
obj.forceClose(  );
end 
end 

function forceClose( obj )
obj.Dialog.close(  );
delete( obj );
end 

function b = isVisible( obj )
b = ( ~isempty( obj.Dialog ) && obj.Dialog.isVisible );
end 

function connectToJob( obj, job )
if obj.Job ~= job
MultiSim.internal.MultiSimManager.getMultiSimManager(  ).unlinkViewerForModel( job.SimulationManager.ModelName );
obj.Job = job;
MultiSim.internal.MultiSimManager.getMultiSimManager(  ).linkViewerToModel( obj, job.SimulationManager.ModelName );
delete( obj.DirtyFlagListener );
obj.DirtyFlagListener = addlistener( obj.Job, 'IsDirty', 'PostSet', @obj.handleJobDirtyFlagChange );
obj.Connector.initializeViewer(  );
end 
end 

function updateJob( obj, simMgr )
obj.Connector.startJobSync(  );
obj.Job.SimulationManager = simMgr;
obj.Connector.waitForJobSyncToFinish(  );
end 

function selectDocument( obj, docNumber )
obj.Connector.publish( struct( 'command', 'selectDocument',  ...
'docNumber', docNumber ) );
end 

function saveToFile( obj, fileName )
obj.checkFileNotAssociatedWithAnotherWindow( fileName );
obj.Job.saveToFile( fileName );
obj.Title = message( 'multisim:SimulationManager:WindowTitle', fileName ).getString(  );
obj.associateWindowWithFile( fileName );
end 

function saveToFileAndClose( obj, fileName )
obj.saveToFile( fileName );
obj.forceClose(  );
end 

function setLayout( obj, layout )
obj.Connector.setLayout( layout );
end 

function closeAndExit( obj )
if ~obj.IsDirty_



obj.Dialog.close(  );
MultiSim.internal.MultiSimJobViewer.SharedConfig.ExitCommand(  );
else 
msg = struct( 'command', 'exitPending' );
obj.Connector.publish( msg );
obj.ExitPending = true;
obj.close(  );
end 
end 


function delete( obj )
multiSimMgr = MultiSim.internal.MultiSimManager.getMultiSimManager(  );
multiSimMgr.deregisterWindow( obj );
delete( obj.Job );
delete( obj.Connector );
delete( obj.Dialog );
end 

function setFigureSubGrid( obj, numRows, numCols )
R36
obj
numRows( 1, 1 ){ mustBeInteger, mustBePositive }
numCols( 1, 1 ){ mustBeInteger, mustBePositive }
end 
msg = struct( 'command', 'setFigureSubGrid', 'value', struct( 'w', numCols, 'h', numRows ) );
obj.Connector.publish( msg );
end 
end 

methods ( Access = private )
function createDialog( obj )
assert( isempty( obj.Dialog ), "Attempt to create a new dialog when one already exists" );
windowCreator = obj.getConfig( 'WindowCreator' );
obj.Dialog = windowCreator.createWindow( obj.URL, obj );
end 

function handleJobDirtyFlagChange( obj, ~, eventData )
isDirty = eventData.AffectedObject.IsDirty;
obj.IsDirty = isDirty;
end 

function associateWindowWithFile( obj, fileName )
multiSimMgr = MultiSim.internal.MultiSimManager.getMultiSimManager(  );
multiSimMgr.associateWindowWithFile( obj, fileName );
end 

function checkFileNotAssociatedWithAnotherWindow( obj, fileName )
multiSimMgr = MultiSim.internal.MultiSimManager.getMultiSimManager(  );
associatedWindow = multiSimMgr.getWindowForFile( fileName );
if ~isempty( associatedWindow ) && associatedWindow ~= obj
error( message( 'multisim:FileIO:CannotSaveAssociatedWindowExists', fileName ) );
end 
end 
end 

methods ( Access = ?MultiSim.internal.MultiSimManager )
function publishFileName( obj, fileName )
obj.Connector.publishFileName( fileName );
end 
end 

methods ( Static )
function oldVal = setConfig( name, value )
config = MultiSim.internal.MultiSimJobViewer.SharedConfig;
oldVal = config.( name );
config.( name ) = value;
end 

function value = getConfig( name )
config = MultiSim.internal.MultiSimJobViewer.SharedConfig;
value = config.( name );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpetqdb7.p.
% Please follow local copyright laws when handling this file.

