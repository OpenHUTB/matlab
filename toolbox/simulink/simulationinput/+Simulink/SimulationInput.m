
















































classdef ( AllowedSubclasses = { ?sltest.harness.SimulationInput, ?matlab.mock.classes.SimulationInputMock } )SimulationInput < matlab.mixin.Heterogeneous
properties ( SetAccess = public, GetAccess = public )








ModelName{ mustBeValidModelName } = ''
end 

properties ( Dependent )











InitialState
end 

properties 












ExternalInput
end 

properties ( Dependent )









ModelParameters










BlockParameters










Variables

end 

properties 

























PreSimFcn






























PostSimFcn









UserString{ Simulink.SimulationMetadata.mustBeValidUserString } = Simulink.SimulationMetadata.DefaultUserString
end 

properties ( Hidden )
ExperimentalProperties = Simulink.Simulation.internal.ExperimentalProperties





RuntimeFcns slsim.RuntimeFcns = slsim.RuntimeFcns(  )
end 

properties ( SetAccess = public, GetAccess = public, Hidden = true )
ActualInitialState = Simulink.SimulationInput.EmptyOperatingPoint
PortParameters = Simulink.Simulation.PortParameter.empty(  )
LoggingSpecification = Simulink.Simulation.LoggingSpecification.empty(  )
HiddenModelParameters = getDefaultHiddenModelParams(  );
HiddenBlockParameters = Simulink.Simulation.BlockParameter.empty(  )
HiddenVariables = Simulink.Simulation.Variable.empty(  )
RunId = 0
end 

properties ( Access = private )
NeedsCleanupLogging = false
RapidAcceleratorUpToDateCheckOff = false
ActualModelParameters = Simulink.Simulation.ModelParameter.empty(  )
ActualBlockParameters = Simulink.Simulation.BlockParameter.empty(  )
ActualVariables = Simulink.Simulation.Variable.empty(  )
end 

properties ( Transient, Constant, Access = private )
DefaultSimHelper = getSimulationInputSimHelper(  );
DefaultSimulationInputHelper = getSimulationInputSimulationInputHelper(  );
DefaultInitialStateHelper = getSimulationInputInitialStateHelper(  )
EmptyOperatingPoint = Simulink.SimulationInput.DefaultInitialStateHelper.EmptyOperatingPoint;
end 

properties ( Hidden = true )




UsingManager = false



IsUsingPCT = false




PreLoadFcn




SimInfo Simulink.Simulation.internal.SimInfo
end 

properties ( Access = private, Transient = true )
EnableConfigSetRefUpdate
end 
properties ( Access = public, Transient = true, Hidden = true )
ImplicitRapidAcceleratorUpToDateCheckOff = false
CreatedForRevert( 1, 1 )logical = false
SimulationDirectory( 1, 1 )string = ""
LoggingSetupFcn function_handle
end 

methods 




function obj = SimulationInput( modelName )
R36
modelName{ mustBeValidModelName } = ''
end 
obj.ModelName = modelName;
end 

function obj = set.PreSimFcn( obj, fh )
if isempty( fh )
obj.PreSimFcn = [  ];
return ;
end 

try 
validateattributes( fh, { 'function_handle' }, { 'scalar' } );
if nargin( fh ) ~= 1
err = MException( message( 'Simulink:Commands:SimInputPrePostFcnArg', 'PreSimFcn' ) );
msld = MSLDiagnostic( err );
msld.reportAsError( '', false );
end 
obj.PreSimFcn = fh;
catch ME
throwAsCaller( ME )
end 
end 

function obj = set.PostSimFcn( obj, fh )
if isempty( fh )
obj.PostSimFcn = [  ];
return ;
end 

try 
validateattributes( fh, { 'function_handle' }, { 'scalar' } );
if nargin( fh ) ~= 1
err = MException( message( 'Simulink:Commands:SimInputPrePostFcnArg', 'PostSimFcn' ) );
msld = MSLDiagnostic( err );
msld.reportAsError( '', false );
end 
obj.PostSimFcn = fh;
catch ME
throwAsCaller( ME )
end 
end 

function obj = setUserString( obj, userStr )











try 
if iscell( userStr ) && numel( userStr ) == numel( obj )
for idx = 1:numel( obj )
obj( idx ).UserString = userStr{ idx };
end 
else 
for idx = 1:numel( obj )
obj( idx ).UserString = userStr;
end 
end 
catch ME
throwAsCaller( ME );
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function obj = setModelName( obj, modelName )











for idx = 1:numel( obj )
obj( idx ).ModelName = modelName;
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function obj = setPreSimFcn( obj, fh )





























try 
for idx = 1:numel( obj )
obj( idx ).PreSimFcn = fh;
end 
catch ME
throwAsCaller( ME )
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function obj = setPostSimFcn( obj, fh )

































try 
for idx = 1:numel( obj )
obj( idx ).PostSimFcn = fh;
end 
catch ME
throwAsCaller( ME )
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 




function out = get.InitialState( obj )
out = obj.ActualInitialState;
end 

function obj = set.InitialState( obj, initialState )
if isempty( initialState ) && ~isequal( [  ], initialState )
obj.ActualInitialState = Simulink.SimulationInput.EmptyOperatingPoint;
else 
try 
obj.DefaultInitialStateHelper.validate( initialState );
obj.ActualInitialState = initialState;
catch ME
throwAsCaller( ME );
end 
end 
end 

function obj = setInitialState( obj, initialState )













if iscell( initialState ) && numel( initialState ) == numel( obj )
for idx = 1:numel( obj )
obj( idx ).InitialState = initialState{ idx };
end 
else 
for idx = 1:numel( obj )
obj( idx ).InitialState = initialState;
end 
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function obj = set.ExternalInput( obj, extInp )
if isempty( extInp )
obj.ExternalInput = [  ];
else 
obj.ExternalInput = extInp;
end 
end 

function obj = setExternalInput( obj, varargin )

















narginchk( 2, 4 );
if ( iscell( varargin{ 1 } ) && numel( varargin{ 1 } ) == numel( obj ) )
for idx = 1:numel( obj )
arg1 = varargin{ 1 }{ idx };
if iscell( arg1 )
obj( idx ) = obj( idx ).setExternalInput( arg1{ : } );
else 
obj( idx ) = obj( idx ).setExternalInput( arg1 );
end 
end 
return ;
elseif numel( obj ) > 1
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setExternalInput( varargin{ : } );
end 
if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
return ;
end 

extInp = varargin{ 1 };
if isempty( extInp )
obj.ExternalInput = [  ];
else 
obj.ExternalInput = extInp;
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function obj = set.ModelParameters( obj, modelParams )
if isempty( modelParams )
obj.ActualModelParameters = Simulink.Simulation.ModelParameter.empty;
else 
try 
validateattributes( modelParams, { 'Simulink.Simulation.ModelParameter' }, { 'vector' } );
obj.ActualModelParameters = Simulink.Simulation.ModelParameter.empty;
for idx = 1:numel( modelParams )
modelParam = modelParams( idx );
obj.validateModelParameter( modelParam );
index = findModelParameter( modelParam.Name,  ...
obj.ModelParameters );
if isempty( index )
obj.ActualModelParameters( end  + 1 ) = modelParam;
else 
obj.ActualModelParameters( index ) = modelParam;
end 
end 
catch ME
throwAsCaller( ME )
end 
end 
end 

function value = get.ModelParameters( obj )
value = obj.ActualModelParameters;
end 

function obj = set.BlockParameters( obj, blockParams )
if isempty( blockParams )
obj.ActualBlockParameters = Simulink.Simulation.BlockParameter.empty;
else 
try 
validateattributes( blockParams, { 'Simulink.Simulation.BlockParameter' }, { 'vector' } );


if obj.RapidAcceleratorUpToDateCheckOff
if ~obj.ImplicitRapidAcceleratorUpToDateCheckOff
error( message( 'Simulink:Commands:CannotSetBlockParamRapidAccelUpToDateCheckOff' ) );
else 

warning( message( 'Simulink:Commands:CannotSetBlockParamRapidAccelUpToDateCheckOff' ) )
end 
end 
obj.ActualBlockParameters = Simulink.Simulation.BlockParameter.empty;
for idx = 1:numel( blockParams )
blockParam = blockParams( idx );
obj.validateBlockParameter( blockParam );
index = findBlockParameter( blockParam.BlockPath,  ...
blockParam.Name,  ...
obj.BlockParameters );
if isempty( index )
obj.ActualBlockParameters( end  + 1 ) = blockParam;
else 
obj.ActualBlockParameters( index ) = blockParam;
end 
end 
catch ME
throwAsCaller( ME )
end 
end 
end 

function value = get.BlockParameters( obj )
value = obj.ActualBlockParameters;
end 

function obj = set.Variables( obj, vars )
if isempty( vars )
obj.ActualVariables = Simulink.Simulation.Variable.empty;
else 
validateattributes( vars, { 'Simulink.Simulation.Variable' }, { 'vector' } );




if obj.RapidAcceleratorUpToDateCheckOff
varWorkspaces = arrayfun( @( x )x.Workspace, vars,  ...
'UniformOutput', false );

globalWorkspaceIndices =  ...
strcmp( 'global-workspace', varWorkspaces );

topModelWorkspaceIndices =  ...
strcmp( obj.ModelName, varWorkspaces );

if ~all( xor( globalWorkspaceIndices, topModelWorkspaceIndices ) )
error( message( 'Simulink:Commands:CannotSetModelWkspVarRapidAccelUpToDateCheckOff' ) );
end 
end 

obj.ActualVariables = Simulink.Simulation.Variable.empty;
for idx = 1:numel( vars )
var = vars( idx );
index = findVariable( var.Name, obj.Variables, var.Workspace, var.Context );
if isempty( index )
obj.ActualVariables( end  + 1 ) = var;
else 
obj.ActualVariables( index ) = var;
end 
end 
end 
end 

function value = get.Variables( obj )
value = obj.ActualVariables;
end 

function obj = setBlockParameter( obj, varargin )









narginchk( 2, inf );

if ( nargin == 2 && iscell( varargin{ 1 } ) &&  ...
numel( varargin{ 1 } ) == numel( obj ) )

for idx = 1:numel( obj )
arg1 = varargin{ 1 }{ idx };
if iscell( arg1 )
obj( idx ) = obj( idx ).setBlockParameter( arg1{ : } );
else 
obj( idx ) = obj( idx ).setBlockParameter( arg );
end 
end 
return ;
elseif nargin == 4 && iscell( varargin{ 3 } )


if numel( obj ) ~= 1 && numel( varargin{ 3 } ) == numel( obj )

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setBlockParameter( varargin{ 1 }, varargin{ 2 },  ...
varargin{ 3 }{ idx } );
end 
return ;
else 

if numel( obj ) > 1
ME = MException( message( 'Simulink:Commands:SimInputAndValueCellDimsMismatch',  ...
numel( obj ), numel( varargin{ 3 } ),  ...
[ varargin{ 1 }, ': ', varargin{ 2 } ] ) );
obj.reportAsWarning( ME );

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setBlockParameter( varargin{ : } );
end 
return ;
end 
end 
elseif numel( obj ) > 1

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setBlockParameter( varargin{ : } );
end 
if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
return ;
end 

if isa( varargin{ 1 }, 'Simulink.Simulation.BlockParameter' )
blockParam = varargin{ 1 };
next = 2;
else 
narginchk( 4, inf );
try 
blockParam =  ...
Simulink.Simulation.BlockParameter( varargin{ 1:3 } );
catch ME
throwAsCaller( ME );
end 
next = 4;
end 



if obj.RapidAcceleratorUpToDateCheckOff
throwAsCaller( MException( message( 'Simulink:Commands:CannotSetBlockParamRapidAccelUpToDateCheckOff' ) ) );
end 


obj.validateBlockParameter( blockParam );
index = findBlockParameter( blockParam.BlockPath,  ...
blockParam.Name, obj.BlockParameters );
if isempty( index )
obj.ActualBlockParameters( end  + 1 ) = blockParam;
else 
obj.ActualBlockParameters( index ) = blockParam;
end 

if nargin > next
obj = obj.setBlockParameter( varargin{ next:end  } );
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function out = getBlockParameter( obj, blockPath, paramName )













try 
validateattributes( blockPath, { 'char', 'string' }, { 'scalartext', 'nonempty' } );
validateattributes( paramName, { 'char', 'string' }, { 'scalartext', 'nonempty' } );
blockParams = arrayfun( @( x )x.getBlockParameterI( blockPath, paramName ), obj );
catch ME
throwAsCaller( ME );
end 
if isscalar( blockParams )
out = blockParams.Value;
else 
out = { blockParams.Value };
end 
end 

function obj = setModelParameter( obj, varargin )










narginchk( 2, inf );
if ( nargin == 2 && iscell( varargin{ 1 } ) &&  ...
numel( varargin{ 1 } ) == numel( obj ) )

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setModelParameter( varargin{ 1 }{ idx } );
end 
return ;
elseif nargin == 3 && iscell( varargin{ 2 } )


if numel( obj ) ~= 1 && numel( varargin{ 2 } ) == numel( obj )

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setModelParameter( varargin{ 1 },  ...
varargin{ 2 }{ idx } );
end 
return ;
else 

if numel( obj ) > 1
ME = MException( message( 'Simulink:Commands:SimInputAndValueCellDimsMismatch',  ...
numel( obj ), numel( varargin{ 2 } ), varargin{ 1 } ) );
obj.reportAsWarning( ME );

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setModelParameter( varargin{ : } );
end 
return ;
end 
end 
elseif numel( obj ) > 1

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setModelParameter( varargin{ : } );
end 
if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
return ;
end 
if isa( varargin{ 1 }, 'Simulink.Simulation.ModelParameter' )
modelParam = varargin{ 1 };
next = 2;
else 
narginchk( 3, inf );
modelParam = Simulink.Simulation.ModelParameter( varargin{ 1:2 } );
next = 3;
end 

try 
if strcmpi( modelParam.Name, 'RapidAcceleratorUpToDateCheck' )
switch lower( modelParam.Value )
case 'off'




if ~isempty( obj.ActualBlockParameters )
error( message( 'Simulink:Commands:SimInputRapidAcceleratorUpToDateCheck' ) );
end 

varWorkspaces = arrayfun( @( x )convertStringsToChars( x.Workspace ), obj.ActualVariables,  ...
'UniformOutput', false );

globalWorkspaceIndices =  ...
strcmp( 'global-workspace', varWorkspaces );

topModelWorkspaceIndices =  ...
strcmp( obj.ModelName, varWorkspaces );

if ~all( xor( globalWorkspaceIndices, topModelWorkspaceIndices ) )
error( message( 'Simulink:Commands:SimInputRapidAcceleratorUpToDateCheckModelWksp' ) );
end 
obj.RapidAcceleratorUpToDateCheckOff = true;

case 'on'
obj.RapidAcceleratorUpToDateCheckOff = false;

otherwise 
error( message( 'Simulink:Engine:InvRapidAccelUpdateCheckOpt' ) );
end 
end 

if modelParam.IsReadOnly
DAStudio.error(  ...
'Simulink:Commands:SimInputReadOnlyModelParam',  ...
modelParam.Name );
else 

obj.validateModelParameter( modelParam );
index = findModelParameter( modelParam.Name,  ...
obj.ModelParameters );
if isempty( index )
obj.ActualModelParameters( end  + 1 ) = modelParam;
else 
obj.ActualModelParameters( index ) = modelParam;
end 
end 
catch ME
throwAsCaller( ME );
end 

if nargin > next
obj = obj.setModelParameter( varargin{ next:end  } );
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function out = getModelParameter( obj, paramName )












try 
validateattributes( paramName, { 'char', 'string' }, { 'scalartext', 'nonempty' } );
modelParams = arrayfun( @( x )x.getModelParameterI( paramName ), obj );
catch ME
throwAsCaller( ME );
end 
if isscalar( modelParams )
out = modelParams.Value;
else 
out = { modelParams.Value };
end 
end 

function obj = removeModelParameter( obj, varargin )









narginchk( 2, inf );
if ( nargin == 2 && iscell( varargin{ 1 } ) &&  ...
numel( varargin{ 1 } ) == numel( obj ) )
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).removeModelParameter( varargin{ 1 }{ idx } );
end 
return ;
elseif numel( obj ) > 1
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).removeModelParameter( varargin{ : } );
end 
return ;
end 

if isnumeric( varargin{ 1 } )
if ( nargin > 2 )
DAStudio.error( 'Simulink:Commands:SimInputRemoveIndexArgs' );
end 
removeIdx = varargin{ 1 };
else 
removeIdx = findModelParameter( varargin{ 1 },  ...
obj.ModelParameters );
if isempty( removeIdx )
DAStudio.error(  ...
'Simulink:Commands:SimInputModelParamNotFound',  ...
varargin{ 1 } );
end 
end 
modelParamName = obj.ModelParameters( removeIdx ).Name;
if strcmpi( modelParamName, "RapidAcceleratorUpToDateCheck" )
obj.RapidAcceleratorUpToDateCheckOff = false;
end 
obj.ModelParameters( removeIdx ) = [  ];

if nargin > 2
if isnumeric( varargin{ 2 } )
DAStudio.error(  ...
'Simulink:Commands:SimInputInvalidRemoveIndexSyntax' );
end 
obj = obj.removeModelParameter( varargin{ 2:end  } );
end 
end 

function obj = removeBlockParameter( obj, varargin )









narginchk( 2, inf );
if ( nargin == 2 && iscell( varargin{ 1 } ) &&  ...
numel( varargin{ 1 } ) == numel( obj ) )
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).removeBlockParameter( varargin{ 1 }{ idx } );
end 
return ;
elseif numel( obj ) > 1
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).removeBlockParameter( varargin{ : } );
end 
return ;
end 
if isnumeric( varargin{ 1 } )
if ( nargin > 2 )
DAStudio.error( 'Simulink:Commands:SimInputRemoveIndexArgs' );
end 
obj.BlockParameters( varargin{ 1 } ) = [  ];
else 
narginchk( 3, inf );
index = findBlockParameter( varargin{ 1:2 },  ...
obj.BlockParameters );
if ~isempty( index )
obj.BlockParameters( index ) = [  ];
else 
DAStudio.error(  ...
'Simulink:Commands:SimInputBlockParamNotFound',  ...
varargin{ 1:2 } );
end 
end 
if nargin > 3
if isnumeric( varargin{ 3 } )
DAStudio.error(  ...
'Simulink:Commands:SimInputInvalidRemoveIndexSyntax' );
end 
obj = obj.removeBlockParameter( varargin{ 3:end  } );
end 
end 

function obj = loadVariablesFromMATFile( obj, matfile, options )












R36
obj
matfile
options.Append( 1, 1 )matlab.lang.OnOffSwitchState = "off"
end 

if iscell( matfile ) && numel( matfile ) == numel( obj )
for idx = 1:numel( obj )
vars = structToVariables( load( matfile{ idx } ) );
obj( idx ) = obj( idx ).setOrAppendVariables( vars,  ...
"Append", options.Append );
end 
else 
vars = structToVariables( load( matfile ) );
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setOrAppendVariables( vars,  ...
"Append", options.Append );
end 
end 
end 


function obj = loadVariablesFromExternalSource( obj, externalSource, options )











































R36
obj( 1, 1 )
externalSource{ mustBeTextScalar }
options.Section{ mustBeText, mustBeVector }
options.Workspace{ mustBeTextScalar } = 'global-workspace'
options.Context{ mustBeTextScalar } = ''
options.Append( 1, 1 )matlab.lang.OnOffSwitchState = "off"
end 

if slfeature( 'SimInputLoadVarFromExternalFile' ) < 1
assert( false, 'loadVariablesFromExternalFile not supported.' );
end 



if ~strcmp( options.Context, '' ) && ~strcmp( options.Workspace, 'global-workspace' )
throwAsCaller( MException( message( 'Simulink:Commands:SimInputInvalidContext' ) ) );
end 


[ path, name, ext ] = fileparts( externalSource );
if strcmpi( ext, '.mat' ) && strcmp( options.Workspace, 'global-workspace' ) ...
 && strcmp( options.Context, '' ) && ~isfield( options, 'Section' )
obj = obj.loadVariablesFromMATFile( fullfile( path, name ), "Append", options.Append );
return ;
end 

namedArgsCell = namedargs2cell( options );
vars = getVariablesFromExternalSource( externalSource, namedArgsCell{ : } );
obj = obj.setOrAppendVariables( vars, "Append", options.Append );
end 

function obj = setVariable( obj, varargin )

























if ( nargin == 2 && iscell( varargin{ 1 } ) &&  ...
numel( varargin{ 1 } ) == numel( obj ) )
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setVariable( varargin{ 1 }{ idx } );
end 
return ;
elseif nargin == 3 && iscell( varargin{ 2 } )


if numel( obj ) ~= 1 && numel( varargin{ 2 } ) == numel( obj )

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setVariable( varargin{ 1 }, varargin{ 2 }{ idx } );
end 
return ;
else 

if numel( obj ) > 1
ME = MException( message( 'Simulink:Commands:SimInputAndValueCellDimsMismatch',  ...
numel( obj ), numel( varargin{ 2 } ), varargin{ 1 } ) );
obj.reportAsWarning( ME );

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setVariable( varargin{ : } );
end 
return ;
end 
end 
elseif numel( obj ) > 1
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).setVariable( varargin{ : } );
end 
if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
return ;
end 
try 
narginchk( 3, 7 );
obj = obj.setVariableOnScalarSimInput( varargin{ 1 }, varargin{ 2 }, varargin{ 3:end  } );
catch ME
throwAsCaller( ME );
end 

if nargout == 0
warning( message( 'Simulink:Commands:SimInputMissingLHS' ) );
end 
end 

function out = getVariable( obj, varName, varargin )
















p = inputParser;
addRequired( p, 'varName', @( x )validateattributes( x,  ...
{ 'char', 'string' }, { 'scalartext', 'nonempty' } ) );
addParameter( p, 'Workspace', '', @( x )validateattributes( x,  ...
{ 'char', 'string' }, { 'scalartext', 'nonempty' } ) );
addParameter( p, 'Context', '', @( x )validateattributes( x,  ...
{ 'char', 'string' }, { 'scalartext', 'nonempty' } ) );

try 
parse( p, varName, varargin{ : } );
vars = arrayfun( @( x )x.getVariableI( p.Results.varName, p.Results.Workspace, p.Results.Context ), obj );
catch ME
throwAsCaller( ME );
end 
if isscalar( vars )
out = vars.Value;
else 
out = { vars.Value };
end 
end 

function obj = removeVariable( obj, varargin )












narginchk( 2, inf );


if ( nargin == 2 && iscell( varargin{ 1 } ) &&  ...
numel( varargin{ 1 } ) == numel( obj ) )
for idx = 1:numel( obj )
obj( idx ) = obj( idx ).removeVariable( varargin{ 1 }{ idx } );
end 
return ;
elseif numel( obj ) > 1

for idx = 1:numel( obj )
obj( idx ) = obj( idx ).removeVariable( varargin{ : } );
end 
return ;
end 


if isnumeric( varargin{ 1 } )
if ( nargin > 2 )
DAStudio.error( 'Simulink:Commands:SimInputRemoveIndexArgs' );
end 
obj.Variables( varargin{ 1 } ) = [  ];
else 
obj = removeVariableFromList( obj, varargin{ 1 }, 'Variables', varargin{ 2:end  } );
end 
if nargin > 3
if isnumeric( varargin{ 3 } )
DAStudio.error(  ...
'Simulink:Commands:SimInputInvalidRemoveIndexSyntax' );
end 
obj = obj.removeVariable( varargin{ 3:end  } );
end 
end 

function validate( obj )





if numel( obj ) > 1
for idx = 1:numel( obj )
obj( idx ).validate;
end 
return ;
end 

if ( obj.ModelName == "" )
error( message( 'Simulink:Commands:SimInputEmptyModelName' ) );
end 

loadModelToRun( obj );
modelHandle = get_param( obj.ModelName, 'Handle' );



for i = 1:length( obj.ModelParameters )
modelParam = obj.ModelParameters( i );
modelParam.validate( modelHandle );
if modelParam.IsReadOnly
DAStudio.error( 'Simulink:Commands:SetParamReadOnly',  ...
'block_diagram', modelParam.Name );
end 
end 

for i = 1:length( obj.BlockParameters )
blockParam = obj.BlockParameters( i );
blockParam.validate;
end 
end 

function applyToModel( obj, options )


















R36
obj( 1, 1 )Simulink.SimulationInput
options.OpenModel( 1, 1 )matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off
options.EnableConfigSetRefUpdate( 1, 1 )matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off
options.ApplyHidden( 1, 1 )matlab.lang.OnOffSwitchState = matlab.lang.OnOffSwitchState.off
end 

if isdeployed
error( message( "Simulink:Commands:SimInputApplyToModelNotSupportedInDeployment" ) );
end 

obj.EnableConfigSetRefUpdate = false;

if options.EnableConfigSetRefUpdate
obj.EnableConfigSetRefUpdate = true;
end 

Simulink.Simulation.internal.loadModelForApply( obj.ModelName, obj.CreatedForRevert );
hasConfigSetRef = obj.modelIsUsingConfigSetRef(  );
obj = Simulink.Simulation.internal.processSimulationInputForRevert( obj,  ...
"ProcessHidden", options.ApplyHidden, "HasConfigSetRef", hasConfigSetRef );
if options.ApplyHidden
obj = Simulink.Simulation.internal.getSimulationInputWithHiddenParamsVisible( obj );
obj.applyPortParameters(  );
end 

obj = Simulink.Simulation.internal.removeSimOnlyParams( obj );
obj.applyExternalInput(  );
obj.applyModelParameters(  );
obj.applyBlockParameters(  );
obj.applyVariables(  );

if options.OpenModel
open_system( obj.ModelName );
end 
end 

function obj = set.LoggingSpecification( obj, logSpec )
if isempty( logSpec )
obj.LoggingSpecification =  ...
Simulink.Simulation.LoggingSpecification.empty(  );
elseif isa( logSpec,  ...
'Simulink.Simulation.LoggingSpecification' )
obj.LoggingSpecification = logSpec;
else 
DAStudio.error( 'Simulink:Commands:SimInputInvalidLoggingSpecObject' );
end 
end 

function out = struct( obj )%#ok<MANU>
out = struct;%#ok<NASGU> % Return an argument so we do not get 'too many output' error
err = MException( message( 'Simulink:Commands:SimInputCannotCreateStruct' ) );
throwAsCaller( err );
end 

function showContents( obj )



R36
obj( 1, 1 )Simulink.SimulationInput
end 

obj.summary(  );
end 

function obj = set.ImplicitRapidAcceleratorUpToDateCheckOff( obj, newVal )
if ( obj.RapidAcceleratorUpToDateCheckOff )
error( 'ImplicitRapidAcceleratorUpToDateCheckOff should not be set if it is explicitly off' );
end 
obj.ImplicitRapidAcceleratorUpToDateCheckOff = newVal;
end 

function obj = set.RapidAcceleratorUpToDateCheckOff( obj, newVal )
if isempty( newVal )




obj.RapidAcceleratorUpToDateCheckOff = false;
else 
obj.RapidAcceleratorUpToDateCheckOff = newVal;
end 
end 
end 

methods ( Access = protected )
function setParamObj = getSetParamObj( obj )



modelName = obj.ModelName;
Simulink.Simulation.internal.loadModelForApply( modelName, obj.CreatedForRevert );
configSet = getActiveConfigSet( modelName );

if isa( configSet, 'Simulink.ConfigSetRef' )
if ~obj.EnableConfigSetRefUpdate
error( message( 'Simulink:Commands:SimInputApplyOnConfigSetRef' ) );
end 
try 
setParamObj = configSet.getRefConfigSet(  );
catch ME
throwAsCaller( ME );
end 
else 
setParamObj = modelName;
end 
end 
end 

methods ( Access = private )

function reportPrePostFcnError( obj, ME, fcnName )
err = MException( message( 'Simulink:Commands:SimInputPrePostFcnError', fcnName ) );
msld = MSLDiagnostic( err );
msld = msld.addCause( MSLDiagnostic( ME ) );
msld.reportAsError( obj.ModelName, false );
end 

function verifyModelNamesAreValid( obj )
for simInput = obj
modelName = simInput.ModelName;
if ~isvarname( modelName )
error( message( 'Simulink:Commands:SimInputInvalidModelName', modelName ) );
end 
end 
end 

function isConfigSetRef = modelIsUsingConfigSetRef( obj )
if ~isdeployed
modelName = obj.getModelNameForApply(  );
configSet = getActiveConfigSet( modelName );
isConfigSetRef = isa( configSet, 'Simulink.ConfigSetRef' );
else 
isConfigSetRef = false;
end 
end 

function validateInitialState( obj )

simModeIndex = findModelParameter( 'SimulationMode', obj.ModelParameters );
if ~isempty( simModeIndex )
simMode = obj.ModelParameters( simModeIndex ).Value;
if startsWith( simMode, 'r', 'IgnoreCase', true )
if ( ~isempty( obj.ActualInitialState ) && ~isequal( class( obj.ActualInitialState ), 'struct' ) &&  ...
~isequal( class( obj.ActualInitialState ), 'Simulink.op.ModelOperatingPoint' ) &&  ...
~isequal( class( obj.ActualInitialState ), 'Simulink.SimulationData.Dataset' ) )
throwAsCaller( MException( message( 'Simulink:Commands:CannotSetInitialStateRapidAccelUpToDateCheckOff' ) ) );
end 
end 
end 
end 

function applyExternalInput( obj )

if ~isempty( obj.ExternalInput )

loadModelToRun( obj );
setParamObj = obj.getSetParamObj(  );
set_param( setParamObj, 'LoadExternalInput', 'on' );
if ischar( obj.ExternalInput )
extInpStr = obj.ExternalInput;
else 


extInpStr = [ 'extInput_', obj.ModelName ];
assignin( 'base', extInpStr, obj.ExternalInput );
end 
set_param( setParamObj, 'ExternalInput', extInpStr );
end 
end 

function applyModelParameters( obj )
setParamObj = obj.getSetParamObj(  );
modelParams = obj.ModelParameters;

for i = 1:length( modelParams )
modelParam = modelParams( i );
setParamObjToUse = setParamObj;
if isa( setParamObj, "Simulink.ConfigSet" ) && ~setParamObj.hasProp( modelParam.Name )
setParamObjToUse = obj.ModelName;
end 
set_param( setParamObjToUse, modelParam.Name, modelParam.Value );
end 
end 

function applyBlockParameters( obj )
Simulink.Simulation.internal.loadModelForApply( obj.ModelName, obj.CreatedForRevert );
blockParameters = obj.BlockParameters;

for i = 1:length( blockParameters )
blockParam = blockParameters( i );
set_param( blockParam.BlockPath, blockParam.Name, blockParam.Value );
end 
end 

function applyVariables( obj )
Simulink.Simulation.internal.applySimInputVariables( obj );
end 

function applyPortParameters( obj )
loadModelToRun( obj );

for portParam = obj.PortParameters
set_param( portParam.PortHandle, portParam.Name, portParam.Value );
end 
end 

function validateBlockParameter( obj, blockParam )

C = strsplit( blockParam.BlockPath, '/' );
if numel( C ) <= 1
error( message( 'Simulink:Commands:SimInputInvalidBlockPath', blockParam.BlockPath ) );
end 

if strcmpi( blockParam.Name, 'Name' )
err = MException( message( 'Simulink:Commands:SimInputBlockNameChangeNotAllowed' ) );
msld = MSLDiagnostic( err );
msld.reportAsError( obj.ModelName, false );
end 
end 

function validateModelParameter( obj, modelParam )

paramName = modelParam.Name;
switch lower( paramName )
case 'fastrestart'
if ~obj.ImplicitRapidAcceleratorUpToDateCheckOff
err = MException( message( 'Simulink:Commands:SimInputFastRestartModelParam' ) );
msld = MSLDiagnostic( err );
msld.reportAsError( obj.ModelName, false );
end 
case lower( obj.ModelName )
err = MException( message( 'Simulink:Commands:ParamUnknown', 'block_diagram', paramName ) );
msld = MSLDiagnostic( err );
msld.reportAsError( obj.ModelName, false );
end 
end 




function obj = addVariableToList( obj, varExpr, exprValue, varList, namedArgs )
R36
obj
varExpr
exprValue
varList
namedArgs.Workspace = 'global-workspace'
namedArgs.Context = ''
end 

namedArgsCell = namedargs2cell( namedArgs );
obj.errorOutIfUnsupportedVariableType( exprValue, namedArgs.Workspace );


[ varName, remain ] = strtok( varExpr, '{.(' );
try 


assert( length( namedArgsCell ) == 4 );
checkIfAddVarToBothGlobalAndSLDDWorkspace( varName, obj.Variables, namedArgsCell( 1:2 ) );
varIdx = findVariable( varName, obj.( varList ), namedArgs.Workspace, namedArgs.Context );
if ~isempty( varIdx )

varValue = obj.Variables( varIdx ).Value;

newVarValue = obj.DefaultSimulationInputHelper.modifyVariableValue(  ...
varName,  ...
varValue,  ...
varExpr,  ...
exprValue ...
 );
else 

if ~isempty( remain ) && remain ~= ""





wasResolved = false;
if strcmp( namedArgs.Workspace, 'global-workspace' ) && ~isempty( namedArgs.Context )
contextlessVarIdx = findVariable( varName, obj.( varList ), namedArgs.Workspace, '' );
if ~isempty( contextlessVarIdx )
varValue = obj.Variables( contextlessVarIdx ).Value;
wasResolved = true;
end 
end 
if wasResolved == false
[ varValue, wasResolved ] =  ...
obj.DefaultSimulationInputHelper.getVariableValue(  ...
obj.ModelName,  ...
varName, namedArgsCell{ : } );
end 
if wasResolved

newVarValue = obj.DefaultSimulationInputHelper.modifyVariableValue(  ...
varName,  ...
varValue,  ...
varExpr,  ...
exprValue ...
 );
else 


evalc( [ varExpr, '= exprValue' ] );
evalc( [ 'newVarValue = ', varName ] );
end 
else 

newVarValue = exprValue;
end 
end 
catch ME
throwAsCaller( ME );
end 







if strcmp( namedArgs.Workspace, 'global-workspace' )
if isempty( namedArgs.Context )

scopeMatchIdx = findVariable( varName, obj.( varList ), namedArgs.Workspace, false );
obj.Variables( scopeMatchIdx ) = [  ];

if isempty( obj.Variables )
obj.Variables = Simulink.Simulation.Variable.empty(  );
end 
else 

obj = removeVariableFromList( obj, varName, 'Variables', 'Workspace', namedArgs.Workspace, 'Context', namedArgs.Context );
end 
end 

simVar = Simulink.Simulation.Variable( varName, newVarValue,  ...
namedArgsCell{ : } );

obj.DefaultSimulationInputHelper.validateVariable( simVar, obj );

index = findVariable( simVar.Name, obj.( varList ), simVar.Workspace, simVar.Context );
if isempty( index )
obj.( varList )( end  + 1 ) = simVar;
else 
obj.( varList )( index ) = simVar;
end 
end 

function obj = removeVariableFromList( obj, varName, varList, varargin )
p = inputParser;
addRequired( p, 'varName', @ischar );
addRequired( p, 'varList', @ischar );
addParameter( p, 'Workspace', '', @ischar );
addParameter( p, 'Context', '', @ischar );
parse( p, varName, varList, varargin{ : } );
index = findVariable( p.Results.varName, obj.( p.Results.varList ),  ...
p.Results.Workspace, p.Results.Context );
obj.( p.Results.varList )( index ) = [  ];


if isempty( obj.( p.Results.varList ) )
obj.( p.Results.varList ) = Simulink.Simulation.Variable.empty(  );
end 
end 

function cleanup( obj )
obj.cleanupLogging(  );
end 

function checkForDuplicateExternalInputsSpecification( obj )
if ~isempty( obj.ExternalInput ) &&  ...
( ~isempty( findModelParameter( 'LoadExternalInput', obj.ModelParameters ) ) ||  ...
~isempty( findModelParameter( 'ExternalInput', obj.ModelParameters ) ) )
DAStudio.error( 'Simulink:Commands:SimInputRepeatedExternalInputSpec' );
end 
end 

function obj = prepareForRapidAcceleratorUpToDateCheckOffSim( obj )
obj = handleRapidAcceleratorParameters( obj );
end 

function obj = handleRapidAcceleratorParameters( obj, config )



R36
obj
config.SimHelper( 1, 1 )Simulink.Simulation.internal.SimHelper = Simulink.SimulationInput.DefaultSimHelper
end 



paramIdx = findModelParameter( 'RapidAcceleratorParameterSets', obj.ModelParameters );
if ~isempty( paramIdx )
rtp = obj.ModelParameters( paramIdx ).Value;
else 
rtp = [  ];
end 

obj = config.SimHelper.tuneParametersForRapidAccelerator( obj, rtp );
end 

function bp = getBlockParameterI( obj, blockPath, paramName )


index = findBlockParameter( blockPath, paramName, obj.BlockParameters );
if isempty( index )
error( message( 'Simulink:Commands:SimInputParamUnknown',  ...
paramName ) );
else 
bp = obj.BlockParameters( index );
end 
end 

function mp = getModelParameterI( obj, paramName )

index = findModelParameter( paramName, obj.ModelParameters );
if isempty( index )
error( message( 'Simulink:Commands:SimInputParamUnknown',  ...
paramName ) );
else 
mp = obj.ModelParameters( index );
end 
end 

function varObj = getVariableI( obj, varName, workspace, context )


if ( nargin == 2 )
workspace = '';
context = '';
elseif ( nargin == 3 )
context = '';
end 

index = findVariable( varName, obj.Variables, workspace, context );
if isempty( index )
error( message( 'Simulink:Commands:SimInputVarUnknown',  ...
varName ) );
elseif ~isscalar( index )
error( message( 'Simulink:Commands:SimInputMultipleVars',  ...
varName, strjoin( { obj.Variables( index ).Workspace }, ', ' ), strjoin( { obj.Variables( index ).Context }, ', ' ) ) );
else 
varObj = obj.Variables( index );
end 
end 

function TF = isErrorCaptured( obj )
TF = false;

modelParamProperty = 'HiddenModelParameters';
index = findModelParameter( 'CaptureErrors', obj.( modelParamProperty ) );

if isempty( index )
modelParamProperty = 'ModelParameters';
index = findModelParameter( 'CaptureErrors', obj.( modelParamProperty ) );
end 

if ~isempty( index )
modelParam = obj.( modelParamProperty )( index );
if strcmpi( modelParam.Value, 'on' )
TF = true;
end 
end 
end 

function obj = enforceReturnWorkspaceOutputsIsOn( obj )


index = findModelParameter( "ReturnWorkspaceOutputs", obj.ModelParameters );
if ~isempty( index )
modelParam = obj.ModelParameters( index );
paramValue = modelParam.Value;
if strcmpi( paramValue, "off" )
obj.ModelParameters( index ) = [  ];
warning( message( "Simulink:Commands:SimInputReturnWorkspaceOutputsChangedToOn" ) );
end 
end 
end 

function obj = setOrAppendVariables( obj, vars, options )
R36
obj( 1, 1 )Simulink.SimulationInput
vars Simulink.Simulation.Variable
options.Append( 1, 1 )matlab.lang.OnOffSwitchState = "off"
end 

for varIdx = 1:numel( vars )
obj.errorOutIfUnsupportedVariableType( vars( varIdx ).Value, vars( varIdx ).Workspace );
end 

if options.Append
obj.Variables = [ obj.Variables, vars ];
else 
obj.Variables = vars;
end 
end 

function obj = setVariableOnScalarSimInput( obj, varName, varValue, namedargs )
R36
obj( 1, 1 )Simulink.SimulationInput
varName{ mustBeTextScalar }
varValue
namedargs.Workspace = 'global-workspace'
namedargs.Context = ''
end 





if obj.RapidAcceleratorUpToDateCheckOff
varWorkspace = namedargs.Workspace;
if ~strcmp( 'global-workspace', varWorkspace ) &&  ...
~strcmp( obj.ModelName, varWorkspace )
if ~obj.ImplicitRapidAcceleratorUpToDateCheckOff
error( message( 'Simulink:Commands:CannotSetModelWkspVarRapidAccelUpToDateCheckOff' ) );
end 
end 
end 



if ~strcmp( namedargs.Context, '' ) && ~strcmp( namedargs.Workspace, 'global-workspace' )
throwAsCaller( MException( message( 'Simulink:Commands:SimInputInvalidContext' ) ) );
end 

namedargsCell = namedargs2cell( namedargs );
obj = addVariableToList( obj, varName, varValue, 'ActualVariables',  ...
namedargsCell{ : } );
end 

function errorOutIfUnsupportedVariableType( obj, varValue, varWorkspace )
if isa( varValue, 'Simulink.Variant' )
err = MException( message( 'Simulink:Commands:SimInputSimulinkVariantNotSupported' ) );
msld = MSLDiagnostic( err );
msld.reportAsError( obj.ModelName, false );
end 

if isa( varValue, 'Simulink.ConfigSet' ) ||  ...
isa( varValue, 'Simulink.ConfigSetRef' )
err = MException( message( 'Simulink:Commands:SimInputVarTypeNotSupported', class( varValue ) ) );
msld = MSLDiagnostic( err );
msld.reportAsError( obj.ModelName, false );
end 


if isa( varValue, 'Simulink.Bus' ) &&  ...
~strcmp( varWorkspace, 'global-workspace' ) && ~endsWith( varWorkspace, '.sldd' )
error( message( 'Simulink:Data:BusObjectInModelWorkspace' ) );
end 
end 
end 

methods ( Hidden = true )
function loadModelToRun( obj )
if ~isdeployed
load_system( obj.ModelName );
end 
end 

function name = validateModelNames( obj, name )
if nargin == 1
name = obj( 1 ).ModelName;
end 
for idx = 1:numel( obj )
if ( ~isvarname( obj( idx ).ModelName ) ||  ...
~strcmp( name, obj( idx ).ModelName ) )
DAStudio.error(  ...
'Simulink:Commands:DifferentModelsInArrayOfSimInput' );
end 
end 
end 

function obj = executePreLoadFcn( obj )

if ~isempty( obj.PreLoadFcn )
try 
obj.PreLoadFcn(  );
catch ME
obj.reportPrePostFcnError( ME, 'PreLoadFcn' );
end 
end 
end 

function out = executePostSimFcn( obj, simOut )



out = simOut;


loadIntoMemory( out );


if ~isempty( obj.PostSimFcn )
oldMStackValue = diagnostic_stacks_handlers( 'm_stack', true );
restoreMStackValue = onCleanup( @(  )diagnostic_stacks_handlers( 'm_stack', oldMStackValue ) );
try 
try 
postSimOut = obj.PostSimFcn( simOut );
validateattributes( postSimOut, { 'struct', 'Simulink.SimulationOutput' }, { 'scalar' } );
if isstruct( postSimOut )
md = simOut.SimulationMetadata;
out = Simulink.SimulationOutput( postSimOut );
out = out.setMetadata( md );
else 
out = postSimOut;
end 
catch ME
if ~strcmp( ME.identifier, 'MATLAB:maxlhs' ) &&  ...
~strcmp( ME.identifier, 'MATLAB:TooManyOutputs' )
rethrow( ME );
end 


obj.PostSimFcn( simOut );
out = simOut;
end 
catch ME
obj.reportPrePostFcnError( ME, 'PostSimFcn' );
end 
end 
end 

function obj = setLoggingSpecification( obj, loggingSpec )
if iscell( loggingSpec ) && numel( loggingSpec ) == numel( obj )
for idx = 1:numel( obj )
obj( idx ).LoggingSpecification = loggingSpec{ idx };
end 
else 
for idx = 1:numel( obj )
obj( idx ).LoggingSpecification = loggingSpec;
end 
end 
end 

function obj = cleanupLogging( obj )
if numel( obj ) > 1
for idx = 1:numel( obj )
obj( idx ).cleanupLogging(  );
end 
return ;
end 

if obj.NeedsCleanupLogging

obj.PortParameters = Simulink.Simulation.PortParameter.empty(  );

sigs = obj.LoggingSpecification.SignalsToLog;
if ~isempty( sigs )

obj.removeHiddenModelParameter( 'DataLoggingOverride' );
obj.removeHiddenModelParameter( 'SignalLogging' );
obj.removeHiddenModelParameter( 'SignalLoggingSaveFormat' );
end 
obj.NeedsCleanupLogging = false;
end 
end 

function isLTF = isLTFSetToOn( obj )

isLTF = isequal( get_param( obj.ModelName, 'LoggingToFile' ), 'on' );



paramIdx = findModelParameter( 'LoggingToFile', obj.ModelParameters );
if ~isempty( paramIdx )
isLTF = isequal( obj.ModelParameters( paramIdx ).Value, 'on' );
end 
end 

function fName = getLTFName( obj, varargin )

paramIdx = findModelParameter( 'LoggingFileName', obj.ModelParameters );
if ~isempty( paramIdx )
fName = obj.ModelParameters( paramIdx ).Value;
else 
fName = get_param( obj.ModelName, 'LoggingFileName' );
end 
end 

function fName = getToFileName( obj, bPath )
paramIdx = findBlockParameter( bPath,  ...
'Filename',  ...
obj.BlockParameters );
if ~isempty( paramIdx )
fName = obj.BlockParameters( paramIdx ).Value;
else 
fName = get_param( bPath, 'Filename' );
end 
end 

function obj = setPortParameter( obj, varargin )
narginchk( 2, 4 );
if nargin == 2 &&  ...
isa( varargin{ 1 }, 'Simulink.Simulation.PortParameter' )
obj.PortParameters( end  + 1 ) = varargin{ 1 };
else 
obj.PortParameters( end  + 1 ) =  ...
Simulink.Simulation.PortParameter( varargin{ : } );
end 
end 

function obj = removePortParameter( obj, ph, paramName )
index = findPortParameter( ph, paramName, obj.PortParameters );
if ~isempty( index )
if length( obj.PortParameters ) == 1

assert( index == 1 );
obj.PortParameters = Simulink.Simulation.PortParameter.empty(  );
else 
obj.PortParameters( index ) = [  ];
end 
else 
DAStudio.error( 'Simulink:Commands:SimInputPortParamNotFound', ph, paramName );
end 
end 

function obj = addHiddenModelParameter( obj, varargin )
narginchk( 2, 3 );
if nargin == 2 &&  ...
isa( varargin{ 1 }, 'Simulink.Simulation.ModelParameter' )
modelParam = varargin{ 1 };
else 
modelParam = Simulink.Simulation.ModelParameter( varargin{ : } );
end 
paramIdx = findModelParameter( modelParam.Name,  ...
obj.HiddenModelParameters );
if isempty( paramIdx )
obj.HiddenModelParameters( end  + 1 ) = modelParam;
else 
obj.HiddenModelParameters( paramIdx ) = modelParam;
end 
end 

function obj = removeHiddenModelParameter( obj, paramName )
index = findModelParameter( paramName, obj.HiddenModelParameters );
if ~isempty( index )
if length( obj.HiddenModelParameters ) == 1

assert( index == 1 );
obj.HiddenModelParameters = Simulink.Simulation.ModelParameter.empty(  );
else 
obj.HiddenModelParameters( index ) = [  ];
end 
else 
DAStudio.error(  ...
'Simulink:Commands:SimInputModelParamNotFound', paramName );
end 
end 

function obj = addHiddenBlockParameter( obj, varargin )
narginchk( 2, 4 );
blockParam = Simulink.Simulation.BlockParameter( varargin{ : } );
paramIdx = findBlockParameter( blockParam.BlockPath,  ...
blockParam.Name, obj.HiddenBlockParameters );
if isempty( paramIdx )
obj.HiddenBlockParameters( end  + 1 ) = blockParam;
else 
obj.HiddenBlockParameters( paramIdx ) = blockParam;
end 
end 

function obj = addHiddenVariable( obj, fullName, varValue, varargin )
obj = addVariableToList( obj, fullName, varValue, 'HiddenVariables',  ...
varargin{ : } );
end 

function obj = removeHiddenVariable( obj, fullName, varargin )
obj = removeVariableFromList( obj, fullName, 'HiddenVariables',  ...
varargin{ : } );
end 

function out = sim( obj, varargin, config )
R36
obj
end 

R36( Repeating )
varargin
end 

R36
config.SimHelper( 1, 1 )Simulink.Simulation.internal.SimHelper = Simulink.SimulationInput.DefaultSimHelper
end 


try 
try 

[ varargin{ : } ] = convertStringsToChars( varargin{ : } );

if isempty( obj )
err = MException( message( 'Simulink:Commands:EmptySimInputArray' ) );
msld = MSLDiagnostic( err );


msld.reportAsError( '', false );
end 

obj.verifyModelNamesAreValid(  );

config.SimHelper.doPreSimulationChecks( obj );

if numel( obj ) > 1 || nargin > 1
out = config.SimHelper.runUsingManager( obj, varargin{ : } );
else 
assert( isscalar( obj ), 'sim: SimulationInput object must be a scalar' );
obj.executePreLoadFcn(  );
obj = config.SimHelper.doPreSimulationSetup( obj );
try 
try 
if ~isempty( obj.LoggingSetupFcn )
obj = obj.LoggingSetupFcn( obj );
end 
hasConfigSetRef = obj.modelIsUsingConfigSetRef(  );
obj = Simulink.Simulation.internal.processSimulationInputForRevert( obj,  ...
"ProcessHidden", "on", "HasConfigSetRef", hasConfigSetRef );
obj.validateInitialState(  );
obj.checkForDuplicateExternalInputsSpecification(  );

if obj.RapidAcceleratorUpToDateCheckOff
obj = prepareForRapidAcceleratorUpToDateCheckOffSim( obj );
end 
obj = obj.enforceReturnWorkspaceOutputsIsOn(  );
out = config.SimHelper.sim( obj );
catch ME
if obj.isErrorCaptured(  )
out = config.SimHelper.captureErrorInSimulationOutput( ME, obj );
else 
throw( ME );
end 
end 
out = obj.executePostSimFcn( out );
config.SimHelper.executePostSimTasksOnSuccess( obj );
catch ME
config.SimHelper.executePostSimTasksOnFailure( obj );
throw( ME );
end 
end 
catch ME
throwAsCaller( ME )
end 
catch ME
throwAsCaller( ME );
end 
end 


function reportAsWarning( obj, ME )

warnState = warning( 'query', 'backtrace' );
oc = onCleanup( @(  )warning( warnState ) );
warning off backtrace;
if ~isscalar( obj )

modelName = obj( 1 ).ModelName;
else 
modelName = obj.ModelName;
end 
msld = MSLDiagnostic( ME );
msld.reportAsWarning( modelName, false );
end 

function TF = isCoverageEnabled( obj )

TF = SlCov.CoverageAPI.isSimInputCoverageOn( obj );
end 

function val = get_param( obj, paramName )

paramIdx = findModelParameter( paramName, obj.ModelParameters );
if ~isempty( paramIdx )
val = obj.ModelParameters( paramIdx ).Value;
else 
val = get_param( obj.ModelName, paramName );
end 
end 

function summary( obj )






MultiSim.internal.SimulationInputSummarizer.summarize( obj );
end 

function simIn = constructDefaultObject( obj )
simIn = Simulink.SimulationInput( obj.ModelName );
end 

function modelName = getModelNameForApply( obj )
modelName = obj.ModelName;
end 

function contents( obj )






R36
obj( 1, 1 )Simulink.SimulationInput
end 

obj.summary(  );
end 
end 
end 

function index = findPortParameter( ph, param, paramList )
if isempty( paramList )
index = [  ];
else 
paramPortHandles = find( [ paramList.PortHandle ] == ph );
paramNames = { paramList.Name };
flags = strcmpi( paramNames, param );
namesIndex = find( flags == 1 );
index = intersect( paramPortHandles, namesIndex );
end 
end 

function index = findModelParameter( param, paramList )
if isempty( paramList )
index = [  ];
else 
paramNames = string( { paramList.Name } );
flags = strcmpi( paramNames, param );
index = find( flags == 1 );
assert( length( index ) <= 1 );
end 
end 

function index = findBlockParameter( blockPath, paramName, paramList )
index = [  ];
if isempty( paramList )
return ;
else 
assert( ~isempty( blockPath ) );
blockPaths = string( { paramList.BlockPath } );
flags = strcmp( blockPaths, blockPath );
blockPathIdx = find( flags == 1 );


if isempty( blockPathIdx ), return ;end 


paramNames = string( { paramList.Name } );
flags = strcmpi( paramNames, paramName );
nameIdx = find( flags == 1 );
if isempty( nameIdx ), return ;end 


index = intersect( blockPathIdx, nameIdx );
assert( length( index ) <= 1 );
end 
end 

function checkIfAddVarToBothGlobalAndSLDDWorkspace( varName, varList, workspaceArgs )
R36
varName string{ mustBeNonempty }
varList
workspaceArgs( 1, 2 )string
end 
targetWorkspace = workspaceArgs{ 2 };
if ~strcmp( targetWorkspace, 'global-workspace' ) && ~endsWith( targetWorkspace, '.sldd' )
return ;
end 
vars = string( { varList.Name } );
flags = strcmp( vars, varName );
varIdxWithSameName = find( flags == 1 );
if isempty( varIdxWithSameName )
return ;
else 



for idx = 1:length( varIdxWithSameName )
workspace = varList( idx ).Workspace;
if ( strcmp( targetWorkspace, 'global-workspace' ) && endsWith( workspace, '.sldd' ) ) ||  ...
( endsWith( targetWorkspace, '.sldd' ) && strcmp( workspace, 'global-workspace' ) )
error( message( 'Simulink:Commands:CannotAddVariableToBothGlobalAndSLDDWsp',  ...
varName ) );
end 
end 
end 
end 

function index = findVariable( varName, varList, scope, context )
index = [  ];
if isempty( varList )
return ;
else 
if nargin == 2
scope = '';
context = '';
elseif nargin == 3
context = '';
end 
assert( ~isempty( varName ) );
vars = string( { varList.Name } );
flags = strcmp( vars, varName );
varIdx = find( flags == 1 );

index = varIdx;
if isempty( index ), return ;end 


if ~isempty( scope )
scopes = string( { varList.Workspace } );
flags = strcmp( scopes, scope );
scopeIdx = find( flags == 1 );
index = intersect( index, scopeIdx );
end 
if isempty( index ), return ;end 



if ( context == false ), return ;end 

contexts = string( { varList.Context } );
flags = strcmp( contexts, context );
contextIdx = find( flags == 1 );
index = intersect( index, contextIdx );
end 
end 

function out = structToVariables( s )
out = Simulink.Simulation.Variable.empty(  );
if isa( s, 'struct' )
varNames = fields( s );
for idx = 1:numel( varNames )
out( end  + 1 ) = Simulink.Simulation.Variable( varNames{ idx },  ...
s.( varNames{ idx } ) );
end 
else 

end 
end 

function vars = getVariablesFromExternalSource( externalSource, options )
R36
externalSource
options.Section
options.Workspace
options.Context
options.Append
end 

vars = Simulink.Simulation.Variable.empty(  );

namedArgs = {  };
if isfield( options, 'Section' )
namedArgs = { 'Section', options.Section };
end 
try 
da = Simulink.data.DataAccessor.createForOutputData( externalSource, namedArgs{ : } );
catch ME
throwAsCaller( ME );
end 

varIds = da.identifyVisibleVariables(  );
for idx = 1:numel( varIds )



value = da.getVariable( varIds( idx ) );
vars( end  + 1 ) = Simulink.Simulation.Variable( varIds( idx ).Name,  ...
value, 'Workspace', options.Workspace, 'Context', options.Context );%#ok<*AGROW>
end 
end 

function mustBeValidModelName( modelName )
if ~( ( ischar( modelName ) && ( isrow( modelName ) || isempty( modelName ) ) ) ...
 || isStringScalar( modelName ) )
throwAsCaller( MException( message( 'Simulink:Commands:InvModelParam' ) ) );
end 
end 

function hiddenParams = getDefaultHiddenModelParams(  )

hiddenParam1 = Simulink.Simulation.ModelParameter( 'ReturnWorkspaceOutputs', 'on' );



hiddenParam2 = Simulink.Simulation.ModelParameter( 'ReturnDatasetRefInSimOut', 'on' );

hiddenParams = [ hiddenParam1, hiddenParam2 ];
end 














% Decoded using De-pcode utility v1.2 from file /tmp/tmpOEHHNp.p.
% Please follow local copyright laws when handling this file.

