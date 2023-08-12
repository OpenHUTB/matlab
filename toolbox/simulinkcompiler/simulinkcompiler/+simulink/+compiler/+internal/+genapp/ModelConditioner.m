classdef ModelConditioner < handle

















properties ( Access = private )
TempModelState
ModelDataSvc
SigLoggingUtils
SimIn
end 

properties ( Access = private, Dependent )
Model
end 

methods 
function obj = ModelConditioner( modelDataSvc, sigLoggingUtils )

R36
modelDataSvc( 1, 1 )simulink.compiler.internal.ModelDataService
sigLoggingUtils( 1, 1 )simulink.compiler.internal.SignalLoggingUtils
end 

obj.ModelDataSvc = modelDataSvc;
obj.SigLoggingUtils = sigLoggingUtils;
obj.SimIn = Simulink.SimulationInput( obj.Model );
end 

function modelName = get.Model( obj )
modelName = obj.ModelDataSvc.ModelName;
end 

function ensureOutputSavingIsOn( obj )


numOutports = numel( obj.ModelDataSvc.getRootOutports(  ) );
noOutports = isequal( numOutports, 0 );
if noOutports, return ;end 

obj.SimIn = obj.SimIn.setModelParameter( 'SaveOutput', 'on' );
obj.applyAndCacheTempState(  );
end 

function limitDataPoints( obj, maxDataPoints )


import simulink.compiler.internal.util.printMsg

msgKey = "simulinkcompiler:genapp:LimitingNumberOfDataPoints";
printMsg( msgKey, maxDataPoints );

obj.SimIn = obj.SimIn.setModelParameter( 'LimitDataPoints', 'on' );
obj.SimIn = obj.SimIn.setModelParameter( 'MaxDataPoints', num2str( maxDataPoints ) );
obj.applyAndCacheTempState(  );
end 

function limitLoggedSignalDataPoints( obj, numPoints )
sigs = obj.SigLoggingUtils.getLoggedSignals(  );
if isempty( sigs ), return ;end 
for idx = 1:sigs.Count
s = sigs.get( idx );
blk = s.BlockPath.getBlock( 1 );
ph = get_param( blk, 'PortHandles' );
port = ph.Outport( s.OutputPortIndex );

if isequal( get_param( port, 'DataLoggingLimitDataPoints' ), 'on' ), continue ;end 
obj.SimIn = obj.SimIn.setPortParameter( port, 'DataLoggingLimitDataPoints', 'on' );
obj.SimIn = obj.SimIn.setPortParameter( port, 'DataLoggingMaxPoints', num2str( numPoints ) );
end 
obj.applyAndCacheTempState(  );
end 

function logRootScopeData( obj )


import simulink.compiler.internal.util.printMsg

if ~obj.ModelDataSvc.modelHasScopes(  ), return ;end 

printMsg( "simulinkcompiler:genapp:EnsuringScopeDataLoggingIsOn" );

blockPaths = obj.ModelDataSvc.getRootScopeBlockPaths(  );
blockPaths = blockPaths';
for idx = 1:numel( blockPaths )
blockPath = blockPaths{ idx };
varName = [ 'Scope', num2str( idx ), 'Data' ];
obj.SimIn = obj.SimIn.setBlockParameter( blockPath, 'DataLogging', 'on' );
obj.SimIn = obj.SimIn.setBlockParameter( blockPath, 'DataLoggingSaveFormat', 'Structure With Time' );
obj.SimIn = obj.SimIn.setBlockParameter( blockPath, 'DataLoggingVariableName', varName );
end 

obj.applyAndCacheTempState(  );
end 

function limitRootScopeDataPoints( obj, maxDataPoints )


import simulink.compiler.internal.util.printMsg

if ~obj.ModelDataSvc.modelHasScopes(  ), return ;end 

printMsg( "simulinkcompiler:genapp:LimitingNumberOfScopeDataPoints", maxDataPoints );

numPoints = num2str( maxDataPoints );
blockPaths = obj.ModelDataSvc.getRootScopeBlockPaths(  );
for blkPath = blockPaths'
blockPath = blkPath{ 1 };
obj.SimIn = obj.SimIn.setBlockParameter( blockPath, 'DataLoggingLimitDataPoints', 'on' );
obj.SimIn = obj.SimIn.setBlockParameter( blockPath, 'DataLoggingMaxPoints', numPoints );
end 

obj.applyAndCacheTempState(  );
end 

function delete( obj )
delete( obj.TempModelState );
set_param( obj.Model, 'Dirty', 'off' );
end 

end 

methods ( Access = private )

function applyAndCacheTempState( obj )
if ~isempty( obj.TempModelState )
delete( obj.TempModelState );
end 
obj.TempModelState =  ...
Simulink.internal.TemporaryModelState( obj.SimIn,  ...
'EnableConfigSetRefUpdate', 'on', 'ApplyHidden', 'on' );
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7mBNVz.p.
% Please follow local copyright laws when handling this file.

