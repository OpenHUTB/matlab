


classdef ( Sealed )ReportContext < matlab.mixin.Copyable

properties ( Constant, Access = private )
HAS_SIMULINK = exist( 'bdroot', 'builtin' ) ~= 0
end 

properties 
Report struct{ mustBeScalarOrEmpty( Report ) }
ClientType char{ mustBeTextScalar( ClientType ) }
BuildDirectory char{ mustBeTextScalar( BuildDirectory ) }
ReportDirectory char{ mustBeTextScalar( ReportDirectory ) }
Config{ mustBeScalarOrEmpty( Config ) }
CompilerName char{ mustBeTextScalar( CompilerName ) } = 'Unknown'
SimulinkSID char{ mustBeTextScalar( SimulinkSID ) }
ClientArgs cell
CompilationContext coder.internal.CompilationContext{ mustBeScalarOrEmpty( CompilationContext ) }
FeatureControl{ mustBeScalarOrEmpty( FeatureControl ) }
CodeReplacementLibrary
DesignInspectorResults coder.report.RegisterCGIRInspectorResults{ mustBeScalarOrEmpty( DesignInspectorResults ) }
IsCpp( 1, 1 )logical
IsEmlc( 1, 1 )logical
IsErt( 1, 1 )logical
IsHdl( 1, 1 )logical
IsGui( 1, 1 )logical
IsStateflow( 1, 1 )logical
end 

properties ( Dependent, SetAccess = private )
IsEmbeddedCoder
CoderProject
SimulinkModelName
end 

methods 
function this = ReportContext( report, opts )
R36
report struct{ mustBeScalarOrEmpty( report ) } = struct.empty
opts.CompilationContext coder.internal.CompilationContext{ mustBeScalarOrEmpty( opts.CompilationContext ) } =  ...
coder.internal.CompilationContext.empty(  )
end 

this.Report = report;
this.useDefaultFolders(  );
if ~isempty( opts.CompilationContext )
this.useCompilationContext(  );
end 
end 

function this = useDefaultFolders( this )




buildDir = '';
if this.IsEmbeddedCoder && isfield( this.Report.summary, 'buildInfo' )
buildDir = this.Report.summary.buildInfo.getLocalBuildDir;
end 
if isempty( buildDir ) && isfield( this.Report.summary, 'directory' )
buildDir = this.Report.summary.directory;
end 
this.BuildDirectory = buildDir;
if ~isempty( buildDir )
this.ReportDirectory = fullfile( buildDir, 'html' );
else 
this.ReportDirectory = tempname(  );
end 
end 

function this = useCompilationContext( this, compilationContext )
R36
this( 1, 1 )
compilationContext( 1, 1 )coder.internal.CompilationContext
end 

this.CompilationContext = compilationContext;
this.Config = compilationContext.ConfigInfo;
this.ClientType = compilationContext.ClientType;
this.FeatureControl = compilationContext.getFeatureControl(  );
end 

function useDesignInspectorResults( this, results )
R36
this( 1, 1 )
results{ mustBeScalarOrEmpty( results ) } = safeCopyDesignInspectorResultsSingleton(  )
end 

if isempty( results )
results = coder.report.RegisterCGIRInspectorResults.empty(  );
end 
this.DesignInspectorResults = results;
end 

function form = toReportSerializeableForm( this )



form = codergui.evalprivate( 'filterObjectForJson', this, 'Blacklist',  ...
{ 'Report', 'CompilationContext', 'CodeReplacementLibrary', 'Config',  ...
'CoderProject', 'DesignInspectorResults' } );
form.CoderProject = codergui.evalprivate( 'flattenCoderProjectForJson', this.CoderProject );
end 

function set.Report( this, report )
if ~isstruct( report ) || ~all( isfield( report, { 'summary', 'inference' } ) )
error( message( 'Coder:reportGen:noSummaryInfo' ) );
end 
this.Report = report;
end 

function set.ClientType( this, clientType )
validateattributes( clientType, { 'char' }, { 'scalartext' } );
this.ClientType = lower( clientType );
end 

function set.ClientArgs( this, value )
validateattributes( value, { 'cell' }, {  } );
this.ClientArgs = value;
end 

function set.BuildDirectory( this, value )
validateattributes( value, { 'char' }, { 'scalartext' } );
this.BuildDirectory = value;
end 

function set.ReportDirectory( this, value )
validateattributes( value, { 'char' }, { 'scalartext' } );
this.ReportDirectory = value;
end 

function set.Config( this, value )
assert( isobject( value ) || isstruct( value ) || isempty( value ) );
this.Config = value;
end 

function set.CodeReplacementLibrary( this, value )
this.CodeReplacementLibrary = value;
end 

function set.CompilerName( this, value )
validateattributes( value, { 'char' }, { 'scalartext' } );
this.CompilerName = value;
end 

function set.SimulinkSID( this, value )
validateattributes( value, { 'char' }, { 'scalartext' } );
this.SimulinkSID = value;
end 

function set.IsEmbeddedCoder( this, value )
validateattributes( value, { 'logical' }, { 'scalar' } );
this.IsEmbeddedCoder = value;
end 

function set.IsCpp( this, value )
validateattributes( value, { 'logical' }, { 'scalar' } );
this.IsCpp = value;
end 

function set.IsEmlc( this, value )
validateattributes( value, { 'logical' }, { 'scalar' } );
this.IsEmlc = value;
end 

function set.IsHdl( this, value )
validateattributes( value, { 'logical' }, { 'scalar' } );
this.IsHdl = value;
end 

function set.CompilationContext( this, value )
assert( isa( value, 'coder.internal.CompilationContext' ) || isempty( value ) );
this.CompilationContext = value;
end 

function ecoder = get.IsEmbeddedCoder( this )
ecoder = isa( this.Config, 'coder.EmbeddedCodeConfig' ) || this.IsErt;
end 

function model = get.SimulinkModelName( this )
if this.HAS_SIMULINK && ~isempty( this.SimulinkSID )
model = bdroot( this.SimulinkSID );
else 
model = '';
end 
end 

function set.IsGui( this, value )
validateattributes( value, { 'logical' }, { 'scalar' } );
this.IsGui = value;
end 

function gui = get.IsGui( this )
gui = this.IsGui || this.determineIfGuiBased( this.CompilationContext );
end 

function coderProject = get.CoderProject( this )
if ~isempty( this.CompilationContext )
coderProject = this.CompilationContext.Project;
else 
coderProject = [  ];
end 
end 

function ert = get.IsErt( this )
ert = false;
if this.IsErt
ert = this.IsErt;
elseif ~isempty( this.SimulinkModelName )
configSet = getActiveConfigSet( this.SimulinkModelName );
if ~isempty( configSet ) && strcmp( get_param( configSet, 'IsERTTarget' ), 'on' )
ert = true;
end 
end 
end 
end 

methods ( Static, Access = private )
function gui = determineIfGuiBased( cc )
if ~usejava( 'jvm' ) || isempty( cc ) || isempty( cc.JavaConfig )
gui = false;
else 
openProject = com.mathworks.toolbox.coder.app.CoderRegistry.getInstance(  ).getOpenProject(  );%#ok<JAPIMATHWORKS> 
gui = ~isempty( openProject ) && openProject.getConfiguration(  ).equals( cc.JavaConfig );
end 
end 
end 

end 


function copy = safeCopyDesignInspectorResultsSingleton(  )
instance = coder.report.RegisterCGIRInspectorResults.getInstance(  );
if ~isempty( instance )
copy = instance.copy(  );
else 
copy = [  ];
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpbhy2u1.p.
% Please follow local copyright laws when handling this file.

