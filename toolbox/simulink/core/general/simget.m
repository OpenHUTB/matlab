function varargout = simget( varargin )




































OptionsStructure = simset;
FieldNames = fieldnames( OptionsStructure );

switch nargin, 
case 0, 
varargout{ 1 } = OptionsStructure;

case 1, 

if isstruct( varargin{ 1 } ), 
varargout{ 1 } = LocalGetEmptyFields( varargin{ 1 }, FieldNames );

else 
try 
varargout{ 1 } = LocalGetOptionsStructure( varargin{ 1 } );
catch e
throw( e );
end 
end 
case 2, 
if isstruct( varargin{ 1 } ), 
Options = varargin{ 1 };
else 
try 
Options = LocalGetOptionsStructure( varargin{ 1 } );
catch e
throw( e );
end 
end 
if ~iscell( varargin{ 2 } ), 
Name = varargin( 2 );
else 
Name = varargin{ 2 };
end 

Names = lower( char( FieldNames ) );
TempOut = [  ];
for CellLp = 1:length( Name ), 
TempName = lower( Name{ CellLp } );
Loc = strmatch( TempName, Names );
if isempty( Loc ), 
DAStudio.error( 'Simulink:util:UnrecognizedOption', TempName, 'SIMSET' );
elseif length( Loc ) > 1, 

TempLoc = strmatch( TempName, Names, 'exact' );
if length( TempLoc ) == 1, 
Loc = TempLoc;
else 
DAStudio.error( 'Simulink:util:AmbiguousOption', name, 'SIMSET' );
end 
end 


if length( Name ) == 1, 
TempOut = Options.( FieldNames{ Loc } );


else 
TempOut{ CellLp } = Options.( FieldNames{ Loc } );%#ok<AGROW>
end 
end 
varargout{ 1 } = TempOut;
end 




function [ Struct ] = LocalGetOptionsStructure( ModelName )

OpenFlag = 1;
ErrorFlag = isempty( find_system( 0, 'flat', 'CaseSensitive', 'off', 'Name', ModelName ) );
if ErrorFlag, 
ErrorFlag = ~( exist( ModelName ) == 4 );%#ok<EXIST>
if ~ErrorFlag, 
OpenFlag = 0;
load_system( ModelName );
end 
end 
if ErrorFlag, 
DAStudio.error( 'Simulink:util:ModelNameRequired', ModelName );
end 

Struct = simset;
ErrorString = {  };



ErrorString = LocalGetVal( ModelName, 'StartTime', ErrorString );
ErrorString = LocalGetVal( ModelName, 'StopTime', ErrorString );

Struct.Solver = get_param( ModelName, 'Solver' );

Struct.RelTol = get_param( ModelName, 'RelTol' );
if strcmpi( Struct.RelTol, 'auto' ) == 0
[ ErrorString, Struct.RelTol ] = LocalGetVal( ModelName, 'RelTol', ErrorString );
end 

Struct.AbsTol = get_param( ModelName, 'AbsTol' );
if strcmpi( Struct.AbsTol, 'auto' ) == 0
[ ErrorString, Struct.AbsTol ] = LocalGetVal( ModelName, 'AbsTol', ErrorString );
end 

[ ErrorString, Struct.Refine ] = LocalGetVal( ModelName, 'Refine', ErrorString );

Struct.MaxStep = get_param( ModelName, 'MaxStep' );
if strcmpi( Struct.MaxStep, 'auto' ) == 0
[ ErrorString, Struct.MaxStep ] = LocalGetVal( ModelName, 'MaxStep', ErrorString );
end 

Struct.MinStep = get_param( ModelName, 'MinStep' );
if strcmpi( Struct.MinStep, 'auto' ) == 0
[ ErrorString, Struct.MinStep ] = LocalGetVal( ModelName, 'MinStep', ErrorString );
end 

[ ErrorString, Struct.MaxConsecutiveMinStep ] = LocalGetVal( ModelName, 'MaxConsecutiveMinStep', ErrorString );

Struct.InitialStep = get_param( ModelName, 'InitialStep' );
if strcmpi( Struct.InitialStep, 'auto' ) == 0
[ ErrorString, Struct.InitialStep ] =  ...
LocalGetVal( ModelName, 'InitialStep', ErrorString );
end 

Struct.MaxOrder = get_param( ModelName, 'MaxOrder' );

Struct.ConsecutiveZCsStepRelTol = get_param( ModelName, 'ConsecutiveZCsStepRelTol' );
if strcmpi( Struct.ConsecutiveZCsStepRelTol, 'auto' ) == 0
[ ErrorString, Struct.ConsecutiveZCsStepRelTol ] =  ...
LocalGetVal( ModelName, 'ConsecutiveZCsStepRelTol', ErrorString );
end 
[ ErrorString, Struct.MaxConsecutiveZCs ] = LocalGetVal( ModelName, 'MaxConsecutiveZCs', ErrorString );



Struct.FixedStep = get_param( ModelName, 'FixedStep' );
if strcmpi( Struct.FixedStep, 'auto' ) == 0
[ ErrorString, Struct.FixedStep ] =  ...
LocalGetVal( ModelName, 'FixedStep', ErrorString );
end 

switch get_param( ModelName, 'OutputOption' ), 
case 'RefineOutputTimes', 
Struct.OutputPoints = 'all';
case 'AdditionalOutputTimes', 
Struct.OutputPoints = 'all';
case 'SpecifiedOutputTimes', 
Struct.OutputPoints = 'specified';
end 

TTemp = get_param( ModelName, 'SaveTime' );
XTemp = get_param( ModelName, 'SaveState' );
YTemp = get_param( ModelName, 'SaveOutput' );
Val = '';
if TTemp( 2 ) == 'n', Val = [ Val, 't' ];end 
if XTemp( 2 ) == 'n', Val = [ Val, 'x' ];end 
if YTemp( 2 ) == 'n', Val = [ Val, 'y' ];end 
Struct.OutputVariables = Val;

if strcmp( get_param( ModelName, 'LimitDataPoints' ), 'off' ), 
Struct.MaxDataPoints = 0;
else 
[ ErrorString, Struct.MaxDataPoints ] =  ...
LocalGetVal( ModelName, 'MaxDataPoints', ErrorString );
end 

[ ErrorString, Struct.Decimation ] =  ...
LocalGetVal( ModelName, 'Decimation', ErrorString );

if strcmp( get_param( ModelName, 'LoadInitialState' ), 'off' ), 
Struct.InitialState = [  ];
else 
[ ErrorString, Struct.InitialState ] =  ...
LocalGetVal( ModelName, 'InitialState', ErrorString );
end 

if strcmp( get_param( ModelName, 'SaveFinalState' ), 'off' ), 
Struct.FinalStateName = '';
else 
Struct.FinalStateName = get_param( ModelName, 'FinalStateName' );
end 

Struct.Debug = 'off';
Struct.Trace = '';
Struct.SrcWorkspace = 'base';
Struct.DstWorkspace = 'current';
Struct.ZeroCross = get_param( ModelName, 'ZeroCross' );
Struct.SaveFormat = get_param( ModelName, 'SaveFormat' );
Struct.SignalLogging = get_param( ModelName, 'SignalLogging' );

if strcmp( Struct.SignalLogging, 'off' ), 
Struct.SignalLoggingName = '';
else 
Struct.SignalLoggingName = get_param( ModelName, 'SignalLoggingName' );
end 

Struct.ExtrapolationOrder = get_param( ModelName, 'ExtrapolationOrder' );
Struct.NumberNewtonIterations = get_param( ModelName, 'NumberNewtonIterations' );

if ~OpenFlag, close_system( ModelName, 0 );end 
if ~isempty( ErrorString ), 
ParamString = '';
ReturnChar = sprintf( '\n' );
for lp = 1:length( ErrorString ), 
ParamString = [ ParamString, '    ', ErrorString{ lp }, ReturnChar ];%#ok<AGROW>
end 
ParamString( end  ) = '';

DAStudio.error( 'Simulink:util:UndefinedVarsInSimGet', ParamString );
end 





function OptionsStructure = LocalGetEmptyFields( OptionsStructure, FieldNames )
for lp = 1:length( FieldNames ), 
if ~isfield( OptionsStructure, FieldNames{ lp } ), 
OptionsStructure.( FieldNames{ lp } ) = [  ];
end 
end 




function [ ErrorString, OutputVal ] = LocalGetVal( ModelName, Parameter, ErrorString )

OutputVal = Simulink.data.internal.evalConfigSetParam( ModelName, Parameter );
if ( isempty( OutputVal ) && ~isa( OutputVal, 'Simulink.SimState.ModelSimState' ) )
ErrorString{ end  + 1 } = Parameter;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpu8Wu4j.p.
% Please follow local copyright laws when handling this file.

