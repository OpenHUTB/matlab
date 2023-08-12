classdef RptFile < slreportgen.report.Reporter &  ...
mlreportgen.report.internal.RptFileBase


















































































































































properties 








Model{ mlreportgen.report.validators.mustBeString( Model ) } = [  ];









System{ mustBeValidSystem( System ) } = [  ];

































































Block{ mustBeValidBlock( Block ) } = [  ];

end 

methods 

function this = RptFile( varargin )
if ( nargin == 1 )
varargin = [ { "SetupFile" }, varargin ];
end 

this = this@slreportgen.report.Reporter( varargin{ : } );


if isempty( this.TemplateName )
this.TemplateName = "RptFile";
end 
end 

function set.Model( this, value )
if ischar( value )
this.Model = string( value );
else 
this.Model = value;
end 
end 

function set.System( this, value )
if ischar( value )
this.System = string( value );
else 
this.System = value;
end 
end 

function set.Block( this, value )
if ischar( value )
this.Block = string( value );
else 
this.Block = value;
end 
end 

function impl = getImpl( this, rpt )
R36
this( 1, 1 )
rpt( 1, 1 ){ validateReport( this, rpt ) }
end 


loadSetupFile( this );


this.CReport.CompileModel = rpt.CompileModelBeforeReporting;


updateContext( this );



impl = getImpl@slreportgen.report.Reporter( this, rpt );
end 

end 

methods ( Hidden )
function templatePath = getDefaultTemplatePath( this, rpt )%#ok<INUSL>


reporterPath = mlreportgen.report.RptFile.getClassFolder(  );
templatePath =  ...
mlreportgen.report.ReportForm.getFormTemplatePath(  ...
reporterPath, rpt.Type );
end 
end 

methods ( Access = protected, Hidden )

result = openImpl( reporter, impl, varargin )
end 

methods ( Access = { ?mlreportgen.report.ReportForm, ?slreportgen.report.RptFile } )
function content = getContent( this, rpt )





content = getHoleContent( this, rpt );
end 
end 

methods ( Access = private )
function updateContext( this )




mdl_loop = this.CReport.find( '-isa', 'rptgen_sl.csl_mdl_loop' );
sys_loop = this.CReport.find( '-isa', 'rptgen_sl.csl_sys_loop' );
blk_loop = this.CReport.find( '-isa', 'rptgen_sl.csl_blk_loop' );


if ~isempty( this.Model )
if isempty( mdl_loop )
error( message( "slreportgen:report:error:missingComponent", "Model Loop",  ...
"Model" ) );
elseif length( mdl_loop ) ~= 1
error( message( "slreportgen:report:error:multipleComponents", "Model Loop",  ...
"Model" ) );
else 
mdl_loop.LoopList.MdlName = this.Model;
end 
end 


if ~isempty( this.System )
if isempty( sys_loop )
error( message( "slreportgen:report:error:missingComponent",  ...
"System Loop", "System" ) );
elseif length( sys_loop ) ~= 1
error( message( "slreportgen:report:error:multipleComponents",  ...
"System Loop", "System" ) );
else 
if ~isempty( mdl_loop )
mdl_loop.LoopList.SysLoopType = "current";
end 
sys_loop.LoopType = "list";

if isa( this.System, "slreportgen.finder.DiagramResult" )

sys_loop.ObjectList = { this.System.Path };
else 
sys_loop.ObjectList = { this.System };
end 
end 
end 


if ~isempty( this.Block )
if isempty( blk_loop )
error( message( "slreportgen:report:error:missingComponent",  ...
"Block Loop", "Block" ) );
elseif length( blk_loop ) ~= 1
error( message( "slreportgen:report:error:multipleComponents",  ...
"Block Loop", "Block" ) );
else 
blk_loop.LoopType = "list";

if isa( this.Block, "slreportgen.finder.BlockResult" )

blk_loop.ObjectList = { this.Block.BlockPath };
elseif isa( this.Block, "slreportgen.finder.DiagramElementResult" )

blk_loop.ObjectList =  ...
slreportgen.utils.pathJoin(  ...
this.Block.DiagramPath,  ...
this.Block.Name );
else 
blk_loop.ObjectList = { this.Block };
end 
end 
end 
end 
end 

methods ( Static )

function path = getClassFolder(  )


[ path ] = fileparts( mfilename( 'fullpath' ) );
end 

function template = createTemplate( templatePath, type )








sourcePath = mlreportgen.report.RptFile.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, sourcePath );
end 

function classfile = customizeReporter( toClasspath )









classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
"slreportgen.report.RptFile", "mlreportgen.report.RptFile" );
end 

end 

end 


function mustBeValidSystem( system )
if ~( ( isnumeric( system ) && isempty( system ) ) ||  ...
( ischar( system ) && ~isempty( system ) ) ||  ...
( isstring( system ) && ( numel( system ) == 1 ) && ( system ~= "" ) ) ||  ...
isa( system, "slreportgen.finder.DiagramResult" ) )
error( message( "slreportgen:report:error:mustBeValidSystem",  ...
"slreportgen.finder.DiagramResult" ) );
end 
end 


function mustBeValidBlock( block )
if ~( ( isnumeric( block ) && isempty( block ) ) ||  ...
( ischar( block ) && ~isempty( block ) ) ||  ...
( isstring( block ) && ( numel( block ) == 1 ) && ( block ~= "" ) ) ||  ...
isa( block, "slreportgen.finder.BlockResult" ) ||  ...
isa( block, "slreportgen.finder.DiagramElementResult" ) )
error( message( "slreportgen:report:error:mustBeValidBlock",  ...
"slreportgen.finder.BlockResult",  ...
"slreportgen.finder.DiagramElementResult" ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpNVW3le.p.
% Please follow local copyright laws when handling this file.

