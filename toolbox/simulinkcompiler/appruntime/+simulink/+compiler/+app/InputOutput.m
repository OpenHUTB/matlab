






























classdef InputOutput < handle
properties ( SetAccess = ?simulink.compiler.app.SimulationHelper )
SimulationInput
SimulationOutput
end 

properties ( Access = private )
App
SimulationHelper

TSDataInSelectedSet
TSDataFromLoggedDatasets
end 

methods ( Access = { ?simulink.compiler.app.SimulationHelper, ?matlab.mock.classes.InputOutputMock } )
function obj = InputOutput( simulationHelper )










R36
simulationHelper( 1, 1 )simulink.compiler.app.SimulationHelper
end 

obj.App = simulationHelper.App;
obj.SimulationHelper = simulationHelper;
end 
end 

methods 

function simInp = createSimulationInput( obj )









if isempty( obj.SimulationHelper.ModelName )
error( message( 'simulinkcompiler:genapp:ModelNameNotSet' ) );
end 

simInp = Simulink.SimulationInput( obj.SimulationHelper.ModelName );

if ~isempty( obj.SimulationHelper.Workspace.ModelParameterSets )
simInp.ModelParameters =  ...
obj.SimulationHelper.Workspace.ModelParameterSets.DefaultSet;
end 


simInp = simInp.setModelParameter( 'SimulationMode', 'rapid' );
simInp = simInp.setModelParameter( 'RapidAcceleratorUpToDateCheck', 'off' );

simInp = obj.SimulationHelper.Binder.applyBindings( simInp );

obj.SimulationInput = simInp;
end 

function vars = loadMATFile( obj, fileName, fileExt )














R36
obj
fileName( 1, 1 )string
fileExt( 1, 1 ) = "*.mat"
end 

vars = [  ];

if fileName == ""
[ file, path ] = uigetfile( fileExt,  ...
message( 'simulinkcompiler:genapp:SelectMATFile' ).getString );
if isequal( file, 0 ), return ;end 
fileName = fullfile( path, file );
end 

try 
simulink.compiler.internal.loadEnumTypes( obj.SimulationHelper.ModelName );
rawVars = load( fileName );
vars = obj.extractVariableSets( rawVars );
catch ME
obj.SimulationHelper.UserInterface.reportError( ME );
return 
end 

obj.SimulationHelper.Workspace.update( vars );
end 

function saveSimulationInputOutput( obj, fileName )














suffix = datestr( datetime( 'now' ) );
descriptionMsg =  ...
message( 'simulinkcompiler:genapp:SimInpAndOutDescription',  ...
obj.SimulationHelper.ModelName, suffix ).getString;

simInpAndOut.Description = descriptionMsg;
simInpAndOut.simInp = obj.SimulationInput;
simInpAndOut.simOut = obj.SimulationOutput;

save( fileName, 'simInpAndOut' );

simIOSavedMessage = message(  ...
'simulinkcompiler:genapp:SimulationIOSaved',  ...
fileName ).getString;

obj.SimulationHelper.UserInterface.setStatusMessage( simIOSavedMessage );
end 

function [ tsArray, tsPaths, tsNames ] = extractTimeSeriesFromLoggedDatasets( obj )















function answer = isStructLogVar( slv )
answer = false;
if ( isstruct( slv ) && isfield( slv, 'time' ) ...
 && isfield( slv, 'signals' ) && isstruct( slv.signals ) ...
 && isa( slv.time, 'double' ) && isvector( slv.time ) ...
 && isfield( slv.signals, 'values' ) && ~isempty( slv.signals( 1 ).values ) ...
 && ismatrix( slv.signals( 1 ).values ) ...
 && size( slv.signals( 1 ).values, 1 ) == length( slv.time ) )
answer = true;
end 
end 

tsArray = {  };
tsPaths = {  };
tsNames = {  };

namesOfVarsInSimOut = obj.SimulationOutput.who;

for iv = 1:length( namesOfVarsInSimOut )
varName = namesOfVarsInSimOut{ iv };
var = obj.SimulationOutput.( varName );
if isStructLogVar( var )

var = Simulink.SimulationData.Dataset( var, 'DatasetName', varName );
end 
varType = class( var );
switch varType
case 'Simulink.SimulationData.Dataset'

[ tsArrayInDS, tsPathsInDS, tsNamesInDS ] =  ...
simulink.compiler.internal.extractTimeseriesFromDataset( var );

tsArray = [ tsArray, tsArrayInDS ];%#ok
tsPaths = [ tsPaths, tsPathsInDS ];%#ok
tsNames = [ tsNames, tsNamesInDS ];%#ok

otherwise 
skipVarMessage =  ...
message( 'simulinkcompiler:genapp:SkippingVariable',  ...
varName, varType ).getString;

obj.SimulationHelper.UserInterface.setStatusMessage( skipVarMessage );
end 
end 


obj.TSDataFromLoggedDatasets.tsArray = tsArray;
obj.TSDataFromLoggedDatasets.tsPaths = tsPaths;
obj.TSDataFromLoggedDatasets.tsNames = tsNames;
end 

function [ tsArray, tsPaths, tsNames ] = extractTimeseriesFromDataset( obj, dataset )














R36
obj
dataset( 1, 1 )Simulink.SimulationData.Dataset
end 

[ tsArray, tsPaths, tsNames ] =  ...
simulink.compiler.internal.extractTimeseriesFromDataset( dataset );


obj.TSDataInSelectedSet.tsArray = tsArray;
obj.TSDataInSelectedSet.tsPaths = tsPaths;
obj.TSDataInSelectedSet.tsNames = tsNames;
end 

function signals = externalInputSignalsForCurrentSet( obj )







signals = [  ];

if isempty( obj.TSDataInSelectedSet )
return 
end 

signals = obj.TSDataInSelectedSet.tsArray;
end 

function signals = loggedSignals( obj )






signals = [  ];

if isempty( obj.TSDataFromLoggedDatasets )
return 
end 

signals = obj.TSDataFromLoggedDatasets.tsArray;
end 

function signalNames = externalInputSignalNamesForCurrentSet( obj )







signalNames = [  ];

if isempty( obj.TSDataInSelectedSet )
return 
end 

signalNames = obj.TSDataInSelectedSet.tsNames;
end 

function signalNames = loggedSignalNames( obj )






signalNames = [  ];

if isempty( obj.TSDataFromLoggedDatasets )
return 
end 

signalNames = obj.TSDataFromLoggedDatasets.tsNames;
end 
end 

methods ( Access = private )
function variableSets = extractVariableSets( obj, variables )
varExtractor =  ...
simulink.compiler.internal.VariableSetExtractor( variables );

try 
variableSets = varExtractor.extractSets(  );
catch ME
obj.SimulationHelper.UserInterface.reportError( ME );
end 
end 
end 
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpsHE1xR.p.
% Please follow local copyright laws when handling this file.

