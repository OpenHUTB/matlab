














function varargout = openSimulationManager( varargin )
narginchk( 1, Inf );
if isa( varargin{ 1 }, 'Simulink.SimulationInput' )
try 
MultiSim.internal.createSimulationManagerFromSimInputOutputPair( varargin{ : } );
catch ME
throwAsCaller( ME );
end 
return ;
end 

p = inputParser;
addRequired( p, 'ModelName',  ...
@( x )validateattributes( x, { 'char' }, { 'vector' } ) );
addParameter( p, 'ReturnHandle', false, @( x )islogical( x ) );
parse( p, varargin{ : } );

[ ~, modelName, ~ ] = fileparts( p.Results.ModelName );

viewer = [  ];
if bdIsLoaded( modelName )
modelHandle = get_param( modelName, "Handle" );
dataId = simulink.multisim.internal.blockDiagramAssociatedDataId(  );
if Simulink.BlockDiagramAssociatedData.isRegistered( modelHandle, dataId )
bdData = Simulink.BlockDiagramAssociatedData.get( modelHandle, dataId );
if bdData.IsSimulationJobActive
if isfield( bdData, "JobViewer" ) && ~isempty( bdData.JobViewer )
viewer = bdData.JobViewer;
bdData.JobViewer.show(  );
else 
job = bdData.SimulationJob;
viewer = MultiSim.internal.MultiSimJobViewer( job );
modelObj = get_param( modelHandle, 'InternalObject' );
addlistener( modelObj, 'SLGraphicalEvent::CLOSE_MODEL_EVENT',  ...
@( ~, ~ )delete( viewer ) );
bdData.JobViewer = viewer;
Simulink.BlockDiagramAssociatedData.set( modelHandle, dataId, bdData );
end 
end 
end 
end 

if isempty( viewer )
multiSimMgr = MultiSim.internal.MultiSimManager.getMultiSimManager(  );
viewer = multiSimMgr.getViewerForModel( modelName );
if isempty( viewer ) || ~isvalid( viewer )
simMgr = Simulink.SimulationManager( modelName );
job = MultiSim.internal.MultiSimJob( simMgr );
viewer = MultiSim.internal.MultiSimJobViewer( job );
end 
viewer.show(  );
end 
if p.Results.ReturnHandle
varargout( 1 ) = { viewer };
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpThA190.p.
% Please follow local copyright laws when handling this file.

