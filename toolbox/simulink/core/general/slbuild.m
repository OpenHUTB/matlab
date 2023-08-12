function varargout = slbuild( mdl, varargin )




































































































narginchk( 1, inf );

if ~iscell( mdl )
mdl = { mdl };
end 


mdl = cellfun( @convertStringsToChars, mdl, 'UniformOutput', false );

nargs = nargin;
if nargs > 1
[ varargin{ : } ] = convertStringsToChars( varargin{ : } );
end 


for i = 1:numel( mdl )
if ~coder.internal.validateModelParam( mdl{ i }, true )
DAStudio.error( 'RTW:buildProcess:ArgIsNotModelOrSubsystem', 'slbuild' );
end 
end 

outputs = cell( numel( mdl ), 1 );


parBuildContext = coder.parallel.ParallelBuildContext;
cleanup = onCleanup( @(  )delete( parBuildContext ) );

for i = 1:numel( mdl )
outputs{ i } = locSlbuild( mdl{ i }, varargin{ : }, 'ParallelBuildContext', parBuildContext );
end 



if nargout > 0
if numel( outputs ) == 1
varargout{ 1 } = outputs{ 1 };
else 
varargout{ 1 } = outputs;
end 
end 
end 

function subSysBlockHdl = locSlbuild( mdl, varargin )

args = locValidateArgs( varargin{ : } );

isSubsystemBuild = slroot(  ).isValidSlObject( mdl ) &&  ...
strcmp( get_param( mdl, 'Type' ), 'block' ) &&  ...
strcmp( get_param( mdl, 'BlockType' ), 'SubSystem' );

if isSubsystemBuild
subsys = mdl;
buildSubsystemArgs = [ { subsys }, varargin ];
if args.OkayToPushNags


subSysBlockHdl = slInternal( 'MV_ui_subsys_build_cmd_wrapper',  ...
get_param( bdroot( subsys ), 'Name' ),  ...
'coder.build.internal.buildSubsystem',  ...
buildSubsystemArgs{ : } );
else 
subSysBlockHdl = coder.build.internal.buildSubsystem( buildSubsystemArgs{ : } );
end 
else 
try 
sl( 'slbuild_private', mdl, varargin{ : } );
catch ex



if args.OkayToPushNags && ~args.CalledFromInsideSimulink
coder.internal.createAndPushNag( ex );
end 
rethrow( ex );
end 
subSysBlockHdl = [  ];
end 

end 

function args = locValidateArgs( varargin )

persistent p;
if isempty( p )
p = inputParser;
p.addOptional( 'BuildSpec', 'StandaloneCoderTarget', @coder.build.internal.isBuildSpec );
p.addParameter( 'UpdateThisModelReferenceTarget', '', @ischar );
p.addParameter( 'GenerateCodeOnly', [  ], @isCoercibleToLogical );
p.addParameter( 'StoredChecksum', [  ] );
p.addParameter( 'ForceTopModelBuild', false, @isCoercibleToLogical );
p.addParameter( 'OpenBuildStatusAutomatically', false, @isCoercibleToLogical );
p.addParameter( 'ConfigSet', [  ] );
p.addParameter( 'UpdateTopModelReferenceTarget', false, @isCoercibleToLogical );
p.addParameter( 'OnlyCheckConfigsetMismatch', false, @isCoercibleToLogical );
p.addParameter( 'OkayToPushNags', false, @isCoercibleToLogical );
p.addParameter( 'CalledFromInsideSimulink', false, @isCoercibleToLogical );
p.addParameter( 'ObfuscateCode', false, @isCoercibleToLogical );
p.addParameter( 'SubSystemBuild', false, @isCoercibleToLogical );
p.addParameter( 'IncludeModelReferenceSimulationTargets', false, @isCoercibleToLogical );
p.addParameter( 'Mode', 'Normal', @( x )any( strcmpi( x, { 'Normal', 'ExportFunctionCalls' } ) ) );
p.addParameter( 'ExportFunctionFileName', '', @ischar );
p.addParameter( 'ExportFunctionInitializeFunctionName', '', @iscvar );
p.addParameter( 'CheckSimulationResults', false, @isCoercibleToLogical );
p.addParameter( 'ReplaceSubsystem', false, @isCoercibleToLogical );
p.addParameter( 'ExpandVirtualBusPorts', [  ], @isCoercibleToLogical );
p.addParameter( 'ParallelBuildContext', [  ], @( x )isa( x, 'coder.parallel.ParallelBuildContext' ) )
end 
p.parse( varargin{ : } );
args = p.Results;
end 

function tf = isCoercibleToLogical( x )
tf = isscalar( x ) && ( islogical( x ) || isnumeric( x ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBacyUK.p.
% Please follow local copyright laws when handling this file.

