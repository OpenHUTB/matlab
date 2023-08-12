classdef PreprocessingDataModel < handle









properties ( Dependent )
OriginalWorkspace
end 
methods 
function val = get.OriginalWorkspace( this )
val = this.OriginalWorkspaceI;
end 

function set.OriginalWorkspace( this, val )
this.OriginalWorkspaceI = val;
this.updateWorkspace;
end 

function delete( this )
if ~isempty( this.Steps )
this.Steps = [  ];
end 
delete( this.CurrentWorkspace );
delete( this.OriginalWorkspace );
end 
end 

properties ( SetAccess = protected )
CurrentWorkspace( 1, 1 )matlab.internal.datatoolsservices.AppWorkspace;
end 

properties ( Access = { ?matlab.unittest.TestCase } )
OriginalWorkspaceI( 1, 1 )matlab.internal.datatoolsservices.AppWorkspace;
PreprocessingStepMap containers.Map;
PreprocessingStepIDsList( :, 1 )int64
end 

properties 
StateChangedFcn
StateMap


PreventUpdates( 1, 1 )logical = false
end 

properties ( Dependent )
Steps struct
end 
methods 

function val = get.Steps( this )
if isempty( this.PreprocessingStepIDsList )
val = [  ];
end 
for i = 1:length( this.PreprocessingStepIDsList )
stepID = string( this.PreprocessingStepIDsList( i ) );
stepStruct = this.PreprocessingStepMap( stepID );
val( i ) = stepStruct;%#ok<AGROW>
end 
end 


function set.Steps( this, Steps )
if ~isempty( Steps )
for i = 1:length( Steps )
if ~isfield( Steps( i ), 'ID' ) || isempty( Steps( i ).ID )
Steps( i ).ID = this.getNewStepID;
end 
if ~isfield( Steps( i ), 'Enabled' ) || isempty( Steps( i ).Enabled )
Steps( i ).Enabled = true;
end 

key = string( Steps( i ).ID );
this.PreprocessingStepMap( key ) = Steps( i );
end 
currentSteps = this.PreprocessingStepIDsList;

this.PreprocessingStepIDsList = [ Steps.ID ];
else 
this.PreprocessingStepMap = containers.Map;
this.PreprocessingStepIDsList = int64( [  ] );
currentSteps = this.PreprocessingStepIDsList;
end 
try 
this.updateWorkspace;
catch e

if ~isempty( currentSteps )
this.PreprocessingStepIDsList = currentSteps;
end 
rethrow( e );
end 

end 
end 

methods 

function this = PreprocessingDataModel( workspace )
R36
workspace( 1, 1 )matlab.internal.datatoolsservices.AppWorkspace = matlab.internal.datatoolsservices.AppWorkspace;
end 



this.OriginalWorkspace = workspace;
this.CurrentWorkspace = workspace.clone;


this.PreprocessingStepMap = containers.Map;
this.PreprocessingStepIDsList = int64( [  ] );
end 

function workspace = getWorkspaceAt( this, stepIndex )
R36
this
stepIndex double
end 
workspace = this.OriginalWorkspace.clone;
for i = 1:stepIndex
this.evalCodeAtStep( i, workspace );
end 
end 

function evalCodeAtStep( this, stepIndex, workspace )
stepID = string( this.PreprocessingStepIDsList( stepIndex ) );
stepCode = this.PreprocessingStepMap( stepID );

if stepCode.Enabled

if iscell( stepCode.Code )
stepCode.Code = string( stepCode.Code );
end 

evalin( workspace, join( stepCode.Code ) );
end 
end 

function stepIndex = getIndexWithID( this, stepID )
stepIndexArrayLogical = ( string( this.PreprocessingStepIDsList ) == string( stepID ) );
stepIndex = find( stepIndexArrayLogical, 1, 'first' );
end 

function [ isSuccess, errorMsg ] = addCodeAt( this, pvPairs )
R36
this( 1, 1 )matlab.internal.preprocessingApp.state.PreprocessingDataModel
pvPairs.Code string = ""
pvPairs.DisplayName string = ""
pvPairs.VariableName( 1, 1 )string = ""
pvPairs.TableVariableName = ""
pvPairs.OperationType( 1, 1 )string = ""
pvPairs.Enabled( 1, 1 )logical = true
pvPairs.StepIndex( 1, 1 )int64 = length( this.PreprocessingStepIDsList ) + 1
pvPairs.VariablesList string = ""
end 


isSuccess = true;
errorMsg = "";

codeStep = this.createCodeStruct( pvPairs );

if isempty( this.PreprocessingStepIDsList )
this.PreprocessingStepIDsList = codeStep.ID;
else 
this.PreprocessingStepIDsList = [ this.PreprocessingStepIDsList( 1:max( pvPairs.StepIndex - 1, 1 ) );codeStep.ID;this.PreprocessingStepIDsList( pvPairs.StepIndex:end  ) ];
end 
this.PreprocessingStepMap( string( codeStep.ID ) ) = codeStep;

try 
isAppend = pvPairs.StepIndex == length( this.PreprocessingStepIDsList );
this.updateWorkspace( isAppend )





if pvPairs.StepIndex == length( this.PreprocessingStepIDsList )
[ varsDiff, newVarNames ] = this.areVariablesDifferent(  );
if varsDiff
addVarnamesToStep = false;
if length( this.PreprocessingStepIDsList ) > 1
stepIndex = find( arrayfun( @( s )~all( strcmp( s.VariableList, "" ) ), this.Steps ) );
if ~isempty( stepIndex )
stepIndex = stepIndex( end  );
else 
stepIndex = length( this.PreprocessingStepIDsList ) - 1;
end 
previousStep = this.Steps( stepIndex );
if ~isequal( newVarNames, previousStep.VariableList )
addVarnamesToStep = true;
end 
else 
addVarnamesToStep = true;
end 

if addVarnamesToStep

codeStep.VariableList = newVarNames;
this.PreprocessingStepMap( string( codeStep.ID ) ) = codeStep;
end 
end 
end 
catch e
this.PreprocessingStepIDsList( pvPairs.StepIndex ) = [  ];
this.PreprocessingStepMap.remove( string( codeStep.ID ) );
isSuccess = false;
errorMsg = e.message;
end 
end 

function [ isSuccess, errorMsg ] = removeCodeAt( this, stepIndex )
R36
this
stepIndex double
end 
isSuccess = true;
errorMsg = "";

currentSteps = this.PreprocessingStepIDsList;

try 
this.PreprocessingStepIDsList( stepIndex ) = [  ];
this.updateWorkspace;
catch e
this.PreprocessingStepIDsList = currentSteps;
isSuccess = false;
errorMsg = e.message;
end 
end 

function replaceCodeAt( this, pvPairs )
R36
this( 1, 1 )matlab.internal.preprocessingApp.state.PreprocessingDataModel
pvPairs.Code string = ""
pvPairs.DisplayName string = ""
pvPairs.VariableName( 1, 1 )string = ""
pvPairs.TableVariableName = ""
pvPairs.OperationType( 1, 1 )string = ""
pvPairs.Enabled( 1, 1 )logical = true
pvPairs.StepIndex( 1, 1 )int64 = length( this.PreprocessingStepIDsList )
pvPairs.VariablesList string = ""
end 


isSuccess = true;
errorMsg = "";

IDToReplace = this.PreprocessingStepIDsList( pvPairs.StepIndex );
stepToReplace = this.PreprocessingStepMap( string( IDToReplace ) );

newCodeStep = this.createCodeStruct( pvPairs, IDToReplace );


this.PreprocessingStepMap( string( IDToReplace ) ) = newCodeStep;

try 
this.updateWorkspace;
catch e


this.PreprocessingStepIDsList( pvPairs.StepIndex ) = IDToReplace;
this.PreprocessingStepMap( string( IDToReplace ) ) = stepToReplace;
isSuccess = false;
errorMsg = e.message;
end 
end 

function [ varValue, fullTable ] = getVariableValueAt( this, pvPairs )
R36
this( 1, 1 )matlab.internal.preprocessingApp.state.PreprocessingDataModel
pvPairs.VariableName( 1, 1 )string
pvPairs.TableVariableName string = string.empty
pvPairs.StepIndex( 1, 1 )int64 = length( this.PreprocessingStepIDsList )
end 

varName = pvPairs.VariableName;
if ~isempty( pvPairs.TableVariableName ) && strlength( pvPairs.TableVariableName ) > 0
varName = internal.matlab.datatoolsservices.VariableUtils.generateDotSubscripting( varName,  ...
pvPairs.TableVariableName,  ...
this.CurrentWorkspace.( varName ) );
end 

origWSVariables = this.generateWorkspaceVariablesList( this.OriginalWorkspace );
stepIndex = pvPairs.StepIndex;
if stepIndex <= 0

if ismember( varName, origWSVariables )
varValue = this.OriginalWorkspace.evalin( varName );
fullTable = this.OriginalWorkspace.evalin( pvPairs.VariableName );
return ;
else 
s = this.Steps;
for i = 1:length( s )
if ismember( varName, s( i ).VariableList )
stepIndex = i;
break ;
end 
end 
end 
end 
try 
switch stepIndex
case 0
ws = this.OriginalWorkspace;
case length( this.PreprocessingStepIDsList )
ws = this.CurrentWorkspace;
otherwise 
ws = this.getWorkspaceAt( stepIndex );
end 
varValue = ws.evalin( varName );
fullTable = ws.evalin( pvPairs.VariableName );
catch 
varValue = [  ];
fullTable = table.empty;
end 
end 

function updateStateMap( this, stepID, state )

if isempty( this.StateMap )
this.StateMap = containers.Map;
end 

this.StateMap( string( stepID ) ) = state;
end 

function state = getStateWithStepID( this, stepID )
key = string( stepID );
state = struct.empty;
if isKey( this.StateMap, key )
state = this.StateMap( key );
end 
end 
end 

methods ( Access = { ?matlab.unittest.TestCase } )
function newStepID = getNewStepID( ~ )

persistent currentStepID;
if isempty( currentStepID )
currentStepID = int64( 1 );
else 
currentStepID = currentStepID + 1;
end 

newStepID = currentStepID;
end 

function stepStruct = createCodeStruct( this, codeStruct, stepID )
R36
this( 1, 1 )matlab.internal.preprocessingApp.state.PreprocessingDataModel
codeStruct( 1, 1 )struct
stepID( 1, 1 )int64 = this.getNewStepID;
end 



stepStruct = struct;
stepStruct.ID = stepID;
stepStruct.Code = codeStruct.Code;
stepStruct.Enabled = codeStruct.Enabled;
stepStruct.DisplayName = codeStruct.DisplayName;
stepStruct.VariableName = codeStruct.VariableName;
stepStruct.TableVariableName = codeStruct.TableVariableName;
stepStruct.OperationType = codeStruct.OperationType;
stepStruct.VariableList = codeStruct.VariablesList;
end 

function updateWorkspace( this, isAppend )
R36
this
isAppend( 1, 1 )logical = false
end 



if ~isAppend
workspace = this.getWorkspaceAt( length( this.PreprocessingStepIDsList ) );
else 
workspace = this.CurrentWorkspace;
this.evalCodeAtStep( length( this.PreprocessingStepIDsList ), workspace );
end 
this.CurrentWorkspace = workspace;

if ~isempty( this.StateChangedFcn ) && ~this.PreventUpdates
try 
argCount = nargin( this.StateChangedFcn );






this.StateChangedFcn(  );
catch e
disp( e );
end 
end 
end 

function [ variablesAreDifferent, newVariableNames ] = areVariablesDifferent( this )
originalVars = this.generateWorkspaceVariablesList( this.OriginalWorkspace );
newVariableNames = this.generateWorkspaceVariablesList( this.CurrentWorkspace );

variablesAreDifferent = ~isequal( originalVars, newVariableNames );
end 

function varList = generateWorkspaceVariablesList( this, ws )
topLevelVars = string( ws.who )';
varList = topLevelVars;
for i = 1:length( topLevelVars )
varName = topLevelVars( i );
varValue = ws.( varName );
if isa( varValue, 'tabular' )
for i = 1:length( varValue.Properties.VariableNames )
tableVar = internal.matlab.datatoolsservices.VariableUtils.generateDotSubscripting( varName,  ...
varValue.Properties.VariableNames{ i },  ...
this.CurrentWorkspace.( varName ) );

varList = [ varList, tableVar ];%#ok<AGROW>
end 
end 
if istimetable( varValue )

varList = [ varList, varName + "." + varValue.Properties.DimensionNames{ 1 } ];%#ok<AGROW>
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpT9iOJR.p.
% Please follow local copyright laws when handling this file.

