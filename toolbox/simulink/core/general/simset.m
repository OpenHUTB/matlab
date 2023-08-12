function options = simset( varargin )










































































































































































































if ( nargin == 0 ) && ( nargout == 0 )
slvrs = getSolversByParameter( 'SolverType', 'Variable Step', 'States', 'Discrete' );
fprintf( '                    Solver: [' );
for i = 1:length( slvrs )
fprintf( ' ''%s'' |', slvrs{ i } );
end 
fprintf( '\n' );
slvrs = getSolversByParameter( 'SolverType', 'Variable Step', 'States', 'Continuous' );
fprintf( '                             ' );
for i = 1:length( slvrs )
fprintf( ' ''%s'' |', slvrs{ i } );
end 
fprintf( '\n' );

slvrs = getSolversByParameter( 'SolverType', 'Fixed Step', 'States', 'Discrete' );
fprintf( '                             ' );
for i = 1:length( slvrs )
fprintf( ' ''%s'' |', slvrs{ i } );
end 
fprintf( '\n' );
slvrs = getSolversByParameter( 'SolverType', 'Fixed Step', 'States', 'Continuous' );
fprintf( '                             ' );
for i = 1:length( slvrs ) - 1
fprintf( ' ''%s'' |', slvrs{ i } );
end 
fprintf( ' ''%s'' ]\n', slvrs{ end  } );

fprintf( '                    RelTol: [ positive scalar {1e-3} ]\n' );
fprintf( '                    AbsTol: [ positive scalar {1e-6} ]\n' );
fprintf( '           AutoScaleAbsTol: [ ''on'' | {''off''} ]\n' );
fprintf( '                    Refine: [ positive integer {1} ]\n' );
fprintf( '                   MaxStep: [ positive scalar {auto} ]\n' );
fprintf( '                   MinStep: [ [positive scalar, nonnegative integer] {auto} ]\n' );
fprintf( '     MaxConsecutiveMinStep: [ positive integer >=1]\n' );
fprintf( '               InitialStep: [ positive scalar {auto} ]\n' );
fprintf( '                  MaxOrder: [ 1 | 2 | 3 | 4 | {5} ]\n' );
fprintf( '  ConsecutiveZCsStepRelTol: [ positive scalar {10*128*eps}]\n' );
fprintf( '         MaxConsecutiveZCs: [ positive integer >=1]\n' );
fprintf( '                 FixedStep: [ positive scalar {auto} ]\n' );

fprintf( '        ExtrapolationOrder: [ 1 | 2 | 3 | {4} ]\n' );
fprintf( '    NumberNewtonIterations: [ positive integer {1} ]\n' );

fprintf( '              OutputPoints: [ {''specified''} | ''all'' ]\n' );
fprintf( '           OutputVariables: [ {''txy''} | ''tx'' | ''ty'' | ''xy'' | ''t'' | ''x'' | ''y'' ]\n' );
fprintf( '                SaveFormat: [ {''Array''} | ''Structure'' | ''StructureWithTime'']\n' );
fprintf( '             MaxDataPoints: [ non-negative integer {0} ]\n' );
fprintf( '                Decimation: [ positive integer {1} ]\n' );
fprintf( '              InitialState: [ vector {[]} ]\n' );
fprintf( '            FinalStateName: [ string {''''} ]\n' );
fprintf( '                     Trace: [ comma separated list of ''minstep'', ''siminfo'', ''compile'', ''compilestats'' {''''}]\n' );
fprintf( '              SrcWorkspace: [ {''base''} | ''current'' | ''parent'' ]\n' );
fprintf( '              DstWorkspace: [ ''base'' | {''current''} | ''parent'' ]\n' );
fprintf( '                 ZeroCross: [ {''on''} | ''off'' ]\n' );
fprintf( '             SignalLogging: [ {''on''} | ''off'' ]\n' );
fprintf( '         SignalLoggingName: [ string {''''} ]\n' );
fprintf( '                     Debug: [ ''on'' | {''off''} ]\n' );
fprintf( '                   TimeOut: [ positive scalar {Inf} ]\n' );
fprintf( '      ConcurrencyResolvingToFileSuffix : [ string {''''} ]\n' );
fprintf( '                 ReturnWorkspaceOutputs: [ ''on'' | {''off''} ]\n' );
fprintf( '          RapidAcceleratorUpToDateCheck: [ ''on'' | {''off''} ]\n' );
fprintf( '          RapidAcceleratorParameterSets: [ ''Structure'' ]\n' );
fprintf( '\n' );
return ;
end 

Names = { 
'AbsTol'
'AutoScaleAbsTol'
'Debug'
'Decimation'
'DstWorkspace'
'FinalStateName'
'FixedStep'
'InitialState'
'InitialStep'
'MaxOrder'
'ConsecutiveZCsStepRelTol'
'MaxConsecutiveZCs'
'SaveFormat'
'MaxDataPoints'
'MaxStep'
'MinStep'
'MaxConsecutiveMinStep'
'OutputPoints'
'OutputVariables'
'Refine'
'RelTol'
'Solver'
'SrcWorkspace'
'Trace'
'ZeroCross'
'SignalLogging'
'SignalLoggingName'
'ExtrapolationOrder'
'NumberNewtonIterations'
'TimeOut'
'ConcurrencyResolvingToFileSuffix'
'ReturnWorkspaceOutputs'
'RapidAcceleratorUpToDateCheck'
'RapidAcceleratorParameterSets'
 };
m = size( Names, 1 );
names = lower( char( Names ) );


options = [  ];
for j = 1:m
options.( Names{ j } ) = [  ];
end 
i = 1;
while i <= nargin
arg = varargin{ i };
if ischar( arg )
break ;
end 
if ~isempty( arg )
if ~isa( arg, 'struct' )
DAStudio.error( 'Simulink:util:NotExpectedSimSetArgument', i );
end 
for j = 1:m
if any( strcmp( fieldnames( arg ), deblank( Names{ j } ) ) )
val = arg.( Names{ j } );
else 
val = [  ];
end 
if ~isempty( val )
options.( Names{ j } ) = val;
end 
end 
end 
i = i + 1;
end 


if rem( nargin - i + 1, 2 ) ~= 0
DAStudio.error( 'Simulink:util:NotNameValArguments' );
end 
expectval = 0;
while i <= nargin
arg = varargin{ i };

if ~expectval
if ~ischar( arg )
DAStudio.error( 'Simulink:util:ExpectedStringPropertyName', i );
end 

if ( strcmpi( arg, 'maxrows' ) )
arg = 'MaxDataPoints';
end 
lowArg = lower( arg );
j = strmatch( lowArg, names );
if isempty( j )
DAStudio.error( 'Simulink:util:UnrecognizedPropertyName', arg );
elseif length( j ) > 1

k = strmatch( lowArg, names, 'exact' );
if length( k ) == 1
j = k;
else 
msg = Names{ j( 1 ) };
for k = j( 2:length( j ) )'
msg = [ msg, ', ', Names{ k } ];%#ok<AGROW>
end 
DAStudio.error( 'Simulink:util:AmbiguousPropertyName', arg, msg );
end 
end 
expectval = 1;

else 
options.( Names{ j } ) = arg;
expectval = 0;

end 
i = i + 1;
end 

if expectval
DAStudio.error( 'Simulink:util:ExpectedAValue', arg );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpN8GKfM.p.
% Please follow local copyright laws when handling this file.

